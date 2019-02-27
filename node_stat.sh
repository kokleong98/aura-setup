tail -n 10000 20190227.txt | awk -v dsum="$dsum" -v dfirst="$dfirst" -v dlast="$dlast"  'BEGIN {FS="[,:\"]+"} {
  for(i=1;i<=NF;i++){
    if($i == "pv") dsum+=$(i+1);
  }
  {
    if(NR == 1) dfirst=$3;
    if(NR == FNR)dlast=$3;
  }
}
{print dsum ", " dsum / NR;} 
END{print FNR "," dsum, dfirst, dlast}'

tail -n 10000 20190227.txt | awk -v dsum="$dsum" -v dfirst="$dfirst" -v dlast="$dlast"  'BEGIN {FS="[,:\"]+"} {
  for(i=1;i<=NF;i++){
    if($i == "pv") dsum+=$(i+1);
  }
  {
    if(NR == 1) dfirst=$3;
    if(NR == FNR)dlast=$3;
  }
}
END{print FNR "," dsum, dfirst, dlast}'




tail -n 10000 20190227.txt | awk -v dsum="$dsum" -v dfirst="$dfirst" -v dlast="$dlast"  '  BEGIN {FS="[,:\"]+"} {
  for(i=1;i<=NF;i++){
    if($i == "pv") dsum+=$(i+1);
  }
  {
    if(NR == 1) dfirst=$3;
    if(NR == FNR)dlast=$3;
  }
}
{print dsum ", " dsum / NR;} 
END{print FNR "," dsum, dfirst, dlast}'
