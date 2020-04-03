# UpdateSGAWS

Shell Script to update a security group with the name XXX to allow all traffic for current Public IP Address.

This script file reads a credential file into .aws folder to update all profiles in use for the current current user.

Pre-requisites are:
- this file has  755 permission
- the security group exists
- the IAM user has permissions to alter security group.
- have stedolan/jq installed
This script accepts one parameter for use with several security group names (one at a time).

To  execute this script use "/path/updateSG.sh securityGroupName".
