#!/bin/bash

#--Declare WANIP variable

OS=$(uname)

wanip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
	
	echo "Public IP:"
	echo "$wanip"
	echo ""
		
#--List all NAMESERVERS under resolv.conf

dns=$(printf "%s" "\\n" && cat /etc/resolv.conf | grep 'nameserver' | awk '{printf "%s\\n", $2}' | cut -d ':' -f1)

#--Define OS, and Declare FOR list of active interfaces
if [ "$OS" == "Linux" ] ;then
	
	for each in $(ls -1 /sys/class/net) ;do

		lanip=$(ifconfig $each | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
                gateway=$(ip route show dev $each | grep default | cut -d' ' -f4)
                mac=$(ifconfig $each | grep HWaddr | awk '{print $5}' | cut -c 1-17) 


               if [ ! -z "${gateway// }" ] ;then

                       	echo  "$each"
                        echo  "IP: $lanip"
                        echo  "Default Gateway: $gateway"
                        echo  "MAC: $mac"
                        echo ""
	
 
		fi
	done

elif [ "$OS" == "Darwin" ] ;then
	
	for each in $(networksetup -listallhardwareports | grep "Device" | cut -d' ' -f2) ;do
 
		result=$(ifconfig $each | grep -v inet6 | grep inet | cut -d' ' -f2)
		gateway=$(netstat -nr -f inet | grep default | grep $each | awk '{print$2}')
		mac=$(ifconfig $each | grep ether | awk '{print $2}'| cut -c 1-17)
		state=$(ifconfig $each | grep status | awk '{print$2}')
	
		if [ "$state" == "active" ] ;then
        
  			echo "$each"
			echo "IP: $lanip"
			echo "Default Gateway: $gateway"
			echo "MAC: $mac"
			echo ""

		fi
	done	

fi

	echo -e "Name Servers": $dns | awk '!a[$0]++'

