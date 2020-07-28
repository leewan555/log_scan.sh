ip="\"13.113.54.250\"-185.216.250.243"

reg="^(\"[[:digit:]])"
if [[ "$ip" =~ $reg ]];then
	#nip=$(echo $ip | sed 's/\"-//g')
	nip=$(echo ${ip%-*} | sed 's/\"//g')
	#nip=$(echo $nip | sed 's/\"//g')
	echo $nip
fi

