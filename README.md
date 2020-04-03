# UpdateSGAWS

Shell Script to update a security group with name XXX to allow all traffic for current Public IP Address.

This script file reads a credential file into .aws folder for update all profiles in use for current user.

Pre-requisites is this file have a 755 permission, the security group existing in profile and user key in credential file with permission to alter security group.

This script accept a parameter for use more security group names.

For execute this script use "/path/updateSG.sh", this mode use security group name XXX. 
Foe execute this scritpt using paramenter "/path/updateSG.sh securityGroupName", this mode use security group name securityGroupName.
