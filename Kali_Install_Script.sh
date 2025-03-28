#!/bin/bash

#Note, this is a script that I started to build after repeatedly needing to roll out builds. 
#I thought about creating a custom Kali Distro, however with needing to install custom tools from github 
#I decided on a modifiable script instead. When I started to build the script, 
#I built upon the foundation that Matthew Clark May had used in a Repository he created, but no longer maintains. Credit where it's due.

#if issues when running and saved using windows run this
#sed -i -e 's/\r$//'scriptname.sh

#update Kali
sudo apt-get update ; sudo apt-get -y upgrade ; sudo apt-get -y dist-upgrade ; sudo apt-get -y autoremove ; sudo apt-get -y autoclean ; echo

echo updating power settings
#pre-login power settings
sudo -i -u Debian-gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
sudo -i -u Debian-gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

#update default gdm3 profile to not sleep at login prompt
sudo sed -i 's/# sleep-inactive-ac-type=.*/sleep-inactive-ac-type='"'"'nothing'"'"'/g' /etc/gdm3/greeter.dconf-defaults
sudo sed -i 's/# sleep-inactive-battery-type=.*/sleep-inactive-battery-type='"'"'nothing'"'"'/g' /etc/gdm3/greeter.dconf-defaults

#user power settings
dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

#set lid action to not sleep on close
sudo sed -i '/IgnoreLid=/{s/false/true/}' /etc/UPower/UPower.conf 
sudo sed -i '/HandleLidSwitch/{s/#//;s/suspend/ignore/}' /etc/systemd/logind.conf

# install golang
sudo apt install -y golang

# install python
sudo apt install -y virtualenv python3.11-venv python3-venv pipx

#install tmux
sudo apt install -y tmux

#install xfreerdp
sudo apt install -y freerdp2-x11

# install docker
sudo apt install -y docker.io
sudo apt install -y docker-compose

#remove preinstalled software that causes some conflicts with updated installs below
sudo apt remove -y crackmapexec tightvncserver netexec evil-winrm

#set pipx path in bash and zsh profile for root profile
echo "export PATH=\"\$PATH:/root/.local/bin\"" | sudo tee -a /root/.bashrc
echo "export PATH=\"\$PATH:/root/.local/bin\"" | sudo tee -a /root/.zshrc

