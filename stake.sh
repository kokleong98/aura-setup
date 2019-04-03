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
      ret=mktime(substr(data, 1, 4)  " "  substr(data, 5, 2)  " "  substr(data, 7, 2)  " "   substr(data, 9, 2) " "  substr(data, 11, 2) " 00"  );
      return ret;
    }

    # Load all fields of each record into recs.
    BEGIN{FS="[{},:]+"}
    {
      totalcol=0;
      for (i = 3; i <= NF; i+=2)
      {
        recs[NR, substr($(i-1), 2, length($(i-1))-2)] = substr($i, 2, length($i)-2);
        totalcol+=1;
      }
      if (length(last_stake) == 0) last_stake=recs[NR, "st"];
      if(length(recs[NR, "st"]) > 0 && match(recs[NR, "st"], /^[0-9]*[.]?[0-9]*$/))
      {
          if(last_stake != recs[NR, "st"])
          {
              last_stake=recs[NR, "st"];
              printf "%s,%s\n",  recs[NR, "t"], recs[NR, "st"];
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
    ret=mktime(substr(data, 1, 4)  " "  substr(data, 5, 2)  " "  substr(data, 7, 2)  " "   substr(data, 9, 2) " "  substr(data, 11, 2) " 00"  );
    return ret;
  }

  function printSumm()
  {
    if(line % 2 == 0)
    {
      mydate=substr(lastday, 1, 4) "-" substr(lastday, 5, 2) "-" substr(lastday, 7, 2)
      printf "\033[4;5;82m%-10s\033[0m", mydate;
      printf "%4s\033[0m", (range_10k + range_50k + range_100k + range_200k + range_500k + range_1mill + range_2mill + range_5mill + range_remains);
      printf "\033[41m%4s\033[0m", (range_d10k + range_d50k + range_d100k + range_d200k + range_d500k + range_d1mill + range_d2mill + range_d5mill + range_dremains);
      printf "%8.3f\033[0m\033[41m%8.3f\033[0m", stakePositive / 1000000, stakeNegative / 1000000;
      printf "%4s\033[0m\033[41m%4s\033[0m", range_10k, range_d10k;
      printf "%4s\033[0m\033[41m%4s\033[0m", range_50k, range_d50k;
      printf "%4s\033[0m\033[41m%4s\033[0m", range_100k, range_d100k;
      printf "%4s\033[0m\033[41m%4s\033[0m", range_200k, range_d200k;
      printf "%4s\033[0m\033[41m%4s\033[0m", range_500k, range_d500k;
      printf "%4s\033[0m\033[41m%4s\033[0m", range_1mill, range_d1mill;
      printf "%4s\033[0m\033[41m%4s\033[0m", range_2mill, range_d2mill;
      printf "%4s\033[0m\033[41m%4s\033[0m", range_5mill, range_d5mill;
      printf "%4s\033[0m\033[41m%4s\033[0m", range_remains, range_dremains;
      printf "\n";
    }
    else
    {
      mydate=substr(lastday, 1, 4) "-" substr(lastday, 5, 2) "-" substr(lastday, 7, 2)
      printf "\033[4;5;82m%-10s\033[0m", mydate
      printf "\033[1;30;47m%4s\033[0m", (range_10k + range_50k + range_100k + range_200k + range_500k + range_1mill + range_2mill + range_5mill + range_remains)
      printf "\033[41m%4s\033[0m", (range_d10k + range_d50k + range_d100k + range_d200k + range_d500k + range_d1mill + range_d2mill + range_d5mill + range_dremains)
      printf "\033[1;30;47m%8.3f\033[0m\033[41m%8.3f\033[0m", stakePositive / 1000000, stakeNegative / 1000000
      printf "\033[1;30;47m%4s\033[0m\033[41m%4s\033[0m", range_10k, range_d10k
      printf "\033[1;30;47m%4s\033[0m\033[41m%4s\033[0m", range_50k, range_d50k
      printf "\033[1;30;47m%4s\033[0m\033[41m%4s\033[0m", range_100k, range_d100k
      printf "\033[1;30;47m%4s\033[0m\033[41m%4s\033[0m", range_200k, range_d200k
      printf "\033[1;30;47m%4s\033[0m\033[41m%4s\033[0m", range_500k, range_d500k
      printf "\033[1;30;47m%4s\033[0m\033[41m%4s\033[0m", range_1mill, range_d1mill
      printf "\033[1;30;47m%4s\033[0m\033[41m%4s\033[0m", range_2mill, range_d2mill
      printf "\033[1;30;47m%4s\033[0m\033[41m%4s\033[0m", range_5mill, range_d5mill
      printf "\033[1;30;47m%4s\033[0m\033[41m%4s\033[0m", range_remains, range_dremains
      printf "\n"
    }
    printf "Min: %8.3f, Max: %8.3f, Start: %8.3f, End: %8.3f\n", day_min, day_max, day_start, day_end;
  }

  function printHeader()
  {
    printf "\033[30;47m%-10s\033[0m\033[4;5;82m%-8s\033[0m", "Date", "  Moves"
    printf "\033[30;47m%-16s\033[0m", "  Volumes(Mils)"
    printf "\033[4;5;82m%-8s\033[0m", " <= 10k"
    printf "\033[30;47m%-8s\033[0m", " <= 50k"
    printf "\033[4;5;82m%-8s\033[0m", "<= 100k"
    printf "\033[30;47m%-8s\033[0m", "<= 200k"
    printf "\033[4;5;82m%-8s\033[0m", "<= 500k"
    printf "\033[30;47m%-8s\033[0m", "<= 1mil"
    printf "\033[4;5;82m%-8s\033[0m", "<= 2mil"
    printf "\033[30;47m%-8s\033[0m", "<= 5mil"
    printf "\033[4;5;82m%-8s\033[0m", " > 5mil"
    printf "\n"
  }

  function abs(x){return ( x >= 0 ) ? x : -x }

  function resetStats()
  {
    daychanges=1;
    stakePositive=0
    stakeNegative=0
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
    day_min=0
    day_max=0
    day_start=0
    day_end=0
  }

  function calcStats(data)
  {
    if(data < 0)
    {
      data=abs(data);
      stakeNegative+=data;
      if (data <= 10000) range_d10k++;
      else if (data <= 50000) range_d50k++;
      else if (data <= 100000) range_d100k++;
      else if (data <= 200000) range_d200k++;
      else if (data <= 500000) range_d500k++;
      else if (data <= 1000000) range_d1mill++;
      else if (data <= 2000000) range_d2mill++;
      else if (data <= 5000000) range_d5mill++;
      else range_dremains++;
    }
    else
    {
      stakePositive+=data;
      if (data <= 10000) range_10k++;
      else if (data <= 50000) range_50k++;
      else if (data <= 100000) range_100k++;
      else if (data <= 200000) range_200k++;
      else if (data <= 500000) range_500k++;
      else if (data <= 1000000) range_1mill++;
      else if (data <= 2000000) range_2mill++;
      else if (data <= 5000000) range_5mill++;
      else range_remains++;
    }
  }

  BEGIN{FS=","}
  {
    if(NR == 1)
    {
      line=1;
      resetStats();
      lastday=substr($1, 1, 8);
      last_totalstakes=$2;
      day_start=$2
      day_end=$2
      day_min=$2
      day_max=$2
      printHeader();
    }

    if(lastday == substr($1, 1, 8))
    {
      if(last_totalstakes != $2) daychanges+=1;
      day_end=$2
    }
    else
    {
      line++;
      printSumm();
      resetStats();
      if(last_totalstakes != $2) daychanges+=1;
      lastday=substr($1, 1, 8);
      last_totalstakes=$2;
      day_start=$2
      day_end=$2
      day_min=$2
      day_max=$2
    }
    calcStats($2 - last_totalstakes);
    if($2 > day_max) day_max = $2;
    if($2 < day_min) day_min = $2;
    last_totalstakes=$2;
  }
  END {
    line++;
    printSumm();
  }
' "tilldate=$tilldate" <<< "$result"
