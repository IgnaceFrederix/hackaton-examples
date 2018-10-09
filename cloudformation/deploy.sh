#!/bin/bash
usage()
{
cat << EOF
usage: $0 options

This script is deploying the stack and showing the DNS name as output.

OPTIONS:
-h Show help message
-t Do this if you want to run a test on the loadbalancer
EOF
}

while getopts "th" OPTION
do
    case $OPTION in
        t) TEST=true ;;
        h) usage; exit 1 ;;
        ?) usage; exit 1 ;;
        *)
            echo "Invalid option '$OPTION'. Use -h to see the valid options" >&2
            exit 1
            ;;
    esac
done
aws cloudformation deploy --template-file stack.yaml --stack-name teststack

LBDNS=$(aws cloudformation describe-stacks --stack-name teststack --query 'Stacks[0].Outputs[0].OutputValue')

echo ======================================THE ELB DNS NAME IS=====================================
echo
echo $LBDNS | xargs
echo
echo ==============================================================================================

if [ "$TEST" == "true" ]; then
  echo BEGIN LOADBALANCER
  echo
  for i in {1..10}
  do
    curl http://teststack-ElasticL-XAYXQXDDKCAU-2119337948.us-east-1.elb.amazonaws.com
  done
  echo
  echo END LOADBALANCER TEST
fi
