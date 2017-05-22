import sys
import os
import hashlib
import json
import socket
import const
import logging

# Conig for ads module 
if (const.IS_WSGI_CALL):
	_defaultURLPrefix = 'https://www.yongwuart.com/flask/'
else:
	_defaultURLPrefix = 'http://127.0.0.1:5000/'

_picList = {
	'glowball':['png', _defaultURLPrefix + 'ads/pic/glowball'],
	'paperplane':['png', _defaultURLPrefix + 'ads/pic/paperplane'],
	'tetris2':['png', 'https://play.google.com/store/apps/details?id=com.yongwu.tetris099']
}

_appMapPics = {
	'glowball':{'pics':['paperplane'], 'scale':1.0},
	'paperplane':{'pics':['tetris2', 'glowball'], 'scale':0.8},
	'tetris2':{'pics':['glowball'], 'scale':1.0},
    'template_ios':{'pics':['glowball'], 'scale':1.0},
    'template_android':{'pics':['tetris2', 'paperplane'], 'scale':1.0}
}

_version = 1.8

################################################

_confJsonArr = {}
_confDict = {}

def init(fileDir):
	global _confDict
	global _confJsonArr
	_confDict = _createPicMd5Dict(fileDir)
	_confJsonArr = _createPicJsonDict(_confDict)
	logging.debug(json.dumps(_confDict))

def getJsonConf(name):
	global _confJsonArr
	return _confJsonArr.get(name)

def getJsonVersion():
	global _version
	return _version

def getFileExt(name):
	global _picList
	if (name in _picList):
		return _picList[name][0]
	else:
		return None

def _getBigFileMD5(filepath):
    if os.path.isfile(filepath):
        md5obj = hashlib.md5()
        maxbuf = 8192
        f = open(filepath,'rb')
        while True:
            buf = f.read(maxbuf)
            if not buf:
                break
            md5obj.update(buf)
        f.close()
        hash = md5obj.hexdigest()
        return str(hash).upper()
    else:
    	return None

def _createPicMd5Dict(fileDir):
	confDict = {}
	picNameMapMd5 = {}
	for appname, picArr in _appMapPics.iteritems():
		confDict[appname] = []
		for picName in picArr['pics']:
			tempDict = []
			if (picName not in picNameMapMd5):
				extName = picName + '.' + _picList[picName][0]
				picNameMapMd5[picName] = _getBigFileMD5(os.path.join(fileDir, extName))
			tempDict.append(picName)
			tempDict.append(_picList[picName][1])
			tempDict.append(picNameMapMd5[picName] + '.' + _picList[picName][0])
			confDict[appname].append(tempDict)

	return confDict

def _createPicJsonDict(md5Dic):
	confJsonArr = {}
	for name, md5List in md5Dic.iteritems():
		tempJson = {}
		tempJson['version'] = _version
		tempJson['scale'] = _appMapPics[name]['scale']
		tempJson['picArr'] = md5List
		confJsonArr[name] = json.dumps(tempJson)

	return confJsonArr
