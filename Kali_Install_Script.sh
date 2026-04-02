#!/bin/bash

#Note, this is a script that I started to build after repeatedly needing to roll out builds. 
#I thought about creating a custom Kali Distro, however with needing to install custom tools from github 
#I decided on a modifiable script instead. When I started to build the script, 
#I built upon the foundation that Matthew Clark May had used in a Repository he created, but no longer maintains. Credit where it's due.

#if issues when running and saved using windows run this
#sed -i -e 's/\r$//'scriptname.sh

# Redirect stdout and stderr to a log file
exec > >(tee -a Kali_install_script_output.log) 2>&1

#update Kali
sudo apt-get update ; sudo apt-get full-upgrade -y ; sudo apt-get autoremove -y ; sudo apt-get autoclean -y ; echo

# ==========================================
# Kali Linux XFCE Power Management Hardening
# ==========================================

# 1. Pre-login power settings (systemd-logind)
# Prevents the system from sleeping or suspending on lid close at the login screen
# or system level (before login).
sudo mkdir -p /etc/systemd/logind.conf.d
sudo tee /etc/systemd/logind.conf.d/10-no-idle-sleep.conf > /dev/null <<'EOF'
[Login]
IdleAction=ignore
IdleActionSec=0
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF

echo "[*] Systemd-logind configuration updated."

# 2. LightDM / X Server DPMS Settings
# Disables screensaver and DPMS (Display Power Management) on the login screen.
sudo mkdir -p /etc/lightdm/lightdm.conf.d
sudo tee /etc/lightdm/lightdm.conf.d/50-no-dpms.conf > /dev/null <<'EOF'
[Seat:*]
xserver-command=X -s 0 -dpms
EOF

echo "[*] LightDM configuration updated."

# 3. User power settings (XFCE)
# Disable sleep on lid close or inactivity when logged in.
TARGET_USER=${SUDO_USER:-root}

echo "[*] Applying XFCE Power Manager settings for user: $TARGET_USER"

# Helper function to run xfconf-query as the target user
run_xfconf() {
    sudo -u "$TARGET_USER" xfconf-query -c xfce4-power-manager "$@"
}

# Disable sleep actions when logged in (on AC and on battery)
# Inactivity sleep mode (0 = Do nothing)
run_xfconf -p /xfce4-power-manager/inactivity-sleep-mode-on-ac --create -t int -s 0
run_xfconf -p /xfce4-power-manager/inactivity-sleep-mode-on-battery --create -t int -s 0

# Set inactivity timeout to never (0 = Never)
run_xfconf -p /xfce4-power-manager/inactivity-on-ac --create -t uint -s 0
run_xfconf -p /xfce4-power-manager/inactivity-on-battery --create -t uint -s 0

# Disable DPMS (Display Power Management)
run_xfconf -p /xfce4-power-manager/dpms-enabled --create -t bool -s false

# Lid action (0 = Nothing, 1 = Suspend, 2 = Hibernate, 3 = Shutdown, 4 = Lock screen, 5 = Switch off display)
run_xfconf -p /xfce4-power-manager/lid-action-on-ac --create -t uint -s 0
run_xfconf -p /xfce4-power-manager/lid-action-on-battery --create -t uint -s 0

echo "[*] XFCE settings applied."

# 4. Restart services to apply system-level changes
echo "[*] Restarting systemd-logind and upower..."
sudo systemctl restart systemd-logind
sudo systemctl restart upower

echo "[Done] Power settings configured. Please log out and back in if XFCE settings don't apply immediately."


# install golang
sudo apt install -y golang

# install python
sudo apt install -y virtualenv python3-all-venv python3-venv pipx

#install tmux
sudo apt install -y tmux

#install xfreerdp
sudo apt install -y freerdp2-x11

# install docker
sudo apt install -y docker.io
sudo apt install -y docker-compose

#remove preinstalled software that causes some conflicts with updated installs below
sudo apt remove -y crackmapexec tightvncserver netexec evil-winrm

source ./Vnc-info.txt

sudo apt install -y xterm

curl -L -o VNC.deb https://downloads.realvnc.com/download/file/vnc.files/VNC-Server-Latest-Linux-x64.deb
sudo apt install -y ./VNC.deb

echo 'AllowIpListenRfb=0' | sudo tee -a /root/.vnc/config.d/vncserver-x11
echo 'EnableAnalytics=0' | sudo tee -a /root/.vnc/config.d/vncserver-x11
echo 'EnableAutoUpdateChecks=1' | sudo tee -a /root/.vnc/config.d/vncserver-x11
echo 'Encryption=AlwaysMaximum' | sudo tee -a /root/.vnc/config.d/vncserver-x11

sudo vncserver-x11 -service -joinCloud "$VNC_Cloud_Token" -joinGroup "$VNC_Group"

read -p "Press any key to resume ..."

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

#install software with go

export GOPATH=/opt/nuclei
sudo -E go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
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

export GOPATH=/opt/go-out
sudo -E go install -v github.com/sensepost/go-out@latest
sudo ln -s /opt/go-out/bin/go-out /usr/local/bin/go-out

#install pipx tools

pipx install pypykatz
pipx install git+https://github.com/Pennyw0rth/NetExec
pipx install git+https://github.com/blacklanternsecurity/MANSPIDER
pipx install git+https://github.com/iiitee/parsuite
#pipx install git+https://github.com/lgandx/Responder

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

sudo git clone https://github.com/Flangvik/statistically-likely-usernames.git

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

sudo git clone https://github.com/cisagov/snafflepy.git
cd snafflepy
python3 -m venv venv_snafflepy
source venv_snafflepy/bin/activate
venv_snafflepy/bin/pip3 install -r requirements.txt
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

sudo git clone https://github.com/secorizon/MSFinger.git

sudo git clone https://github.com/TKCERT/nessus-report-downloader.git

sudo git clone https://github.com/topotam/PetitPotam.git

sudo git clone https://github.com/lgandx/PCredz.git
cd PCredz
sudo docker build . -t pcredz
printf "run the following command from directory with data to analyze \n docker run --rm -v \$(pwd):/data pcredz -f /data/capture.pcap\n" | sudo tee README_RUN_DOCKER.txt
cd /opt

sudo git clone https://github.com/iiitee/changeme.git
cd changeme/
sudo docker build -t changeme .
printf "run the following command with commandline options and targets \n docker run -it changeme \n" | sudo tee README_RUN_DOCKER.txt
cd /opt

sudo docker pull tenable/nessus:latest-ubuntu
sudo docker pull bettercap/bettercap

sudo mkdir /opt/BloodHoundCE
sudo wget https://ghst.ly/getbhce -O /opt/BloodHoundCE/docker-compose.yml
cd /opt/BloodHoundCE
sudo docker-compose pull

