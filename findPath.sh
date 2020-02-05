#!/bin/bash

theWebsite=$1


if [ "$2" == "default" ]; then
 thePath="../gopth/gopth.txt"
else
 thePath=$2
fi

if [ $3 -lt 0 -o $3 -gt 10 ]; then
  theNumberOfThread=1
 else
  theNumberOfThread=$3
fi
run(){

 #1 the website
 #2 the filepath
 #3 the number of thread

 gobuster dir -u $theWebsite -w $thePath -t $theNumberOfThread

}

run
