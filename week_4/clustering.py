import math

## constants
#
rEarth  = 3959.     # radius Earth miles
seaLat  = 47.6      # latitude Seattle
seaLong = -122.3    # longitude Seattle

iyr   = 1
ilat  = 2
ilong = 3
idpth = 4
imag  = 5

'''
200 miles is about 2.9 degrees in latitude
200 miles is about 4.3 degrees in longitude at Seattle
'''

def convert_data_file(f):
   '''
   Convert the quake data file into a list of events [year,lat,long,depth,magnitude]
   '''

   quakes = []

   # use an index to label an event for easy access
   index = 0

   for line in f:
       cols = [index]
       data = line[12:-2].split()
       cols.append(int(data[0]))
       for i in range(1,5):
           cols.append(float(data[i]))
       quakes.append(cols)
       index = index + 1

   return quakes
       
#end convert_data_file

def counter(data, lat, long, dLat, dLong, begin_year, end_year, threshold):
   '''
   Returns the data values that fall within lat (+/- dLat), long (+/- dLong) range,
   begin_year, end_year date, and quake magnitude > threshold.
   '''

   selection = []

   for d in data:
      if d[iyr  ] < begin_year:       continue
      if d[iyr  ] > end_year:         continue
      if d[ilat ] < lat - dLat/2.:    continue
      if d[ilat ] > lat + dLat/2.:    continue
      if d[ilong] < long - dLong/2.:  continue
      if d[ilong] > long + dLong/2.:  continue
      if d[imag ] < threshold:        continue

      selection.append(d)

   return selection

#end counter

def clusters(quakes, dLat, dLong, dYr):
   '''
   For each event return a list of indices for events that are within lat (+/- dLat),
   long (+/- dLong), and year (+/- dyr)

   The data structure returned will be
       [
         index_a [neighbors of a]
         index_b [neighbors of b]
         ...
       ]
   '''

   bins = []

   print "processing ", len(quakes), " quakes\n"

   for i in range(0,len(quakes)):
      event = quakes[i]
      lat  = event[ilat ]
      long = event[ilong]
      year = event[iyr  ]
      neighbors = counter(quakes, lat, long, dLat, dLong, year-dYr/2., year+dYr/2., 1)

      neighbor_indices = []
      if len(neighbors) > 5:
         for neighbor in neighbors:
            neighbor_index = neighbor[0]
            if i == neighbor_index:  continue   # don't include self
            neighbor_indices.append(neighbor_index)
         bins.append([i, neighbor_indices])

   return bins

#end clusters

'''
This is run only if called directly by python
and not imported as a module.
'''
if __name__ == "__main__":

   import sys
   import argparse

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

   ## list data structure for quake data
   #

   quakes = convert_data_file(infile)

   '''
   Select a subset of events [index,year,lat,long,depth,magnitude]
   '''
   seaQuakes = counter(quakes, seaLat, seaLong, 2.9, 4.3, 1900, 2010, 1)

   print "All events within 100 mile radius of Seattle:\n"
   for quake in seaQuakes:
      print quake[1:]
   print

   '''
   Find clusters (bins) 2 degrees lat X 2 degrees long X 10 years
   '''
   cluster_bins = clusters(quakes, 2, 2, 10)
   for cluster in cluster_bins:
      # print years
      event = quakes[cluster[0]]
      neighbors = cluster[1]
      group = []
      for i in neighbors:
         neighbor_event = quakes[i]
         group.append(neighbor_event[iyr])
      print event[iyr], ":", group

   ## close all open files
   #
   if args.infile:   infile.close()
   if args.outfile: outfile.close()

