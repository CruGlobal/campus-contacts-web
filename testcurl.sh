#!/bin/bash
atk="b6fef51e27a21ffebb8ff33166ed0b8315b0b008987caf25d4cfb71c54f75b59"
baseurl="http://localhost:8889"
if [ ! -n "$1" ]
	then
	echo "fetching access_token via username & password"
	curl -i $baseurl/oauth/access_token \
		-F grant_type=password \
		-F client_id=1 \
		-F client_secret=c3dea407509f4b8ee93dc4f52eb917e01b9c4b8fc0c4a445938a0216ef327e4e \
		-F "scope=read" \
		-F username=matt.webb@cojourners.com \
		-F password=testtest
fi

if [ "$*" == "getuser" ]
	then
	echo "getuser"
	curl -i $baseurl/api/getuser \
		-H "Authorization: OAuth $atk"
fi

if [ "$*" == "none" ]
	then
	echo "grant_type=none.  2-legged oauth flow"
	curl -i $baseurl/oauth/access_token \
	-F grant_type=none \
	-F client_id=1 \
	-F client_secret=c3dea407509f4b8ee93dc4f52eb917e01b9c4b8fc0c4a445938a0216ef327e4e
fi	
