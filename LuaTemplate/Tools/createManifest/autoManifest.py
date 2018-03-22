import os
import hashlib
import time

def getFileMd5(filename):
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

def walk(path, assetsDict, prefix):
    fl = os.listdir(path) 
    for f in fl:
        if os.path.isdir(os.path.join(path,f)): # if is a dir.
            if prefix == '':
                walk(os.path.join(path, f), assetsDict, f)
            else:
                walk(os.path.join(path,f), assetsDict, prefix + '/' + f)
        else:
            md5 = getFileMd5(os.path.join(path, f))
            if prefix == '':
                assetsDict[f] = md5
            else:
                assetsDict[prefix + '/' + f] = md5

def writeManifest(manifest, filePath):
    strMan = json.dumps(manifest, encoding = 'utf8')
    f = file(filePath, "w+")
    f.write(strMan)
    f.close()

def process(srcdir, destdir, version, url):
    manifest = {
        'packageUrl': url,
        'remoteManifestUrl': url + 'project.manifest',
        'remoteVersionUrl': url + 'version.manifest',
        'version': version,
        'assets': {},
        'searchPaths': []
    };

    writeManifest(manifest, os.path.join(destdir, 'version.manifest'))

    if not os.path.exists(destdir):
        os.mkdir(destdir)

    walk(srcdir, manifest.assets, '')

    writeManifest(manifest, os.path.join(destdir, 'project.manifest'))

if __name__ == "__main__": 
    curPath = os.path.split(os.path.realpath(__file__))[0]
    srcdir = curPath
    destdir = curPath
    version = '1.0.0'
    url = 'http://localhost:8080/'

    index = 1
    while index < len(sys.argv):
        arg = sys.argv[index]
        if arg == '-d' or arg == '--dest':
            destdir = sys.argv[index + 1]
        elif arg == '-v' or arg == '--version':
            version = sys.argv[index + 1]
        elif arg == '-u' or arg == '--url':
            url = sys.argv[index + 1]
        elif arg == '-v' or arg == '--version':
            version = sys.argv[index + 1]
        elif arg == '-s' or arg == '--src':
            srcdir = sys.argv[index + 1]

        index = index + 1

    process(srcdir, destdir, version, url)
