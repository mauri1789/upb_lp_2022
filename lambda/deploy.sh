#!/bin/bash

OPTIONS=ibdr
LONGOPTS=install,build,deploy,remove

! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")

i=0 p=0 b=0 d=0

# CF_FILE="/tmp/cf_file.txt"
DEPLOYMENTS_BUCKET="maudeployments2" #CHANGE TO YOUR OWN BUCKET
PACKAGED_TEMPLATE="packaged-template.yaml"

case "$1" in
  -i|--install)
    i=1
    shift
    ;;
  -r|--remove)
    r=1
    shift
    ;;
  -b|--build)
    b=1
    shift
    ;;
  -d|--deploy)
    d=1
    shift
    ;;
  --)
    shift
    break
    ;;
  *)
    ;;
esac

if [[ $i -eq 1 ]]; then
  echo "installation step"
  pip install -r requirements.txt -t build
  cp -r src/. build
fi

if [[ $b -eq 1 ]]; then
  aws cloudformation package \
    --template-file template.yaml \
    --s3-bucket $DEPLOYMENTS_BUCKET \
    --output-template-file $PACKAGED_TEMPLATE
fi

if [[ $d -eq 1 ]]; then
  aws cloudformation deploy \
    --no-fail-on-empty-changeset \
    --template-file $PACKAGED_TEMPLATE \
    --stack-name lambda-stack \
    --capabilities CAPABILITY_NAMED_IAM
fi