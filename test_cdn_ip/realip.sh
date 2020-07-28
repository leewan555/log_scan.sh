ip="\"-\"-47.100.1.70"

#reg="(\"-\"-)"
reg="^(\"-\"-)"
if [[ "$ip" =~ $reg ]];then
	nip=$(echo $ip | sed 's/\"-//g')
	echo $nip
fi


