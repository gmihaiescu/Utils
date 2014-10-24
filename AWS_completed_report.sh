#!/bin/bash
#set -x

# put your AWS credentials in /root/aws-creds.sh
source /root/aws-creds.sh
report="/tmp/reports_completed"

unsecure="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
rm -rf $report
mkdir $report

key="/root/flying_snow.pem"

echo "Getting the list of instances"
instances=`ec2-describe-instances --region eu-west-1 --filter tag:youxia.managed_tag=flying_snow | grep INSTANCE | awk '{print $4}'`
count=`echo $instances| wc -w`
echo "There are $count instances running in Ireland tagged by youxia."

for instance in $instances;\
do ssh $unsecure -i $key ubuntu@$instance "sudo -u seqware -i /home/seqware/bin/seqware workflow report --accession 21 | grep -A 4 -B 1 -i completed" > $report/${instance}_report.txt

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

completed=`grep completed $report/* | wc -l`
echo "There were $completed workflows completed by the AWS Ireland instances."


