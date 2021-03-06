#-*-coding:utf-8 -*-
import const
if __name__ == '__main__':
	const.IS_WSGI_CALL = False
	const.LOG_FILE = "game.log"
else:
	const.IS_WSGI_CALL = True
	const.LOG_FILE = "/var/www/game/game.log"

import sys
import os
import adsConf
import uuid
import time

from flask import Flask, url_for, Response, request, jsonify
from datetime import datetime, timedelta
from weixin.pay import Process_Pay 
from weixin.db import MongoConn

app = Flask(__name__)

import logging
logging.basicConfig(level=logging.DEBUG,
                format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
                datefmt='%a, %d %b %Y %H:%M:%S',
                filename=const.LOG_FILE,
                filemode='w')

@app.route('/')
def hello_world():
    return 'Hello World!'

@app.route('/ads/version')
def get_version():
	return str(adsConf.getJsonVersion())

@app.route('/ads/pic/<picName>')
def get_ads_pic(picName):
	ext = adsConf.getFileExt(picName)
	if (ext == None):
		return 'Not found this pic !'
	else:
		imageid = os.path.join(sys.path[0], 'static/adsPic/%s.%s' % (picName, ext))
		image = file(imageid)
		resp = Response(image, mimetype="image/%s" % ext)
		return resp

@app.route('/ads/conf/<packageName>')
def get_ads_conf(packageName):
	strConf = adsConf.getJsonConf(packageName)
	if (strConf == None):
		return None
	else:
		return strConf

def _initAdsConf():
    adsConf.init(os.path.join(sys.path[0], 'static/adsPic'))

def get_mac_address(): 
    mac=uuid.UUID(int = uuid.getnode()).hex[-12:] 
    return ":".join([mac[e:e+2] for e in range(0,11,2)])

_initAdsConf()


###############################################################################################
#####################################  WeiXin Pay #############################################
###############################################################################################

@app.route('/herochess/wxpay/unifyorder/<int:fee>')
def unifyOrder(fee):
    return Process_Pay().pay(fee)

@app.route('/herochess/wxpay/notify', methods=['POST'])
def payNotify():
    return Process_Pay().notify(request.data)


if (const.IS_WSGI_CALL == False):
    print 'local running'
    app.run(debug=True, host = '192.168.0.102')

