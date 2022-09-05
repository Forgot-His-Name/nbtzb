#!/bin/sh

# need jq and curl to be installed

[ ! -f .env ] || export $(sed 's/#.*//g' .env | xargs)

count=`curl -s -X GET \
 -H "Authorization: TOKEN $NETBOX_TOKEN" \
 -H "Accept: application/json" \
 https://${NETBOX_HOST}/api/dcim/devices.json | jq -e '.count'`

if [ "$?" -eq "0" ]
then
  echo "netbox api: OK"
else
  echo "netbox api: FAIL"
fi

token=`curl -s -X POST \
 -H 'Content-Type: application/json' \
 -d "{\"jsonrpc\":\"2.0\", \"method\":\"user.login\", \"params\":{\"user\":\"${ZABBIX_USER}\", \"password\":\"${ZABBIX_PASS}\"}, \"id\":1, \"auth\":null } " https://${ZABBIX_HOST}/api_jsonrpc.php | jq -e '.result'`

if [ "$?" -eq "0" ]
then
  echo "zabbix api: OK"
else
  echo "zabbix api: FAIL"
fi

echo ""
