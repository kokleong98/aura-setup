#!/bin/bash

days="$1"
fromdate="$(date -d "+$((days * -1)) days" +%Y%m%d)"
tilldate="$(date  +%Y%m%d)"

for ((val=$days; val >= 1; val--))
do
  curdate="$(date -d "+$((val * -1)) days" +%Y%m%d)"

awk  '
function toDatetime(data, ret)
{
  ret=mktime(substr(data, 1, 4)  " "  substr(data, 5, 2)  " "  substr(data, 7, 2)  " "   substr(data, 9, 2) " "  substr(data, 11, 2) " "  substr(data, 13, 2) );
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
  diff=maxdate - mindate;
  cnt=int((diff/60)+0.5)+1;
  print ARGV[1] "," cnt "," online "," offline "," miss
}' "$curdate.txt"

done
