#!/bin/bash

# ********************************************************************************************************************
# Creator: Remo Tomasi
# extract v0.1.1 11-02-2016
# extract v0.1.2 14-09-2016
# extract v0.1.3 12-11-2016
# extract v0.1.4 02-01-2017
#
#
# Launch this bash exectable simply with ./extract.sh GRIBFILE.grb
# and several files will be created. The most important will be prev.xls
#
#
# remotomasi: https://github.com/remotomasi
#
#                     GNU AFFERO GENERAL PUBLIC LICENSE
#                        Version 3, 19 November 2007
#
# Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.
#
# 2017 Remo Tomasi • remo.tomasi@gmail.com
#
#
# For the GRIB file send an email to: query@saildoc.com
# and only this content:
# send GRIB:40N,40N,18.2E,18.2E|1,1|0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96,102,108,114,120,126,132,138,144|TMP,CAPE,PRESS,RH,APCP,HGT,WIND,LFTX,RAIN,TCDC
#
# some infos about the previous string
# APCP: accumulo precipitazioni
# HGT: geopotenziale (gpm 500 hPa)
# LFTX: lifted index
# RAIN: pioggia mm/h
#
# per estrarre
# PRESS → PRMSL
# WIND → UGRD
# WIND → VGRD
# RAIN → PRATE
#
# grep -A1 "5 5" --> grep -A1 "3 5" o "5 5"
# grep -A1 "361 1" --> grep -A1 "361 1" o "361 1"

