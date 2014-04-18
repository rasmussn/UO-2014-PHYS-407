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

## break into decades
#
for i in range(0,len(storm_list)):
   d = storm_list[i]
   d['year'] = (d['year']/10)*10
   storm_list[i] = d

'''
Container data structure can be sorted:

sorted_list = sorted(storm_list, key=lambda x: x['pressure'])
'''

year = 1900
decade  = []
decades = []

count = 0
minimum = 99999999   # a big number

for d in storm_list:
   if year == d['year']:
      decade.append(d)
      count += 1
      if minimum > d['pressure']: minimum = d['pressure']
   else:
      print 'year:', year, ' minimum:', minimum, ' number:', count, ' average:', count/10.

      year += 10
      count = 0
      minimum = 99999999

# print end decade values
print 'year:', year, ' minimum:', minimum, ' number:', count, ' average:', count/10.

'''
      year = d['year']
      if names.__contains__(name) == False:
         l = storms.dict_to_list(d)
         outfile.write(str(l) + ',' + '\n')
      names.append(name)
'''

## close all open files
#
if args.infile:   infile.close()
if args.outfile: outfile.close()

