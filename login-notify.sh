#!/bin/env bash
# check the bash shell script is being run by root
if [ "$EUID" -ne 0 ]
  then echo 'this script must be run with sudo'
  exit
fi

echo 'updating'
apt --yes --quiet --quiet update
echo 'installing jq'
apt --yes --quiet --quiet install jq
echo 'installing nmap'
apt --yes --quiet --quiet install nmap
echo
echo 'example of JSON file : {"config":{"telegram":{"token":"your_token","chat_id":"your_chat_id"},"whitelist":["your_ip_address","your_ip_address/mask"]}}'
echo
printf 'enter path to JSON file (example http://domain.com/settings.json) : '
read json_file

echo '#!/bin/env bash' >> /etc/profile.d/login-notify.sh
echo '# content of /etc/profile.d/login-notify.sh' >> /etc/profile.d/login-notify.sh
echo '# get variables from json file' >> /etc/profile.d/login-notify.sh
echo 'token=$(curl --silent --show-error ' "$json_file" ' | jq --raw-output .config.telegram.token);' >> /etc/profile.d/login-notify.sh
echo 'chat_id=$(curl --silent --show-error ' "$json_file" ' | jq --raw-output .config.telegram.chat_id);' >> /etc/profile.d/login-notify.sh
echo 'whitelist=$(curl --silent --show-error ' "$json_file" ' | jq --raw-output '"'"'.config.whitelist | join(''"'' ''"'')'"'"');' >> /etc/profile.d/login-notify.sh

echo '# if ip address with mask make list of ip' >> /etc/profile.d/login-notify.sh
echo '  ip_list=$(nmap -sL $whitelist | awk '"'"'/Nmap scan report/{print $NF}'"'"');' >> /etc/profile.d/login-notify.sh

echo '# set variables for message' >> /etc/profile.d/login-notify.sh
echo 'time=$(date +"%Y-%m-%d %H:%M");' >> /etc/profile.d/login-notify.sh
echo 'host=$(hostname --fqdn);' >> /etc/profile.d/login-notify.sh
echo 'l=$(last | head -1);' >> /etc/profile.d/login-notify.sh
echo 'who=$(echo $l | awk '"'"'{print $1}'"'"');' >> /etc/profile.d/login-notify.sh
echo 'how=$(echo $l | awk '"'"'{print $2}'"'"' | sed '"'"'s/pts.*/ssh/'"'"' | sed '"'"'s/tty.*/console/'"'"');' >> /etc/profile.d/login-notify.sh
echo 'ipa=$(echo $l | awk '"'"'{print $3}'"'"');' >> /etc/profile.d/login-notify.sh

echo '# if console login send message, if ssh login with ip not listed in whitelist send message' >> /etc/profile.d/login-notify.sh
echo 'if [[ $how == "console" ]]; then' >> /etc/profile.d/login-notify.sh
echo '  message="$time - $host user $who login via $how";' >> /etc/profile.d/login-notify.sh
echo '  curl --silent --show-error --request POST "https://api.telegram.org/bot$token/sendMessage" --data chat_id="$chat_id" --data text="$message" > /dev/null 2>&1;' >> /etc/profile.d/login-notify.sh
echo 'elif [[ $how == "ssh" ]] && [[ $ip_list == *$ipa* ]]; then' >> /etc/profile.d/login-notify.sh
echo '  echo "$ipa in whitelist"; else' >> /etc/profile.d/login-notify.sh
echo '  message="$time - $host user $who login from $ipa via $how";' >> /etc/profile.d/login-notify.sh
echo '  curl --silent --show-error --request POST "https://api.telegram.org/bot$token/sendMessage" --data chat_id="$chat_id" --data text="$message" > /dev/null 2>&1;' >> /etc/profile.d/login-notify.sh
echo 'fi' >> /etc/profile.d/login-notify.sh
