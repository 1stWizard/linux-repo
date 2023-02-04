#User Managment Script
#Author: Edmund Fordjour
#Date: March 04, 2021
#Linux Administration Class
#UML - Spring 2021
#! /bin/bash
# For each loop to qurey the shadow file
for line in `cat /etc/shadow`
do
  #non_password_account holds users who do not have Password
  #this code check if there is a user without a Password
  #and then lock such account
  non_password_account=`echo $line | awk -F":" '($2=="")||($2=="!") {print $1}'`
  if [ $non_password_account ]
  then
    usermod -L $non_password_account
    echo "$non_password_account has no Password"
    echo "$non_password_account is Locked!"
  fi

#user_name holds values for users in the shadow file
#added_shadow holds values for sum of 7 and 8 fields in a user record
#in the shadow file and then add them together
#the purpose is to compare if added_shadow is less than current_date
#if true, the then that account has expired
#converted_shadow_date is variable that holds dates in days to real life
#date eg 18690 is converted to 2021-0304
#this block of code checks if an account has expired
  user_name=`echo $line | awk -F":" '{print $1}'`
  #unexpired_account holds users that have accounts that do not expired
  #These accounts do not expire
  unexpired_account=`echo $line | awk -F":" '($8=="")||($8<=0) {print $1}'`
  if [ $unexpired_account ]
  then
      echo "$unexpired_account NEVER expire"
    else
      added_shadow=`echo $line | awk -F":" ' {print $7+$8}'`
      current_date=`expr $(date +%s) / 86400`
      if [ $added_shadow -lt $current_date ]
      then
        echo "$user_name has expired"
      else
        #to_expire_date holds the date when the account will expire
        to_expire_date=`echo $line | awk -F":" '($8>0) {print $8}'`
        if [ $to_expire_date ]
        then
          #converted_shadow_date holds values expressed in real time date other
          #than the shadow values in numbers
          converted_shadow_date=`date -d "1970-01-01 +${to_expire_date}days" +%F`
          echo "$user_name expires in $converted_shadow_date"
        fi
      fi
  fi

  #A line to separate users
  echo "-----------------------------"
done



#first parameter used on commandline
username=$1

#prompt for a user  if user failed to add a user on the commandline
if [ ! $username ]
then
   echo "Check a user?"
   echo "Enter username"
   read new_user
   username=$new_user
fi

#chech if user exist in the shadow file and then throw away the results
grep -w "$username" /etc/shadow > /dev/null

#if the previous command worked perfectly, the results will be 0
#otherwise any random number will appear
#in that case, the program will execute the else commands
success=`echo $?`
 if [ $success -eq 0 ]
 then
   echo "Lock or Unlock a user?"
   echo "1. To Lock $username"
   echo "2. To Unlock $username"
   echo "3. To exit"
   read modify_user_account
   case $modify_user_account in
       1)echo "Lock user"
       usermod -L $username
       echo "$username is Locked!"
       ;;
       2)echo "Unlock user"
        usermod -U $username
        echo "$username is Unlocked"
        echo "ONLY if $username has a PASSWORD!"
       ;;
       3)exit 1
       ;;
       *)echo "Press 1 or 2 to continue..."
       ;;
     esac
   else
     echo "$username does not exist"
     echo "Do you want to add $username (y or n)?"
     read add_user
     case $add_user in
       y)echo "User's home directory"
       read home_directory
       echo "Enter User's full name"
       read fullname
       echo "Enter Shell"
       read chosen_shell
       echo "Account expire date (YYYY-MM-DD)"
       read account_expire_date
       echo "Creating User $username"

       #useradd is a command that modify users,creat new uesers or modify users
       useradd "$username" -d"$home_directory" -c"$fullname" -s"$chosen_shell"\
       -e "$account_expire_date"
       #creating password for user
       passwd $username

        #check if user is a root user or not.
        #this code set a root user's password that never expires
        #if the user is a regular user, the user will be required to
        #change password after first log in

       echo "Is $username a root user (y or n)?"
       read root_privilage
       case $root_privilage in
          y) usermod -e '' $username
          #Verify if the user has succefully been created as a root user
          check_user=`cat /etc/shadow | grep -w "$username" | awk -F":"\
           '($8=="") {print $1}'`
          if [ $check_user ]
          then
            usermod -aG sudo $check_user
            echo "$check_user is Root user"
            echo "account NEVER expire"
            #Root Users in the systems
            root_users=`cat /etc/group | grep -w sudo | awk -F":" '{print $4}'`
            echo "Root Users are:"
            echo "$root_users"
          else
            #not neccessary but to avoid exception
            echo "$username is NOT Root User"
          fi
          ;;
          n)#Requiring a new created user to login after first log-in
          passwd -e $username
          echo "$username require new PASSWORD"
          echo "After first log-in"
          ;;
        esac
      ;;
      n)exit 2
      ;;
     *)echo "Press y or n"
      ;;
    esac
  fi

  #Unlock root account
  #passwd root
  #Lock root account
  #passwd -dl root
