#!/bin/bash

sst_filename="$1-sstools-subdomains.json"
crt_filename="$1-crt-tools-subdomains.json"
cstr_filename="$1-cstr-tools-subdomains.json"
foldername=$(date | md5 | base64)

sstools() {
  curl -Ss "https://ssltools.digicert.com/chainTester/webservice/ctsearch/search?keyword=$1" -o "$sst_filename"

  if [ $? -eq 0 ]; then
    echo "$(tput setaf 7)$(tput setab 2)\tsst carregado com sucesso \t $(tput sgr 0)"
  else
    echo "$(tput setaf 7)$(tput setab 1)\tProcesso executado com erro \t $(tput sgr 0)"
  fi

}

crt_tools() {
  curl -Ss "https://crt.sh/?q=yahoo&output=json" -o "$crt_filename"
  if [ $? -eq 0 ] ; then
    echo "$(tput setaf 7)$(tput setab 2)\tcrt carregado com sucesso \t $(tput sgr 0)"
  else
    echo "$(tput setaf 7)$(tput setab 1)\tProcesso executado com erro \t $(tput sgr 0)"
  fi

 }


certspotter() {
  curl -Ss "https://api.certspotter.com/v1/issuances?domain=$1&include_subdomains=true&expand=dns_names&expand=issuer&expand=cert" -o "$cstr_filename"
  if [ $? -eq 0 ]; then
   echo "$(tput setaf 7)$(tput setab 2)certspotter carregado com sucesso$(tput sgr 0)"
  else
    echo "$(tput setaf 7)$(tput setab 1)Processo executado com erro$(tput sgr 0)"
  fi
}

MoveToDir() {
  mkdir $foldername
  mv *.json $foldername
}

jqRunner() {
  cat $sst_filename $crt_filename $cstr_filename | jq -r '.data.certificateDetail[].commonName,.data.certificateDetail[].subjectAlternativeNames[],.[].name_value,.[].dns_names[]' 2>/dev/null | sed 's/\*\.//g'| egrep -v "^(null|jq\:)" | sort -u

}

sniffPorts (){
  sh -c "./toSearch.sh $foldername/$cstr_filename"
}
search_subdomains() {

  sstools "${1}"
  crt_tools "${1}"
  certspotter "${1}"
  #jqRunner not important because i just want to see the result of the request
  # read the file and find the information that we want :D
  case $2 in
    ports)
     MoveToDir
     echo "$(tput setaf 7)$(tput setab 3)Verificando as portas$(tput sgr 0)"
     sniffPorts
  esac
     echo "$(tput setaf 7)$(tput setab 4)Processo concluido$(tput sgr 0)"

}



#copied from https://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: git is not installed.' >&2
  exit 1
fi

search_subdomains $1 $2
