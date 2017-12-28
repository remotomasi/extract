# extract

## Description
*extract* is a shell script to obtain a table of a series of weather parameters based on a GRIB file (downloaded by an email request).

## Requires
* bash 
* sudo apt-get install python-qt4 libqtwebkit4 python-pip xvfb
* sudo apt-get install cutycapt

## Command-Line usage
$ ./extract4.sh *file.grb*

## Require a grib file through the use of an email
* Create a new message
* To: *query@saildocs.com*
* Subject: 
* In the body do a request like this:
send GRIB:40N,40N,18E,18E|1,1|0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96,102,108,114,120,126,132,138,144|TMP,CAPE,PRESS,RH,APCP,HGT,WIND,LFTX,RAIN,TCDC,ABSV

## Link
* [The Weather Window] (http://weather.mailasail.com/Franks-Weather/Saildocs-Free-Grib-Files) infos about request a GRIB file through an email.

