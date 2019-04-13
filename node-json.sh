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

    function defaultIfEmpty(data, defaultValue, ret)
    {
      if (length(data) > 0) return data;
      else return defaultValue;
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
        curtime=toDatetime(recs[NR, "t"]);
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
        curstat="0"
      }
      else if(recs[NR, "s"] == "1")
      {
        online=1 + online
        curstat="1"
      }
      else
      {
        miss=1 + miss
        curstat=""
      }

      if (NR == 1)
      {
        laststat=curstat;
        lasttime=toDatetime(recs[NR, "t"]);
      }

      if (laststat != curstat)
      {
        if(length(json) > 0) json=json ","
        endtime=(toDatetime(recs[NR, "t"])-60)
        duration=(endtime -lasttime)/60
        json=json strftime("{\"start\":\"%H:%M\"", lasttime) "," strftime("\"end\":\"%H:%M\"", endtime) ",\"span\":" duration+1 ",\"stat\":\"" laststat "\"}"
        laststat=curstat;
        lasttime=toDatetime(recs[NR, "t"]);
      }
      totalrow+=1;
    }
    END {
      if (laststat == curstat)
      {
        if(length(json) > 0) json=json ","
        endtime=(toDatetime(recs[totalrow, "t"]))
        duration=(endtime -lasttime)/60
        json=json strftime("{\"start\":\"%H:%M\"", lasttime) "," strftime("\"end\":\"%H:%M\"", endtime) ",\"span\":" duration+1 ",\"stat\":\"" laststat "\"}"
      }

      diff=maxdate - mindate + 60;
      cnt=int((diff/60));

      online=defaultIfEmpty(online, 0)
      offline=defaultIfEmpty(offline, 0)
      miss=defaultIfEmpty(miss, 0)
      cnt=defaultIfEmpty(cnt, 0)

      printf "{\"Date\":%s,\"Online\":%s,\"Offline\":%s,\"NoStatus\":%s,\"Est\":%s,\"Miss\":%s", strftime("%Y-%m-%dT00:00:00.000Z", endtime), online, offline, miss, cnt, (cnt -online - offline - miss)
      printf ",\"History\":[%s]}", json
    }' "$DIR/stats/$curdate.txt"
    )

    if [ -z "$result" ]; then
      result="$line"
    else
      result="$result$newline$line"
    fi
done

echo "$result"
