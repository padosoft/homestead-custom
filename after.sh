#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

VAGRANTHOME=/home/vagrant/

if [ ! -f /usr/local/extra_homestead_software_installed ]; then
	echo 'installing some extra software and customizations...'

	
    # We should be super user 
    sudo -s 

	#
	# Time zone
	#
	echo 'set timezone'
	timedatectl set-timezone Europe/Rome
	
	#
	# firewall
	#
	echo 'make iptables persistent'
	apt-get -y install iptables-persistent

	#
	# custom nano
	#
	echo 'costomize nano'
	mkdir /usr/share/nano/scopatz
	cd  /usr/share/nano/scopatz
	git clone https://github.com/scopatz/nanorc.git
	cat /usr/share/nano/scopatz/nanorc/*.nanorc >> /etc/nanorc
	cd $VAGRANTHOME
	
	#
	# Utilities
	#
	apt-get -y install htop
	apt-get -y install atop
	apt-get -y install multitail
	apt-get -y install goaccess
	apt-get -y install apachetop
	apt-get -y install mytop
	apt-get -y install ncdu
	apt-get -y install mc
	apt-get -y install whois
	apt-get -y install checkinstall
	apt-get -y install apache2-utils 
	apt-get -y install gdb
	apt-get -y install iptraf
	apt-get -y install iotop
	apt-get -y install dnsutils
	apt-get -y install locate
	updatedb
	apt-get -y install python-pip
	apt-get -y install gcc make git libpcap0.8-dev
	apt-get -y install httpry
	apt-get -y install mydumper
	apt-get -y install build-essential
	apt-get -y install software-properties-common
	pip install ngxtop
	pip install --upgrade pip
	
	#
	# percona Xtrabackup
	#
	echo 'installing percona Xtrabackup...'
	cd $VAGRANTHOME
	rel=$(lsb_release -sc)
	wget https://repo.percona.com/apt/percona-release_0.1-4.${rel}_all.deb
	dpkg -i percona-release_0.1-4.${rel}_all.deb
	apt-get update
	apt-get -y install percona-xtrabackup-24

	#
	# percona toolkit
	#
	echo 'installing percona toolkit...'	
	apt-get -y install percona-toolkit
	
	#
	# PHP LIB
	#
	echo "installing php lib ..."
	apt-get -y install php-redis
	apt-get -y install php7.1-bz2
	apt-get -y install php-imagick
	
	#
	# Restart php/nginx services
	#
	echo "Restart php/nginx services ..."
    service php7.1-fpm restart
    service nginx restart   

    #
    # install zsh
    #
	echo 'installing zsh'
    apt-get -y install zsh
	
    #
    # install oh my zhs
	# ref.: https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
    # (after.sh is run as the root user, but ssh is the vagrant user)
    #
	cd $VAGRANTHOME
	ZSH=/home/vagrant/.oh-my-zsh
    git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $ZSH
    cp $ZSH/templates/zshrc.zsh-template $VAGRANTHOME.zshrc
sed "/^export ZSH=/ c\\
export ZSH=$ZSH
" $VAGRANTHOME.zshrc > $VAGRANTHOME.zshrc-omztemp
mv -f $VAGRANTHOME.zshrc-omztemp $VAGRANTHOME.zshrc
sed "/^plugins=(git)/ c\\
plugins=(git colored-man colorize command-not-found compleat cp history sublime urltools web-search autojump fasd jump redis-cli repo symfony symfony2 debian copydir copyfile laravel laravel4 laravel5 rsync)
" $VAGRANTHOME.zshrc > $VAGRANTHOME.zshrc-omztemp
mv -f $VAGRANTHOME.zshrc-omztemp $VAGRANTHOME.zshrc
    chsh -s /usr/bin/zsh vagrant	
	
    #
    # use .dotfiles from osx
    #
    #rm -f $VAGRANTHOME.zshrc
    #ln -s $VAGRANTHOME.dotfiles/shell/.zshrc /home/vagrant/.zshrc    
    
    #
    # make tab complete case insensitive
    #
	echo "make tab complete case insensitive ..."
    echo set completion-ignore-case on | tee -a /etc/inputrc
    
    #
    # set up global gitignore
    #
	#echo "set up global gitignore"
    #git config --global core.excludesfile ~/.gitignore_global
    #echo ".DS_Store" > ~/.gitignore_global
    
    #
	# install pdftotext
	#
    apt-get -y install poppler-utils
    
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
	curl https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
	tar xvf go1.6.linux-amd64.tar.gz
	chown -R root:root ./go
	mv go /usr/local
	echo "export GOPATH=\$HOME/work" >> $VAGRANTHOME.profile
	echo "export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> $VAGRANTHOME.profile
	source $VAGRANTHOME.profile
	
    #
    # Install MailHog
	#
    go get github.com/mailhog/MailHog
	wget https://raw.githubusercontent.com/geerlingguy/ansible-role-mailhog/master/templates/mailhog.init.j2
	mv -f $VAGRANTHOME.mailhog.init.j2 /etc/init.d/mailhog
	chmod +x /etc/init.d/mailhog
    update-rc.d mailhog defaults 95 10
		
	#
    # elasticsearch 
	# (instructions copied from https://github.com/fideloper/Vaprobash/blob/master/scripts/elasticsearch.sh)	
    # 
	#echo "install elasticsearch ..."
    #ELASTICSEARCH_VERSION=5.5.2 # Check http://www.elasticsearch.org/download/ for latest version
    #apt-get -y install -qq openjdk-7-jre-headless
    #wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELASTICSEARCH_VERSION.deb	
    #dpkg -i elasticsearch-$ELASTICSEARCH_VERSION.deb
    #rm elasticsearch-$ELASTICSEARCH_VERSION.deb

    # Configure Elasticsearch for development purposes (1 shard/no replicas, don't allow it to swap at all if it can run without swapping)
    #sed -i "s/# index.number_of_shards: 1/index.number_of_shards: 1/" /etc/elasticsearch/elasticsearch.yml
    #sed -i "s/# index.number_of_replicas: 0/index.number_of_replicas: 0/" /etc/elasticsearch/elasticsearch.yml
    #sed -i "s/# bootstrap.mlockall: true/bootstrap.mlockall: true/" /etc/elasticsearch/elasticsearch.yml
    #service elasticsearch restart

    # Configure to start up Elasticsearch automatically
    #update-rc.d elasticsearch defaults 95 10
    
    #
    # remember that the extra software is installed
    #      
    touch /usr/local/extra_homestead_software_installed
	
else    
    echo "extra software already installed... moving on..."
fi
