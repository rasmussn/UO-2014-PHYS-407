import numpy as np
import matplotlib.pyplot as plt
import scipy.optimize as opt

# obtained this from shell command wc of icedata.txt
data_length = 144

def read_data_file(f):
   '''
   Read the ice data file and return a tuple of numpy arrays (year,july,august,september)
   '''

   year = np.zeros((data_length,), dtype=np.int)
   july = np.zeros((data_length,), dtype=np.float)
   aug  = np.zeros((data_length,), dtype=np.float)
   sept = np.zeros((data_length,), dtype=np.float)

   # use an index to label an event for easy access
   index = 0

   for i in range(data_length):
       line = f.readline()
       data = line.split()
       year[i] = int(  data[0])
       july[i] = float(data[1])
       aug[i]  = float(data[2])
       sept[i] = float(data[3])
       
   return (year, july, aug, sept)
       
#end read_data_file

def differentiate(year, july, aug, sept):
   ''' Calculate and plot derivatives at 5 year intervals '''
   # this range allows use of ghost cells on either side of cell center
   #
   indices = np.arange(1,len(year),5)

   # take the average
   avg = (july + aug + sept)/3.0

   # avg on either side of 5 yr center
   avg_p1 = avg[indices+1]
   avg_m1 = avg[indices-1]

   # calculate derivatives
   dt = 1.0   # units of years
   deriv = (avg_p1 - avg_m1)/(2.0*dt)

   # plot averaged data
   plt.plot(year, avg, 'bo')
   plt.title("Monthly Average")
   plt.show()

   # plot derivatives
   plt.plot(year[indices], deriv, 'ro')
   plt.plot(year[indices], (avg_p1-avg[indices])/dt, 'bo')
   plt.plot(year[indices], (avg[indices]-avg_m1)/dt, 'go')
   plt.title("Derivatives")
   plt.show()

#end differentiate

def integrate(year, july, aug, sept):
   ''' Calculate and plot integrals from 1870-1950 and 1950-2013 '''

   ## take averages
   #
   avg = (july + aug + sept)/3.0
   avg1 = avg[:81]
   avg2 = avg[80:]

   ## calculate integrals
   #
   dt = 1.0
   integral1 = sum(avg1)*dt
   integral2 = sum(avg2)*dt

   print "integral [", year[0], ":", year[80],  "] is", integral1, integral1/len(avg1)
   print "integral [", year[80], ":", year[-1], "] is", integral2, integral2/len(avg2)

#end integrate

def smooth_box(year, july, aug, sept):
   ''' smooth using box car average '''

   # box-car filter
   box_filter = np.ones(3, dtype=np.float)

   # this range allows use of ghost cells on either side of cell center
   #
   indices = np.arange(1,len(year)-1)

   # take the monthly average
   avg = (july + aug + sept)/3.0

   # avg on either side of 5 yr center
   avg_p1 = avg[indices+1]
   avg_m1 = avg[indices-1]

   # calculate box-car average
   avg_box = box_filter[0]*avg_m1 + box_filter[1]*avg[1:-1] + box_filter[2]*avg_p1

   # plot filtered data
   plt.plot(year[1:-1], avg_box, 'go')
   plt.title("Box Car Filter")
   plt.show()

#end smooth_box

def histogram(year, july, aug, sept):
   ''' plot histogram of july/sept data '''

   ratio = july/sept

   # plot histogram data
   plt.bar(year, ratio, align='center')
   plt.title("Ratio July/September")
   plt.show()

#end histogram

def fit_curve(year, july, aug, sept):
   ''' fit curve with linear function from 1988-2013 '''

   # only use september data
   avg = (july + aug + sept)/3.0
      
   x = year[109:]
   y = avg[109:]

   # Fit the first set
   fitfunc = lambda p, x: p[0] + p[1]*(x-1979)    # Target function
   errfunc = lambda p, x, y: fitfunc(p, x) - y    # Distance to the target function
   p0 = [9., -3./15.]                             # Initial guess for the parameters
   p1, success = opt.leastsq(errfunc, p0[:], args=(x, y))

   print "Ice free by ", -p1[0]/p1[1] + 1979

   y = p1[0] + p1[1]*(x-1979)

   # plot fit
   plt.plot(year, avg, 'bo')
   plt.plot(x, y, 'r')
   plt.title("Fit")
   plt.show()

#end fit_curve

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

   ## read in data
   #
   (year, july, aug, sept) = read_data_file(infile)

   ## differentiate (problem 2)
   #
   differentiate(year, july, aug, sept)

   from scipy import fftpack

   y = sept[:57]

   sample_freq = fftpack.fftfreq(y.size, d=1)
   sig_fft = fftpack.fft(y)

   plt.plot(sample_freq, np.log(np.abs(sig_fft)), 'ro')
   plt.show()

   exit(0)

   ## integrate (problem 3)
   #
   integrate(year, july, aug, sept)

   ## smooth (problem 4)
   #
   smooth_box(year, july, aug, sept)

   ## plot histogram (problem 5)
   #
   histogram(year, july, aug, sept)

   ## curve fitting (sort of problem 6-7)
   #
   fit_curve(year, july, aug, sept)

   ## close all open files
   #
   if args.infile:   infile.close()
   if args.outfile: outfile.close()

#end main
