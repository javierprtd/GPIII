#!/bin/bash

# Author: Javier Partido Rufo
# Date: 24/03/2022

if [ $# -ne 2 ] && [ $# -ne 4 ] && [ $# -ne 6 ]; then
    echo "Usage: ${0} --install wordpress|webview --analysis wordpress|webview --compile phar|apk";
    exit 0;
fi

case $1 in
  --install)
    INSTALL="${2}"
    ;;
  --analysis)
    ANALYSIS="${2}"
    ;;
  --compile)
    COMPILE="${2}"
    ;;
  *)
    echo "Unknown option ${1}"
    exit 1
    ;;
esac
case "$3" in
  --install)
    INSTALL="${4}"
    ;;
  --analysis)
    ANALYSIS="${4}"
    ;;
  --compile)
    COMPILE="${4}"
    ;;
  "")
    ;;
  *)
    echo "Unknown option ${3}"
    exit 1
    ;;
esac
case "$5" in
  --install)
    INSTALL="${6}"
    ;;
  --analysis)
    ANALYSIS="${6}"
    ;;
  --compile)
    COMPILE="${6}"
    ;;
  "")
    ;;
  *)
    echo "Unknown option ${5}"
    exit 1
    ;;
esac

echo "INSTALL  = ${INSTALL}"
echo "ANALYSIS = ${ANALYSIS}"
echo "COMPILE  = ${COMPILE}"

