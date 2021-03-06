#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

json=0
if [ $# -eq 4 ] && [ $3 == "json" ]; then
  json=1
  dest=$4
fi

if [ -z "$1" ]; then
  days="1"
else
  days="$1"
fi

if [ -z "$2" ]; then
  fromdate="$(date -d "+$(((days * -1)+1)) days" +%Y-%m-%d)"
  tilldate="$(date  +%Y-%m-%d)"
else
  fromdate="$(date -d "$2 +$(((days * -1)+1)) days" +%Y-%m-%d)"
  tilldate="$(date -d "$2" +%Y-%m-%d)"
fi

newline='
'

for ((val=$days-1; val >= 0; val--))
do
  curdate="$(date -d "$tilldate +$((val * -1)) days" +%Y%m%d)"

  if [ ! -f "$DIR/stats/$curdate.txt" ]; then
    echo "$curdate.txt file not found."
    continue;
  fi

  line=$(
    awk  '
    function toDatetime(data, ret)
    {
      # ret=mktime(substr(data, 1, 4)  " "  substr(data, 5, 2)  " "  substr(data, 7, 2)  " "   substr(data, 9, 2) " "  substr(data, 11, 2) " "  substr(data, 13, 2) );
      ret=mktime(substr(data, 1, 4)  " "  substr(data, 5, 2)  " "  substr(data, 7, 2)  " "   substr(data, 9, 2) " "  substr(data, 11, 2) " 00"  );
      return ret;
    }

    # Load all fields of each record into recs.
    BEGIN{FS="[{},:]+"}
    {
      totalcol=0

      for (i = 3; i <= NF; i+=2)
      {
        recs[NR, substr($(i-1), 2, length($(i-1))-2)] = substr($i, 2, length($i)-2);
        totalcol+=1;
      }
      if (NR == 1)
      {
        mindate=toDatetime(recs[NR, "t"]);
        maxdate=toDatetime(recs[NR, "t"]);
      }
      else
      {
        if (mindate > toDatetime(recs[NR, "t"]))
          mindate=toDatetime(recs[NR, "t"]);
        if (maxdate < toDatetime(recs[NR, "t"]))
          maxdate=toDatetime(recs[NR, "t"]);
      }
      if(recs[NR, "s"] == "0")
      {
        offline=1 + offline
      }
      else if(recs[NR, "s"] == "1")
      {
        online=1 + online
      }
      else
      {
        miss=1 + miss
      }

      totalrow+=1;
    }
    END {
      diff=maxdate - mindate + 60;
      cnt=int((diff/60));
      printf "%s,%s,%s,%s,%s,%s", ARGV[1], cnt, online, offline, miss, (online/cnt)*100;
    }' "$DIR/stats/$curdate.txt"
    )

    if [ -z "$result" ]; then
      result="$line"
    else
      result="$result$newline$line"
    fi
done

awk '
function printSummary()
{
  printf "\033[0;33m%-9s: Last %s day(s) from %s\033[0m\n", "Summary",  total_rows, tilldate
  printf "\033[0;32m%-9s:\033[0m \033[30;48;5;82m%8.4f\033[0m%% ", "Online", (tot_online / tot_cnt)*100
  printf "\033[30;48;5;82m%6s\033[0m\n", tot_online
  printf "\033[0;31m%-9s:\033[0m \033[41m%8.4f\033[0m%% ", "Offline", (tot_offline / tot_cnt)*100
  printf "\033[4;41;82m%6s\033[0m\n", tot_offline
  printf "\033[0;34m%-9s:\033[0m \033[4;5;82m%8.4f\033[0m%% ", "No status", (tot_nostatus / tot_cnt)*100
  printf "\033[4;5;82m%6s\033[0m\n", tot_nostatus
  printf "\033[0;36m%-9s:\033[0m \033[4;5;82m%8.4f\033[0m%% ", "Miss", ((tot_cnt - tot_online - tot_offline - tot_nostatus) / tot_cnt)*100
  printf "\033[4;5;82m%6s\033[0m\n\n", (tot_cnt - tot_online - tot_offline - tot_nostatus)
}

function printJson()
{

}

BEGIN{FS=","}
{
  if( json == 0)
  {
    printf "\033[0;33mDate: %s-%s-%s\033[0m\n", substr($1, length($1) - 11, 4), substr($1, length($1) - 7, 2), substr($1, length($1) - 5, 2)
    printf "\033[0;32mOnline:\033[0m \033[30;48;5;82m%8.4f\033[0m%% ", $6
    printf "\033[4;5;82m%4s\033[0m ", $3
    if ($4 == "")
    {
      printf "\033[0;31mOffline:\033[0m \033[41m%4s\033[0m ", 0
    }
    else
    {
      printf "\033[0;31mOffline:\033[0m \033[41m%4s\033[0m ", $4
    }
    if ($5 == "")
    {
      printf "\033[0;34mNo status:\033[0m \033[4;5;82m%4s\033[0m ", 0
    }
    else
    {
      printf "\033[0;34mNo status:\033[0m \033[4;5;82m%4s\033[0m ", $5
    }
    printf "\033[0;35mEst.:\033[0m \033[4;5;82m%4s\033[0m ", $2
    printf "\033[0;36mMiss:\033[0m \033[4;5;82m%4s\033[0m\n\n", $2 - $3 - $4
  }
  else
  {
    json_filename=dest "stat_" substr($1, length($1) - 11, 4) "_" substr($1, length($1) - 7, 2) "_" substr($1, length($1) - 5, 2) ".json"
    printf "%s\n", json_filename
    content="{" "\"Date\":\"" substr($1, length($1) - 11, 4) "-" substr($1, length($1) - 7, 2) "-" substr($1, length($1) - 5, 2) "T00:00:00.000Z" "\""
    content=content ",\"Online\":" $3
    if ($4 == "")
    {
      content=content ",\"Offline\":0"
    }
    else
    {
      content=content ",\"Offline\":" $4
    }
    if ($5 == "")
    {
      content=content ",\"NoStatus\":0"
    }
    else
    {
      content=content ",\"NoStatus\":" $5
    }
    content=content ",\"Est\":" $2
    content=content ",\"Miss\":" ($2 - $3 - $4) "}"
    print content > ""json_filename""
  }

  tot_cnt+=$2
  tot_online+=$3
  tot_offline+=$4
  tot_nostatus+=$5
  total_rows++;
}
END {
  if (json == 0) printSummary();
}
' "tilldate=$tilldate" "json=$json" "dest=$dest" <<< "$result"
