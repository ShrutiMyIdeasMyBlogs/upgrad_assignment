
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



