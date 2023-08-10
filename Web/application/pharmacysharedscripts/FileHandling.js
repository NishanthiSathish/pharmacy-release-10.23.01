/*

FileHandling.js


Provides helper methods to read files from user computer or network
Currently only uses text files.
Uses Scripting.FileSystemObject
*/

// Read and return the file context
function readFile(filename) 
{
    var fso = new ActiveXObject("Scripting.FileSystemObject");
    if (fso.FileExists(filename)) 
    {
        var file = fso.OpenTextFile(filename, /*read*/1, /*append*/false, 0);
        var content = file.ReadAll();
        file.close();
    }
    else
        alert('File not found\n' + filename);

    return content;
}

// Write the file to disk, will overwrite the existing file if it exsts 
function writeFile(filename, content) 
{
    var fso = new ActiveXObject("Scripting.FileSystemObject");
    var file = fso.CreateTextFile(filename, true, false);
    file.Write(content);
    file.close();
}

// Delete the file from the disk
function deleteFile(filename) 
{
    var fso = new ActiveXObject("Scripting.FileSystemObject");
    if (fso.FileExists(filename))
        fso.DeleteFile(filename);
}

// Returns true if the file exists
function ifFileExists(filename) 
{
    var fso = new ActiveXObject("Scripting.FileSystemObject");
    return fso.FileExists(filename);
}