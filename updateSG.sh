#!/bin/bash
  
clients=$( egrep -i "\[(\w+)\]" ~/.aws/credentials | tr '\n' '\0' | sed 's/\[//g' )

if [ ! -f ./oldip ]; then
    $( echo "" > ./oldip )
fi

oldip=$( egrep -i "(?:[0-9]{1,3}\.){3}[0-9]{1,3}" ./oldip )

echo "$oldip"

novoip=$( curl -L http://evolvest.com.br/meuip.php )

IFS=$']' read -rd '' -a array <<< "$clients"

for client in "${array[@]}"
do

        client=$( echo "${client}" | sed -e 's/^[[:space:]]*//' )
        if [ "$client" != '' ];
        then
                if [ "$oldip" != '' ];
                then
                        echo "Cliente - $client"

                        for CidrIp in  $( aws ec2 describe-security-groups --group-name Evolve --profile "$client" --output json | jq -r '.SecurityGroups[0].IpPermissions[0].IpRanges[]|"\(.CidrIp)"' )
                        do
                                if [ "$CidrIp" == "$oldip/32" ];
                                then
                                        echo "Revogando o IP - $CidrIp"
                                        aws ec2 revoke-security-group-ingress --group-name Evolve --protocol all --port -1 --cidr "$CidrIp" --profile "$client"
                                        echo "Liberando o IP $novoip"
                                        aws ec2 authorize-security-group-ingress --group-name Evolve --protocol all --port -1 --cidr "$novoip/32" --profile "$client"
                                else
                                        echo "Ignorar o IP - $CidrIp"
                                fi
                        done
                else
                        echo "Cliente - $client"
                        echo "Sem IP Anterior"
                        echo "Liberando o IP $novoip"
                        aws ec2 authorize-security-group-ingress --group-name Evolve --protocol all --port -1 --cidr "$novoip/32" --profile "$client"
                fi
                echo "Salvando novo IP - $novoip"
                $( echo "$novoip" > ./oldip )
        fi
done
