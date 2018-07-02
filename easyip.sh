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
	
	for int in $(ls -1 /sys/class/net) ;do

		lanip=$(ifconfig $int | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
                gateway=$(ip route show dev $int | awk 'FNR == 1 {print}' | awk '{print$4}')
                mac=$(ifconfig $int | grep HWaddr | awk '{print $5}' | cut -c 1-17) 


               if [ "$gateway" != "none" ] ;then

                       	echo  "$int"
                        echo  "IP: $lanip"
                        echo  "Default Gateway: $gateway"
                        echo  "MAC: $mac"
                        echo ""
	
 
		fi
	done

elif [ "$OS" == "Darwin" ] ;then
	
	for int in $(networksetup -listallhardwareports | awk '/Bluetooth/ {getline; next} {print}' | grep Device | cut -d' ' -f2) ;do
 
		lanip=$(ifconfig $int | grep -v inet6 | grep inet | cut -d' ' -f2)
		gateway=$(netstat -nr -f inet | grep $int | awk 'FNR == 1 {print}' | awk '{print$2}')
		mac=$(ifconfig $int | grep ether | awk '{print $2}'| cut -c 1-17)
		state=$(ifconfig $int | grep status | awk '{print$2}')
	
		if [ "$state" == "active" ] ;then
        
  			echo "$int"
			echo "IP: $lanip"
			echo "Default Gateway: $gateway"
			echo "MAC: $mac"
			echo ""

		fi
	done	

elif [ "$OS" == "FreeBSD" ] ;then
	for int in $(ifconfig -l) ;do

		lanip=$(ifconfig $int | grep inet | cut -d ':' -f2 | cut -d' ' -f2)
		gateway=$(netstat -nr -f inet | grep $int | awk 'FNR == 1 {print}' | awk '{print$2}')
		mac=$(ifconfig $int | grep hwaddr | cut -d' ' -f2)
		state=$(ifconfig $int | grep status | awk '{print$2}')

		if [ "$state" == "active" ] ;then
			
			echo "$int"
                        echo "IP: $lanip"
                        echo "Default Gateway: $gateway"
                        echo "MAC: $mac"
                        echo ""
	
		fi

	done

fi
	echo -e "Name Servers": $dns | awk '!a[$0]++'

