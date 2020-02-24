#!/bin/bash

sst_filename="$1-sstools-subdomains.json"
crt_filename="$1-crt-tools-subdomains.json"
cstr_filename="$1-cstr-tools-subdomains.json"
foldername=$(date | md5 | base64)
totalError=0

sstools() {

  curl -Ss "https://ssltools.digicert.com/chainTester/webservice/ctsearch/search?keyword=$1" -o "$sst_filename"

  if [ $? -eq 0 ]; then
     echo "$(tput setaf 7)$(tput setab 2) SUCESSO $(tput sgr 0) sst processados com sucesso"
  else
    echo "$(tput setaf 7)$(tput setab 1) FALHA $(tput sgr 0) sst processado com falha"
  fi

}

crt_tools() {

  curl -Ss "https://crt.sh/?q=$1&output=json" -o "$crt_filename"

  if [ $? -eq 0 ]; then
     echo "$(tput setaf 7)$(tput setab 2) SUCESSO $(tput sgr 0) crt processados com sucesso"
  else
     echo "$(tput setaf 7)$(tput setab 1) FALHA $(tput sgr 0) crt processado com falha"
  fi

}


certspotter() {

  curl -Ss "https://api.certspotter.com/v1/issuances?domain=$1&include_subdomains=true&expand=dns_names&expand=issuer&expand=cert" -o "$cstr_filename"

  if [ $? -eq 0 ]; then
     echo "$(tput setaf 7)$(tput setab 2) SUCESSO $(tput sgr 0) certfiles processados com sucesso"
    else
     echo "$(tput setaf 7)$(tput setab 1) FALHA $(tput sgr 0) certfiles processado com falha"
  fi

 }

MoveToDir() {

ls *.json* $foldername 2>/dev/null
if [ $? -eq 0 ]; then
    mkdir $foldername
    mv *.json $foldername
else
    echo "$(tput setaf 7)$(tput setab 1) FALHA $(tput sgr 0) ficheiros nao existem"
   exit 3
fi

}

jqRunner() {
  cat $sst_filename $crt_filename $cstr_filename | jq -r '.data.certificateDetail[].commonName,.data.certificateDetail[].subjectAlternativeNames[],.[].name_value,.[].dns_names[]' 2>/dev/null | sed 's/\*\.//g'| egrep -v "^(null|jq\:)" | sort -u

}

sniffPorts (){
  if [ -f $foldername/$cstr_filename ]; then
     sh -c "./toSearch.sh $foldername/$cstr_filename"
  else
     echo "$(tput setaf 7)$(tput setab 1) FALHA $(tput sgr 0) nao foi possivel verificar as portas processado"
     exit 3
  fi
 }

checkDirs (){
  sh -c "./findPath.sh $1 $2 $3"
}

search_subdomains() {

  echo "$(tput setaf 7)$(tput setab 2) EM CURSO  $(tput sgr 0) Verificando os subdominios"

  sstools "${1}"
  crt_tools "${1}"
  certspotter "${1}"

  #jqRunner not important because i just want to see the result of the request
  # read the file and find the information that we want :D


  echo "$(tput setaf 7)$(tput setab 2) SUCESSO $(tput sgr 0) Processo de verificacao dos subdominios concluido com sucesso"

  MoveToDir

  case $2 in
    --ports)
     echo "$(tput setaf 7)$(tput setab 3)EXECUTADO$(tput sgr 0) Verificando as portas"
     sniffPorts
     ;;

     --dir)
      checkDirs $1 $3 $4
     ;;
   esac

  if [ $? -eq 0 ]; then
     echo "$(tput setaf 7)$(tput setab 2)SUCESSO $(tput sgr 0) Processo concluido com sucesso"
  else
     echo "$(tput setaf 7)$(tput setab 1) ERRO $(tput sgr 0) Processo terminado com falha"
  fi
}

#copied from https://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script

if ! [ -x "$(command -v jq)" -a -x "$(command -v nmap)" -a -x "$(command -v gobuster)" ]; then
  echo 'echo "$(tput setaf 7)$(tput setab 1) ERRO $(tput sgr 0)" Make sure that jq and nmpa and gobuster is already installed' >&2
  exit 1
fi


search_subdomains $1 $2 $3 $4
