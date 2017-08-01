#!/bin/bash
project_name='WebTemperature'
dir_base=`pwd`

function info {
	echo -e "\e[1;36m$1\e[0m"
}

function err {
	echo -e "\e[1;31m$1\e[0m"
}

# ask for password
read -s -p "[sudo] password for user: " user_pwd

# check the password
sudo -k
echo $user_pwd | sudo -S echo oops &> /dev/null
if [ $? -ne 0 ]; then
	err "\nInvalid password"
	exit 1
fi

# set Pi's i2c
sudo raspi-config nonint do_i2c 0 

# python module installation
# echo $user_pwd | sudo -S apt-get update
echo $user_pwd | sudo -S apt-get install git
echo $user_pwd | sudo -S pip install bottle

info "\nPython Module Installed"

# git clone here
git clone https://github.com/geeekpi/WebTemperature.git
info "\ngit cloned"

# complie the C code to binary
gcc -o ntc $project_name/ntc.c -lm -O3

# nginx configuration
echo $user_pwd | sudo -S apt-get install nginx
echo $user_pwd | sudo -S rm /etc/nginx/sites-available/default
echo $user_pwd | sudo -S touch /etc/nginx/sites-available/default
echo $user_pwd | sudo -S cat > /etc/nginx/sites-available/default <<EOF
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        server_name _;

        location / {
		root $dir_base/$project_name;
		index index.html index.htm index.nginx-debian.html;
        }
        location /data {
                proxy_pass      http://127.0.0.1:9000;
        }
}
EOF

echo $user_pwd | sudo -S /etc/init.d/nginx restart

if [ $? -ne 0 ]; then
	err "\nError during Nginx Configuration"
else
	info "\nNginx Configured"
fi

# start data collection 
python $project_name/main.py > /dev/null 2>&1 &

# get IP address
myIP=`ifconfig wlan0 | awk '/inet addr/{print substr($2,6)}'`
info "\nYou can access WebTemperature via:"
info "Visit http://$myIP"
