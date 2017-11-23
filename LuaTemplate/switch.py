#!/usr/bin/env python
# -*- coding: utf8 -*-
# http://www.python-excel.org
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import os
import shutil
import json
import re
from Tools.iconscale.tool import image_produce_run
from Tools.excel2csv.excel2csv import excel2csvDir
from Tools.texturePacker.packTextures import packagePic

def replace_string(filepath, src_string, dst_string):
    """ From file's content replace specified string
    Arg:
        filepath: Specify a file contains the path
        src_string: old string
        dst_string: new string
    """
    if src_string is None or dst_string is None:
        raise TypeError

    content = ""
    f1 = open(filepath, "rb")
    for line in f1:
        strline = line.decode('utf8')
        if src_string in strline:
            content += strline.replace(src_string, dst_string)
        else:
            content += strline
    f1.close()
    f2 = open(filepath, "wb")
    f2.write(content.encode('utf8'))
    f2.close()

def replaceRegularString(filepath, reStr, dstString):
    f1 = open(filepath, "rb")
    reInfo = re.compile(reStr)
    content = reInfo.sub(dstString, f1.read())
    f1.close()
    f2 = open(filepath, "wb")
    f2.write(content.encode('utf8'))
    f2.close()

def replacePlistKeyValue(filepath, key, reSrcValueStr, dstvalueStr):
    content = ""
    nextReplace = False
    f1 = open(filepath, "rb")
    reInfo = re.compile(reSrcValueStr)

    for line in f1:
        strline = line.decode('utf8')
        if key in strline:
            nextReplace = True
        else:
            if nextReplace == True:
                strline = reInfo.sub(dstvalueStr, strline)
                nextReplace = False

        content += strline
    f1.close()
    f2 = open(filepath, "wb")
    f2.write(content.encode('utf8'))
    f2.close()

def get_current_path():
    return os.path.split(os.path.realpath(__file__))[0]

def isGameDirExist(name):
    curPath = get_current_path()
    if os.path.exists(os.path.join(curPath, "src", "app", name)) or \
        os.path.exists(os.path.join(curPath, "res", name)):
        return True
    else:
        return False

def isGameDirExistBoth(name):
    curPath = get_current_path()
    if os.path.exists(os.path.join(curPath, "src", "app", name)) and \
        os.path.exists(os.path.join(curPath, "res", name)):
        return True
    else:
        return False

def newGame(name, packageName):
    curPath = get_current_path()
    if not isGameDirExist(name):
        ##os.mkdir(os.path.join(curPath, "res", name))
        shutil.copytree(os.path.join(curPath, "src", "app", "template"), 
            os.path.join(curPath, "src", "app", name))
        shutil.copytree(os.path.join(curPath, "res", "template"), 
            os.path.join(curPath, "res", name))
        if isGameDirExistBoth(name):
            os.rename(os.path.join(curPath, "src", "app", name, "template_config.json"), 
                os.path.join(curPath, "src", "app", name, '%s_config.json'%name))
            relplaceGameConfig(name, packageName)
    else:
        print 'The python script is not in the correct dir or the %s dir is already exist' % name

def removeGame(name):
    curPath = get_current_path()
    if isGameDirExistBoth(name):
        shutil.rmtree(os.path.join(curPath, "src", "app", name))
        shutil.rmtree(os.path.join(curPath, "res", name))
    else:
        print 'The game dir to be remove may not exist !'

# move all files and dirs under sourceDir to destDir
def mergeDir(sourceDir, destDir):
    for f in os.listdir(sourceDir):
        shutil.move(os.path.join(sourceDir, f), destDir)

