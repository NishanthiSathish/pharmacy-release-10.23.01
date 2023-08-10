/**
Copyright (c) 2012, Benjamin Dumke-von der Ehe

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

/*

Orignal Author Article: http://balpha.de/2012/03/javascript-concurrency-and-locking-the-html5-localstorage/

Orignal Download Source: https://bitbucket.org/balpha/lockablestorage/src/96b7ddb1962334cde9c647663d0053ab640ec5a1/lockablestorage.js?at=default

Modification by Ascribe
=======================
Now can create an instance of the Mutex.
Can now use once instance of mutex to acquire locks by differnt methods on the same page,
Can now create a named mutex, where multiple mutex instances can be used to acquire the same lock as long as the instances are created in the same window.
Functions are now executed in the order they were queued when calling the api.
*/
(function (declarationWindow) {

    var mutex = function (mutexName, scriptExecutionWindow) {
        /// <summary>
        /// Returns an instance of the Mutex object which is used to acquire a lock.
        /// A unnamed mutex can only be used to acquire a lock compared to a named mutex where any mutex instance with that name can acquire a lock.
        ///
        /// Following methods are used try to execute the callback asynchronously only once a lock is acquired. The method doesn't keep on trying to acquire the lock and execute the callback.
        /// GetMutex().lock(callback)
        /// GetMutex().lock(callback, maxDuration)
        ///
        /// Following methods are used to execute the callback synchronously if a lock is acquired. The method doesn't keep on trying to acquire the lock and execute the callback.
        /// GetMutex().trySyncLock(callback)
        /// GetMutex().trySyncLock(callback, maxDuration)
        /// </summary>
        /// <param name="mutexName"  type="string">
        /// Optional. If the mutex name is specified than multiple instance can be used to acquire the lock.
        /// </summary>
        /// <param name="scriptExecutionWindow"  type="Window">
        /// Optional. The window whose setTimeout function should be used to queue execution.
        /// </summary>
        /// <returns type="Mutex" />

        var executionWindow = scriptExecutionWindow || declarationWindow;

        if (mutexName == "") {
            throw "Can't have a blank key";
        }

        this.lock = function (callback, maxDuration) {
            startLockImpl(callback, maxDuration, false);
        };

        this.trySyncLock = function (callback, maxDuration) {
            return startLockImpl(callback, maxDuration, true);
        };

        function startLockImpl(callback, maxDuration, synchronous) {
            var myId = getTransactionId();
            getLocks().queue.push(
            { "myId": myId,
                "callback": callback,
                "maxDuration": maxDuration,
                "synchronous": synchronous
            });
            return lockImpl(mutexName, myId, callback, maxDuration, synchronous);
        }

        var locks =
        {
            queue: []
        };

        var localLocks = locks;

        function getLocks() {

            if (Mutex.prototype.globalLocks == undefined) {
                Mutex.prototype.globalLocks = locks;
            }

            if (mutexName) {
                return Mutex.prototype.globalLocks;
            } else {
                return localLocks;
            }
        }

        function now() {
            return new Date().getTime();
        }

        function someNumber() {
            return Math.random() * 1000000000 | 0;
        }

        function getTransactionId() {
            return now() + ":" + someNumber();
        }

        function getter(lskey) {
            return function () {
                var value = getLocks()[lskey];
                if (!value)
                    return null;

                var splitted = value.split(/\|/);
                if (parseInt(splitted[1]) < now()) {
                    return null;
                }
                return splitted[0];
            }
        }

        function _mutexTransaction(key, myId, callback, synchronous) {
            var xKey = key + "__MUTEX_x",
            yKey = key + "__MUTEX_y",
            getY = getter(yKey);

            function criticalSection() {
                try {
                    return callback();
                } finally {
                    getLocks()[yKey] = undefined;
                }
            }

            getLocks()[xKey] = myId;
            if (getY()) {
                if (!synchronous)
                    executionWindow.setTimeout(function () { _mutexTransaction(key, myId, callback); }, 0);
                return false;
            }
            getLocks()[yKey] = myId + "|" + (now() + 40);

            if (getLocks()[xKey] !== myId) {
                if (!synchronous) {
                    executionWindow.setTimeout(function () {
                        if (getY() !== myId) {
                            executionWindow.setTimeout(function () { _mutexTransaction(key, myId, callback); }, 0);
                        } else {
                            criticalSection();
                        }
                    }, 50)
                }
                return false;
            } else {
                return criticalSection();
            }
        }

        function dequeueTransactionId(myId) {
            for (var itemNum = 0; itemNum < getLocks().queue.length; itemNum++) {
                if (getLocks().queue[itemNum].myId === myId) {
                    getLocks().queue.splice(itemNum, 1);
                    break;
                }
            }
        }

        function lockImpl(key, myId, callback, maxDuration, synchronous) {

            maxDuration = maxDuration || 5000;

            key = key || "";

            var mutexKey = key + "__MUTEX",
            getMutex = getter(mutexKey),
            mutexValue = myId + ":" + someNumber() + "|" + (now() + maxDuration);

            function restart() {
                executionWindow.setTimeout(function () { lockImpl(key, myId, callback, maxDuration); }, 10);
            }

            if (getMutex()) {
                if (!synchronous) {
                    restart();
                } else {
                    dequeueTransactionId(myId);
                }
                return false;
            }

            var aquiredSynchronously = _mutexTransaction(key, myId, function () {
                if (getMutex()) {
                    if (!synchronous)
                        restart();
                    return false;
                }

                if (getLocks().queue[0].myId !== myId) {
                    if (!synchronous) {
                        restart();
                    }

                    return false;
                }

                // Acquire Lock
                getLocks()[mutexKey] = mutexValue;

                mutexAquired();

                return true;

            }, synchronous);

            if (synchronous && !aquiredSynchronously) {
                dequeueTransactionId(myId);
            }

            return synchronous && aquiredSynchronously;

            function mutexAquired() {
                try {
                    callback();
                } finally {
                    _mutexTransaction(key, myId, function () {
                        if (getLocks()[mutexKey] !== mutexValue)
                            throw "key: " + key + " was locked by a different process while I held the lock, which may be possible if the lock timed out";

                        if (getLocks().queue[0].myId !== myId)
                            throw "transaction: " + myId + " was removed from the queue by a different process";

                        getLocks().queue.shift();

                        // Release Lock
                        getLocks()[mutexKey] = undefined;
                    });
                }
            }

        }
    }

    declarationWindow.Mutex = mutex;
})(window);