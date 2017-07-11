#!/bin/bash

# ********************************************************************************************************************
# Creator: Remo Tomasi
# extract v0.1.1 11-02-2016
# extract v0.1.2 14-09-2016
# extract v0.1.3 12-11-2016
# extract v0.1.4 02-01-2017
# extract v0.1.5 17-04-2017
# extract v0.1.6 19-04-2017
# extract v0.2.0 12-05-2017
# extract v0.2.5 05-07-2017
# extract v0.2.6 11-07-2017
#
# send GRIB:40.02N,40N,18.15E,18.17E|1,1|0,12,24,36,48,60,72,84,96,108,120|TMP,CAPE,PRESS,RH,APCP,HGT,WIND,LFTX,RAIN
# send GRIB:40N,40N,18.2E,18.2E|1,1|0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96,102,108,114,120,126,132,138,144|TMP,CAPE,PRESS,RH,APCP,HGT,WIND,LFTX,RAIN,TCDC
# send GFS:40.35,40.35N,18.15E,18.15E|1,1|0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96,102,108,114,120,126,132,138,144|TMP,CAPE,PRESS,RH,APCP,HGT,WIND,LFTX,RAIN,TCDC,ABSV
#
# info
# APCP: accumulo precipitazioni
# HGT: geopotenziale (gpm 500 hPa)
# LFTX: lifted index
# RAIN: pioggia mm/h
# ABSV: absolute vorticity n^(-5)/sec
#
# per estrarre
# PRESS → PRMSL
# WIND → UGRD
# WIND → VGRD
# RAIN → PRATE

# grep -A1 "5 5" --> grep -A1 "3 5" o "5 5"
# grep -A1 "361 1" --> grep -A1 "361 1" o "361 1"