def recoverGameDir():
    curPath = get_current_path()

    if len(os.listdir(os.path.join(curPath, "temp", "src"))) > 0 :
        for f in os.listdir(os.path.join(curPath, "src", "app")):
            if os.path.isdir(os.path.join(curPath, "src", "app", f)):
                shutil.rmtree(os.path.join(curPath, "src", "app", f))

        for f in os.listdir(os.path.join(curPath, "res")):
            if os.path.isdir(os.path.join(curPath, "res", f)):
                shutil.rmtree(os.path.join(curPath, "res", f))

        mergeDir(os.path.join(curPath, "temp", "src"), os.path.join(curPath, "src", "app"))
        mergeDir(os.path.join(curPath, "temp", "res"), os.path.join(curPath, "res"))
    else:
        print('Nothing to recover !')

def relplaceGameConfig(name, packageName):
    curPath = get_current_path()
    replace_string(os.path.join(curPath, "src", "app", name, "%s_config.json"%name), '"appName":"template"', 
        '"appName":"%s"'%name)
    replace_string(os.path.join(curPath, "src", "app", name, "%s_config.json"%name), '"packageName":"com.yongwuart.template",', 
        '"packageName":"%s",'%packageName)

def applayGameConfigToProject(name):
    curPath = get_current_path()
    f = open(os.path.join(curPath, "src", "app", name, "%s_config.json"%name))
    gameConfig = json.load(f)
    f.close()

    ## Auto Scale, Design resolution
    replaceRegularString(os.path.join(curPath, "src", "config.lua"), "width = .*", 
        'width = %d,'%gameConfig['width'])
    replaceRegularString(os.path.join(curPath, "src", "config.lua"), "height = .*", 
        'height = %d,'%gameConfig['height'])
    replaceRegularString(os.path.join(curPath, "src", "config.lua"), 'autoscale = .*', 
        'autoscale = "%s",'%gameConfig['autoScale1'])
    replaceRegularString(os.path.join(curPath, "src", "config.lua"), 'return {autoscale = .*', 
        'return {autoscale = "%s"}'%gameConfig['autoScale2'])

    ## android
    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/AndroidManifest.xml"),
        "package=.*", 'package="%s"'%gameConfig['android']['packageName'])
    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/build.gradle"),
        "versionCode.*", 'versionCode %d'%gameConfig['android']['versionCode'])
    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/build.gradle"),
        "versionName.*", 'versionName "%s"'%gameConfig['android']['version'])
    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/build.gradle"),
        "applicationId.*", 'applicationId "%s"'%gameConfig['android']['packageName'])
    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/res/values/strings.xml"),
        '<string name="app_name">.*', '<string name="app_name">%s</string>'%gameConfig['android']['appDisplayName'])
    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/res/values/strings.xml"),
        '<string name="app_id">.*', '<string name="app_id">%s</string>'%gameConfig['android']['googlePlayAppId'])

    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/res/values-zh-rCN/strings.xml"),
        '<string name="app_name">.*', '<string name="app_name">%s</string>'%gameConfig['android']['appDisplayName_cn'])
    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/res/values-zh-rCN/strings.xml"),
        '<string name="app_id">.*', '<string name="app_id">%s</string>'%gameConfig['android']['googlePlayAppId'])

    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/src/org/cocos2dx/lua/GameHelperUtils.java"),
        'import com.*.R;', 'import %s.R;'%gameConfig['android']['packageName'])

    if os.path.exists(os.path.join(curPath, "res/%s/google-services.json"%name)):
        shutil.copy(os.path.join(curPath, "res/%s/google-services.json"%name), 
            os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app"))

    ## ios
    replacePlistKeyValue(os.path.join(curPath, "frameworks/runtime-src/proj.ios_mac/ios/Info.plist"),
        "CFBundleShortVersionString", '<string>.*$', '<string>%d</string>'%gameConfig['ios']['versionCode'])
    replacePlistKeyValue(os.path.join(curPath, "frameworks/runtime-src/proj.ios_mac/ios/Info.plist"),
        "CFBundleVersion", '<string>.*$', '<string>%s</string>'%gameConfig['ios']['version'])
    replacePlistKeyValue(os.path.join(curPath, "frameworks/runtime-src/proj.ios_mac/ios/Info.plist"),
        "CFBundleIdentifier", '<string>.*$', '<string>%s</string>'%gameConfig['ios']['packageName'])
    replacePlistKeyValue(os.path.join(curPath, "frameworks/runtime-src/proj.ios_mac/ios/Info.plist"),
        "CFBundleDisplayName", '<string>.*$', '<string>%s</string>'%gameConfig['ios']['appDisplayName'])

    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.ios_mac/en.lproj/InfoPlist.strings"),
        'CFBundleDisplayName = .*$', 'CFBundleDisplayName = "%s";'%gameConfig['ios']['appDisplayName'])
    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.ios_mac/zh-Hans.lproj/InfoPlist.strings"),
        'CFBundleDisplayName = .*$', 'CFBundleDisplayName = "%s";'%gameConfig['ios']['appDisplayName_cn'])
    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.ios_mac/Base.lproj/InfoPlist.strings"),
        'CFBundleDisplayName = .*$', 'CFBundleDisplayName = "%s";'%gameConfig['ios']['appDisplayName'])

    if os.path.exists(os.path.join(curPath, "res/%s/GoogleService-Info.plist"%name)):
        shutil.copy(os.path.join(curPath, "res/%s/GoogleService-Info.plist"%name), 
            os.path.join(curPath, "frameworks/runtime-src/proj.ios_mac/ios"))

    ## common

