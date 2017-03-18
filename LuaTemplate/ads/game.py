import sys
import os
import adsConf
from flask import Flask, url_for, Response
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello World!'

@app.route('/ads/version')
def get_version():
	return str(adsConf.getJsonVersion())

@app.route('/ads/pic/<picName>')
def get_ads_pic(picName):
	ext = adsConf.getFileExt(picName)
	imageid = os.path.join(sys.path[0], 'static/adsPic/%s.%s' % (picName, ext))
	image = file(imageid)
	resp = Response(image, mimetype="image/%s" % ext)
	return resp

@app.route('/ads/conf/<packageName>')
def get_ads_conf(packageName):
	return adsConf.getJsonConf(packageName)

def _initAdsConf():
	adsConf.init(os.path.join(sys.path[0], 'static/adsPic'))

if __name__ == '__main__':
	_initAdsConf()
	app.run(debug=True)