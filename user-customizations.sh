#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

VAGRANTHOME=/home/vagrant/

if [ ! -f /usr/local/extra_homestead_software_installed ]; then
	echo 'installing some extra software and customizations...'

	
    # We should be super user 
	echo 'We should be super user ...'
    sudo -s 
    
	#suppress every further questions (ex.: apt-get -y install iptables-persistent show prompt)	
	echo "suppress every further questions ..."
	export DEBIAN_FRONTEND=noninteractive
	
	#
	# Time zone
	#
	echo 'set timezone'
	sudo timedatectl set-timezone Europe/Rome
	
	#
	# firewall: make iptables persistent
	# Warning actually on windows do not bypass prompt!
	#
	#echo 'make iptables persistent'
	#sudo apt-get -y install iptables-persistent

	#
	# custom nano
	#
	echo 'costomize nano'
	if [ -d /usr/share/nano/scopatz ]; then
		sudo rm -f -s /usr/share/nano/scopatz
	fi	
	sudo mkdir /usr/share/nano/scopatz
	cd  /usr/share/nano/scopatz
	sudo git clone https://github.com/scopatz/nanorc.git
	if [ -f /etc/nanorc ]; then
		sudo rm -f /etc/nanorc
	fi	
	sudo cat /usr/share/nano/scopatz/nanorc/*.nanorc >> /etc/nanorc
	cd $VAGRANTHOME
	
	#
	# Utilities
	#
	sudo apt-get -y install htop
	sudo apt-get -y install atop
	sudo apt-get -y install multitail
	sudo apt-get -y install goaccess
	sudo apt-get -y install apachetop
	sudo apt-get -y install mytop
	sudo apt-get -y install ncdu
	sudo apt-get -y install mc
	sudo apt-get -y install whois
	sudo apt-get -y install checkinstall
	sudo apt-get -y install apache2-utils 
	sudo apt-get -y install gdb
	sudo apt-get -y install iptraf
	sudo apt-get -y install iotop
	sudo apt-get -y install dnsutils
	sudo apt-get -y install locate
	sudo updatedb
	sudo apt-get -y install python-pip
    sudo apt-get -y install gcc make git libpcap0.8-dev
	sudo apt-get -y install httpry
	sudo apt-get -y install mydumper
	sudo apt-get -y install build-essential
	sudo apt-get -y install software-properties-common
	sudo pip install ngxtop
	sudo pip install --upgrade pip
	
	#
	# percona Xtrabackup
	#
	echo 'installing percona Xtrabackup...'
	cd $VAGRANTHOME
	rel=$(lsb_release -sc)
	if [ -f ${VAGRANTHOME}percona-release_0.1-4.${rel}_all.deb ]; then
		sudo rm -f ${VAGRANTHOME}percona-release_0.1-4.${rel}_all.deb
	fi	
	sudo wget https://repo.percona.com/apt/percona-release_0.1-4.${rel}_all.deb
	sudo dpkg -i percona-release_0.1-4.${rel}_all.deb
	sudo apt-get update
	sudo apt-get -y install percona-xtrabackup-24
	sudo rm -f percona-release_0.1-4.${rel}_all.deb

	#
	# percona toolkit
	#
	echo 'installing percona toolkit...'	
	sudo apt-get -y install percona-toolkit
	
	#
	# PHP LIB
	#
	echo "installing php lib ..."
	sudo apt-get -y install php-redis
	#sudo apt-get -y install php7.1-bz2
	sudo apt-get -y install php-imagick
	
		
	#
	# CONFIGURING PHP: 
	# configuring memory_limit && max_execution_time php.ini for 7.4/8.0/8.1
	#
	sudo sed -i 's/max_execution_time[[:space:]]=[[:space:]]30/max_execution_time=120/' /etc/php/7.4/fpm/php.ini
	sudo sed -i 's/memory_limit[[:space:]]=[[:space:]]512M/memory_limit=4096M/' /etc/php/7.4/fpm/php.ini
	sudo sed -i 's/max_execution_time[[:space:]]=[[:space:]]30/max_execution_time=120/' /etc/php/8.0/fpm/php.ini
	sudo sed -i 's/memory_limit[[:space:]]=[[:space:]]512M/memory_limit=4096M/' /etc/php/8.0/fpm/php.ini
	sudo sed -i 's/max_execution_time[[:space:]]=[[:space:]]30/max_execution_time=120/' /etc/php/8.1/fpm/php.ini
	sudo sed -i 's/memory_limit[[:space:]]=[[:space:]]512M/memory_limit=4096M/' /etc/php/8.1/fpm/php.ini


	
	#
	# Restart php/nginx services
	#
	echo "Restart php/nginx services ..."
    #sudo service php7.1-fpm restart
    sudo service php8.1-fpm restart
    sudo service nginx restart   

    #
    # install zsh
    #
	echo 'installing zsh'
    sudo apt-get -y install zsh
	
    #
    # install oh my zhs
	# ref.: https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
    # (after.sh is run as the root user, but ssh is the vagrant user)
    #
	cd $VAGRANTHOME
	ZSH=/home/vagrant/.oh-my-zsh
	if [ -d $ZSH ]; then
		sudo rm -f $ZSH
	fi	
    sudo git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $ZSH
	if [ -f $VAGRANTHOME.zshrc ]; then
		sudo rm -f $VAGRANTHOME.zshrc
	fi		
    sudo cp $ZSH/templates/zshrc.zsh-template $VAGRANTHOME.zshrc
sudo sed "/^export ZSH=/ c\\
export ZSH=$ZSH
" $VAGRANTHOME.zshrc > $VAGRANTHOME.zshrc-omztemp
sudo mv -f $VAGRANTHOME.zshrc-omztemp $VAGRANTHOME.zshrc
sudo sed "/^plugins=(git)/ c\\
plugins=(git colored-man colorize command-not-found compleat cp history sublime urltools web-search autojump fasd jump redis-cli repo symfony symfony2 debian copydir copyfile laravel laravel4 laravel5 rsync)
" $VAGRANTHOME.zshrc > $VAGRANTHOME.zshrc-omztemp
sudo mv -f $VAGRANTHOME.zshrc-omztemp $VAGRANTHOME.zshrc
    sudo chsh -s /usr/bin/zsh vagrant	
	
    #
    # use .dotfiles from osx
    #
    #rm -f $VAGRANTHOME.zshrc
    #ln -s $VAGRANTHOME.dotfiles/shell/.zshrc /home/vagrant/.zshrc    
    
    #
    # make tab complete case insensitive
    #
	echo "make tab complete case insensitive ..."
    sudo echo set completion-ignore-case on | sudo tee -a /etc/inputrc
        		
	#configuring mysql
	echo "configuring mysql8"
	sudo echo sql-mode="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" | sudo tee -a /etc/mysql/conf.d/mysqld.cnf
	sudo echo key_buffer_size=16M | sudo tee -a /etc/mysql/conf.d/mysqld.cnf
	sudo echo max_allowed_packet=512M | sudo tee -a /etc/mysql/conf.d/mysqld.cnf
	sudo echo sort_buffer_size=512M | sudo tee -a /etc/mysql/conf.d/mysqld.cnf
	sudo echo net_buffer_length=8K | sudo tee -a /etc/mysql/conf.d/mysqld.cnf
	sudo echo read_buffer_size=256K | sudo tee -a /etc/mysql/conf.d/mysqld.cnf
	sudo echo read_rnd_buffer_size=512K | sudo tee -a /etc/mysql/conf.d/mysqld.cnf
	sudo echo myisam_sort_buffer_size=8M | sudo tee -a /etc/mysql/conf.d/mysqld.cnf
	
	sudo sed -i 's/max_allowed_packet[[:space:]]=[[:space:]]16M/max_allowed_packet=512M/' /etc/mysql/conf.d/mysqldump.cnf
	#sudo echo max_allowed_packet=512M | sudo tee -a /etc/mysql/conf.d/mysqldump.cnf

	#
	# Restart mysql services
	#
	sudo /etc/init.d/mysql restart

    #
    # set up global gitignore
    #
	#echo "set up global gitignore"
    #git config --global core.excludesfile ~/.gitignore_global
	#if [ -f ~/.gitignore_global ]; then
	#	sudo rm -f ~/.gitignore_global
	#fi
    #echo ".DS_Store" > ~/.gitignore_global
    
    #
	# install pdftotext
	#
    sudo apt-get -y install poppler-utils
    
    #
    # Install ruby
	#
	#echo "Install ruby version manager (rvm)..."
	#gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
	#\curl -sSL https://get.rvm.io | bash -s stable
	#source /etc/profile.d/rvm.sh
	#echo "Install ruby 1.9.3 ..."
	#rvm 1.9.3 do gem install mime-types -v 2.6.2

    #
    # Install Mail catcher
	#
    #gem install mailcatcher 

	#
	# Install go
	#
	#wget https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
	#tar xvf go1.6.linux-amd64.tar.gz
	#rm go1.6.linux-amd64.tar.gz
	#chown -R root:root ./go
	#mv -f go /usr/local
	#echo "export GOPATH=\$HOME/work" >> $VAGRANTHOME.profile
	#echo "export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> $VAGRANTHOME.profile
	#source $VAGRANTHOME.profile
	
    #
    # Install MailHog (require go lang)
	#
    #go get github.com/mailhog/MailHog
	#wget https://raw.githubusercontent.com/geerlingguy/ansible-role-mailhog/master/templates/mailhog.init.j2
	#mv -f $VAGRANTHOME.mailhog.init.j2 /etc/init.d/mailhog
	#chmod +x /etc/init.d/mailhog
    #update-rc.d mailhog defaults 95 10
		
	#
    # elasticsearch 
	# (instructions copied from https://github.com/fideloper/Vaprobash/blob/master/scripts/elasticsearch.sh)	
    # 
	#echo "install elasticsearch ..."
    #ELASTICSEARCH_VERSION=5.5.2 # Check http://www.elasticsearch.org/download/ for latest version
    #apt-get -y install -qq openjdk-7-jre-headless
    #wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELASTICSEARCH_VERSION.deb	
    #dpkg -i elasticsearch-$ELASTICSEARCH_VERSION.deb
    #rm -f elasticsearch-$ELASTICSEARCH_VERSION.deb

    # Configure Elasticsearch for development purposes (1 shard/no replicas, don't allow it to swap at all if it can run without swapping)
    #sed -i "s/# index.number_of_shards: 1/index.number_of_shards: 1/" /etc/elasticsearch/elasticsearch.yml
    #sed -i "s/# index.number_of_replicas: 0/index.number_of_replicas: 0/" /etc/elasticsearch/elasticsearch.yml
    #sed -i "s/# bootstrap.mlockall: true/bootstrap.mlockall: true/" /etc/elasticsearch/elasticsearch.yml
    #service elasticsearch restart

    # Configure to start up Elasticsearch automatically
    #update-rc.d elasticsearch defaults 95 10
	
	#Download and install phpMyAdmin latest version
	echo "Installing phpmyadmin lastest version..."
	cd  /home/vagrant/codephp80
	if [ -d /home/vagrant/codephp80 ]; then
		echo "remove existent /home/vagrant/codephp80/phpmyadmin directory..."
		sudo rm -R --interactive=never phpmyadmin
	fi
	VERSION_INFO="$(sudo curl -sS 'https://www.phpmyadmin.net/home_page/version.txt')"
	LATEST_VERSION="$(sudo echo -e "$VERSION_INFO" | head -n 1)"
	LATEST_VERSION_URL="$(sudo echo -e "$VERSION_INFO" | tail -n 1)"
	# We want the .tar.gz version
	LATEST_VERSION_URL="${LATEST_VERSION_URL/.zip/.tar.gz}"

	echo "Downloading phpMyAdmin $LATEST_VERSION ($LATEST_VERSION_URL)"
	sudo curl $LATEST_VERSION_URL -q -# -o 'phpmyadmin.tar.gz'

	sudo mkdir phpmyadmin && sudo tar xf phpmyadmin.tar.gz -C phpmyadmin --strip-components 1

	sudo rm phpmyadmin.tar.gz

    
    #
    # remember that the extra software is installed
    #      
    sudo touch /usr/local/extra_homestead_software_installed
	
else    
    echo "extra software already installed... moving on..."
fi
