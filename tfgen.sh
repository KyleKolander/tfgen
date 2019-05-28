#!/bin/bash

cleanup() {
    echo ""; echo "Cleaning up..."
    if [ -e *.tf ]; then rm *.tf; fi
    if [ -e ".terraform" ]; then rm -rf .terraform; fi
}

replace_placeholder() {
    file=$1; placeholder=$2; replacement_text=$3
    echo "......replacing  [${placeholder}]  with  ${replacement_text}"
    sed -i 's/\['${placeholder}'\]/'${replacement_text}'/g' ${file}
    status=$?; if [ $status -ne 0 ]; then exit $status; fi
}

default_profile="default"
default_app=${PWD##*/}

# Display help if first argument starts with -h or --h
if [ $# -eq 0 ] || [[ "$1" = "-h"* ]] || [[ "$1" = "--h"* ]]; then
  echo ""; echo "Usage: ./`basename $0` region [profile] [app]"; echo "";
  echo "  region      AWS Region."
  echo "  profile     AWS Profile in ~/.aws/credentials.    Default:  ${default_profile}"
  echo "  app         Application name.                     Default:  ${default_app}"
  cleanup
  exit 1
fi

region=${1}
profile=${2:-$default_profile}
app=${3:-$default_app}

cleanup

echo "getting AWS Account ID..."
accountID=$(aws sts get-caller-identity --output text --query 'Account' --profile ${profile})
status=$?; if [ $status -ne 0 ]; then exit $status; fi

for f in *.tfgen
do
    tf_file="${f%gen}"
    tmp_preprocess_file=$(mktemp)

    echo "copying  ${f}   to   ${tmp_preprocess_file}"; cp ${f} ${tmp_preprocess_file}

    replace_placeholder ${tmp_preprocess_file} "region" ${region}
    replace_placeholder ${tmp_preprocess_file} "profile" ${profile}
    replace_placeholder ${tmp_preprocess_file} "app" ${app}
    replace_placeholder ${tmp_preprocess_file} "accountID" ${accountID}

    echo "moving  $tmp_preprocess_file   to   $tf_file"; mv $tmp_preprocess_file $tf_file
done

echo "formatting .tf files..."; terraform fmt

exit 0
