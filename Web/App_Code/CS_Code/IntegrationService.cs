using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

// NOTE: If you change the class name "IntegrationService" here, you must also update the reference to "IntegrationService" in Web.config.
public class IntegrationService : IIntegrationService
{
    public string AddIntegrationData(string input)
    {
        INGRTL10.V1 v = new INGRTL10.V1();
        return v.AddIntegrationData(input);
    }
}
