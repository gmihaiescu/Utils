#!/bin/sh
#set -x

# put your AWS credentials in /root/aws-creds.sh
source /root/aws-creds.sh

unsecure="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
rm -rf /root/reports
mkdir /root/reports

key="/root/flying_snow.pem"

echo "Getting the list of instances"
instances=`ec2-describe-instances --region eu-west-1 --filter tag:youxia.managed_tag=flying_snow | grep INSTANCE | awk '{print $4}'`
count=`echo $instances| wc -w`
echo "There are $count instances running in Ireland tagged by youxia."

echo "Copying the script to tmp"
for instance in $instances;\
do scp $unsecure -i $key check-seqware-jobs-duration.sh  ubuntu@$instance:/tmp;\
ssh $unsecure -i $key ubuntu@$instance "chmod +x /tmp/check-seqware-jobs-duration.sh; /tmp/check-seqware-jobs-duration.sh" > /root/reports/${instance}_report.txt

#echo -n "Continue? [y or n]: "
#read answer
#case $answer in

#        [yY] )
#                echo "Going on..."
#                ;;

#        [nN] )
#                echo "Exit";
#                exit 1
#                ;;
#        *) echo "Invalid input"
#                exit 1
#            ;;
#esac

done

echo "These are the issues discovered:"
echo "There are `egrep "No problems detected" /root/reports/*| wc -l` instances with no problems detected."
echo "But there are `egrep -v "No problems detected" /root/reports/*| wc -l` instances with the following issues:"
egrep -v "No problems detected" /root/reports/*
