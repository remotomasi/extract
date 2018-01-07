#!/bin/bash

# ********************************************************************************************************************
# Creator: Remo Tomasi
#
# Examples of string request to send to query@saildocs.com
# send GRIB:40.02N,40N,18.15E,18.17E|1,1|0,12,24,36,48,60,72,84,96,108,120|TMP,CAPE,PRESS,RH,APCP,HGT,WIND,LFTX,RAIN
# send GRIB:40N,40N,18.2E,18.2E|1,1|0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96,102,108,114,120,126,132,138,144|TMP,CAPE,PRESS,RH,APCP,HGT,WIND,LFTX,RAIN,TCDC
# send GFS:40.35,40.35N,18.15E,18.15E|1,1|0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96,102,108,114,120,126,132,138,144|TMP,CAPE,PRESS,RH,APCP,HGT,WIND,LFTX,RAIN,TCDC,ABSV
#
# info
# APCP: precipitations accumulated
# HGT: geopotential (gpm 500 hPa)
# LFTX: lifted index
# RAIN: rain mm/h
# ABSV: absolute vorticity n^(-5)/sec
#
# to extract
# PRESS → PRMSL
# WIND → UGRD
# WIND → VGRD
# RAIN → PRATE

# grep -A1 "5 5" --> grep -A1 "3 5" o "5 5"
# grep -A1 "361 1" --> grep -A1 "361 1" o "361 1"

