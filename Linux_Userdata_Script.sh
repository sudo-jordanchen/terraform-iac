#!/bin/bash
sudo su
sudo apt update -y
sudo apt upgrade -y
sudo apt-get install ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
cd /opt
sudo git clone --recurse-submodules https://github.com/cobbr/Covenant
cd Covenant/Covenant
sudo docker build -t covenant .
sudo apt install expect -y
echo -e '#!/bin/expect\nspawn sudo docker run -it -p 7443:7443 -p 8080:8080 -p 4433:4433 --name covenant -v /opt/Covenant/Covenant/Data:/app/Data covenant --username AdminUser --computername 0.0.0.0\nexpect "Password:"' > script
echo 'send "\n"' >> script
echo 'expect *root*' >> script
echo 'send "\n"' >> script
echo 'expect *root*' >> script
chmod 777 script
./script