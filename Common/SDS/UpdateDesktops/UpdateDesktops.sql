/*
Patch No: 6.0191
Author: Luke Smith
Date: 13-December-2016

Description: Updates desktops to new version
*/

update icwsys.WindowParameter set Value = 'C:\ProgramData\SDS\Version6\Applications\Pharmacy Client\PC_{BuildNumber}' where Description = 'ApplicationPath'