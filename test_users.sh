#!/bin/bash
app_id="164949660195249"
client_secret="727c29f0456f721456dcae1584eae164"

#get application access token
#curl -i https://graph.facebook.com/oauth/access_token \
#     -F "client_id=$app_id"  \
#     -F "client_secret=$client_secret" \
#     -F grant_type=client_credentials

#access token for Chama App
access_token="164949660195249|nRyrEz4Z5p9acHVI3HbfWC9BRzY"

if [ ! -n "$1" ]
	then
	echo "creating and getting login credentials for test user"

curl -i https://graph.facebook.com/$app_id/accounts/test-users \
  -F installed=false \
  -F permissions=read_stream \
  -F method=post \
  -F access_token=$access_token
fi

 #Test User 1:  
 # {"id":"499119138","access_token":null,"login_url":"https:\/\/www.facebook.com\/platform\/test_account_login.php?user_id=499119138&n=1Hc3encaCXFn6am",
 #"email":"sarvbul_romanwitz@tfbnw.net","password":"91467260"}

#Test User 2:
# {"id":"499119783","access_token":null,"login_url":"https:\/\/www.facebook.com\/platform\/test_account_login.php?user_id=499119783&n=nJelSa0KBpXPAWl",
# "email":"tjczolq_rosenthalman@tfbnw.net","password":"1023325644"}

#Test User 3:
# {"id":"499119862","access_token":null,"login_url":"https:\/\/www.facebook.com\/platform\/test_account_login.php?user_id=499119862&n=LZ0mff8DxtNB5El",
# "email":"ubcwqdd_seligsteinman@tfbnw.net","password":"1135941463"}

if [ "$*" == "friends" ]
	then
	friends=(499119138 499119783 499119862)
	echo "create friend relationships between test users"
	for id in $friends; do 
	  for id2 in $friends; do
	    curl -i https://graph.facebook.com/$id/friends/$id2 \
     	     -F method=post

			curl -i https://graph.facebook.com/$id2/friends/$id \
      		 -F method=post
     done
  done
fi
if [ "$*" == "users" ]
	then
		curl -i https://graph.facebook.com/$app_id/accounts/test-users \
  			 -F access_token=$access_token
fi