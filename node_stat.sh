#!/bin/bash

awk  '
function toDatetime(data, ret)
{
  ret=mktime(substr(data, 1, 4)  " "  substr(data, 5, 2)  " "  substr(data, 7, 2)  " "   substr(data, 9, 2) " "  substr(data, 11, 2) " "  substr(data, 13, 2) );
  return ret;
}

function min(arr, rowsize, name,     ret)
{
  first=0
  for(i=1; i<=rowsize; i++)
  {
    #print arr[i, name]
    if(arr[i, name] == "") continue;
    if(first==0)
    {
       ret=arr[i, name];
       first=1
    }
    if(ret > arr[i, name])
    {
       ret=arr[i, name];
    }
  }
  return ret;
}

function max(arr, rowsize, name,     ret)
{
  first=0
  for(i=1; i<=rowsize; i++)
  {
    #print arr[i, name]
    if(arr[i, name] == "") continue;
    if(first==0)
    {
       ret=arr[i, name];
       first=1
    }
    if(ret < arr[i, name])
    {
       ret=arr[i, name];
    }
  }
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
  totalrow+=1;
}
END {
  print min(recs, totalrow, "pc");
  print max(recs, totalrow, "pc");
  #print recs[1, "pc"]
}' $1
