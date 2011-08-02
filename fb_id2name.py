#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import sys
import re
import urllib
import simplejson
reload(sys)
sys.setdefaultencoding('utf-8')

id_list = list()

for line in sys.stdin:
  uid = re.search('f2p_(\d+)', line)
  id_list.append(uid.group(1))

id_str = ','.join(id_list)
url_str = 'https://api.facebook.com/method/fql.query?format=json&query='
query_str = 'SELECT name FROM user WHERE uid IN (%s)' % id_str
query_str = urllib.quote(query_str)
url = url_str + query_str
page = urllib.urlopen(url)
json_obj = simplejson.loads(page.read())

for item in json_obj:
  print item['name']