def excel2csv(name):
    curPath = get_current_path()
    csvDir = os.path.join(curPath, "res/%s/csv"%name)
    if os.path.exists(csvDir):
        shutil.rmtree(csvDir)

    os.mkdir(csvDir)
    excel2csvDir(os.path.join(curPath, "Share/%s"%name, u"配置表"), csvDir)

def texturepack(name):
    curPath = get_current_path()

    destDir = os.path.join(curPath, "res/%s"%name)
    cocostudioDir = os.path.join(curPath, "Share/demo/cocosstudio/%s"%name)
    if not os.path.exists(cocostudioDir):
        cocostudioDir = None

    packagePic(os.path.join(curPath, "Share/%s"%name, "packageRes"), destDir, cocostudioDir)

def applyGameIcon(name):
    curPath = get_current_path()
    image_produce_run(
        os.path.join(curPath, "res/%s/512.png"%name), 
        os.path.join(curPath, "res/%s/splash.png"%name),
        os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/res/mipmap-xxhdpi/ic_launcher.png"),
        os.path.join(curPath, "frameworks/runtime-src/proj.ios_mac/LuaTemplate-mobile/Images.xcassets/AppIcon.appiconset"),
        os.path.join(curPath, "frameworks/runtime-src/proj.ios_mac/ios"))

def applyGame(name):
    if isGameDirExistBoth(name):
        curPath = get_current_path()
        replaceRegularString(os.path.join(curPath, "src", "config.lua"), "DD_WORKING_GAME_NAME =.*", 
            'DD_WORKING_GAME_NAME = "%s"'%name)
        applayGameConfigToProject(name)
    else:
        print('The game %s is not exist !' % name)

