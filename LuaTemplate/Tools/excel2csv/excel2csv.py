#!/usr/bin/env python
# -*- coding: utf8 -*-
# http://www.python-excel.org

import xlrd
import csv
import os
import shutil

def getExcelDict(file):
	data = xlrd.open_workbook(file, encoding_override="utf8")
	sheet = data.sheets()[0]

	header = []
	for j in range(sheet.ncols):
		cell = sheet.cell(1, j)
		if cell.ctype == xlrd.XL_CELL_TEXT:
			header.append(cell.value)
		else:
			break

	table = []
	cols = len(header)
	for i in range(2, sheet.nrows):
		row = {}
		for j in range(cols):
			name = header[j]
			cell = sheet.cell(i, j)
			if cell.ctype == xlrd.XL_CELL_EMPTY:
				row[name] = ""
			elif cell.ctype == xlrd.XL_CELL_TEXT:
				row[name] = cell.value.encode("utf8")
			elif cell.ctype == xlrd.XL_CELL_NUMBER:
				if int(cell.value) == cell.value:
					row[name] = int(cell.value)
				else:
					row[name] = cell.value
			elif cell.ctype == xlrd.XL_CELL_DATE:
				row[name] = cell.value
			elif cell.ctype == xlrd.XL_CELL_BOOLEAN:
				row[name] = cell.value
			elif cell.ctype == xlrd.XL_CELL_ERROR:
				row[name] = ""
			elif cell.ctype == xlrd.XL_CELL_BLANK:
				row[name] = ""
		table.append(row)

	return header, table


def processFile(infile, outfile):
	header, table = getExcelDict(infile)
	with open(outfile, 'wb') as csvfile:
		writer = csv.DictWriter(csvfile, fieldnames=header)
		writer.writeheader()
		for row in table:
			writer.writerow(row)

def excel2csvDir(srcDir, destDir):
	for filename in os.listdir(srcDir):
		name, ext = os.path.splitext(filename)
		if ext == ".xlsx":
			realname = name.split("-")[0]
			processFile(os.path.join(srcDir, filename), os.path.join(destDir, realname + ".csv"))
		
