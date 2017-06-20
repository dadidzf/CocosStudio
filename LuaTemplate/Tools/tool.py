import os
import sys
import shutil
from PIL import Image

iosSizes = ['Icon-29', 'Icon-40', 'Icon-50', 'Icon-57', 
			'Icon-58', 'Icon-72', 'Icon-76', 'Icon-80', 
			'Icon-87', 'Icon-100','Icon-114', 'Icon-120', 
			'Icon-144', 'Icon-152', 'Icon-180']
androidSizes = [512]
androidNames = ['ic_launcher']

sizesiOS = [(640,960),(640, 1136),(750, 1334),(1242, 2208),(1024, 768)]
outFilesiOS = ['Default@2x','Default-568h@2x','Default-667h@2x','Default-736h@3x','Default-Landscape~ipad']

#sizesiOS = [(640,960),(640, 1136),(750, 1334),(1242, 2208),(1536, 2048),(2048, 2732)]
#foldersiOS = ['iPhone4s','iPhone5','iPhone6','iPhone6plus','iPad','iPadLarge']


sizesAndroid = [(480,800),(720,1280),(1080,1920)]
outFilesAndroid = ['480x800','720x1280','1080x1920']

def get_current_path():
    return os.path.dirname(__file__)

shutil.rmtree(os.path.join(get_current_path(), 'output'))
os.mkdir(os.path.join(get_current_path(), 'output'))
os.mkdir(os.path.join(get_current_path(), 'output/androidIcon'))
os.mkdir(os.path.join(get_current_path(), 'output/androidSplash'))
os.mkdir(os.path.join(get_current_path(),  'output/iosSplash'))
os.mkdir(os.path.join(get_current_path(), 'output/iosIcon'))

def processIcon(filename, platform, destPath):
	icon = Image.open(filename).convert("RGBA")

	if icon.size[0] != icon.size[1]:
		print 'Icon file must be a rectangle!'
		return

	if platform == 'android':
		mask = Image.open(os.path.join(get_current_path(), 'mask.png'))
		mask.load()
		r,g,b,a = mask.split()
		icon.putalpha(a)
		index = 0
		for size in androidSizes:
			im = icon.resize((size,size),Image.BILINEAR)
			savePath = os.path.join(get_current_path(), 'output/androidIcon/', androidNames[index] + '.png')
			im.save(savePath)
			shutil.copy(savePath, destPath)
			index = index + 1
	else:
		for size in iosSizes:
			length = int(size.split('-')[1])
			im = icon.resize((length, length), Image.BILINEAR)
			savePath = os.path.join(get_current_path(), 'output/iosIcon/', size + '.png')
			im.save(savePath)
			shutil.copy(savePath, destPath)
	print 'Congratulations!It\'s all done!'

def cut_by_ratio(im, outfile, iWidth, iHeight, destPath):  
    width = float(iWidth)  
    height = float(iHeight)  
    (x, y) = im.size  

    if x/width > y/height:
    	region = (int((x - width*y/height)/2), 0, int(x - ((x - width*y/height)/2)), y)
    elif x/width < y/height:
    	region = (0, int((y - height*x/width)/2), x, int(y - ((y - height*x/width)/2)))
    else:
    	region = (0, 0, x, y)

    crop_img = (im.crop(region)).resize((iWidth, iHeight), Image.ANTIALIAS)
    crop_img.save(outfile)  
    shutil.copy(outfile, destPath)

def produceImage(filename, platform, destPath):
    print 'Processing:' + filename
    img = Image.open(filename)
    index = 0
    ext =  os.path.splitext(filename)[1]
    sizes = sizesiOS
    outFile = outFilesiOS
    outDir = 'iosSplash'

    if platform == 'android':
        sizes = sizesAndroid
        outFile = outFilesAndroid
        outDir = 'androidSplash'
    for size in sizes:
        savePath = os.path.join(get_current_path(), 'output/' + outDir, outFile[index] + ext)
        if size[0] > size[1]:
            cut_by_ratio(img, savePath, size[1], size[0], destPath)
            pic = Image.open(savePath)
            pic2 = pic.transpose(Image.ROTATE_270)
            pic2.save(os.path.join(destPath, outFile[index] + ext))
        else:
            cut_by_ratio(img, savePath, size[0], size[1], destPath)
        index = index + 1

def image_produce_run(iconPath, screenshotPath, destAndroidIconPath, destIosIconPath, destIosSplashPath):
	processIcon(iconPath, 'ios', destIosIconPath)	
	processIcon(iconPath, 'android', destAndroidIconPath)	
	produceImage(screenshotPath, 'ios', destIosSplashPath)

# test
# image_produce_run('512.png', 'splash.png', 'temp', 'temp', 'temp')