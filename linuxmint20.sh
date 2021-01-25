#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NOCOLOR='\033[0m'

general_success() {
	printf "${GREEN}✓ Done${NOCOLOR}\n\n"
	sleep 1
}

success() {
	printf "${GREEN}$1${NOCOLOR}\n"
}

error() {
	printf "${RED}$1${NOCOLOR}\n"
}

warn() {
	printf "${ORANGE}$1${NOCOLOR}\n"
}

check_version() {
    CODENAMESTR=`cat /etc/linuxmint/info | grep CODENAME`
    IFS='=' read -ra CODENAME <<< "$CODENAMESTR"

    if [ "${CODENAME[1]}" != "ulyana" ]; then
        error "Your version (${CODENAME[1]}) is not supported by this script"
        exit
    else 
		DESCRIPTIONSTR=`cat /etc/linuxmint/info | grep DESCRIPTION`
    	IFS='=' read -ra DESCRIPTION <<< "$DESCRIPTIONSTR"
		success "✓ ${DESCRIPTION[1]}\n"
	fi
}

install_themes() {
	cd $USERDIR
	warn "Installing Materia theme..."
	apt install materia-gtk-theme -y
	general_success

	warn "Installing Numix..."
	apt-add-repository ppa:numix/ppa -y
	apt update && apt install numix-icon-theme numix-icon-theme-circle -y
	general_success

	warn "Downloading Paper icons..."
	wget -O $USERDIR/papers.zip https://codeload.github.com/snwh/paper-icon-theme/zip/master -q --show-progress
	unzip -oq papers
	mv $USERDIR/paper-icon-theme-master/Paper $USERDIR/.icons/
	rm -Rf $USERDIR/paper-icon-theme-master && rm -f $USERDIR/papers.zip
	success "✓ Installed Paper icon theme\n"
}

USERNAME=$1
USERDIR=$2

if [[ $EUID -ne 0 ]]; then
   	warn "Did you use the launcher script?" 
	error "PLEASE RUN ME AS ROOT" 
   	exit 1
