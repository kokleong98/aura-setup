#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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
    BEGIN{FS="[{},:\"]+"}
    {
      totalcol=0

      for (i = 3; i <= NF; i+=2)
      {
        recs[NR, $(i-1)] = $i;
        totalcol+=1;
      }
      if (NR == 1)
      {
        last_stake=0;
      }

      if(match(recs[NR, "st"], /^[0-9]*[.]?[0-9]*$/))
      {
          if(last_stake != recs[NR, "st"])
          {
              last_stake=recs[NR, "st"]
              printf "%s,%s\n",  recs[NR, "t"], recs[NR, "st"]
          }
          
      }
      totalrow+=1;
    }
    END {
      #
    }' "$DIR/stats/$curdate.txt"
  )

  if [ -z "$result" ]; then
    result="$line"
  else
    result="$result$newline$line"
  fi
done

awk '
  function toDatetime(data, ret)
  {
    # ret=mktime(substr(data, 1, 4)  " "  substr(data, 5, 2)  " "  substr(data, 7, 2)  " "   substr(data, 9, 2) " "  substr(data, 11, 2) " "  substr(data, 13, 2) );
    ret=mktime(substr(data, 1, 4)  " "  substr(data, 5, 2)  " "  substr(data, 7, 2)  " "   substr(data, 9, 2) " "  substr(data, 11, 2) " 00"  );
    return ret;
  }

  function printSumm()
  {
    mydate=substr(lastday, 1, 4) "-" substr(lastday, 5, 2) "-" substr(lastday, 7, 2)
    printf "%-10s %6s ", mydate, daychanges
    printf "%4s\033[0m \033[41m%4s\033[0m", range_10k, range_d10k
    printf "%4s\033[0m \033[41m%4s\033[0m", range_50k, range_d50k
    printf "%4s\033[0m \033[41m%4s\033[0m", range_100k, range_d100k
    printf "%4s\033[0m \033[41m%4s\033[0m", range_200k, range_d200k
    printf "%4s\033[0m \033[41m%4s\033[0m", range_500k, range_d500k
    printf "%4s\033[0m \033[41m%4s\033[0m", range_1mill, range_d1mill
    printf "%4s\033[0m \033[41m%4s\033[0m", range_2mill, range_d2mill
    printf "%4s\033[0m \033[41m%4s\033[0m", range_5mill, range_d5mill
    printf "%4s\033[0m \033[41m%4s\033[0m", range_remains, range_dremains
    printf "\n"
  }

  function printHeader()
  {
    printf "%-10s %6s ", "Date", "Moves"
    printf "%-9s", "  <= 10k"
    printf "%-9s", "  <= 50k"
    printf "%-9s", " <= 100k"
    printf "%-9s", " <= 200k"
    printf "%-9s", " <= 500k"
    printf "%-9s", " <= 1mil"
    printf "%-9s", " <= 2mil"
    printf "%-9s", " <= 5mil"
    printf "%-9s", "  > 5mil"
    printf "\n"
  }

  function abs(x){return ( x >= 0 ) ? x : -x }

  function resetStats()
  {
    daychanges=1;
    range_10k=0
    range_50k=0
    range_100k=0
    range_200k=0
    range_500k=0
    range_1mill=0
    range_2mill=0
    range_5mill=0
    range_remains=0
    range_d10k=0
    range_d50k=0
    range_d100k=0
    range_d200k=0
    range_d500k=0
    range_d1mill=0
    range_d2mill=0
    range_d5mill=0
    range_dremains=0
  }

  function calcStats(data)
  {
    if(data < 0)
    {
      data=abs(data);
      if (data <= 10000)
      {
        range_d10k++;
      }
      else if (data <= 50000)
      {
        range_d50k++;
      }
      else if (data <= 100000)
      {
        range_d100k++;
      }
      else if (data <= 200000)
      {
        range_d200k++;
      }
      else if (data <= 500000)
      {
        range_d500k++;
      }
      else if (data <= 1000000)
      {
        range_d1mill++;
      }
      else if (data <= 2000000)
      {
        range_d2mill++;
      }
      else if (data <= 5000000)
      {
        range_d5mill++;
      }
      else
      {
        range_dremains++;
      }
    }
    else
    {
      if (data <= 10000)
      {
        range_10k++;
      }
      else if (data <= 50000)
      {
        range_50k++;
      }
      else if (data <= 100000)
      {
        range_100k++;
      }
      else if (data <= 200000)
      {
        range_200k++;
      }
      else if (data <= 500000)
      {
        range_500k++;
      }
      else if (data <= 1000000)
      {
        range_1mill++;
      }
      else if (data <= 2000000)
      {
        range_2mill++;
      }
      else if (data <= 5000000)
      {
        range_5mill++;
      }
      else
      {
        range_remains++;
      }
    }
  }

  BEGIN{FS=","}
  {
    if(NR == 1)
    {
      resetStats()
      lastday=substr($1, 1, 8)
      last_totalstakes=$2
      printHeader();
    }
    if(lastday == substr($1, 1, 8))
    {
      if(last_totalstakes != $2)
      {
        daychanges+=1;
      }
    }
    else
    {
      printSumm();
      resetStats();

      if(last_totalstakes != $2)
      {
        daychanges+=1;
      }
      lastday=substr($1, 1, 8)
      last_totalstakes=$2
    }
    calcStats(last_totalstakes - $2);
    last_totalstakes=$2
  }
  END {
    printSumm();
  #printf "\033[0;33m%-9s: Last %s day(s) from %s\033[0m\n", "Summary",  total_rows, tilldate
  #printf "\033[0;32m%-9s:\033[0m \033[30;48;5;82m%8.4f\033[0m%% ", "Online", (tot_online / tot_cnt)*100
  #printf "\033[30;48;5;82m%6s\033[0m\n", tot_online
  #printf "\033[0;31m%-9s:\033[0m \033[41m%8.4f\033[0m%% ", "Offline", (tot_offline / tot_cnt)*100
  #printf "\033[4;41;82m%6s\033[0m\n", tot_offline
  #printf "\033[0;34m%-9s:\033[0m \033[4;5;82m%8.4f\033[0m%% ", "No status", (tot_nostatus / tot_cnt)*100
  #printf "\033[4;5;82m%6s\033[0m\n", tot_nostatus
  #printf "\033[0;36m%-9s:\033[0m \033[4;5;82m%8.4f\033[0m%% ", "Miss", ((tot_cnt - tot_online - tot_offline - tot_nostatus) / tot_cnt)*100
  #printf "\033[4;5;82m%6s\033[0m\n\n", (tot_cnt - tot_online - tot_offline - tot_nostatus)
  }
' "tilldate=$tilldate" <<< "$result"