case "$INSTALL" in
  wordpress)
    echo "Installing wordpress... this require privileges";
    sleep 0.5;
    sudo apt update;
    sudo apt install -y php7.4 php7.4-mysql mysql-server;
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';"
    sudo mysql -u root -ppassword -e "FLUSH PRIVILEGES;"
    sudo mysql -u root -ppassword -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'password';"
    sudo mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'wordpress'@'localhost' WITH GRANT OPTION;"
    sudo mysql -u wordpress -ppassword -e "CREATE DATABASE proof_of_concept;"
    sudo apt install -y apache2;
    sudo chown -R $USER:$USER /var/www/html;
    cd;
    wget https://es.wordpress.org/latest-es_ES.zip
    unzip latest-es_ES.zip;
    rm latest-es_ES.zip;
    cd wordpress;
    B=`pwd`
    cd /var/www/html;
    mv $B/* .;
    rm -R $B;
    mv wp-config-sample.php wp-config.php;
    sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', 'proof_of_concept' );/g" wp-config.php
    sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', 'wordpress' );/g" wp-config.php
    sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', 'password' );/g" wp-config.php
    echo "Visit http://localhost/wp-admin/install.php and install wordpress finally";
    echo "Done";
    sleep 0.5;
    ;;
  webview)
    echo "Installing webview...";
    cd;
    git clone https://github.com/Luckae/Android-WebView-Example;
    echo "Done";
    sleep 0.5;
    ;;
  "")
    ;;
  *)
    echo "Invalid install package ${INSTALL}";
    exit 1;
    ;;
esac

case "$ANALYSIS" in
  wordpress)
    if [ ! "$(ls -A /var/www/html 2>/dev/null)" ]; then
      echo "Wordpress is not installed, you must install wordpress first";
      exit 1;
    fi;
    echo "Analyzing wordpress...";
    if [ ! "$(ls -A /home/${USER}/sonarqube-9.4.0.54424 2>/dev/null)" ]; then
      echo "First step install the sonarqube..."
      cd;
      rm -R sonarqube-9.4.0.54424/bin/linux-x86-64 2>/dev/null;
      wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.4.0.54424.zip;
      unzip sonarqube-9.4.0.54424.zip;
      rm sonarqube-9.4.0.54424.zip;
      cd sonarqube-9.4.0.54424/bin/linux-x86-64;
      echo "Executing de sonarqube server...";
      sleep 0.5;
      x-terminal-emulator -e ./sonar.sh console
    fi;
    echo "Second step scan the wordpress code..";
    echo "Visit http://localhost:9000 with credentials admin/admin . Create project and anote the project name and token login.";
    sleep 0.5;
    read -p "Enter the project name: " PK;
    read -p "Enter the token login: " LOGIN;
    cd;
    rm -R sonar-scanner-4.7.0.2747-linux 2>/dev/null;
    wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip;
    unzip sonar-scanner-cli-4.7.0.2747-linux.zip;
    rm sonar-scanner-cli-4.7.0.2747-linux.zip;
    export PATH=${HOME}/sonar-scanner-4.7.0.2747-linux/bin:${PATH};
    cd /var/www/html;
    sonar-scanner \
    -Dsonar.projectKey=${PK} \
    -Dsonar.sources=. \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.login=${LOGIN};
    echo "The results are in http://localhost:9000/projects";
    sleep 0.5;
    ;;
  webview)
    if [ ! -d "$HOME/Android-WebView-Example" ]; then
      echo "Webview is not installed, you must install webview first";
      echo "Aborted";
      exit 1;
    fi;
    echo "Analyzing webview...";
    echo "This require privileges...";
    sleep 0.5;
    sudo apt-get -y install nodejs;
    if [ ! "$(ls -A /home/${USER}/sonarqube-9.4.0.54424 2>/dev/null)" ]; then
      echo "First step install the sonarqube..."
      cd;
      rm -R sonarqube-9.4.0.54424/bin/linux-x86-64 2>/dev/null;
      wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.4.0.54424.zip;
      unzip sonarqube-9.4.0.54424.zip;
      rm sonarqube-9.4.0.54424.zip;
      cd sonarqube-9.4.0.54424/bin/linux-x86-64;
      echo "Executing de sonarqube server...";
      sleep 0.5;
      x-terminal-emulator -e ./sonar.sh console
    fi;
    cd;
    echo "Second step scan the webview code..";
    echo "Visit http://localhost:9000 with credentials admin/admin . Create project and anote the project name and token login.";
    sleep 0.5;
    read -p "Enter the project name: " PK;
    read -p "Enter the token login: " LOGIN;
    cd Android-WebView-Example;
    if [ ! grep "systemProp.sonar.host.url" gradle.properties 2>/dev/null ]; then
        printf "systemProp.sonar.host.url=http://localhost:9000" >> gradle.properties;
    fi;
    if [ ! grep "org.sonarqube" build.gradle 2>/dev/null ]; then
    	sed -ie '/allprojects/i \plugins {\n        id "org.sonarqube" version "3.3"\n}\n' build.gradle;
    fi;
    cd;
    rm -R sonar-scanner-4.7.0.2747-linux 2>/dev/null;
    wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip;
    unzip sonar-scanner-cli-4.7.0.2747-linux.zip;
    rm sonar-scanner-cli-4.7.0.2747-linux.zip;
    export PATH=${HOME}/sonar-scanner-4.7.0.2747-linux/bin:${PATH};
    cd Android-WebView-Example;
    ./gradlew sonarqube \
    -Dsonar.projectKey=${PK} \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.login=${LOGIN};
    echo "The results are in http://localhost:9000/projects";
    sleep 0.5;
    ;;
  "")
    ;;
  *)
    echo "Invalid analysis package ${ANALYSIS}";
    exit 1;
    ;;
esac

case "$COMPILE" in
  phar)
    if [ ! "$(ls -A /var/www/html 2>/dev/null)" ]; then
      echo "Wordpress is not installed, you must install wordpress first";
      exit 1;
    fi;
    echo "Compiling wordpress...";
    sleep 0.5;
    cd /var/www/html;
    cat <<EOF > create-phar.php
<?php

try {
    \$pharFile = 'wordpress.phar';

    if (file_exists(\$pharFile)) {
        unlink(\$pharFile);
    }
    
    \$phar = new Phar(\$pharFile);

    \$phar->startBuffering();

    \$defaultStub = \$phar->createDefaultStub('index.php');

    \$phar->buildFromDirectory(__DIR__ . '/');

    \$stub = "#!/usr/bin/env php \n" . \$defaultStub;

    \$phar->setStub(\$stub);

    \$phar->stopBuffering();

    \$phar->compressFiles(Phar::GZ);
    
    chmod(__DIR__ . '/wordpress.phar', 0775);

    echo "\$pharFile successfully created" . PHP_EOL;
} catch (Exception \$e) {
    echo \$e->getMessage();
}

?>
EOF
    ulimit -n 4096;
    php --define phar.readonly=0 create-phar.php;
    rm create-phar.php;
    echo "wordpress.phar saved in ${PWD}";    
    sleep 0.5;
    ;;
  apk)
    if [ ! -d "$HOME/Android-WebView-Example" ]; then
      echo "Webview is not installed, you must install webview first";
      echo "Aborted";
      exit 1;
    fi;
    echo "Compiling apk... this require privileges";
    sleep 0.5;
    sudo apt update;
    sudo apt install -y android-sdk;
    cd;
    wget https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip;
    unzip commandlinetools-linux-8092744_latest.zip;
    rm commandlinetools-linux-8092744_latest.zip;
    cd cmdline-tools/bin;
    echo "You must accept the licenses...";
    sudo ./sdkmanager --licenses --sdk_root=/usr/lib/android-sdk;
    cd;
    rm -R cmdline-tools;
    cd Android-WebView-Example;
    echo "sdk.dir = /usr/lib/android-sdk" > local.properties;
    if [ ! -f "$PWD/keystore.jks" ]; then
      keytool -genkey -alias javierprtd \
        -keyalg RSA -keystore keystore.jks \
        -dname "CN=Javier Partido, OU=javierprtd, O=Sun, L=Pamplona, S=Navarra, C=ES" \
        -storepass password -keypass password;
    fi;
    cd app;
    if [ ! grep "signingConfigs {\n        release" build.gradle 2>/dev/null ]; then
      sed -ie "/    buildTypes/i \    signingConfigs {\n        release {\n            storeFile file('../keystore.jks'\)\n            storePassword 'password'\n            keyAlias 'javierprtd'\n            keyPassword 'password'\n        }\n    }\n" build.gradle;
      sed -ie "/proguard-rules.pro/a \            signingConfig signingConfigs.release" build.gradle;
    fi;
    cd ..;
    sudo ./gradlew assembleRelease;
    echo "apk signed release saved in ${PWD}/app/build/outputs/apk/release/app-release.apk";
    sudo rm -R build;
    cd app;
    sudo chown alumno:alumno -R build;
    cd ..;
    echo "Done";
    sleep 0.5;
    ;;
  "")
    ;;
  *)
    echo "Invalid compile package ${COMPILE}";
    exit 1;
    ;;
esac
 
sleep 0.5;
exit 0;