if [ $# -eq 0 ]; then
  echo "Insert the GRIB file name"
  exit 1
fi

touch orario.txt data.txt temp2.txt temp3.txt rh2.txt rh3.txt uwind2.txt vwind2.txt pres.txt pres2.txt geop5002.txt cloudCover.txt cloudCover2.txt rainAcc2.txt cape2.txt
touch rainRate2.txt li2.txt wind2.txt wind2Dir.txt wind3Dir.txt abs.txt abs2.txt

echo -n ";" >> data.txt

# Extraction of all datas from the GRIB file
./wgrib -s $1 | grep ":TMP:" | ./wgrib -i -text $1 -o out.txt # sono in gradi Kelvin (occorre sottrarre 273)

# according to the downloading time of the GRIB file I estabilish the forecasts
HOUR=$(./wgrib -s $1 | head -1 | cut -c13-14) # obtain hour of the run from the GRIB file
if [ $HOUR = "00" ] || [ $HOUR = "06" ] || [ $HOUR = "12" ]                     # to know which is the starting day
  then day=1
else
  day=0
fi

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

# Insertion of DATE, TIME to temp.txt
awk '{print $1,$2,$3,$4,$5}' OFS="|" data.txt > data.xls
orario=$(./wgrib -s $1 | cut -d':' -f6 | cut -d ' ' -f1 | head -23)
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > temp.txt

# Extraction of singular datas
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
./wgrib -s $1 | grep ":APCP:" | ./wgrib -i -text $1 -o out.txt	# mm of accumulated rain
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | head -n 21 > rainAcc.txt
for i in $(cat rainAcc.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1}' >> rainAcc2.txt); done
./wgrib -s $1 | grep ":HGT:" | ./wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > geop500.txt
for i in $(cat geop500.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1}' >> geop5002.txt); done
./wgrib -s $1 | grep ":UGRD:" | ./wgrib -i -text $1 -o out.txt	# m/s
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > uwind.txt
for i in $(cat uwind.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1*3.6}' >> uwind2.txt); done
./wgrib -s $1 | grep ":VGRD:" | ./wgrib -i -text $1 -o out.txt	# m/s
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > vwind.txt
for i in $(cat vwind.txt); do $(echo ${i} | gawk '{printf "%.2f\n",$1*3.6}' >> vwind2.txt); done
./wgrib -s $1 | grep ":LFTX:" | ./wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > li.txt
for i in $(cat li.txt); do $(echo ${i} >> li2.txt); done
./wgrib -s $1 | grep ":PRATE:" | ./wgrib -i -text $1 -o out.txt	# it refers to the gust
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | head -n 21 > rainRate.txt
for i in $(cat rainRate.txt); do $(echo ${i} | gawk '{printf "%.4f\n",$1*3600}' >> rainRate2.txt); done # mm/h
./wgrib -s $1 | grep ":TCDC:" | ./wgrib -i -text $1 -o out.txt
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | tail -n 21 > cloudCover.txt
for i in $(cat cloudCover.txt); do $(echo ${i} | gawk '{printf "%.0f\n",$1}' >> cloudCover2.txt); done
./wgrib -s $1 | grep ":ABSV:" | ./wgrib -i -text $1 -o out.txt # Absolute vorticity at 500mb
cat out.txt | grep -A1 "361 1" | grep -v "361 1" | grep -ve '--' | head -n 21 > abs.txt
for i in $(cat abs.txt); do $(echo ${i} | gawk '{printf "%.1f\n",$1*100000}' >> abs2.txt); done

# Manipulation of some datas
paste uwind2.txt vwind2.txt | gawk '{print (sqrt($1*$1 + $2*$2)), $3}' | xargs printf '%.0f\n' >> wind2.txt                             # calculation of wind power
paste uwind2.txt vwind2.txt | gawk '{print (atan2($1,$2)*57.3+180), $3}' >> wind2Dir.txt                                                # calculation of wind direction in sexagesimal degree
paste rh2.txt temp2.txt | gawk '{print (sqrt(sqrt(sqrt($1 / 100)))*(112 + 0.9*$2)+0.1*$2-112), $3}' | xargs printf '%.0f\n' >> dp.txt   # calculation of the wind power
paste temp2.txt dp.txt | gawk '{print ($1 - $2), $3}' | xargs printf '%.0f\n' >> fog.txt                                                # calculation of the wind power

# Temperatures
for i in $(cat temp2.txt)
  do
    if (( $(echo "$i > -10" |bc -l) && $(echo "$i <= -5" |bc -l) ))
      then echo -e "<p style=\"background-color: navy\">$i</p>">>temp3.txt
    elif (( $(echo "$i > -5" |bc -l) && $(echo "$i <= 0" |bc -l) ))
      then echo "<p style=\"background-color: blue\">$i</p>">>temp3.txt
    elif (( $(echo "$i > 0" |bc -l) && $(echo "$i <= 5" |bc -l) ))
      then echo "<p style=\"background-color: teal\">$i</p>">>temp3.txt
    elif (( $(echo "$i > 5" |bc -l) && $(echo "$i <= 10" |bc -l) ))
      then echo "<p style=\"background-color: aqua\">$i</p>">>temp3.txt
    elif (( $(echo "$i > 10" |bc -l) && $(echo "$i <= 15" |bc -l) ))
      then echo "<p style=\"background-color: lime\">$i</p>">>temp3.txt
    elif (( $(echo "$i > 15" |bc -l) && $(echo "$i <= 20" |bc -l) ))
      then echo "<p style=\"background-color: yellow\">$i</p>">>temp3.txt
    elif (( $(echo "$i > 20" |bc -l) && $(echo "$i <= 25" |bc -l) ))
      then echo "<p style=\"background-color: orange\">$i</p>">>temp3.txt
    elif (( $(echo "$i > 25" |bc -l) && $(echo "$i <= 30" |bc -l) ))
      then echo "<p style=\"background-color: red\">$i</p>">>temp3.txt
    elif (( $(echo "$i > 30" |bc -l) && $(echo "$i <= 35" |bc -l) ))
      then echo "<p style=\"background-color: maroon\">$i</p>">>temp3.txt
    elif (( $(echo "$i > 35" |bc -l) && $(echo "$i <= 40" |bc -l) ))
      then echo "<p style=\"background-color: fuchsia\">$i</p>">>temp3.txt
    elif (( $(echo "$i > 40" |bc -l) && $(echo "$i <= 45" |bc -l) ))
      then echo "<p style=\"background-color: purple\">$i</p>">>temp3.txt
    fi
done

# Humidity
for i in $(cat rh2.txt)
  do
    if (( $(echo "$i >= 0" |bc -l) && $(echo "$i <= 20" |bc -l) ))
      then echo -e "<p style=\"background-color: LightCyan\">$i</p>">>rh3.txt
    elif (( $(echo "$i > 20" |bc -l) && $(echo "$i <= 40" |bc -l) ))
      then echo "<p style=\"background-color: Lavender\">$i</p>">>rh3.txt
    elif (( $(echo "$i > 40" |bc -l) && $(echo "$i <= 60" |bc -l) ))
      then echo "<p style=\"background-color: LightBlue\">$i</p>">>rh3.txt
    elif (( $(echo "$i > 60" |bc -l) && $(echo "$i <= 80" |bc -l) ))
      then echo "<p style=\"background-color: DeepSkyBlue\">$i</p>">>rh3.txt
    elif (( $(echo "$i > 80" |bc -l) && $(echo "$i <= 100" |bc -l) ))
      then echo "<p style=\"background-color: Blue\">$i</p>">>rh3.txt
    fi
done

# Wind direction
touch wind5Dir.txt

for i in $(cat wind2Dir.txt)
  do
    if (( $(echo "$i > 335" |bc -l) || $(echo "$i <= 25" |bc -l) ))
      then echo -e "N">>wind5Dir.txt                #North (Tramontana)
    elif (( $(echo "$i > 25" |bc -l) && $(echo "$i <= 65" |bc -l) ))
      then echo "NE">>wind5Dir.txt                  #North-East (Grecale)
    elif (( $(echo "$i > 65" |bc -l) && $(echo "$i <= 115" |bc -l) ))
      then echo "E">>wind5Dir.txt                   #East (Levante)
    elif (( $(echo "$i > 115" |bc -l) && $(echo "$i <= 155" |bc -l) ))
      then echo "SE">>wind5Dir.txt                  #South-East (Scirocco)
    elif (( $(echo "$i > 155" |bc -l) && $(echo "$i <= 205" |bc -l) ))
      then echo "S">>wind5Dir.txt                   #South (Ostro)
    elif (( $(echo "$i > 205" |bc -l) && $(echo "$i <= 245" |bc -l) ))
      then echo "SW">>wind5Dir.txt                  #South-West (Libeccio)
    elif (( $(echo "$i > 245" |bc -l) && $(echo "$i <= 295" |bc -l) ))
      then echo "W">>wind5Dir.txt                   #West (Ponente)
    elif (( $(echo "$i > 295" |bc -l) && $(echo "$i <= 335" |bc -l) ))
      then echo "NW">>wind5Dir.txt                  #North-West (Maestrale)
    fi
done

# Wind direction icon
rm wind3Dir.txt
touch wind4Dir.txt

for i in $(cat wind2Dir.txt)
  do
    if (( $(echo "$i > 335" |bc -l) || $(echo "$i <= 25" |bc -l) ))
      then echo -e "<img src="icons/n.png"></img>">>wind3Dir.txt                #North (Tramontana)
    elif (( $(echo "$i > 25" |bc -l) && $(echo "$i <= 65" |bc -l) ))
      then echo "<img src="icons/ne.png"></img>">>wind3Dir.txt                  #North-East (Grecale)
    elif (( $(echo "$i > 65" |bc -l) && $(echo "$i <= 115" |bc -l) ))
      then echo "<img src="icons/e.png"></img>">>wind3Dir.txt                   #East (Levante)
    elif (( $(echo "$i > 115" |bc -l) && $(echo "$i <= 155" |bc -l) ))
      then echo "<img src="icons/se.png"></img>">>wind3Dir.txt                  #South-East (Scirocco)
    elif (( $(echo "$i > 155" |bc -l) && $(echo "$i <= 205" |bc -l) ))
      then echo "<img src="icons/s.png"></img>">>wind3Dir.txt                   #South (Ostro)
    elif (( $(echo "$i > 205" |bc -l) && $(echo "$i <= 245" |bc -l) ))
      then echo "<img src="icons/sw.png"></img>">>wind3Dir.txt                  #South-West (Libeccio)
    elif (( $(echo "$i > 245" |bc -l) && $(echo "$i <= 295" |bc -l) ))
      then echo "<img src="icons/w.png"></img>">>wind3Dir.txt                   #West (Ponente)
    elif (( $(echo "$i > 295" |bc -l) && $(echo "$i <= 335" |bc -l) ))
      then echo "<img src="icons/nw.png"></img>">>wind3Dir.txt                  #North-West (Maestrale)
    fi
done

# Wind power
rm wind4Dir.txt
touch wind4Dir.txt

for i in $(cat wind2.txt)
  do
    if (( $(echo "$i == 0" |bc -l) || $(echo "$i < 1" |bc -l) ))
      then echo -e "<p style=\"background-color: #ffffff\">Calma<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 1" |bc -l) && $(echo "$i <= 5" |bc -l) ))
      then echo -e "<p style=\"background-color: #e6ffe6\">Bava di vento<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 6" |bc -l) && $(echo "$i <= 11" |bc -l) ))
      then echo -e "<p style=\"background-color: #ccffcc\">Brezza leggera<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 12" |bc -l) && $(echo "$i <= 19" |bc -l) ))
      then echo -e "<p style=\"background-color: #b3ffb3\">Brezza tesa<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 20" |bc -l) && $(echo "$i <= 28" |bc -l) ))
      then echo -e "<p style=\"background-color: #99ff99\">Vento moderato<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 29" |bc -l) && $(echo "$i <= 38" |bc -l) ))
      then echo -e "<p style=\"background-color: #80ff80\">Vento teso<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 39" |bc -l) && $(echo "$i <= 49" |bc -l) ))
      then echo -e "<p style=\"background-color: #66ff66\">Vento fresco<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 50" |bc -l) && $(echo "$i <= 61" |bc -l) ))
      then echo -e "<p style=\"background-color: #4dff4d\">Vento forte<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 62" |bc -l) && $(echo "$i <= 74" |bc -l) ))
      then echo -e "<p style=\"background-color: #33ff33\">Burrasca<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 75" |bc -l) && $(echo "$i <= 88" |bc -l) ))
      then echo -e "<p style=\"background-color: #1aff1a\">Burrasca forte<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 89" |bc -l) && $(echo "$i <= 102" |bc -l) ))
      then echo -e "<p style=\"background-color: #00ff00\">Tempesta<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 103" |bc -l) && $(echo "$i <= 117" |bc -l) ))
      then echo -e "<p style=\"background-color: #00e600\">Fortunale<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 135" |bc -l) && $(echo "$i <= 176" |bc -l) ))
      then echo -e "<p style=\"background-color: #00cc00\">Uragano categoria 1<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 177" |bc -l) && $(echo "$i <= 204" |bc -l) ))
      then echo -e "<p style=\"background-color: #00b300\">Uragano categoria 2<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 205" |bc -l) && $(echo "$i <= 241" |bc -l) ))
      then echo -e "<p style=\"background-color: #009900\">Uragano categoria 3<p>" >>wind4Dir.txt
    elif (( $(echo "$i > 242" |bc -l) && $(echo "$i <= 287" |bc -l) ))
      then echo -e "<p style=\"background-color: #008000\">Uragano categoria 4<p>" >>wind4Dir.txt
    elif (( $(echo "$i >= 288" |bc -l) ))
      then echo -e "<p style=\"background-color: #006600\">Uragano categoria 5<p>" >>wind4Dir.txt
    fi
