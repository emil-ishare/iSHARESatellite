#! /bin/sh

#Docker check and installations
IsDockerInstalledAlready=false
if which docker && docker --version && docker-compose --version; then
  echo "Docker is already installed"
  IsDockerInstalledAlready=true
else
  echo "Install docker and docker-compose"

sudo apt-get update ||  { echo 'update existing list of packages failed' ; exit 1; }

sudo apt install apt-transport-https ca-certificates curl software-properties-common -y ||  { echo 'installation of prerequisite packages which let apt use packages over HTTPS failed' ; exit 1; }

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - ||  { echo 'add the GPG key for the official Docker repository to your system failed' ; exit 1; }

sudo apt-key fingerprint 0EBFCD88 ||  { echo 'Adding fingerprint failed' ; exit 1; }

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" ||  { echo 'Adding Docker repository to APT sources failed' ; exit 1; }

sudo apt-get update -y || { echo 'update the package database with the Docker packages failed' ; exit 1; }

sudo apt-get install docker-ce docker-ce-cli containerd.io ||  { echo 'Downloading docker-ce adn docker-ce-cli failed' ; exit 1; }

sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose ||  { echo 'Downloading of docker-compose failed' ; exit 1; }

sudo chmod +x /usr/local/bin/docker-compose ||  { echo 'Moving file to root location failed' ; exit 1; }

sudo gpasswd -a $USER docker ||  { echo 'Adding Docker user failed' ; exit 1; }

docker version ;
fi

#Check jq and install

if jq --version; then
  echo "jq is already installed"
else
  echo "jq does not exist. Install jq"
sudo apt update ||  { echo 'update existing list of packages failed' ; exit 1; }

sudo apt install -y jq ||  { echo 'Installing of jq failed' ; exit 1; }
fi

#Installation of HLF Binaries

if [ -d "bin" ] && [ -d "config"  ] ;
then
    echo "Directory bin and config exists."  ||  { echo 'Binaries files already exist' ; exit 1; }
else
    echo "Error: Directory bin and config does not exists."
curl https://raw.githubusercontent.com/hyperledger/fabric/master/scripts/bootstrap.sh | bash -s -- 2.2.0 1.4.8 -d -s
fi


#Check and install openssl

if openssl version; then
  echo "openssl is installed"
else
  echo "Install openssl"
sudo apt update ||  { echo 'update existing list of packages failed' ; exit 1; }

sudo apt install build-essential checkinstall zlib1g-dev -y ||  { echo 'install build-essential failed' ; exit 1; }
cd /usr/local/src/ ;
wget https://www.openssl.org/source/openssl-1.1.1k.tar.gz ||  { echo 'wget openssl failed' ; exit 1; }
tar -xf openssl-1.1.1k.tar.gz ||  { echo 'Extracting openssl tar file failed' ; exit 1; }
cd openssl-1.1.1k.tar.gz;
openssl version ||  { echo 'check opensslversion failed' ; exit 1; }
sudo ./config --prefix=/us3r/local/ssl --openssldir=/usr/local/ssl shared zlib ||  { echo 'configure and compile OpenSSL failed' ; exit 1; }
sudo make ||  { echo 'make command failed' ; exit 1; }
sudo make test;
sudo make install;
fi

if [[ ${IsDockerInstalledAlready} = false ]]; then 
    cat <<EOF
**
** Reboot to complete the installation of docker before proceeding
**
EOF
fi
