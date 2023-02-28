
##################################### Update the package details  ###############################################
sudo apt update -y

##################################################################################################################


################### Check HTTP Apache server is already installed #################################################
if apache2 -v; then
        echo "Apache server is installed"
else  sudo apt install apache2
fi

####################################################################################################################



##############  checks whether the server is running or not. If it is not running, then it starts the server ###########

server_stat=$(service apache2 status)
if  $server_stat == *"active (running)"* ; then
  echo "server is running"
else sudo systemctl start apache2
fi

##########################################################################################################################




################### Ensures that the server runs on restart/reboot.It enables the service if not enabled already##########
if sudo systemctl is-enabled apache2; then
	echo " Apache2 is enable"

else sudo systemctl enable apache2
fi

#############################################################################################################################




############################################ Variables declaration ##########################################################
myname="Shruti"
timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket="upgrad-shruti-assignment"

#############################################################################################################################



######################################## Copying the logs files to tar files ################################################

tar cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log

#############################################################################################################################


####################################### Check whether aws cli is installaed or not ###########################################
dpkg -s awscli
if [ $? -eq 0 ]
then
    echo "awscli  is installed."
else
    echo "awscli is not installed,installing awscli"
    sudo apt install awscli -y
fi

###############################################################################################################################


##################################### Copying the tar files from tmp directory to aws ###########################################

aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

###############################################################################################################################





######################## Checking if inventory file name is present,if not creating an inventory file name ######################
if [ -e $inventory_file ]
then
    echo "inventory.html file exist"
    file_size=$(ls -lh /tmp/${myname}-httpd-logs-${timestamp}.tar | awk '{ print $5}')
    printf "<p>httpd-logs &emsp;&emsp;&emsp;&emsp; $timestamp &emsp;&emsp;&emsp;&emsp; tar &emsp;&emsp;&emsp;&emsp; $file_size \n" >> $inventory_file
    echo "log file extractions are added to the inventory.html file"

else
    echo "inventory.html file doesnot exist,generating inventory.html file"
    printf "<p style='padding: 10px; border: 2px solid #ccc; background-color:#f5f5f5;'>cat /var/www/html/inventory.html</p> \n <h3>Log Type &emsp;&emsp;&emsp; Date Created &emsp;&emsp;&emsp; Type &emsp;&emsp;&emsp; Size</h3> \n" > $inventory_file
    file_size=$(ls -lh /tmp/${myname}-httpd-logs-${timestamp}.tar  | awk '{ print $5}')
    printf "<p>httpd-logs &emsp;&emsp;&emsp;&emsp; $timestamp &emsp;&emsp;&emsp;&emsp; tar &emsp;&emsp;&emsp;&emsp; $file_size \n" >> $inventory_file
    echo "log file extractions are added to the inventory.html file"
fi
#####################################################################################################################################


############################################################# Creating a cron job ###################################################
automate_cron_job="/etc/cron.d/automation"
if [  -f $automate_cron_job ]
then
    echo "cron file for automation exist"
else
echo "cron job needs to be created,creating a cron job"
    printf "0 0 * * * root /root/Automation_Project/automation.sh\n" > $automate_cron_job 
fi
#####################################################################################################################################