done

# Cloud cover
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

# Rain rate
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

# Fog
touch nebbia.txt

for i in $(cat fog.txt)
  do
    if (( $(echo "$i >= 3" | bc) )) && (( $(echo "$i < 5" | bc) ))
      then  echo "<img src="icons/fog2.png"></img>">>nebbia.txt
    elif (( $(echo "$i >= 2" | bc) )) && (( $(echo "$i < 3" | bc) ))
      then  echo "<img src="icons/fog3.png"></img>">>nebbia.txt
    elif (( $(echo "$i < 2" | bc) ))
      then  echo "<img src="icons/fog4.png"></img>">>nebbia.txt
    elif (( $(echo "$i >= 5" | bc -l) ))
      then  echo "-">>nebbia.txt
    fi
done

# Dew Point
for i in $(cat dp.txt)
  do
    if (( $(echo "$i <= 10" |bc -l) ))
      then echo -e "<p style=\"background-color: LightBlue\">Secco</p>">>dp2.txt
    elif (( $(echo "$i > 10" |bc -l) && $(echo "$i <= 12" |bc -l) ))
      then echo "<p style=\"background-color: #01A9DB\">Molto confortevole</p>">>dp2.txt
    elif (( $(echo "$i > 12" |bc -l) && $(echo "$i <= 15" |bc -l) ))
      then echo "<p style=\"background-color: green\">Confortevole</p>">>dp2.txt
    elif (( $(echo "$i > 15" |bc -l) && $(echo "$i <= 18" |bc -l) ))
      then echo "<p style=\"background-color: yellow\">Leggermente umido</p>">>dp2.txt
    elif (( $(echo "$i > 18" |bc -l) && $(echo "$i <= 21" |bc -l) ))
      then echo "<p style=\"background-color: orange\">Umido</p>">>dp2.txt
    elif (( $(echo "$i > 21" |bc -l) && $(echo "$i <= 24" |bc -l) ))
      then echo "<p style=\"background-color: #ff8000\">Molto umido</p>">>dp2.txt
    elif (( $(echo "$i > 24" |bc -l) && $(echo "$i <= 26" |bc -l) ))
      then echo "<p style=\"background-color: red\">Disagio</p>">>dp2.txt
    elif (( $(echo "$i > 26" |bc -l) ))
      then echo "<p style=\"background-color: maroon\">Aria opprimente</p>">>dp2.txt
    fi
