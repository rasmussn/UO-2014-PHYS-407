def line_to_dict(line):
   '''place values in an input line into a dictionary'''

   words = line.split(',')

   d = {}
   d['id']    =   int(words[0])
   d['name']  =       words[1]
   d['lat']   = float(words[2])
   d['long']  = float(words[3])
   d['speed'] =   int(words[4])
   d['pressure'] =int(words[5])
   d['year']  =   int(words[6])
   d['hours'] = float(words[7])
   d['desc']  =          words[8]

   if len(d['desc']) == 0: d['desc'] = 'UNKNOWN'

   return d
# end line_to_dict


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
   dict_entry = storms.line_to_dict(line)
   storm_list.append(storms.line_to_dict(line))

for d in storm_list:
    outfile.write(str(d) + '\n')

## close open files
#
if args.infile:   infile.close()
if args.outfile: outfile.close()