if [ $# -eq 0 ]; then
  echo "Inserisci il nome del file grb"
  exit 1
fi

rm prev.csv data.txt orario.txt temp2.txt rh2.txt uwind2.txt vwind2.txt pres.txt pres2.txt geop5002.txt cloudCover.txt cloudCover2.txt rainAcc2.txt cape2.txt
rm rainRate2.txt li2.txt wind2.txt wind2Dir.txt wind3Dir.txt dp.txt fog.txt abs.txt abs2.txt

touch orario.txt data.txt temp2.txt rh2.txt uwind2.txt vwind2.txt pres.txt pres2.txt geop5002.txt cloudCover.txt cloudCover2.txt rainAcc2.txt cape2.txt
touch rainRate2.txt li2.txt wind2.txt wind2Dir.txt wind3Dir.txt

echo -n ";" >> data.txt

#echo '\n' | gawk '{printf "\n"}' > temp.txt
./wgrib -s $1 | grep ":TMP:" | ./wgrib -i -text $1 -o out.txt	#sono in gradi Kelvin (occorre sottrarre 273)

# in base all'orario di download del file GRIB stabilisco la data delle previsioni
lastByteData=$(./wgrib -s $1 | cut -d':' -f3 | cut -d ' ' -f1 | head -23 | cut -d'=' -f2 | tail -c 3)
if [ $lastByteData -ne 18 ]
  then day=1
else
  day=0
fi
#echo "ciao $day $lastByteData"
date +%d/%m/%Y -d "+$day days" >> data.txt
((day++))
echo -e " \n \n " >>  data.txt
date +%d/%m/%Y -d "+$day days" >> data.txt
((day++))
echo -e " \n \n " >>  data.txt
date +%d/%m/%Y -d "+$day days" >> data.txt
((day++))
echo -e " \n \n " >>  data.txt
date +%d/%m/%Y -d "+$day days" >> data.txt
((day++))
echo -e " \n \n " >>  data.txt
date +%d/%m/%Y -d "+$day days" >> data.txt
echo -e " \n \n " >>  data.txt
#echo "ciao $day"
awk '{print $1,$2,$3,$4,$5}' OFS="|" data.txt > data.xls
orario=$(./wgrib -s $1 | cut -d':' -f6 | cut -d ' ' -f1 | head -23)
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > temp.txt
#echo ";" + $data ";" > temp.txt
for i in $(cat temp.txt); do $(echo $data >> data.txt); done
echo $orario | tr ' ' '\n' | head -n 21 > orario.txt
for i in $(cat temp.txt); do $(echo ${i} | gawk '{printf "%.0f\n",$1 -273.15}' >> temp2.txt); done
./wgrib -s $1 | grep ":CAPE:" | ./wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > cape.txt
for i in $(cat cape.txt); do $(echo ${i} | gawk '{printf "%.0f\n",$1}' >> cape2.txt); done
./wgrib -s $1 | grep ":PRMSL:" | ./wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--'  | tail -n 21 > pres.txt
for i in $(cat pres.txt); do $(echo ${i} | gawk '{printf "%.0f\n",$1/100}' >> pres2.txt); done
./wgrib -s $1 | grep ":RH:" | ./wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > rh.txt
for i in $(cat rh.txt); do $(echo ${i} | gawk '{printf "%.0f\n",$1}' >> rh2.txt); done
./wgrib -s $1 | grep ":APCP:" | ./wgrib -i -text $1 -o out.txt	#sono mm pioggia accumulata
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | head -n 21 > rainAcc.txt
for i in $(cat rainAcc.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1}' >> rainAcc2.txt); done
./wgrib -s $1 | grep ":HGT:" | ./wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > geop500.txt
for i in $(cat geop500.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1}' >> geop5002.txt); done
./wgrib -s $1 | grep ":UGRD:" | ./wgrib -i -text $1 -o out.txt	#sono in m/s
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > uwind.txt
for i in $(cat uwind.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1*3.6}' >> uwind2.txt); done
./wgrib -s $1 | grep ":VGRD:" | ./wgrib -i -text $1 -o out.txt	#sono in m/s
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > vwind.txt
for i in $(cat vwind.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1*3.6}' >> vwind2.txt); done
./wgrib -s $1 | grep ":LFTX:" | ./wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > li.txt
for i in $(cat li.txt); do $(echo ${i} >> li2.txt); done
./wgrib -s $1 | grep ":PRATE:" | ./wgrib -i -text $1 -o out.txt	# si riferisce alla raffica
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | head -n 21 > rainRate.txt
for i in $(cat rainRate.txt); do $(echo ${i} | gawk '{printf "%.4f\n",$1*3600}' >> rainRate2.txt); done # mm/h
./wgrib -s $1 | grep ":TCDC:" | ./wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > cloudCover.txt
for i in $(cat cloudCover.txt); do $(echo ${i} | gawk '{printf "%.0f\n",$1}' >> cloudCover2.txt); done
./wgrib -s $1 | grep ":ABSV:" | ./wgrib -i -text $1 -o out.txt # Absolute vorticity at 500mb
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | head -n 21 > abs.txt
for i in $(cat abs.txt); do $(echo ${i} | gawk '{printf "%.1f\n",$1*100000}' >> abs2.txt); done

paste uwind2.txt vwind2.txt | gawk '{print (sqrt($1*$1 + $2*$2)), $3}' | xargs printf '%.0f\n' >> wind2.txt                             # calcolo potenza del vento
paste uwind2.txt vwind2.txt | gawk '{print (atan2($1,$2)*57.3+180), $3}' >> wind2Dir.txt                                                # calcolo direzione del vento in gradi sessagesimali
paste rh2.txt temp2.txt | gawk '{print (sqrt(sqrt(sqrt($1 / 100)))*(112 + 0.9*$2)+0.1*$2-112), $3}' | xargs printf '%.0f\n' >> dp.txt   # calcolo potenza del vento
paste temp2.txt dp.txt | gawk '{print ($1 - $2), $3}' | xargs printf '%.0f\n' >> fog.txt                                                # calcolo potenza del vento


rm wind3Dir.txt
touch wind4Dir.txt

for i in $(cat wind2Dir.txt)
  do
    if (( $(echo "$i > 335" |bc -l) || $(echo "$i <= 25" |bc -l) ))
      then echo -e "<img src="icons/n.png"></img>">>wind3Dir.txt                  #Nord (Tramontana)
    elif (( $(echo "$i > 25" |bc -l) && $(echo "$i <= 65" |bc -l) ))
      then echo "<img src="icons/ne.png"></img>">>wind3Dir.txt                    #Nord-Est (Grecale)
    elif (( $(echo "$i > 65" |bc -l) && $(echo "$i <= 115" |bc -l) ))
      then echo "<img src="icons/e.png"></img>">>wind3Dir.txt                     #Est (Levante)
    elif (( $(echo "$i > 115" |bc -l) && $(echo "$i <= 155" |bc -l) ))
      then echo "<img src="icons/se.png"></img>">>wind3Dir.txt                    #Sud-Est (Scirocco)
    elif (( $(echo "$i > 155" |bc -l) && $(echo "$i <= 205" |bc -l) ))
      then echo "<img src="icons/s.png"></img>">>wind3Dir.txt                     #Sud (Ostro)
    elif (( $(echo "$i > 205" |bc -l) && $(echo "$i <= 245" |bc -l) ))
      then echo "<img src="icons/sw.png"></img>">>wind3Dir.txt                    #Sud-Ovest (Libeccio)
    elif (( $(echo "$i > 245" |bc -l) && $(echo "$i <= 295" |bc -l) ))
      then echo "<img src="icons/w.png"></img>">>wind3Dir.txt                     #Ovest (Ponente)
    elif (( $(echo "$i > 295" |bc -l) && $(echo "$i <= 335" |bc -l) ))
      then echo "<img src="icons/nw.png"></img>">>wind3Dir.txt                    #Nord-Ovest (Maestrale)
    fi
done

rm wind4Dir.txt
touch wind4Dir.txt

for i in $(cat wind2.txt)
  do
    if (( $(echo "$i == 0" |bc -l) || $(echo "$i < 1" |bc -l) ))
      then echo "Calma">>wind4Dir.txt
    elif (( $(echo "$i >= 1" |bc -l) && $(echo "$i <= 5" |bc -l) ))
      then echo "Bava di vento">>wind4Dir.txt
    elif (( $(echo "$i >= 6" |bc -l) && $(echo "$i <= 11" |bc -l) ))
      then echo "Brezza leggera">>wind4Dir.txt
    elif (( $(echo "$i >= 12" |bc -l) && $(echo "$i <= 19" |bc -l) ))
      then echo "Brezza tesa">>wind4Dir.txt
    elif (( $(echo "$i >= 20" |bc -l) && $(echo "$i <= 28" |bc -l) ))
      then echo "Vento moderato">>wind4Dir.txt
    elif (( $(echo "$i >= 29" |bc -l) && $(echo "$i <= 38" |bc -l) ))
      then echo "Vento teso">>wind4Dir.txt
    elif (( $(echo "$i >= 39" |bc -l) && $(echo "$i <= 49" |bc -l) ))
      then echo "Vento fresco">>wind4Dir.txt
    elif (( $(echo "$i >= 50" |bc -l) && $(echo "$i <= 61" |bc -l) ))
      then echo "Vento forte">>wind4Dir.txt
    elif (( $(echo "$i >= 62" |bc -l) && $(echo "$i <= 74" |bc -l) ))
      then echo "Burrasca">>wind4Dir.txt
    elif (( $(echo "$i >= 75" |bc -l) && $(echo "$i <= 88" |bc -l) ))
      then echo "Burrasca forte">>wind4Dir.txt
    elif (( $(echo "$i >= 89" |bc -l) && $(echo "$i <= 102" |bc -l) ))
      then echo "Tempesta">>wind4Dir.txt
    elif (( $(echo "$i >= 103" |bc -l) && $(echo "$i <= 117" |bc -l) ))
      then echo "Fortunale">>wind4Dir.txt
    elif (( $(echo "$i >= 135" |bc -l) && $(echo "$i <= 176" |bc -l) ))
      then echo "Uragano categoria 1">>wind4Dir.txt
    elif (( $(echo "$i >= 177" |bc -l) && $(echo "$i <= 204" |bc -l) ))
      then echo "Uragano categoria 2">>wind4Dir.txt
    elif (( $(echo "$i >= 205" |bc -l) && $(echo "$i <= 241" |bc -l) ))
      then echo "Uragano categoria 3">>wind4Dir.txt
    elif (( $(echo "$i > 242" |bc -l) && $(echo "$i <= 287" |bc -l) ))
      then echo "Uragano categoria 4">>wind4Dir.txt
    elif (( $(echo "$i >= 288" |bc -l) ))
      then echo "Uragano categoria 5">>wind4Dir.txt
    fi
done

rm cloudCover3.txt
touch cloudCover3.txt

for i in $(cat cloudCover.txt)
  do
    if (( $(echo "$i >= 0" |bc -l) && $(echo "$i <= 5" |bc -l) ))
      then echo "<img src="icons/sun.png"></img>">>cloudCover3.txt
    elif (( $(echo "$i > 5" |bc -l) && $(echo "$i <= 10" |bc -l) ))
      then echo "<img src="icons/sun_and_cloud.png"></img>">>cloudCover3.txt
    elif (( $(echo "$i > 10" |bc -l) && $(echo "$i <= 30" |bc -l) ))
      then echo "<img src="icons/bitCloudy.png"></img>">>cloudCover3.txt
    elif (( $(echo "$i > 30" |bc -l) && $(echo "$i <= 60" |bc -l) ))
      then echo "<img src="icons/cloudy.png"></img>">>cloudCover3.txt
    elif (( $(echo "$i > 60" |bc -l) && $(echo "$i <= 85" |bc -l) ))
      then echo "<img src="icons/veryCloudy.png"></img>">>cloudCover3.txt
    elif (( $(echo "$i > 85" |bc -l) && $(echo "$i <= 100" |bc -l) ))
      then echo "<img src="icons/covered.png"></img>">>cloudCover3.txt
    fi
done

rm rainRate3.txt
touch rainRate3.txt

for i in $(cat rainRate2.txt)
  do
    if (( $(echo "$i > 0.005" | bc -l) )) && (( $(echo "$i <= 0.05" | bc -l) ))
      then  echo "Molto debole">>rainRate3.txt
    elif (( $(echo "$i > 0.05" | bc -l) )) && (( $(echo "$i < 2.5" | bc -l) ))
      then  echo "<img src="icons/veryLightRain.png"></img>">>rainRate3.txt
    elif (( $(echo "$i >= 2.5" | bc) )) && (( $(echo "$i < 10" | bc) ))
      then echo "<img src="icons/lightRain.png"></img>">>rainRate3.txt
    elif (( $(echo "$i >= 10" | bc) )) && (( $(echo "$i < 50" | bc) ))
      then echo "<img src="icons/rain.png"></img>">>rainRate3.txt
    elif (( $(echo "$i >= 50" | bc) ))
      then echo "<img src="icons/heavyRain.png"></img>">>rainRate3.txt
    else
      echo "-">>rainRate3.txt
    fi
done

rm nebbia.txt
touch nebbia.txt

for i in $(cat fog.txt)
  do
    if (( $(echo "$i >= 3" | bc) )) && (( $(echo "$i < 5" | bc) ))
      then  echo "<img src="icons/f2.png"></img>">>nebbia.txt
    elif (( $(echo "$i >= 2" | bc) )) && (( $(echo "$i < 3" | bc) ))
      then  echo "<img src="icons/f3.png"></img>">>nebbia.txt
    elif (( $(echo "$i < 2" | bc) ))
      then  echo "<img src="icons/f4.png"></img>">>nebbia.txt
    elif (( $(echo "$i >= 5" | bc -l) ))
      then  echo "-">>nebbia.txt
    fi
done

paste -d';' colonne.txt data.txt orario2.txt temp2.txt rh2.txt pres2.txt geop5002.txt cloudCover2.txt cloudCover3.txt rainRate2.txt rainRate3.txt rainAcc2.txt cape2.txt li2.txt wind2.txt wind3Dir.txt wind4Dir.txt dp.txt fog.txt nebbia.txt abs2.txt> prev.csv

# manipolo le prime due righe in modo da avere intestazione e righe di dati nell'ordine corretto
# (elimino il problema dell'intestazione e della prima riga posta allo stesso livello)
# ho eliminato le colonne uwind2.txt vwind2.txt
riga2=$(cat prev.csv | head -1)
riga1=${riga2:0:137}
riga2=${riga2:137:${#riga2}}

# inserisco le prime due righe e rimuovo le vecchie due righe che erano divenute la terza e la quarta (le elimino)
sed -i "1 i $riga1" prev.csv
sed -i "2 i $riga2" prev.csv
sed -i '3 d' prev.csv

# tabs 2
# INPUT=prev.csv
# IFS=';'
# [ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 106; }
# while read data temp hum uwind vwind press geop500 cloud rainRate rainAcc cape li wind windDir
# do
#   echo -e "$data $temp $hum $press $geop500 $cloud $rainRate $rainAcc $cape $li $windp $windDir"
# done < $INPUT
# IFS=$OLDIFS
# ho eliminato $uwind $vwind

# take only first 21 rows
cat prev.csv | head -n 13 > tmp.txt
# eliminate the first column contains ';' char
#cut -d';' -f1-13 tmp.txt > prev.xls
cut -d';' -f1-22 tmp.txt > prev.xls
cut -d';' -f1,2,3,4,5,9,11,16,17,20 tmp.txt > prev2.xls
sed -i 's/Temp/Temperatura (°C)/g' prev2.xls
sed -i 's/Humidity/Umidita (%)/g' prev2.xls
sed -i 's/CloudCover/Nuvolosita/g' prev2.xls
sed -i 's/RainRate/Pioggia (intensita)/g' prev2.xls
sed -i 's/RainAcc/Pioggia (mm)/g' prev2.xls
sed -i 's/WindP/Vento (km-h)/g' prev2.xls
sed -i 's/WindDir/Vento (direzione)/g' prev2.xls
sed -i 's/WindI/Vento (intensita)/g' prev2.xls
sed -i 's/Foggy/Nebbia (Intensita)/g' prev2.xls

# remove temporary file
#rm tmp.txt

# conversioni nei vari formati
./conv2htm.sh prev.xls > prev.html
sed -i 's/nowrap >/nowrap ><h2>/g' prev.html
sed -i 's/td>/td><\/h2>/g' prev.html
#sed -i 's/align/style="background-color:powderblue;" align/g' prev.html
html2ps prev.html > prev.ps
convert -density 300 -colorspace RGB -alpha remove -trim prev.ps -quality 100 prev.png #-background yellow

./conv2htm.sh prev2.xls > prev2.html
sed -i 's/nowrap >/nowrap ><h2>/g' prev2.html
sed -i 's/td>/td><\/h2>/g' prev2.html
#sed -i 's/align/style="background-color:powderblue;" align/g' prev2.html
html2ps prev2.html > prev2.ps
convert -density 300 -colorspace RGB -alpha remove -trim prev2.ps -quality 100 prev2.png