#set pipx path for bash and zsh on any other profiles
for dir in /home/*/; do
   if test -f $dir/.bashrc; then
	   echo "export PATH=\"\$PATH:$dir.local/bin\"" >> $dir/.bashrc
   fi
   if test -f $dir/.zshrc; then
	   echo "export PATH=\"\$PATH:$dir.local/bin\"" >> $dir/.zshrc
   fi
done


#get nessus version for download
echo Input Nessus Version Number ex 10.6.4
read nessus_version

wget https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-$nessus_version-debian10_amd64.deb -O nessus-install.deb
sudo dpkg -i nessus-install.deb
wget https://www.tenable.com/downloads/api/v2/pages/nessus/files/nessus-updates-$nessus_version.tar.gz -O nessus-updates.tar.gz
sudo /opt/nessus/sbin/nessuscli update nessus-updates.tar.gz

#install software with go

export GOPATH=/opt/nuclei
sudo -E go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
sudo ln -s /opt/nuclei/bin/nuclei /usr/local/bin/nuclei
nuclei -update-templates

export GOPATH=/opt/kerbrute
sudo -E go install github.com/ropnop/kerbrute@latest
sudo ln -s /opt/kerbrute/bin/kerbrute /usr/local/bin/kerbrute

export GOPATH=/opt/brutespray
sudo -E go install -v github.com/x90skysn3k/brutespray@latest
sudo ln -s /opt/brutespray/bin/brutespray /usr/local/bin/brutespray

export GOPATH=/opt/pretender
sudo -E go install -v github.com/RedTeamPentesting/pretender@latest
sudo ln -s /opt/pretender/bin/pretender /usr/local/bin/pretender

export GOPATH=/opt/gowitness
sudo -E go install github.com/sensepost/gowitness@latest
sudo ln -s /opt/gowitness/bin/gowitness /usr/local/bin/gowitness

#install pipx tools

pipx install pypykatz
pipx install git+https://github.com/Pennyw0rth/NetExec
pipx install git+https://github.com/blacklanternsecurity/MANSPIDER

pipx install ldapdomaindump
pipx install adidnsdump
pipx install bloodhound
pipx install bloodhound-ce
pipx install coercer
pipx install certipy-ad
pipx install smbclientng

#sudo pipx install mitm6
sudo apt install mitm6

sudo gem install evil-winrm

sudo mkdir /opt/wordlists
sudo wget https://gist.githubusercontent.com/nullenc0de/96fb9e934fc16415fbda2f83f08b28e7/raw/146f367110973250785ced348455dc5173842ee4/content_discovery_nullenc0de.txt -O /opt/wordlists/content_discovery_nullenc0de.txt
sudo wget https://gist.githubusercontent.com/nullenc0de/538bc891f44b6e8734ddc6e151390015/raw/a6cb6c7f4fcb4b70ee8f27977886586190bfba3d/passwords.txt -O /opt/wordlists/passwords.txt
sudo wget https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt -O /opt/wordlists/all.txt
sudo wget https://gist.githubusercontent.com/nullenc0de/9cb36260207924f8e1787279a05eb773/raw/0197d33c073a04933c5c1e2c41f447d74d2e435b/params.txt -O /opt/wordlists/params.txt


cd /opt

sudo git clone https://github.com/adrecon/ADRecon.git

sudo git clone https://github.com/projectdiscovery/nuclei-templates.git

#sudo git clone https://github.com/danielmiessler/SecLists.git

sudo git clone https://github.com/Greenwolf/Spray.git

sudo git clone https://github.com/vulnersCom/nmap-vulners.git

sudo git clone https://github.com/cube0x0/KrbRelay.git

sudo git clone https://github.com/sqlmapproject/sqlmap.git

sudo git clone https://github.com/trustedsec/SeeYouCM-Thief.git
cd SeeYouCM-Thief
python3 -m venv venv_SeeYouCM-Thief
source venv_SeeYouCM-Thief/bin/activate
venv_SeeYouCM-Thief/bin/pip3 install -r requirements.txt
deactivate
cd /opt

sudo git clone https://github.com/nikallass/sharesearch.git
cd sharesearch
python3 -m venv venv_sharesearch
source venv_sharesearch/bin/activate
venv_sharesearch/bin/pip3 install -r requirements.txt
deactivate
sudo apt-get install cifs-utils
cd /opt

sudo git clone https://github.com/SySS-Research/Seth.git
cd Seth
python3 -m venv venv_Seth
source venv_Seth/bin/activate
venv_Seth/bin/pip3 install -r requirements.txt
deactivate
cd /opt

sudo git clone https://github.com/Arvanaghi/SessionGopher.git
cd /opt

sudo git clone https://github.com/TKCERT/nessus-report-downloader.git

sudo git clone https://github.com/topotam/PetitPotam.git

sudo git clone https://github.com/lgandx/PCredz.git
cd PCredz
sudo docker build . -t pcredz
printf "run the following command from directory with data to analyze \n docker run --net=host -v \$(pwd):/opt/Pcredz/data -it pcredz\n" | sudo tee README_RUN_DOCKER.txt
cd /opt

sudo git clone https://github.com/iiitee/changeme.git
cd changeme/
sudo docker build -t changeme .
printf "run the following command with commandline options and targets \n docker run -it changeme \n" | sudo tee README_RUN_DOCKER.txt
cd /opt

sudo docker pull bettercap/bettercap
sudo mkdir /opt/BloodHoundCE
sudo wget https://ghst.ly/getbhce -O /opt/BloodHoundCE/docker-compose.yml
cd /opt/BloodHoundCE
sudo docker-compose pull