if [ $# -eq 0 ]; then
  echo "Inserisci il nome del file grb"
  exit 1
fi

rm prev.csv prev.ods data.txt orario.txt temp2.txt rh2.txt uwind2.txt vwind2.txt pres.txt pres2.txt geop5002.txt cloudClover.txt cloudCover2.txt rainAcc2.txt cape2.txt orario.txt
rm rainRate2.txt li2.txt wind2.txt wind2Dir.txt wind3Dir.txt uwind22.txt vwind22.txt

touch orario.txt data.txt temp2.txt rh2.txt uwind2.txt vwind2.txt pres.txt pres2.txt geop5002.txt cloudCover.txt cloudCover2.txt rainAcc2.txt cape2.txt orario.txt
touch rainRate2.txt li2.txt wind2.txt wind2Dir.txt wind3Dir.txt uwind22.txt vwind22.txt

#echo '\n' | gawk '{printf "\n"}' > temp.txt
wgrib -s $1 | grep ":TMP:" | wgrib -i -text $1 -o out.txt	#sono in gradi Kelvin (occorre sottrarre 273)
date +%d/%m/%Y -d "+1 days" >> data.txt
echo -e "2\n3\n4" >>  data.txt
date +%d/%m/%Y -d "+2 days" >> data.txt
echo -e "2\n3\n4" >>  data.txt
date +%d/%m/%Y -d "+3 days" >> data.txt
echo -e "2\n3\n4" >>  data.txt
date +%d/%m/%Y -d "+4 days" >> data.txt
echo -e "2\n3\n4" >>  data.txt
date +%d/%m/%Y -d "+5 days" >> data.txt
echo -e "2\n3\n4" >>  data.txt
awk '{print $1,$2,$3,$4,$5}' OFS="|" data.txt > data.xls
orario=$(wgrib -s $1 | cut -d':' -f6 | cut -d ' ' -f1 | head -23)
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > temp.txt
#echo ";" + $data ";" > temp.txt
for i in $(cat temp.txt); do $(echo $data >> data.txt); done
echo $orario | tr ' ' '\n' | head -n 21 > orario.txt
for i in $(cat temp.txt); do $(echo ${i} | gawk '{printf "%.0f\n",$1 -273.15}' >> temp2.txt); done
wgrib -s $1 | grep ":CAPE:" | wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > cape.txt
for i in $(cat cape.txt); do $(echo ${i} | gawk '{printf "%.0f\n",$1}' >> cape2.txt); done
wgrib -s $1 | grep ":PRMSL:" | wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--'  | tail -n 21 > pres.txt
for i in $(cat pres.txt); do $(echo ${i} | gawk '{printf "%.0f\n",$1/100}' >> pres2.txt); done
wgrib -s $1 | grep ":RH:" | wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > rh.txt
for i in $(cat rh.txt); do $(echo ${i} | gawk '{printf "%.0f\n",$1}' >> rh2.txt); done
wgrib -s $1 | grep ":APCP:" | wgrib -i -text $1 -o out.txt	#sono mm pioggia accumulata
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | head -n 21 > rainAcc.txt
for i in $(cat rainAcc.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1}' | tr '.' ',' >> rainAcc2.txt); done
wgrib -s $1 | grep ":HGT:" | wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > geop500.txt
for i in $(cat geop500.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1}' | tr '.' ',' >> geop5002.txt); done
wgrib -s $1 | grep ":UGRD:" | wgrib -i -text $1 -o out.txt	#sono in m/s
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > uwind.txt
for i in $(cat uwind.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1*3.6}' >> uwind2.txt); done
wgrib -s $1 | grep ":VGRD:" | wgrib -i -text $1 -o out.txt	#sono in m/s
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > vwind.txt
for i in $(cat vwind.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1*3.6}' >> vwind2.txt); done
wgrib -s $1 | grep ":LFTX:" | wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > li.txt
for i in $(cat li.txt); do $(echo ${i} | tr '.' ',' >> li2.txt); done
wgrib -s $1 | grep ":PRATE:" | wgrib -i -text $1 -o out.txt	# si riferisce alla raffica
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | head -n 21 > rainRate.txt
for i in $(cat rainRate.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1}' | tr '.' ',' >> rainRate2.txt); done
wgrib -s $1 | grep ":TCDC:" | wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > cloudCover.txt
for i in $(cat cloudCover.txt); do $(echo ${i} | gawk '{printf "%.0f\n",$1}' >> cloudCover2.txt); done

# Gestione del vento
for i in $(cat uwind2.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1}' >> uwind22.txt); done
for i in $(cat vwind2.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1}' >> vwind22.txt); done
paste uwind22.txt vwind22.txt | gawk '{print (sqrt($1*$1 + $2*$2)), $3}' >> wind2.txt  # calcolo potenza del vento
paste uwind22.txt vwind22.txt | gawk '{print (atan2($1,$2)*57.3+180), $3}' >> wind2Dir.txt  # calcolo direzione del vento
for i in $(cat wind2.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1}' >> wind2.txt); done
for i in $(cat wind2Dir.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1}' >> wind2Dir.txt); done
cat wind2.txt | tail -n 21 > wind22.txt
cat wind22.txt > wind2.txt
cat wind2Dir.txt | tail -n 21 > wind22Dir.txt
cat wind22Dir.txt > wind2Dir.txt

#for i in $(cat wind2Dir.txt); do if (( $(echo "$i > 342.5" | bc -l) || $(echo "$i < 22.5" | bc -l))); then echo "N">>wind3Dir.txt; fi; done
#for i in $(cat wind2Dir.txt); do if (( $(echo "$i >= 22.5" | bc -l) || $(echo "$i < 67.5" | bc -l))); then echo "NE">>wind3Dir.txt; fi; done
#for i in $(cat wind2Dir.txt); do if (( $(echo "$i >= 67.5" | bc -l) || $(echo "$i < 112.5" | bc -l))); then echo "E">>wind3Dir.txt; fi; done
#for i in $(cat wind2Dir.txt); do if (( $(echo "$i >= 112.5" | bc -l) || $(echo "$i < 157.5" | bc -l))); then echo "SE">>wind3Dir.txt; fi; done
#for i in $(cat wind2Dir.txt); do if (( $(echo "$i >= 157.5" | bc -l) || $(echo "$i < 202.5" | bc -l))); then echo "S">>wind3Dir.txt; fi; done
#for i in $(cat wind2Dir.txt); do if (( $(echo "$i >= 202.5" | bc -l) || $(echo "$i < 247.5" | bc -l))); then echo "SW">>wind3Dir.txt; fi; done
#for i in $(cat wind2Dir.txt); do if (( $(echo "$i >= 247.5" | bc -l) || $(echo "$i < 292.5" | bc -l))); then echo "W">>wind3Dir.txt; fi; done
#for i in $(cat wind2Dir.txt); do if (( $(echo "$i >= 292.5" | bc -l) || $(echo "$i < 337.5" | bc -l))); then echo "NW">>wind3Dir.txt; fi; done

paste -d';' colonne.txt data.txt orario.txt temp2.txt rh2.txt pres2.txt geop5002.txt cloudCover2.txt rainRate2.txt rainAcc2.txt cape2.txt li2.txt wind2.txt wind2Dir.txt> prev.csv
# manipolo le prime due righe in modo da avere intestazione e righe di dati nell'ordine corretto
# (elimino il problema dell'intestazione e della prima riga posta allo stesso livello)
# ho eliminato le colonne uwind2.txt vwind2.txt

riga2=$(cat prev.csv | head -1)
riga1=${riga2:0:105}
riga2=${riga2:105:${#riga2}}

# inserisco le prime due righe e rimuovo le vecchie due righe che erano divenute la terza e la quarta (le elimino)
sed -i "1 i $riga1" prev.csv
sed -i "2 i $riga2" prev.csv
sed -i '3 d' prev.csv

tabs 2
INPUT=prev.csv
IFS=';'
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 105; }
while read vv data orario temp hum uwind vwind press geop500 cloud rainRate rainAcc cape li wind windDir
do
  echo -e "$vv $data $orario $temp $hum $press $geop500 $cloud $rainRate $rainAcc $cape $li $windp $windDir"
done < $INPUT
IFS=$OLDIFS
# ho eliminato $uwind $vwind

# take only first 21 rows
cat prev.csv | head -n 21 > tmp.txt
# eliminate the first column contains ';' char
cut -d';' -f2-16 tmp.txt > prev.ods
# remove temporary file
rm tmp.txt
