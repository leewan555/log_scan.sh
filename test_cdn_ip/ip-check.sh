
#ip="\"-\"-34.209.232.168"
#reg=".*(123).*"
reg="(\"-\"-)"

while IFS= read -r line;
do
   if [[ $line =~ $reg  ]];
   then
      nip=$(echo $line | sed 's/\"-//g') 
      echo $nip
   fi

done < log

#if [[ $ip =~ $reg ]];
#then
   #nip=$(echo $ip | sed 's/\"-//g')
#   echo "test"     
#   echo $ip 
#fi
#echo $nip
