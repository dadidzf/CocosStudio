import sys
import os
import shutil
import json
import re

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
    return os.path.dirname(__file__)

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
        os.mkdir(os.path.join(curPath, "res", name))
        shutil.copytree(os.path.join(curPath, "src", "app", "template"), 
            os.path.join(curPath, "src", "app", name))
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
    mergeDir(os.path.join(curPath, "temp", "src"), os.path.join(curPath, "src", "app"))
    mergeDir(os.path.join(curPath, "temp", "res"), os.path.join(curPath, "res"))

def relplaceGameConfig(name, packageName):
    curPath = get_current_path()
    replace_string(os.path.join(curPath, "src", "app", name, "%s_config.json"%name), '"appName":"template"', 
        '"appName":"%s"'%name)
    replace_string(os.path.join(curPath, "src", "app", name, "%s_config.json"%name), '"packageName":"com.yongwu.luatemplate",', 
        '"packageName":"%s",'%packageName)

def applayGameConfigToProject(name):
    curPath = get_current_path()
    f = open(os.path.join(curPath, "src", "app", name, "%s_config.json"%name))
    gameConfig = json.load(f)
    f.close()

    ## android
    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/AndroidManifest.xml"),
        "package=.*", 'package="%s"'%gameConfig['android']['packageName'])
    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/build.gradle"),
        "versionCode.*", 'versionCode %d'%gameConfig['android']['versionCode'])
    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/build.gradle"),
        "versionName.*", 'versionName "%s"'%gameConfig['android']['version'])
    replaceRegularString(os.path.join(curPath, "frameworks/runtime-src/proj.android-studio/app/build.gradle"),
        "applicationId.*", 'applicationId "%s"'%gameConfig['android']['packageName'])

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

    if os.path.exists(os.path.join(curPath, "res/%s/GoogleService-Info.plist"%name)):
        shutil.copy(os.path.join(curPath, "res/%s/GoogleService-Info.plist"%name), 
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
    for f in os.listdir(os.path.join(curPath, "src", "app")):
        if os.path.isdir(os.path.join(curPath, "src", "app", f)) and f != name :
            shutil.move(os.path.join(curPath, "src", "app", f), os.path.join(curPath, "temp", "src"))

    for f in os.listdir(os.path.join(curPath, "res")):
        if os.path.isdir(os.path.join(curPath, "res", f)) and f != name :
            shutil.move(os.path.join(curPath, "res", f), os.path.join(curPath, "temp", "res"))

def assertEnoughArgs(needCount):
    if len(sys.argv) < needCount:
        print("Not enough args !")
        return False
    else:
        return True

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

if __name__ == "__main__":
    run()