else
	if [ -z "$USERNAME" ]
	then
		warn "Something wrong is not right..."
		warn "Did you use the launcher script correctly?"
		error "Expected 1st arg USERNAME not to be empty"
		exit 1
	fi
	if [ -z "$USERDIR" ]
	then
		warn "Something wrong is not right..."
		warn "Did you use the launcher script correctly?"
		error "Expected 2nd arg USERDIR to contain user home dir (/home/username) but it is empty"
		exit 1
	fi

	cd $USERDIR
	clear

    echo "Linux Mint 20 post-install script"
    sleep 0.7
    printf "Checking version...\n"
    sleep 0.5

    check_version

	warn "User directory is set to $USERDIR\n\n"
	sleep 1
    
    warn "Running apt update && apt upgrade"
	sleep 1
	#sudo apt update && sudo apt upgrade -y

	sudo apt install dialog
	d=(dialog --separate-output --clear --checklist "Select the type of packages to install using SPACE BAR:" 0 0 16)
	options=(
		1  "Themes and Icons" off
		2  "Build Essentials" off
		3  "Git" off
		4  "Open JDK" off
		5  "IntelliJ IDEA Community 2020.3.1" off
		6  "Android Studio 4.1.1" off
		7  "PyCharm Community 2020.3.2" off
		8  "Visual Studio Code" off
		9  "Nodejs 14" off
		10 "PHP" off
		11 "SASS (node)" off
		12 "Firebase tools (node)" off
		13 "MySQL server" off
		14 "Discord" off
		15 "Skype for Linux" off
		16 "Telegram Desktop" off
		17 "WhatsApp Desktop *" off
		18 "Google Chrome" off
		19 "FileZilla" off
		20 "Laptop Mode Tools" off
		21 "TLD && Slimbook Battery (removes laptop-mode-tools)" off
		22 "Albert" off
		23 "Plank" off
		24 "VLC" off
		25 "Audacity" off
		26 "Spotify" off
		27 "Steam" off
		28 "Lutris" off
		29 "Pulse Effects" off
	)
	choices=$("${d[@]}" "${options[@]}" 2>&1 >/dev/tty)
	for choice in $choices
	do
		case $choice in
			1)
				install_themes
				;;
			2)
				warn "Installing Build Essentials..."
				apt install -y build-essential
				general_success
				;;
			3)
				warn "Installing git..."
				apt install -y git
				success "✓ Installed GIT (`git --version`). Plase configure it later\n"
				sleep 1
				;;
			4)	
				warn "Installing Default JDK..."
				apt install default-jdk -y
				success "✓ Installed Open JDK (`java --version | head -n 1`)"
				success "✓ `javac -version`\n"
				;;
			5)
				warn "Downloading IntelliJ IDEA Community 2020.3.1 from JetBrains..."
				wget https://download-cf.jetbrains.com/idea/ideaIC-2020.3.1.tar.gz -q --show-progress
				warn "Download complete, extracting..."
				mkdir IDEs 2> /dev/null
				tar -zxf ideaIC-2020.3.1.tar.gz --directory IDEs
				chown -R $USERNAME IDEs
				success "✓ IntelliJ IDEA Community 2020.3.1 can be found in `pwd`/IDEs\n"
				;;
			6)
				warn "Downloading Android Studio 4.1.1..."
				wget https://r2---sn-uxaxpo4vcg-j28l.gvt1.com/edgedl/android/studio/ide-zips/4.1.1.0/android-studio-ide-201.6953283-linux.tar.gz -q --show-progress
				warn "Download complete, extracting..."
				mkdir IDEs 2> /dev/null
				tar -zxf android-studio-ide-201.6953283-linux.tar.gz --directory IDEs
				apt install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
				chown -R $USERNAME IDEs
				success "✓ Android Studio 4.1.1 can be found in `pwd`/IDEs\n"
				;;
			7)	
				warn "Downloading PyCharm Community 2020.3.2 from JetBrains..."
				wget https://download-cf.jetbrains.com/python/pycharm-community-2020.3.2.tar.gz -q --show-progress
				warn "Download complete, extracting..."
				mkdir IDEs 2> /dev/null
				tar -zxf pycharm-community-2020.3.2.tar.gz --directory IDEs
				chown -R $USERNAME IDEs
				success "✓ PyCharm Community 2020.3.2 can be found in `pwd`/IDEs\n"
				;;
			8)
				warn "Installing Visual Studio Code..."
				wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
				add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
				apt update && apt install code
				success "✓ Installed VS Code `code --version\n`"
				;;
			9)
				warn "Installing Nodejs 14..."
				apt install -y curl software-properties-common
				curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
				apt install -y nodejs
				success "✓ Installed Nodejs (`node -v`)"
				success "✓ Installed npm (`npm -v`)\n"
				;;
			10)
				warn "Installing Apache..."
				apt install apache2 -y
				general_success

				warn "Installing PHP..."
				apt install php libapache2-mod-php -y
				general_success
	            
        		warn "Installing Phpmyadmin..."
				apt install -y phpmyadmin -y
				general_success

				warn "Cofiguring apache to run Phpmyadmin..."
				echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf

				sudo a2enmod rewrite
				service apache2 restart
				systemctl restart apache2
				success "✓ Installed `php -v | head -n 1`\n"
				;;
			11)	
				warn "Installing node SASS..."
				npmversion=`npm -v 2> /dev/null`
				if [ -z "$npmversion" ]
				then
					error "NPM not found\n"
				else
					npm install -g sass
					general_success
				fi
				;;
			12)
				warn "Installing node firebase-tools..."
				npmversion=`npm -v 2> /dev/null`
				if [ -z "$npmversion" ]
				then
					error "NPM not found\n"
				else
					npm install -g firebase-tools
					general_success
				fi
				;;
			13)
				warn "Installing mysql-server..."
				apt install mysql-server -y
				general_success
				;;
			14)
				warn "Installing Discord..."
				wget -O $USERDIR/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb" -q --show-progress
				sudo dpkg --force-all -i $USERDIR/discord.deb 
				rm -f $USERDIR/discord.deb
				general_success
				;;
			15)
				warn "Installing Skype for linux..."
				apt install apt-transport-https -y
				curl https://repo.skype.com/data/SKYPE-GPG-KEY | apt-key add -
				echo "deb https://repo.skype.com/deb stable main" | tee /etc/apt/sources.list.d/skypeforlinux.list
				apt update && apt install skypeforlinux -y
				general_success
				;;
			16)	
				warn "Installing Telegram Desktop..."
				sudo add-apt-repository ppa:atareao/telegram -y
				apt update && apt install telegram -y
				general_success
				;;
			17)
				warn "Installing Unofficial WhatsApp Desktop..."
				apt install whatsapp-desktop -y
				general_success
				;;
			18)
				warn "Installing Chrome..."
				wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
				sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
				apt update && apt install google-chrome-stable -y
				success "✓ Installed `google-chrome --version`\n"
				;;
			19)
				warn "Installing FileZilla..."
				apt install filezilla -y
				success "✓ Installed `filezilla --version | grep FileZilla`\n"
				;;
			20)
				warn "Installing Laptop power tools..."
				aptitude install -y powertop
				aptitude install -y pm-utils
				aptitude install -y laptop-mode-tools
				general_success
				;;
			21)
				warn "Installing TLP (removes laptop-mode-tools).."
				add-apt-repository ppa:linrunner/tlp -y
				apt update && apt install tlp tlp-rdw -y

				success "Use 'sudo tlp start' to start TPL for the first time"
				success "Configuration file can be found in /etc/default/tlp\n"

				warn "Installing Slimbook Battery..."
				add-apt-repository ppa:slimbook/slimbook -y
				apt update && apt install slimbookbattery -y
				general_success
				;;
			22)
				warn "Installing Albert launcher..."
				wget -O $USERDIR/albert.deb "https://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_20.04/amd64/albert_0.16.1_amd64.deb" -q --show-progress
				sudo dpkg --force-all -i $USERDIR/albert.deb 
				rm -f $USERDIR/albert.deb
				success "✓ Installed `albert --version`\n"
				;;
			23)
				warn "Installing Plank..."
				add-apt-repository ppa:ricotz/docky -y
				apt update && apt install plank -y
				success "✓ Installed Plank `plank --version`\n"
				;;
			24)
				warn "Installing VLC..."
				apt install vlc -y
				success "✓ Installed VLC `vlc --version`\n"
				;;
			25)
				warn "Installing Audacity..."
				apt install audacity -y
				success "✓ Installed `audacity --version`\n"
				;;
			26)
				warn "Installing Spotify..."
				wget -O- https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
				add-apt-repository "deb http://repository.spotify.com stable non-free" -y
				apt update && apt install spotify-client
				success "✓ Installed `spotify --version`\n"
				;;
			27)
				warn "Installing Steam..."
				dpkg --add-architecture i386
				apt update
				apt install libgl1-mesa-glx:i386 -y
				wget -O $USERDIR/steam.deb http://media.steampowered.com/client/installer/steam.deb -q --show-progress
				sudo dpkg --force-all -i $USERDIR/steam.deb
				rm -f $USERDIR/steam.deb
				general_success
				;;
			28)
				warn "Installing Lutris..."
				add-apt-repository ppa:lutris-team/lutris -y
				apt update && apt install lutris -y
				general_success
				;;
			29)
				warn "Installing Pulse Effects..."
				add-apt-repository ppa:mikhailnov/pulseeffects -y
				apt update && apt install pulseaudio pulseeffects --install-recommends -y
				general_success
				;;
		esac
	done
fi