def beforePackageGame(name):
    curPath = get_current_path()

    ## move all games src and res to temp dir
    for f in os.listdir(os.path.join(curPath, "src", "app")):
        if os.path.isdir(os.path.join(curPath, "src", "app", f)):
            shutil.move(os.path.join(curPath, "src", "app", f), os.path.join(curPath, "temp", "src"))

    for f in os.listdir(os.path.join(curPath, "res")):
        if os.path.isdir(os.path.join(curPath, "res", f)):
            shutil.move(os.path.join(curPath, "res", f), os.path.join(curPath, "temp", "res"))

    ## get lua encrypt key and sign
    f = open(os.path.join(curPath, "temp", "src", name, "%s_config.json"%name))
    gameConfig = json.load(f)
    f.close()
    luaKey = gameConfig.pop('luaCompileKey')
    luaSign = gameConfig.pop('luaCompileSign')

    ## encode lua code
    os.system('cocos luacompile -s %s -d %s -e -k %s -b %s --disable-compile'%
        (os.path.join(curPath, 'temp', 'src', name), os.path.join(curPath, 'src', 'app', name), luaKey, luaSign))

    ## copy name_config.json
    shutil.copy(os.path.join(curPath, 'temp', 'src', name, '%s_config.json'%name), 
        os.path.join(curPath, 'src', 'app', name, '%s_config.json'%name))
    gameConfig['packageVersion'] = True
    packageJson = json.dumps(gameConfig, encoding = 'utf8')
    f2 = open(os.path.join(curPath, 'src', 'app', name, '%s_config.json'%name), "wb")
    f2.write(packageJson)
    f2.close()

    ## set decode key and sign in AppDelegate.cpp 
    replaceRegularString(os.path.join(curPath, 'frameworks/runtime-src/Classes/AppDelegate.cpp'), 
            'stack->setXXTEAKeyAndSign.*', 
            'stack->setXXTEAKeyAndSign("%s", strlen("%s"), "%s", strlen("%s"));'%(luaKey, luaKey, luaSign, luaSign)) 
    
    shutil.copytree(os.path.join(curPath, 'temp', 'res', name), os.path.join(curPath, 'res', name))
    #os.remove(os.path.join(curPath, 'res', name, '512.png'))
    #os.remove(os.path.join(curPath, 'res', name, 'splash.png'))
    os.remove(os.path.join(curPath, 'res', name, 'google-services.json'))
    os.remove(os.path.join(curPath, 'res', name, 'GoogleService-Info.plist'))

def assertEnoughArgs(needCount):
    if len(sys.argv) < needCount:
        print("Not enough args !")
        return False
    else:
        return True

def prefixPackageRes(name):
    curPath = get_current_path()
    d = os.path.join(curPath, "Share/%s"%name, "packageRes")
    nameLen = len(name)
    for f in os.listdir(d):
        filesDir = os.path.join(d, f)
        if os.path.isdir(filesDir):
            for file in os.listdir(filesDir):
                if not (file[0:nameLen] == name) and not (file[0:0] == '.') :
                    os.rename(os.path.join(filesDir, file), os.path.join(filesDir, "%s_%s"%(name, file)))

def run():
    curPath = get_current_path()
    if not (os.path.exists(os.path.join(curPath, "res")) and \
        os.path.exists(os.path.join(curPath, "temp")) and \
        os.path.exists(os.path.join(curPath, "temp", "src")) and \
        os.path.exists(os.path.join(curPath, "temp", "res"))):

        print('This script is not working under correct directory !')
    else:
        if len(sys.argv) <= 1:
            print("No args !")
        elif sys.argv[1] == 'package':
            if assertEnoughArgs(3):
                ## make sure no temp dirs
                assert(len(os.listdir(os.path.join(curPath, 'temp', 'src'))) <= 0) 
                applyGame(sys.argv[2])
                beforePackageGame(sys.argv[2])
        else:
            recoverGameDir()
            if not os.path.exists(os.path.join(curPath, "src", "app", "template")):
                print('This script is not working under correct directory !')
                return

            if sys.argv[1] == 'new':
                if assertEnoughArgs(4):
                    newGame(sys.argv[2], sys.argv[3])
                    applyGame(sys.argv[2])
            elif sys.argv[1] == 'remove':
                if assertEnoughArgs(3):
                    removeGame(sys.argv[2])
            elif sys.argv[1] == 'apply':
                if assertEnoughArgs(3):
                    applyGame(sys.argv[2])
            elif sys.argv[1] == 'icon':
                if assertEnoughArgs(3):
                    applyGameIcon(sys.argv[2])
            elif sys.argv[1] == 'excel2csv':
                if assertEnoughArgs(3):
                    excel2csv(sys.argv[2])
            elif sys.argv[1] == 'prefix':
                if assertEnoughArgs(3):
                    prefixPackageRes(sys.argv[2])
            elif sys.argv[1] == 'texturepack':
                if assertEnoughArgs(3):
                    texturepack(sys.argv[2])
            elif sys.argv[1] == 'recover':
                print('Recover finished !')

if __name__ == "__main__":
    run()
