#!/bin/bash

renewDate=`date +%m-%d-%Y`

exec >$renewDate.log 2>&1

echo "Cert renewal process has been started started!"

echo "Renewal Date is" $renewDate

echo "Creating directory"

mkdir $renewDate && cd $renewDate

echo "Starting renewal on $renewDate"

sudo certbot \
certonly \
--webroot \
--webroot-path "/opt/tomcat/webapps/${webapp}" \
-d ${domain} \
--rsa-key-size 4096 \
--force-renewal

echo "Converting cert to PKCS12 format"

sudo openssl pkcs12 \
-export \
-in /etc/letsencrypt/live/${domain-location}/cert.pem \
-inkey /etc/letsencrypt/live/{domain-location}/privkey.pem \
-out cert_and_key.p12 \
-password pass:${secret} \
-name tomcat \
-CAfile /etc/letsencrypt/live/${domain-location}/chain.pem \
-caname root

echo "Importing keystore"

sudo keytool \
-importkeystore \
-deststorepass ${destination-store-pass} \
-destkeypass ${destination-key-pass} \
-destkeystore ~/$renewDate/keystore \
-srckeystore cert_and_key.p12 \
-srcstoretype PKCS12 \
-srcstorepass ${source-store-pass} \
-alias {alias}

sudo keytool \
-importkeystore \
-srckeystore \
~/$renewDate/keystore \
-srcstorepass ${source-store-pass} \
-destkeystore \
~/$renewDate/keystore \
-destkeypass ${destination-key-pass} \
-deststoretype pkcs12

echo "Importing certificate chain"

sudo keytool \
-import -trustcacerts \
-alias root \
-file /etc/letsencrypt/live/${domain-location}/chain.pem \
-storepass ${store-pass} \
-keystore ~/$renewDate/keystore

cp ~/$renewDate/keystore ~/new_keystore

echo "Shutting down tomcat"

sudo /opt/tomcat/bin/shutdown.sh

sleep 10

#Sleep is to make sure the tomcat process is down. Ideally, a condition would be better to check the status of the service.

echo "Running VM updates"

#This step is optional. Since I am running this on AWS (lightsail), I take this opportunity to update my VM as well.

sudo yum update --quiet

sleep 5

echo "Copying original keystore for backup"

sudo cp /opt/tomcat/conf/keystore ~/$renewDate/original_keystore

echo "replacing keystore with new keystore"

sudo cp ~/$renewDate/keystore /opt/tomcat/conf/.

echo "Starting catalina"

sudo /opt/tomcat/bin/startup.sh

sleep 10

echo "Exiting certificate renewal!"
