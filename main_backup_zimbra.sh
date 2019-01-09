#!/bin/bash

# SaratovHolod get 3 domain
# zimbra.sarholod.loc
# pingvin-saratov.ru
# sarholod.loc
domain=pingvin-saratov.ru

##############################
# Get all domain to zimbra   #
# /opt/zimbra/bin/zmprov gad #
##############################

#Create variable from file list users zimbra
subfolder=Projects/scripts/saratovHolod
folder=$HOME/"$subfolder"

#variable for list all users
list=$folder/sh.zim.user.list

#variable for passwd all users
passwdlist=$folder/userPasswd.list

#variable for command initials all user for deploy
cmduser=$folder/cmdBackupData.list

# Folder for backups
dirbackup=$folder/dirbackup
mkdir $dirbackup

#logs
log_dir=$folder/log
mkdir $log_dir


#Get list users without services mailbox
/opt/zimbra/bin/zmprov -l gaa $domain | egrep -v 'avir|galsync|spam|ham|virus' > $list

#this cicle get passwds all users from list
# set passdw to file
for user in `cat $list`
   do
    passwd=`/opt/zimbra/bin/zmprov -l ga $user userPassword`
    echo  $passwd >> $passwdlist
done

# next get data from users ( name, surname, initials)

cat $passwdlist | awk '{print$3}' | while read ulist
do
  #start time backup data one user
  Begin_time=$(date +%s)

  array[i]="$ulist"
  echo "$line"
  GN=`/opt/zimbra/bin/zmprov ga "$ulist" | grep givenName | cut -c 12-`
  SN=`/opt/zimbra/bin/zmprov ga "$ulist" | grep sn | cut -c 5-`
  IN=`/opt/zimbra/bin/zmprov ga "$ulist" | grep initials | cut -c 11-`
  DN=`/opt/zimbra/bin/zmprov ga "$ulist" | grep displayName | cut -c 14-`

  echo $GN $SN $IN
# variable CMD needed for feature restore data from users
# this $CMD set command for deploy
  CMD="/opt/zimbra/bin/zmprov ca "$ulist" password displayName \""$DN"\" sn \""$SN"\" givenName \""$GN"\" initials \""$IN"\""

  echo $CMD >> $cmduser
  /opt/zimbra/bin/zmmailbox -z -m $ulist getRestUrl "//?fmt=tgz" > $dirbackup/$ulist.tgz
  echo "$ulist - OK" >> $log_dir/$(date +%Y%m%d).log
  echo "Сбор и копирование информации пользователя $ulist закончен" >> $log_dir/$(date +%Y%m%d).log
  End_time=$(date +%s)
  Elapsed_time=$(expr $End_time - $Begin_time)
  Hours=$(($Elapsed_time / 3600))
  Elapsed_time=$(($Elapsed_time - $Hours * 3600))
  Minutes=$(($Elapsed_time / 60))
  Seconds=$(($Elapsed_time - $Minutes * 60))
  echo "Затрачено времени на резервное копирование : $Hours час $Minutes минут $Seconds секунд" >> $log_dir/$(date +%Y%m%d).log
  let i++
done
