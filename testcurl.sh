#!/bin/bash
atk="b6fef51e27a21ffebb8ff33166ed0b8315b0b008987caf25d4cfb71c54f75b59"
baseurl="http://test.ccci.us:8881"

curl -i $baseurl/oauth/access_token \
	-F grant_type=authorization_code \
	-F client_id=4 \
	-F client_secret=a0f7de3c353d69c61d4c8a94b338c073d09ebd381bcb4a3b304c59cf4b15bfd5 \
	-F "scope=contacts,userinfo" \
	-F code=14914b05e0d4c7b83b5a883034889dba68ed096490a06a4de90fe1a369ca11cb \
	-F redirect_uri="http://test.ccci.us:8881/oauth/done"
# 
# if [ ! -n "$1" ]
# 	then
# 	echo "fetching access_token via username & password"
# 	curl -i $baseurl/oauth/access_token \
# 		-F grant_type=password \
# 		-F client_id=1 \
# 		-F client_secret=c3dea407509f4b8ee93dc4f52eb917e01b9c4b8fc0c4a445938a0216ef327e4e \
# 		-F "scope=read" \
# 		-F username=matt.webb@cojourners.com \
# 		-F password=testtest
# fi
# 
# if [ "$*" == "getuser" ]
# 	then
# 	echo "getuser"
# 	curl -i $baseurl/api/getuser \
# 		-H "Authorization: OAuth $atk"
# fi
# 
# if [ "$*" == "none" ]
# 	then
# 	echo "grant_type=none.  2-legged oauth flow"
# 	curl -i $baseurl/oauth/access_token \
# 	-F grant_type=none \
# 	-F client_id=1 \
# 	-F client_secret=c3dea407509f4b8ee93dc4f52eb917e01b9c4b8fc0c4a445938a0216ef327e4e
#fi	
