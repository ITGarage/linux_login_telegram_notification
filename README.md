# linux login telegram notification

### Script create file login-notify.sh in /etc/profile.d/ 
Every time when user logins script read variables from external JSON file wich should look like this:

``` 
{"config":{
      "telegram":{
         "token":"your_token",
         "chat_id":"your_chat_id"},
      "whitelist":["your_ip_address","your_ip_address/mask"]}}
```
And sends message to configured chat when user login via console or ssh with ip address not listed in whitelist. 

 Output message examples:
>2020-08-04 20:48 - HostName user UserName login via console

>2020-08-04 20:48 - HostName user UserName login from 10.5.0.80 via ssh

(You can set whitelist with ip address/subnet mask. example 192.168.0.1/24)
