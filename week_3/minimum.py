import sys
import argparse
import storms

## get input file name
#
parser = argparse.ArgumentParser(description='Process csv file.')
parser.add_argument("-i", dest="infile",  help="input file name")
parser.add_argument("-o", dest="outfile", help="output file name")
args = parser.parse_args()

infile  = sys.stdin
outfile = sys.stdout

if args.infile:   infile = open(args.infile,  'r')
if args.outfile: outfile = open(args.outfile, 'w')

## list data structure for storm data
#
storm_list = []

for line in infile:
   d = storms.line_to_dict(line)
   storm_list.append(d)

sorted_list = sorted(storm_list, key=lambda x: x['pressure'])

name = ''
names = []

for d in sorted_list:
   if name != d['name']:
      name = d['name']
      if names.__contains__(name) == False:
         l = storms.dict_to_list(d)
         outfile.write(str(l) + ',' + '\n')
      names.append(name)

## close all open files
#
if args.infile:   infile.close()
if args.outfile: outfile.close()

