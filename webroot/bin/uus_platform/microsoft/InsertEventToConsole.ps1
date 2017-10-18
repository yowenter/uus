Param(
  [Parameter(Mandatory=$true,HelpMessage='class name')][string]$classname,
  [Parameter(Mandatory=$true,HelpMessage='targetfqdn')][string]$targetfqdn,
  [Parameter(Mandatory=$true,HelpMessage='targetfqdn')][string]$targetIMMClass,
  [Parameter(Mandatory=$true,HelpMessage='targetuuid')][string]$targetuuid,
  [Parameter(Mandatory=$true,HelpMessage='eventflag')][string]$eventflag,
  [Parameter(Mandatory=$true,HelpMessage='messageID')][string]$severity,
  [Parameter(Mandatory=$true,HelpMessage='message')][string]$message
)
$PSScriptRoot = (Split-Path $MyInvocation.MyCommand.Path -Parent)
$PSScriptRoot = "$PSScriptRoot\lib"
echo $PSScriptRoot

$Assem = (
    "$PSScriptRoot\Microsoft.EnterpriseManagement.Core.dll",
    "$PSScriptRoot\Microsoft.EnterpriseManagement.OperationsManager.dll",
    "$PSScriptRoot\Microsoft.EnterpriseManagement.Runtime.dll",
    "System.Xml, Version=2.0.0.0, Culture=neutral,PublicKeyToken=b77a5c561934e089",
    "System.Core"
) 

$Source = @" 

using Microsoft.EnterpriseManagement;
using Microsoft.EnterpriseManagement.Common;
using Microsoft.EnterpriseManagement.Configuration;
using Microsoft.EnterpriseManagement.Monitoring;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Security;
using System.Text;
using System.Threading.Tasks;

namespace SCOMSDKClient
{
    public class SDKClient
    {
        public static void RaiseEvent(string classname, string targetfqdn, string targetIMMClass, string targetuuids, string eventflag, string severity, string message)
        {
            try
            {
                ManagementGroup mg = ConnectSCOM();
                //report event into WinComputer record
                
                // eventflag contains event id and RAS event flag. It looks like "816f011b0c01ffffx", here 'x' is 0/1 to specify if the event is RAS event or not.
                string eventnumber = eventflag.PadLeft(17, '0');
                eventnumber = eventnumber.Substring(0, 16);
                eventnumber = eventnumber.ToUpper();                
                string msgShown = message.Replace("EVNID", eventnumber);                
                string[] tgtArr = targetuuids.Split('>');
                string targetuuid = tgtArr[0];
                string targetip = tgtArr[1];
                int eventID = ReCEventID(eventnumber);
                                
                //convert severity
                int eventSeverity = 0;
                if(severity == "2"){
                    // information
                    eventSeverity = 4;
                }else if(severity == "3"){
                    // warning
                    eventSeverity = 2;
                }else{
                    // error
                    eventSeverity = 1;
                }
                //report event into Windows record
                CustomMonitoringEvent customEvent;
                customEvent = new CustomMonitoringEvent(targetip, eventID);
                customEvent.LevelId = eventSeverity;
                customEvent.Message = new CustomMonitoringEventMessage(msgShown);
                
                //When IMM server is discovered as Windows Computer by user, report event into corresponding Windows Computer record
                List<MonitoringObject> targets = GetMonitoringClassInstance(mg,classname);
                for(int i=0;i<targets.Count();i++){
                    Console.WriteLine("find fqdn: "+targets[i].FullName);
                    if(IsSameFQDN(targets[i].FullName, targetfqdn)){
                        InsertCustomEvent(targets[i],customEvent);
                        Console.WriteLine("New RAS Event with EventFlag == " + eventflag + ", insert a new event into SCOM WinComputer with levelid:" + eventSeverity + ", EventId:" + eventID);
                    }
                }
                                
                //report event into IMM record
                targets = GetMonitoringClassInstance(mg,targetIMMClass);
                Console.WriteLine("find imm targets number: "+ targets.Count());
                foreach(MonitoringObject target in targets){
                    foreach(ManagementPackProperty property in target.GetProperties()){
                        //Console.WriteLine("property Name: "+ property.Name.ToString());
                        if(property.Name.Equals("UUID")){
                            Console.WriteLine("find imm uuid: "+ target[property].Value.ToString());
                            if(IsSameFQDN(target[property].Value.ToString(),targetuuid)){
                                InsertCustomEvent(target,customEvent);
                                Console.WriteLine("New RAS Event with EventFlag == " + eventflag + ", insert a new event into SCOM IMM with levelid:" + eventSeverity + ", EventId:" + eventID);
                            }
                        }
                    }
                }
            }catch (Exception sde)
            {
                Console.WriteLine("\nOperation failed. " + sde.Message);
            }
        }

