#!/bin/bash
. /home/postgres/cruser_v2/script/env/vars.txt

# gen_password								# генератор паролtй
gen_pass(){
cat /dev/urandom | tr -dc 'a-zA-Z0-9-#@%^&_' | fold -w 16 | head -1
}

# ldap_search

search(){ 
ldapsearch -D "" -w "passwprd" -p 389 -h host.domain.name -b "ou=_Users,dc=host,dc=domain,dc=name" "(sAMAccountName=$1)" -G extensionName | tail -1 | awk -F '=' '{print $2}';
} #  функция вовзвращающая почтовый адрес из АД search usename

# gener
gener(){
   if [ ! -f $HTML_DIR/${1}_html.html -a -f $HOST_DIR/${1}_host.txt -a -f $PASS_DIR/${1}_pass.txt ];
      then
	 cat $HTML_HEAD > $HTML_DIR/${1}_html.html
	   for H in $(cat $HOST_DIR/${1}_host.txt); do
	     echo "${HTL_SS}${H}${HTML_SE}" >> $HTML_DIR/${1}_html.html;
           done;
	 echo "${HTML_SS}${HTML_SE}" >> $HTML_DIR/${1}_html.html;
         echo "${HTML_SS}Login: $1 ${HTML_SE}" >> $HTML_DIR/${1}_html.html;
         echo "${HTML_SS}Password: $(cat $PASS_DIR/${1}_pass.txt)${HTML_SE}" >> $HTML_DIR/${1}_html.html;
	 cat $HTML_TAIL >> >> $HTML_DIR/${1}_html.html;
   fi
}

# create user

cr_us(){
ssh -T $1 "psql -d postgres -c \"CREATE USER $2 WITH PASSWORD '$3'\"";
ssh -T $1 "psql -d postgres -c \"COMMENT ON ROLE $2 is '$4'\"";
ssh -T $1 "pg_dumpall -r | grep $2 >> /dbhome/postgres/pgdata/son/usr/$2.sql";
echo $3 > $PASS_DIR/${2}_pass.txt;
echo "jdbc:postgresql://$1:5432" >> $HOST_DIR/${2}_host.txt;
}

# check ssh_connection

ssh_con(){
ssh -T $1 "hostname" &>/dev/null; echo $?
}

#check_filepass

pass(){
if [ -f $PASS_DIR/${1}_pass.txt ]; then
echo "1";
else
echo "0";
fi
}

# check pg_connection

pg_con(){
ssh -T $1 "psql -d postgres -c '\! hostname' &>/dev/null; echo $?"
}

# check recursive connection

ch_con(){
for H in $(cat $HOST_VARS); do
    if [ $(ssh_con $H) -lt 1 ]; then
	 echo "$H" >> $SSH_LIST;
         if [ $(pg_con $H) -lt 1 ]; then
		echo "$H" >> $PG_LIST;
         else
		echo "$H" >> $PG_PR;
         fi
    else
	echo "$H" >> $SSH_PR;
    fi;
done
HS=$(cat $HOST_VARS | wc -l | xargs);
SL=$(cat $SSH_LIST | wc -l | xargs);
PL=$(cat $PG_LIST | wc -l | xarhs);
if [ $HS -eq $SL -a $PL]; then
	echo "1";
     else
	echo "0";
fi
}

# check_user_exists

user_ch(){
ssh -T $1 "psql -d postgres -t -c \"SELECT count(*) FROM pg_user where usename='$2'\"" | head -1
}

# send mail
send(){
if [ -f $HTML_DIR/${1}_html.html -a -f $HOST_DIR/${1}_host.txt -a -f $PASS_DIR/${1}_pass.txt ];
then
mutt -c copy_name -e 'set content_type=text/html' -s "#$(code) #USER $1 $2" $(search $1) < $HTML_DIR/${1}_html.html;
fi;
}

code(){
awk -F '-' '{print $1}' $HOST_VARS | awk 'NR==1{print $1}' | tr [:lower:] [:upper:];
}

PP(){
cat $CR_LOG/$UNIQ/pg_pr.txt | wc -l
}

SP(){
cat $CR_LOG/$UNIQ/ssh_pr.txt | wc -l
}

HS(){
cat $HOST_VARS | wc -l | xargs
}

SL(){
cat $SSH_LIST | wc -l | xargs
}

PL(){
cat $PG_LIST | wc -l | xargs
}
