import sys
import os
import hashlib
import json

# Conig for ads module 
_defaultURLPrefix = 'http://127.0.0.1:5000/'
_picList = {
	'glowball':['png', _defaultURLPrefix + 'ads/pic/glowball'],
	'paperplane':['png', _defaultURLPrefix + 'ads/pic/paperplane'],
	'tetris2':['png', _defaultURLPrefix + 'ads/pic/tetris2']
}

_appMapPics = {
	'glowball':['paperplane'],
	'paperplane':['tetris2', 'glowball'],
	'tetris2':['glowball']
}

_version = 1.4

################################################

_confJsonArr = {}
_confDict = {}

def init(fileDir):
	global _confDict
	global _confJsonArr
	_confDict = _createPicMd5Dict(fileDir)
	_confJsonArr = _createPicJsonDict(_confDict)

def getJsonConf(name):
	global _confJsonArr
	if (name in _confJsonArr):
		return _confJsonArr[name]
	else:
		return None

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
		for picName in picArr:
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
		tempJson['picArr'] = md5List
		confJsonArr[name] = json.dumps(tempJson)

	return confJsonArr
