#!/bin/bash

NL=$'\n'

num_of_log_entries=$1

if [[ "" = "$1" ]]
then
    num_of_log_entries=20
fi

log=$(git log -n $num_of_log_entries --pretty="format:%h %H %s")

declare -a hashes
declare -a hashes_selected
optionStr=""

#create menu
counter=0
while read -r line 
do
    counter=$(($counter + 1))
    short_hash=`echo -n $line|sed -En 's/^([^ ]+) (.*)/\1/p'`
    hash=`echo -n $line|sed -En 's/^([^ ]+) ([^ ]+) (.*)/\2/p'`
    message=`echo -n $line|sed -En 's/^([^ ]+) ([^ ]+) ([^\n]+).*/\3/p'`
    message=$(echo $message|sed "s/\"/''/g")

    hashes[$counter]=$hash
    optionStr+=$(printf '%d "%s %s" off ' "$counter" "$short_hash" "$message")
done <<< "$log"

temp=$(mktemp)
command=$(printf 'dialog --checklist "Choose:" 2048 2048 500 %s 2> %s' "$optionStr" "$temp")

eval "$command"
clear

result=$(sed -e 's/"//g' $temp|sed -e 's/ /\n/g')

#store selected hashes
counter=0
while read -r c
do
    counter=$(($counter + 1))
    hashes_selected[counter]="${hashes[$c]} "
done <<< "$result"

echo -n 'git cherry-pick '
for ((i = ${#hashes_selected[@]};i > 0;i--))
do
    echo -n "${hashes_selected[i]} "
done

echo " "
