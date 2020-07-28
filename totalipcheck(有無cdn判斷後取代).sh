#再加一個if條件判斷式
        #如果IP(prinft $1)是長這樣 ->  "-"-209.17.96.90
        #用sed取代成 209.17.96.90  #sed 's/\"-//g'
        #如果IP(prinft $1)是長這樣 ->  "13.113.54.250"-185.216.250.243"
        #用sed取代成 13.113.54.250  #sed 's/\"//g'
        #就變的跟其他IP一樣

reg1="^(\"-\"-)"
reg2="^(\"[[:digit:]])"

if [[ "$ip" =~ $reg1 ]];
then 
	ip=$(echo $ip | sed 's/\"-//g')

elif [[ "$ip" =~ $reg2 ]];
then
	ip=$(echo ${ip%-*} | sed 's/\"//g')
fi