import os
import hashlib
import time
#
def getFileMd5(filename):
    if not os.path.isfile(filename):
        return
    myhash = hashlib.md5()# create a md5 object
    f = file(filename,'rb')
    while True:
        b = f.read(8096)# get file content.
        if not b :
            break
        myhash.update(b)#encrypt the file
    f.close()
    return myhash.hexdigest()

def walk(path, prefix):
    global xml
    fl = os.listdir(path) # get what we have in the dir.
    for f in fl:
        if os.path.isdir(os.path.join(path,f)): # if is a dir.
            if prefix == '':
                walk(os.path.join(path,f), f)
            else:
                walk(os.path.join(path,f), prefix + '/' + f)
        else:
            md5 = getFileMd5(os.path.join(path,f))
            xml += "\n\t\t\"%s\" : {\n\t\t\t\"md5\" : \"%s\"\n\t\t}, " % (prefix + '/' + f, md5) # output to the md5 value to a string in xml format.

if __name__ == "__main__": 
    timeStr = time.strftime("%Y%m%d%H%M%S",time.localtime(time.time()))
    if not os.path.exists(os.getcwd() + '\\manifest'):
        os.mkdir(os.getcwd() + '\\manifest')
    #generate project.manifest
    xml = '{\
    \n\t"packageUrl" : "http://192.168.2.50/version/",\
    \n\t"remoteVersionUrl" : "http://192.168.2.50/manifest/version.manifest",\
    \n\t"remoteManifestUrl" : "http://192.168.2.50/manifest/project.manifest",\
    \n\t"version" : "0.0.%s",\
    \n\t"engineVersion" : "Cocos2d-x v3.10",\
    \n\n\t"assets" : {' % timeStr
    walk(os.getcwd() + '\\version', '')
    xml = xml[:-2]
    xml += '\n\t},\
    \n\t"searchPaths" : [\
    \n\t]\
    \n}'
    f = file("manifest\project.manifest", "w+")
    f.write(xml)
    print 'generate project.manifest finish.'
    #generate version.manifest
    xml = '{\
    \n\t"packageUrl" : "http://192.168.2.50/api/version/",\
    \n\t"remoteVersionUrl" : "http://192.168.2.50/api/manifest/version.manifest",\
    \n\t"remoteManifestUrl" : "http://192.168.2.50/api/manifest/project.manifest",\
    \n\t"version" : "0.0.%s",\
    \n\t"engineVersion" : "Cocos2d-x v3.10"\n}' % timeStr
    f = file("manifest\\version.manifest", "w+")
    f.write(xml)
    print 'generate version.manifest finish.'