        // check if the fqdn before ":" is the same. fqdn in SCOM may contain additional information after ":"
        public static bool IsSameFQDN(string s1, string s2)
        {
            if (s1.Contains(':'))
            {
                string[] spl = s1.Split(':');
                s1 = spl[spl.Length - 1];
                Console.WriteLine("\n" + s1);
            }else{
                Console.WriteLine("\n" + s1);
            }
            s1.Trim();
            if (s2.Contains(':'))
            {
                string[] spl = s2.Split(':');
                s2 = spl[spl.Length - 1];
                Console.WriteLine("\n" + s2);
            }else{
                Console.WriteLine("\n" + s2);
            }
            s2.Trim();
            return s1.Equals(s2);
        }
        
        /* restructure event number
         * eventnumber contains event id and RAS event flag. It looks like "816f011b0c01ffffx", here 'x' is 0/1 to specify if the event is RAS event or not. 
         * IMM event id in eventflag is a 64b hex string. 
         * As SCOM SDK can only insert a event number which is not larger than 0x7fffffff, we need to restructure original IMM event id first. 
         * For example, event id string is d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15. Restructure rule as below. 
         * 1. b30b29 identify d0d1, stand for 40,80,81, or 00 for others.
         * 2. b28..26 identify d2d3, stand for 01,03,04,07,08,0b,6f, or 00 for others.
         * 3. b25..22 = d5, identify d4d5, stand for 00..0f.
         * 4. b21..15 = d6d7 + d8d9, identify d6d7d8d9, the summary is no larger than 128.
         * 5. b14..12 = d10(if d10<7) or 7-(d10-8)(if d10>7)  identify d10, stand for 0 or 8.
         * 6. b11..8 = d11, identify d11, stand for 0..f.         
         * 7. b7..b4 = d13 + d14(if d14 = 0x0f, reset d14 = 0), identify d12d1314.
         * 8. b3..0 = d15, identify d15.
         */
        public static int ReCEventID(string eventnumber)
        {
            int eventid = 0;

            // b30b29
            string d0d1 = eventnumber.Substring(0, 2);
            if (d0d1.Equals("40"))
            {
                eventid = 1;
            }
            else if (d0d1.Equals("80"))
            {
                eventid = 2;
            }
            else if (d0d1.Equals("81"))
            {
                eventid = 3;
            }

            // b28..26
            eventid <<= 3;
            string d2d3 = eventnumber.Substring(2, 2);
            string[] Vd2d3 = new string[8] { "00", "01", "03", "04", "07", "08", "0b", "6F"};
            int idx = 0;
            for (idx = 0; idx < 8; idx++)
            {
                if (d2d3.Equals(Vd2d3[idx]))
                    break;
            }
            if (idx >= 8)
            {
                idx = 0;
            }
            eventid += idx;

            // b25..22
            eventid <<= 4;
            eventid += Convert.ToInt32(eventnumber.Substring(5, 1), 16);

            // b21..15
            eventid <<= 7;
            eventid += Convert.ToInt32(eventnumber.Substring(6, 2), 16)
                + Convert.ToInt32(eventnumber.Substring(8, 2), 16);

            // b14..12
            eventid <<= 3;
            int d10 = Convert.ToInt32(eventnumber.Substring(10, 1), 16);
            if(d10 < 8)
            {
                eventid += d10;
            }
            else
            {                
                eventid += 15 - d10;                
            }

            // b11..8
            eventid <<= 4;
            eventid += Convert.ToInt32(eventnumber.Substring(11, 1), 16);

            // b7..4
            eventid <<= 4;
            int d13 = Convert.ToInt32(eventnumber.Substring(13, 1), 16);
            int d14 = Convert.ToInt32(eventnumber.Substring(14, 1), 16);
            if(d14 == 0xf)
            {
                d14 = 0;
            } 
            eventid += d13 + d14;

            // b3..0
            eventid <<= 4;
            eventid += Convert.ToInt32(eventnumber.Substring(15, 1), 16);

            return eventid;   
        }

