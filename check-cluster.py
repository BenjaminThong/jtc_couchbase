#!/usr/bin/env python3
import urllib.request
import os
import json

etcd = os.getenv("ETCD_ENDPOINT", "empty");
if etcd != "empty":
	print(1);
else :
	val = json.loads(urllib.request.urlopen("http://" + etcd + ":4001/v2/keys/services/couchbase").readall().decode('utf-8'))
	if 'errorCode' in val:
		print(1);
	else:
		print(val['node']['nodes'][0]['value']);