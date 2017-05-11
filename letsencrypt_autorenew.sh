#!/bin/sh
for arg in "$@"; do
	shift
	case "$arg" in
		"--webroot") set -- "$@" "-w" ;;
		"--webroot-path") set -- "$@" "-p" ;;
		"--email") set -- "$@" "-e" ;;
		*) set -- "$@" "$arg"
	esac
done

OPTIND=1
while getopts "wp:e:" opt ; do
	case "$opt" in
		w) authenticator_mode="webroot" ;;
		p) webroot_path=$OPTARG ;;
		e) email=$OPTARG ;;
	esac
done

shift $(expr $OPTIND - 1)

if [ $USER = "root" ] ; then
	green="\033[0;32m"
	blue="\033[0;36m"
	orange="\033[0;33m"
	red="\033[1;31m"
	nc="\033[0m"
	
	log_path="/var/log/letsencrypt_autorenew.log"

	if [ -d "/opt/letsencrypt/" ]; then
		letsencrypt_path="/opt/letsencrypt/"
	else
		letsencrypt_path="" # define here your Let's Encrypt path
	fi
	
	if [ -d "/etc/letsencrypt/live/" ]; then
		ssl_certificates_path="/etc/letsencrypt/live/"
	else
		ssl_certificates_path="" # define here your custom SSL certificate path
	fi
	
	if [ -f "/etc/apache2/apache2.conf" ] ; then
		webserver="apache2"
	elif [ -f "/etc/nginx/nginx.conf" ] ; then
		webserver="nginx"
	else
		webserver="" # define here your custom webserver service name
	fi
	
	if [ "$authenticator_mode" = "webroot" ] ; then
		if [ -z "$webroot_path" ] ; then
			webroot_path="/var/www/html"
		fi
		
		authenticator="--webroot --webroot-path "$webroot_path
	else
		authenticator_mode="standalone"
		authenticator="-a standalone"
	fi

	if [ -z "$email" ] ; then
		email=$USER"@"$(hostname)
	fi
	
	cd $ssl_certificates_path

	echo ""
	echo " "$(ls -lR | grep ^d | wc -l)" SSL certificates founded in "$ssl_certificates_path
	echo ""
	
	if [ "$authenticator_mode" = "standalone" ] ; then
		service $webserver stop
	fi
	
	renewed_domains=0
	renewal_failed_domains=0
	
	for certificates in */ ; do
		certificate=$certificates"fullchain.pem"
		
		not_after=`echo $(openssl x509 -noout -enddate -in $certificate) | sed -e "s/notAfter=//g"`
		not_after_timestamp=`date -d "$not_after" +%s`
		now_timestamp=`date +%s`
		days_remaining=$(((not_after_timestamp-now_timestamp)/86400))
		
		subject=`echo $(openssl x509 -noout -subject -in $certificate) | sed -e "s/subject= \/CN=//g"`
		
		alternative_dns=`echo $(openssl x509 -text -noout -in $certificate | grep DNS) | sed -e "s/DNS:/-d /g; s/-d $subject//g; s/,//g; s/ //g; s/-d/ -d /g"`
		alternative_dns_string=`echo "$alternative_dns" | sed -e "s/ -d /, /g"`
		
		rsa_key_size=`echo $(openssl x509 -text -noout -in $certificate | grep "Public-Key") | sed -e "s/Public-Key: (//g; s/ bit)//g"`
		
		if [ "$days_remaining" -lt 4 ] ; then
			echo " ["${red}"Critical"${nc}"] "$subject""$alternative_dns_string
			echo "            "$days_remaining" days remaining before expiration"
			echo "            Renewing certificate..."

			$letsencrypt_path/letsencrypt-auto certonly $authenticator --force-renewal --rsa-key-size $rsa_key_size --renew-by-default --email $email --text --agree-tos -d $subject""$alternative_dns > $log_path > /dev/null 2>&1
			
			if [ "$?" = 0 ] ; then
				echo "            "${green}"OK"${nc}
				echo ""
				
				renewed_domains=$((renewed_domains+1))
			else
				echo "            "${red}"Failed"${nc}
				echo ""
				
				renewal_failed_domains=$((renewal_failed_domains+1))
			fi
		elif [ "$days_remaining" -lt 20 ] ; then
			echo " ["${orange}"Warning"${nc}"] "$subject""$alternative_dns_string
			echo "           "$days_remaining" days remaining before expiration"	
			echo "           Renewing certificate..."

			$letsencrypt_path/letsencrypt-auto certonly $authenticator --force-renewal --rsa-key-size $rsa_key_size --renew-by-default --email $email --text --agree-tos -d $subject""$alternative_dns > $log_path > /dev/null 2>&1

			if [ "$?" = 0 ] ; then
				echo "           "${green}"OK"${nc}
				echo ""
				
				renewed_domains=$((renewed_domains+1))
			else
				echo "           "${red}"Failed"${nc}
				echo ""
				
				renewal_failed_domains=$((renewal_failed_domains+1))
			fi
		elif [ "$days_remaining" -lt 31 ] ; then
			echo " ["${blue}"Info"${nc}"] "$subject""$alternative_dns_string
			echo "        "$days_remaining" days remaining before expiration"
			echo ""
		else
			echo " ["${green}"OK"${nc}"] "$subject""$alternative_dns_string
			echo "      "$days_remaining" days remaining before expiration"
			echo ""
		fi
	done
	
	if [ "$authenticator_mode" = "standalone" ] ; then
		service $webserver start
	fi
	
	if [ "$renewed_domains" -eq 1 ] ; then
		echo " 1 SSL certificate have been renewed ! Relaunch the script again to see the result"
		echo ""
	elif [ "$renewed_domains" -gt 1 ] ; then
		echo " "$renewed_domains" SSL certificates have been renewed ! Relaunch the script again to see the result"
		echo ""
	fi
	
	if [ "$renewal_failed_domains" -eq 1 ] ; then
		echo " 1 SSL certificate have failed to renew ! Log details : "$log_path
		echo ""
	elif [ "$renewal_failed_domains" -gt 1 ] ; then
		echo " "$renewal_failed_domains" SSL certificates have failed to renew ! Log details : "$log_path
		echo ""
	fi
else
	echo "You are not root :("
	echo ""
fi
