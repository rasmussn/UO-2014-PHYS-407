#! /usr/local/bin/python

'''
Cut out and write values to a file of all occurrences
of a given key.
'''

import sys
import argparse
import storms

## get input file name
#
parser = argparse.ArgumentParser(description='Process csv file.')
parser.add_argument("-i", dest="infile",  help="input file name")
parser.add_argument("-o", dest="outfile", help="output file name")
parser.add_argument("--key=", dest="key",  help="key for values to cut from data")
parser.add_argument("--value=", dest="val",  help="value to cut from data")
args = parser.parse_args()

infile  = sys.stdin
outfile = sys.stdout

if args.infile:   infile = open(args.infile,  'r')
if args.outfile: outfile = open(args.outfile, 'w')

key = args.key
val = args.val

## list data structure for storm data
#
storm_list = []

for line in infile:
   dict_entry = storms.line_to_dict(line)
   storm_list.append(storms.line_to_dict(line))

for d in storm_list:
   if str(d[key]) == str(val):
      l = storms.dict_to_list(d)
      for item in l:
         outfile.write(str(item) + ',')
      outfile.write('\n')

## close open files
#
if args.infile:   infile.close()
if args.outfile: outfile.close()

