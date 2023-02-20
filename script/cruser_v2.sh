#!/bin/bash

# vars
. /home/postgres/cruser_v2/script/env/vars.txt
# function
. /home/postgres/cruser_v2/script/function.sh
#
mkdir -p $HOST_DIR; mkdir -p $PASS_DIR; mkdir -p $HTML_DIR; mkdir -p $CR_LOG/$UNIQ;
rm -rf $CR_LOG/$UNIQ/*;
# main
if [ $(ch_con) -gt 0 ]; then
   for H in $(cat $HOST_VARS); do
      for U in $(cat $USER_HOME); do
         if [ $(user_ch $H $U) -lt 1 ]; then
           if [ $(pass $U) -gt 0 ]; then
	     P=$(cat $PASS_DIR/${U}_pass.txt);
	     $(cr_us $H $U $P $C $UNIQ);
	   else
	     P=$(gen_pass);
	     $(cr_us $H $U $P $C $UNIQ) &>/dev/null;
	   fi
	 fi
       done
    done
else
echo "Part of the hosts did not pass the test, please delete or fix the problem host";
echo "SSH_HOST_PROBLEM: $SP"
echo "PG_HOST_PROBLEB: $PP"
echo "You may see the list of problem hosts:
$SSH_PR
$PG_PR"
fi

# gener
for U in $(cat $USER_HOME); do
  gener $U
done

# sender

for U in $(cat $USER_HOME); do
  send $U $C
done
