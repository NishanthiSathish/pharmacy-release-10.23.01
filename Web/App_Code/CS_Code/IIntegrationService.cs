using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

// NOTE: If you change the interface name "IIntegrationService" here, you must also update the reference to "IIntegrationService" in Web.config.
[ServiceContract]
public interface IIntegrationService
{
    [OperationContract]
    string AddIntegrationData(string input);
}
