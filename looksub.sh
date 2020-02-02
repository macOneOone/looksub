#!/bin/bash

sst_filename="$1-sstools-subdomains.json"
crt_filename="$1-crt-tools-subdomains.json"
cstr_filename="$1-cstr-tools-subdomains.json"

sstools() {
  curl -Ss "https://ssltools.digicert.com/chainTester/webservice/ctsearch/search?keyword=$1" -o "$sst_filename"
}

crt_tools() {
  curl -Ss "https://crt.sh/?q=yahoo&output=json" -o "$crt_filename"
}


certspotter() {
  curl -Ss "https://api.certspotter.com/v1/issuances?domain=$1&include_subdomains=true&expand=dns_names&expand=issuer&expand=cert" -o "$cstr_filename"
}

createDir() {
 foldername=$(date | md5)
  mkdir $foldername
  mv *.json $foldername
}

jqRunner() {

  cat $sst_filename $crt_filename $cstr_filename | jq -r '.data.certificateDetail[].commonName,.data.certificateDetail[].subjectAlternativeNames[],.[].name_value,.[].dns_names[]' 2>/dev/null | sed 's/\*\.//g'| egrep -v "^(null|jq\:)" | sort -u

}

search_subdomains() {

  sstools "${1}"
  crt_tools "${1}"
  certspotter "${1}"
  #jqRunner # read the file and find the information that we want :D
  createDir


}



#copy from https://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: git is not installed.' >&2
  exit 1
fi

search_subdomains $1
