#!/bin/bash


run(){
 cat $1 | jq -r ".[].dns_names[]" | xargs -n1 -P1 -I{} nslookup {} 2>/dev/null | grep "Address" | cut -d ":" -f2 2>/dev/null | grep -v "#" | xargs -n1 -P1 -I{} nmap -oN $(date | md5 | base64) -A -T4 -sV {}
}

run $1

