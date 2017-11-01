#!/usr/bin/env python
# -*- coding: utf8 -*-

import os
import os.path
import sys
import shutil
import xml.etree.ElementTree as ET

# mode: 0-absolute filenames, 1-relative filenames, 2-only filenames
def getAllFiles(dir, ext, mode = 0):
	list = []
	def recursive(d):
		for f in os.listdir(d):
			f = os.path.join(d, f)
			if os.path.isdir(f):
				recursive(f)
			elif os.path.isfile(f):
				if ext == "*" or ext == os.path.splitext(f)[1]:
					if mode == 0:
						list.append(f)
					elif mode == 1:
						list.append(os.path.relpath(f, dir))
					elif mode == 2:
						list.append(os.path.basename(f))
	recursive(dir)
	return list


OPTIONS = {
	'format' : "cocos2d",
	'texture-format' : "png",
	'opt' : "RGBA8888", 
	'algorithm' : "MaxRects",
	'size-constraints' : "POT",
	'reduce-border-artifacts' : "",
	'force-squared' : "",
}


def packagePic(srcDir, destDir, cocostudioDir):
	tpsfiles = getAllFiles(srcDir, ".tps", 2)
	for filename in tpsfiles:
		args = ["TexturePacker"]
		for key, value in OPTIONS.iteritems():
			args.append("--" + key)
			args.append(value)
		args.append(os.path.join(srcDir, filename))
		os.system(" ".join(args))

		plistFileName = "%s.plist"%os.path.splitext(filename)[0]
		pngFileName = "%s.png"%os.path.splitext(filename)[0]

        if cocostudioDir:
	        shutil.copy(os.path.join(srcDir, plistFileName), os.path.join(cocostudioDir, plistFileName))
	        shutil.copy(os.path.join(srcDir, pngFileName), os.path.join(cocostudioDir, pngFileName))

        shutil.move(os.path.join(srcDir, plistFileName), os.path.join(destDir, plistFileName))
        shutil.move(os.path.join(srcDir, pngFileName), os.path.join(destDir, pngFileName))
	
if __name__ == '__main__':
	packagePic(sys.argv[1])