        public static ManagementGroup ConnectSCOM()
        {
            try
            {
                ManagementGroupConnectionSettings mgSettings =
                    new ManagementGroupConnectionSettings("localhost");

                ManagementGroup mg = ManagementGroup.Connect(mgSettings);

                if (mg.IsConnected)
                    Console.WriteLine("Connection succeeded.");     
                else
                    throw new InvalidOperationException("Not connected to an SDK Service.");

                return mg;
            }
            catch (ServerDisconnectedException sde)
            {
                Console.WriteLine("\nConnection failed. " + sde.Message);
                if (sde.InnerException != null)
                    Console.WriteLine(sde.InnerException.Message);

                // Call custom method to prompt the user for credentials if needed.
                return null;
            }
            #region this will try to restart service
            //catch (ServiceNotRunningException snr)
            //{
            //    Console.WriteLine(snr.Message);

            //    // Make one attempt to start the service.
            //    System.ServiceProcess.ServiceController sc = new
            //        ServiceController("localhost", serverName);

            //    Console.WriteLine("Attempting to start the SDK Service on " + serverName + ".");
            //    sc.Start();

            //    // Wait 20 seconds for it to enter the Running state.
            //    sc.WaitForStatus(ServiceControllerStatus.Running, new TimeSpan(0, 0, 20));

            //    if (sc.Status == ServiceControllerStatus.Running)
            //    {
            //        ManagementGroupConnectionSettings mgSettings =
            //        new ManagementGroupConnectionSettings(serverName);
            //        mgSettings.UserName = userName;
            //        mgSettings.Domain = domain;
            //        mgSettings.Password = password;

            //        ManagementGroup mg = ManagementGroup.Connect(mgSettings);
            //        if (mg.IsConnected)
            //            Console.WriteLine("Connection succeeded.");
            //        else
            //            throw new InvalidOperationException("Not connected to an SDK Service.");
            //    }
            //    else
            //    {
            //        throw new InvalidOperationException("Unable to restart and connect to the SDK Service.");
            //    }
            //} 
            #endregion
        }


        public static List<MonitoringObject> GetMonitoringClassInstance(ManagementGroup mg,string className)
        {

            ManagementPackClassCriteria classCriteria =
                new ManagementPackClassCriteria(string.Format("Name = '{0}'",className));

            Console.WriteLine("Querying for data...");
            // There should only be one item in the monitoringClasses collection.
            IList<ManagementPackClass> monitoringClasses =
                mg.EntityTypes.GetClasses(classCriteria);

            // Get all instances of computers running Windows Server 2003 in the management group.
            List<MonitoringObject> targets = new List<MonitoringObject>();
            IObjectReader<MonitoringObject> reader = mg.EntityObjects.GetObjectReader<MonitoringObject>(monitoringClasses[0], ObjectQueryOptions.Default);
            targets.AddRange(reader);

            return targets;

        }


        public static void InsertCustomEvent(MonitoringObject target,CustomMonitoringEvent customEvent)
        {
            target.InsertCustomMonitoringEvent(customEvent);
            
        }

        public void ExecMPTask(ManagementGroup mg)
        {
            string query = "Name = 'IBM.HardwareMgmtPack.IMM2.ManagementModule.SLPDiscovery.Task'";
            ManagementPackTaskCriteria taskCriteria = new ManagementPackTaskCriteria(query);
            IList<ManagementPackTask> tasks = mg.TaskConfiguration.GetTasks(taskCriteria);
            ManagementPackTask task = null;
            if (tasks.Count == 1)
                task = tasks[0];
            else
                throw new InvalidOperationException("Error! Expected one task with: " + query);


            query = "Name = 'IBM.HardwareMgmtPack.IMM2.ManagementModule.DummyBase'";
            ManagementPackClassCriteria criteria = new ManagementPackClassCriteria(query);
            IList<ManagementPackClass> classes = mg.EntityTypes.GetClasses(criteria);
            if (classes.Count != 1)
                throw new InvalidOperationException(
                    "Error! Expected one class with: " + query);

            // Create a MonitoringObject list containing all agents (the 
            // targets of the task).
            List<MonitoringObject> targets = new List<MonitoringObject>();
            IObjectReader<MonitoringObject> reader = mg.EntityObjects.GetObjectReader<MonitoringObject>(classes[0], ObjectQueryOptions.Default);
            targets.AddRange(reader);
            //if (targets.Count < 1)
            //    throw new InvalidOperationException(
            //        "Error! Expected at least one target.");




            Microsoft.EnterpriseManagement.Runtime.TaskConfiguration taskConfiguration = new Microsoft.EnterpriseManagement.Runtime.TaskConfiguration();
            ManagementPackModuleTypeCriteria moduleCriteria = new ManagementPackModuleTypeCriteria("Name = 'IBM.HardwareMgmtPack.IMM2.ManagementModule.Discover.ProbeAction'");
            ManagementPackModuleType writeAction = mg.Monitoring.GetModuleTypes(moduleCriteria)[0];
            foreach (ManagementPackOverrideableParameter overrideParam in writeAction.OverrideableParameterCollection)
            {
                Console.WriteLine(overrideParam.Name);
            }

            object state = mg;
            mg.TaskRuntime.BeginExecuteTask(targets, task, taskConfiguration, (result) =>
            {
                IList<Microsoft.EnterpriseManagement.Runtime.TaskResult> results = mg.TaskRuntime.EndExecuteTask(result);
                if (results.Count == 0)
                    throw new InvalidOperationException("Error! Failed to return any results.");


            }, state);

        }

    }
}


"@ 

Add-Type -ReferencedAssemblies $Assem -TypeDefinition $Source -Language CSharp  

[SCOMSDKClient.SDKClient]::RaiseEvent($classname,$targetfqdn,$targetIMMClass,$targetuuid,$eventflag,$severity,$message)
