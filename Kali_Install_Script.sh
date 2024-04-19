#!/bin/bash

#Note, this is a script that I started to build after repeatedly needing to roll out builds. 
#I thought about creating a custom Kali Distro, however with needing to install custom tools from github 
#I decided on a modifiable script instead. When I started to build the script, 
#I built upon the foundation that Matthew Clark May had used in a Repository he created, but no longer maintains. Credit where it's due.

#if issues when running and saved using windows run this
#sed -i -e 's/\r$//'scriptname.sh

echo updating power settings
#pre-login power settings
#sudo -i -u Debian-gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
#sudo -i -u Debian-gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

#update default gdm3 profile to not sleep at login prompt
sed -i 's/# sleep-inactive-ac-type=.*/sleep-inactive-ac-type='"'"'nothing'"'"'/g' /etc/gdm3/greeter.dconf-defaults
sed -i 's/# sleep-inactive-battery-type=.*/sleep-inactive-battery-type='"'"'nothing'"'"'/g' /etc/gdm3/greeter.dconf-defaults

#user power settings
sudo -i -u eagadmin dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
sudo -i -u eagadmin dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'


apt-get update ; apt-get -y upgrade ; apt-get -y dist-upgrade ; apt-get -y autoremove ; apt-get -y autoclean ; echo

apt install -y golang

apt install -y virtualenv
apt install -y python3.11-venv
apt install -y python3-venv
apt install -y tmux

#remove preinstalled cme, causes issues with install here
apt remove -y crackmapexec


python3 -m pip install pipx

#set pipx path in bash and zsh profile for root profile
echo "export PATH=\"\$PATH:/root/.local/bin\"" >> /root/.bashrc
echo "export PATH=\"\$PATH:/root/.local/bin\"" >> /root/.zshrc

