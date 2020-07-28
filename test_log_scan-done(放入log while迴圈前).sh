#!/bin/bash



LOGFILE=$1
 # $0是檔名 $1是第一個變數 在外頭是用xargs -I @ sh run_scan.sh @ 所以被丟進來的@ 就會變成$1


#LOGPATH=$(ls -l /home/wwwlogs/*.log |awk '/^-/ {print $NF}')
#for a in $LOGPATH
#do
#   a=$a
#done


#BEGIN_TIME="2020-01-09 00:00:00"  原本這裡時間是寫死的，但要進來檔案改我覺得很麻煩
#END_TIME="2020-01-10 23:59:59"
#後來想說讓使用者自己手動key入日期(這樣禮拜一就可以篩選從上禮拜五晚上到這禮拜一早上的log)
#但這樣自動化就比較麻煩


read -p "Input your BEGIN TIME (YYYY-mm-dd HH:MM:SS, ex> 2020-07-15 00:00:01): " BEGIN_TIME
read -p "Input your END TIME (YYYY-mm-dd HH:MM:SS, ex> 2020-07-15 00:00:01): " END_TIME


#/*
#這一大串 看看可不可以 只是要確認我日期是否打對

# date_d=$(echo ${date2} | grep '[[:digit:]]\{14\}')
# if [ "${date_d}" == "" ];then
#         echo "You input the wrong data format..."
#         echo ", ex> {${0} someword}" 這句要改
#         exit 1
# fi

#*/


PATTERNFILE=/usr/wan_sh/log_scan/patterns.txt
WHITELISTFILE=/usr/wan_sh/log_scan/whitelist.txt



do_work() #接下來要做的動作
{
  echo "Put IP: $1 into deny.sh "
  /usr/sadie00/deny.sh -a $1 #丟進deny.sh裡面
}

printf "┏━━━━━━━━━━━━━━━━━$1━━━━━━━━━━━━━━━━━┓\n"


B_TIME=$(date -d "$BEGIN_TIME" +%s) #將$BEGIN_TIME轉換成秒 -d也可以換成--date
E_TIME=$(date -d "$END_TIME" +%s) #將$END_TIME轉換成秒 -d也可以換成--date



printf "OK======================= Patterns ======================= \n"


#touch $PATTERNFILE   #關鍵字資料夾
#我把路徑寫死了 #假如沒有關鍵字檔案，就新增(若已存在，則是更新最後開啟時間及修改時間，不會改變檔案內容)

patterns=""
lastline=$(cat $PATTERNFILE | wc -l)

i=1
#網址https://stackoverflow.com/questions/4385772/bash-read-line-by-line-from-file-with-ifs
#https://www.coder.work/article/2567315
while IFS= read -r pattern; #一行一行讀檔($PATTERNFILE)再放入$pattern(IFS去除前後空白，read -r一行一行讀，且讓反斜線“\”會被認為是行的一部分，防止被視為特殊符號)
do
        #雙括號是因為裡面有正規表示法 #阿驚嘆號應該不用吧??
    if [[ $pattern != *[!\ ]* ]]; # *[!\ ]* 代表如果這關鍵字是字串中間如果有 驚嘆號 反斜線 空白，就跳過 
    then
     
        lastline=$((lastline - 1)) #不要計算空格或是空值
        continue;
    fi

    echo "($i)" $pattern #"($i)" #這樣會變成(1)關鍵字1 (2)關鍵字2
    patterns+="("$pattern")" #patterns=patterns+"$pattern"
    if [ $i -ne $lastline ];
    then
       patterns+="|"
    fi
    i=$((i + 1)) #換下一個關鍵字
done < $PATTERNFILE #讀檔  < 標準輸入(stdin)，程式執行所需要的輸入資料，這樣while迴圈就可以取得$PATTERNFILE內的資料


if [ "$patterns" = "" ]; #假如關鍵字檔案裡面沒東西
then
   printf  "\nNo patterns.\n" 
   exit;
fi

printf "OK======================= Regex ======================= \n"
echo $patterns 



printf "OK==================== Whitelist IPs ==================== \n"
#白名單
#touch $WHITELISTFILE 
#我把路徑寫死了 #假如沒有白名單檔案，就新增(若已存在，則是更新最後開啟時間及修改時間，不會改變檔案內容)

whitelist=`cat $WHITELISTFILE`
if [ "$whitelist" = "" ];
then
    echo "None"
else
    cat $WHITELISTFILE
fi




printf "===================== Log Matched ===================== \n"

ab_ips=""
while IFS= read -r line; #一行一行讀檔($$LOGFILE)再放入$line
do

  logdatetime=$(echo $line | awk '{ print $4}' | sed 's/\[//g;s/\//-/g;s/:/ /') #原本[01/Jul/2020:06:24:24 變成 01-Jul-2020 06:24:24
  logdatetime_s=$(date -d "$logdatetime" +%s)
  
  
  if [ $logdatetime_s -ge "$B_TIME" ] && [ $logdatetime_s -le "$E_TIME" ];
  then
     matchlog=$(echo $line | egrep --color=always "$patterns")
     if [ "$matchlog" != "" ] ;
     then
        ip=$(echo $line | egrep "$patterns" | awk '{printf $1}')
        for wip in $whitelist; 
        do
              if [ "$ip" = "$wip" ];
              then
                  continue 2 #符合條件就跳回if [ "$matchlog"]那邊
              fi
        done
        echo $matchlog
        ab_ips+="$ip\n"
     fi
  fi

done < $LOGFILE

#如果沒有符合的IP
if [ "$ab_ips" = "" ];
then
   printf  "\n0 logs matched.\n" 
   exit;
fi

count=$(printf $ab_ips | wc -l)
printf  "\n"$count" logs matched.\n" 




printf "===================== Weird IPs ===================== \n"
printf "     Counts IP\n"
printf $ab_ips | sort | uniq -c #uniq -c 可以在刪除重複文字行後，標示出每一行的重複次數



printf "======================= Action ======================= \n"
export -f do_work
printf $ab_ips | sort | uniq | xargs -I @ bash -c "do_work @"
printf "\n\nDone.\n"