done

# Union with columns
paste -d';' column.txt data.txt orario2.txt temp2.txt rh2.txt pres2.txt geop5002.txt cloudCover2.txt rainRate2.txt rainAcc2.txt cape2.txt li2.txt wind2.txt wind5Dir.txt dp.txt fog.txt abs2.txt> prevOrigin.csv
paste -d';' colonne.txt data.txt orario2.txt temp3.txt rh3.txt pres2.txt geop5002.txt cloudCover2.txt cloudCover3.txt rainRate2.txt rainRate3.txt rainAcc2.txt cape2.txt li2.txt wind2.txt wind3Dir.txt wind4Dir.txt dp.txt dp2.txt fog.txt nebbia.txt abs2.txt> prev.csv

# actual data
now=$(./wgrib -s $1 | cut -d':' -f3 | cut -d ' ' -f1 | head -23 | cut -d'=' -f2 | tail -c 9)

# manipulation of the first two rows in a way to have heading and rows of datas in the correct order
# (I delete the problem of the heading and of the first row placed on the same level)
# I deleted the uwind2.txt and vwind2.txt columns
riga2=$(cat prev.csv | head -1)
riga1=${riga2:0:145}
riga2=${riga2:145:${#riga2}}

riga4=$(cat prevOrigin.csv | head -1)
riga3=${riga4:0:106}
riga4=${riga4:106:${#riga4}}

# I insert the first two rows and delete the old two rows that were became the third and the fourth (I delete them)
sed -i "1 i $riga1" prev.csv
sed -i "2 i $riga2" prev.csv
sed -i '3 d' prev.csv

sed -i "1 i $riga3" prevOrigin.csv
sed -i "2 i $riga4" prevOrigin.csv
sed -i '3 d' prevOrigin.csv

# take only first 21 rows
cat prev.csv | head -n 13 > tmp.txt
cat prevOrigin.csv | head -n 21 > tmpOrigin.txt
cat tmpOrigin.txt > prevOrigin_$now.csv

# eliminated the first column contains ';' char
cut -d';' -f1-23 tmp.txt > prev.xls
cut -d';' -f1,2,3,4,5,9,11,16,17,19,21 tmp.txt > prev2.xls
sed -i 's/Temp/Temperatura (°C)/g' prev2.xls
sed -i 's/Humidity/Umidita (%)/g' prev2.xls
sed -i 's/CloudCover/Nuvolosita/g' prev2.xls
sed -i 's/RainRate/Pioggia (intensita)/g' prev2.xls
sed -i 's/RainAcc/Pioggia (mm)/g' prev2.xls
sed -i 's/WindP/Vento (km-h)/g' prev2.xls
sed -i 's/WindDir/Vento (direzione)/g' prev2.xls
sed -i 's/WindI/Vento (intensita)/g' prev2.xls
sed -i 's/Foggy/Nebbia (Intensita)/g' prev2.xls

# Conversion in various formats HTML-PNG
# prev: complete datas
# prev2: datas for all users
./conv2htm.sh prev.xls > prev.html
sed -i 's/nowrap >/nowrap ><h2>/g' prev.html
sed -i 's/td>/td><\/h2>/g' prev.html

# test if directories DATAS and IMAGES don't exist and create them
if [ ! -d "DATAS" ]; then mkdir DATAS; fi
if [ ! -d "IMAGES" ]; then mkdir IMAGES; fi

# convertion in PNG format
xvfb-run --server-args="-screen 0, 1024x768x24" cutycapt --url=file://$PWD/prev.html --out=IMAGES/prev_$now.png

./conv2htm.sh prev2.xls > prev2.html
sed -i 's/nowrap >/nowrap ><h2>/g' prev2.html
sed -i 's/td>/td><\/h2>/g' prev2.html

xvfb-run --server-args="-screen 0, 1024x768x24" cutycapt --url=file://$PWD/prev2.html --out=IMAGES/prev2_$now.png

# move files to datas and images folders
mv prevOrigin.csv out.txt data.xls tmpOrigin.txt tmp.txt prevOrigin_$now.csv prev.xls prev2.xls prev.html prev2.html DATAS

# remove created files
rm prev.csv data.txt orario.txt temp2.txt temp3.txt rh2.txt rh3.txt uwind2.txt vwind2.txt pres.txt pres2.txt \
rainAcc.txt li.txt geop500.txt geop5002.txt cloudCover.txt cloudCover2.txt rainAcc2.txt cape2.txt temp.txt \
cape.txt rainRate.txt rh.txt uwind.txt vwind.txt wind4Dir.txt rainRate3.txt nebbia.txt cloudCover3.txt \
rainRate2.txt li2.txt wind2.txt wind2Dir.txt wind3Dir.txt dp.txt dp2.txt fog.txt abs.txt abs2.txt wind5Dir.txt

echo $HOUR