#set pipx path for bash and zsh on any other profiles
for dir in /home/*/; do
   if test -f $dir/.bashrc; then
	   echo "export PATH=\"\$PATH:$dir.local/bin\"" >> $dir/.bashrc
   fi
   if test -f $dir/.zshrc; then
	   echo "export PATH=\"\$PATH:$dir.local/bin\"" >> $dir/.zshrc
   fi
done


#apt-get install -y brutespray
apt-get install -y gobuster
apt-get install -y amass
apt-get install -y masscan

#get nessus version for download
echo Input Nessus Version Number ex 10.6.4
read nessus_version

wget https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-$nessus_version-debian10_amd64.deb -O nessus-install.deb
dpkg -i nessus-install.deb
wget https://www.tenable.com/downloads/api/v2/pages/nessus/files/nessus-updates-$nessus_version.tar.gz -O nessus-updates.tar.gz
/opt/nessus/sbin/nessuscli update nessus-updates.tar.gz


export GOPATH=/opt/nuclei
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
ln -s /opt/nuclei/bin/nuclei /usr/local/bin/nuclei
nuclei -update-templates

export GOPATH=/opt/kerbrute
go install github.com/ropnop/kerbrute@latest
ln -s /opt/kerbrute/bin/kerbrute /usr/local/bin/kerbrute

export GOPATH=/opt/brutespray
go install -v github.com/x90skysn3k/brutespray@latest
ln -s /opt/brutespray/bin/brutespray /usr/local/bin/brutespray

#mkdir /root/gist
#wget https://gist.githubusercontent.com/nullenc0de/96fb9e934fc16415fbda2f83f08b28e7/raw/146f367110973250785ced348455dc5173842ee4/content_discovery_nullenc0de.txt -O /root/gist/content_discovery_nullenc0de.txt
#wget https://gist.githubusercontent.com/nullenc0de/538bc891f44b6e8734ddc6e151390015/raw/a6cb6c7f4fcb4b70ee8f27977886586190bfba3d/passwords.txt -O /root/gist/passwords.txt
#wget https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt -O /root/gist/all.txt
#wget https://gist.githubusercontent.com/nullenc0de/9cb36260207924f8e1787279a05eb773/raw/0197d33c073a04933c5c1e2c41f447d74d2e435b/params.txt -O /root/gist/params.txt

echo "-------------------------------------------------------------------"
echo "--------------- Wordlists Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

cd /opt

echo "-------------------------------------------------------------------"
echo "--------------- Discover Installed, It installed Lots!! Next Tool! ----------------"
echo "-------------------------------------------------------------------"

cd /opt
ls | xargs -I{} git -C {} pull

echo "-------------------------------------------------------------------"
echo "----- Updated Github Tools, Next Phase ------"
echo "-------------------------------------------------------------------"

echo "-------------------------------------------------------------------"
echo "----- Update, Upgrade, and Dist-Upgrade Complete, Next Phase ------"
echo "-------------------------------------------------------------------"

sudo apt-get install htop hexedit exiftool exif -y 

echo "-------------------------------------------------------------------"
echo "---------- Basic Tools Installed, Next Phase ------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/sense-of-security/ADRecon.git

echo "-------------------------------------------------------------------"
echo "--------------- ADReconInstalled, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/ztgrace/changeme.git
cd changeme/
sudo apt-get install unixodbc-dev -y
sudo apt-get install libpq-dev -y
python3 -m venv venv_changeme
source venv_changeme/bin/activate
venv_changeme/bin/pip3 install -r requirements.txt
deactivate
cd /opt

echo "-------------------------------------------------------------------"
echo "--------------- Changeme Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/fortra/impacket.git
cd impacket
pip3 install .
python3 setup.py install
cd /opt

echo "-------------------------------------------------------------------"
echo "--------------- Impacket Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/projectdiscovery/nuclei-templates.git

echo "-------------------------------------------------------------------"
echo "--------------- Nuclei Templates Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

#git clone https://github.com/danielmiessler/SecLists.git

echo "-------------------------------------------------------------------"
echo "--------------- SecLists Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/Greenwolf/Spray.git

echo "-------------------------------------------------------------------"
echo "--------------- Spray Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

pipx install dnstwist

echo "-------------------------------------------------------------------"
echo "--------------- DnsTwist Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/vulnersCom/nmap-vulners.git

echo "-------------------------------------------------------------------"
echo "--------------- nmap-vulners Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/abhaybhargav/bucketeer.git

echo "-------------------------------------------------------------------"
echo "--------------- Bucketeer Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/initstring/linkedin2username.git
cd linkedin2username
python3 -m venv venv_linkedin2username
source venv_linkedin2username/bin/activate
venv_linkedin2username/bin/pip3 install -r requirements.txt
deactivate
cd /opt

echo "-------------------------------------------------------------------"
echo "--------------- Linked2username Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/cube0x0/KrbRelay.git

echo "-------------------------------------------------------------------"
echo "--------------- KrbRelay Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/Porchetta-Industries/CrackMapExec.git
cd CrackMapExec/
pipx install .
#pip3 install -r requirements.txt
cd /opt
#apt-get install python3-venv
#python3 -m pip install pipx
#pipx ensurepath
#pipx install crackmapexec
#apt install -y crackmapexec

echo "-------------------------------------------------------------------"
echo "--------------- Crackmapexec Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/sqlmapproject/sqlmap.git

echo "-------------------------------------------------------------------"
echo "--------------- Sqlmap Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

sudo git clone https://github.com/ly4k/Certipy.git
pipx install /opt/Certipy

echo "-------------------------------------------------------------------"
echo "--------------- Certipy Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

sudo git clone https://github.com/trustedsec/SeeYouCM-Thief.git
cd SeeYouCM-Thief
python3 -m venv venv_SeeYouCM-Thief
source venv_SeeYouCM-Thief/bin/activate
venv_SeeYouCM-Thief/bin/pip3 install -r requirements.txt
deactivate
cd /opt

echo "-------------------------------------------------------------------"
echo "--------------- SeeYouCM-Thief Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/nikallass/sharesearch.git
cd sharesearch
python3 -m venv venv_sharesearch
source venv_sharesearch/bin/activate
venv_sharesearch/bin/pip3 install -r requirements.txt
deactivate
sudo apt-get install cifs-utils
cd /opt

echo "-------------------------------------------------------------------"
echo "--------------- sharesearch Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/SySS-Research/Seth.git
cd Seth
python3 -m venv venv_Seth
source venv_Seth/bin/activate
venv_Seth/bin/pip3 install -r requirements.txt
deactivate
cd /opt

echo "-------------------------------------------------------------------"
echo "--------------- Seth Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/Arvanaghi/SessionGopher.git
cd /opt

echo "-------------------------------------------------------------------"
echo "--------------- SessionGopher Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/RedSiege/EyeWitness.git
cd /opt/EyeWitness/Python/setup
sudo ./setup.sh
sudo chmod -R 777 /opt/EyeWitness/Python
cd /opt

echo "-------------------------------------------------------------------"
echo "--------------- Eyewitness Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/TKCERT/nessus-report-downloader.git

echo "-------------------------------------------------------------------"
echo "--------------- Nessus Report Downloader Installed, Next Tool! ----"
echo "-------------------------------------------------------------------"

git clone https://github.com/topotam/PetitPotam.git

echo "-------------------------------------------------------------------"
echo "--------------- PetitPotam Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

git clone https://github.com/lgandx/PCredz.git
sudo apt install libpcap-dev -y
python -m pip install cython --upgrade
python -m pip install python-libpcap --upgrade

echo "-------------------------------------------------------------------"
echo "--------------- Predz Installed, Next Tool! ----------------"
echo "-------------------------------------------------------------------"

pipx install pypykatz
pipx install git+https://github.com/Pennyw0rth/NetExec

pipx install ldapdomaindump
pipx install adidnsdump
pipx install mitm6
gem install evil-winrm
pipx install bloodhound
pipx install coercer

apt-get install -y docker.io
apt-get install -y docker-compose

docker pull bettercap/bettercap
mkdir /opt/BloodHoundCE
wget https://ghst.ly/BHCEDocker -O /opt/BloodHoundCE/docker-compose.yml
cd /opt/BloodHoundCE
docker-compose pull


echo "-------------------------------------------------------------------"
echo "--------------- All Tools Installed/Updated! Go Break Some Stuff! ---------"
echo "-------------------------------------------------------------------"
