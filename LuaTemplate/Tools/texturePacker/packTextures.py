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


def packagePic(srcDir):
	tpsfiles = getAllFiles(srcDir, ".tps")
	for filename in tpsfiles:
		args = ["TexturePacker"]
		for key, value in OPTIONS.iteritems():
			args.append("--" + key)
			args.append(value)
		args.append(filename)
		os.system(" ".join(args))
	
if __name__ == '__main__':
	packagePic(sys.argv[1])

