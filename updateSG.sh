#!/bin/bash
  
clients=$( egrep -i "\[(\w+)\]" ~/.aws/credentials | tr '\n' '\0' | sed 's/\[//g' )

if [ ! -f ./oldip ]; then
    $( echo "" > ./oldip )
fi

sgName="XXX"

if [ ! -z "$1" ]; then 

    sgName=$1
fi

oldip=$( egrep -i "(?:[0-9]{1,3}\.){3}[0-9]{1,3}" ./oldip )

echo "$oldip"

newip=$( curl -L http://meuip.evolvest.com.br/ )

IFS=$']' read -rd '' -a array <<< "$clients"

for client in "${array[@]}"
do

        client=$( echo "${client}" | sed -e 's/^[[:space:]]*//' )
        if [ "$client" != '' ];
        then
                if [ "$oldip" != '' ];
                then
                        echo "Cliente - $client"

                        for CidrIp in  $( aws ec2 describe-security-groups --group-name "$sgName" --profile "$client" --output json | jq -r '.SecurityGroups[0].IpPermissions[0].IpRanges[]|"\(.CidrIp)"' )
                        do
                                if [ "$CidrIp" == "$oldip/32" ];
                                then
                                        echo "Revoking IP - $CidrIp"
                                        aws ec2 revoke-security-group-ingress --group-name "$sgName" --protocol all --port -1 --cidr "$CidrIp" --profile "$client"
                                        echo "Authorizing IP $newip"
                                        aws ec2 authorize-security-group-ingress --group-name "$sgName" --protocol all --port -1 --cidr "$newip/32" --profile "$client"
                                else
                                        echo "Ignorar o IP - $CidrIp"
                                fi
                        done
                else
                        echo "Cliente - $client"
                        echo "No previous IP"
                        echo "Authorizing IP $newip"
                        aws ec2 authorize-security-group-ingress --group-name "$sgName" --protocol all --port -1 --cidr "$newip/32" --profile "$client"
                fi
                echo "Storing new IP - $newip"
                $( echo "$newip" > ./oldip )
        fi
done
