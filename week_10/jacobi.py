import math
import numpy as np
import matplotlib.pyplot as plt

def source_fourier(x):
   return (1 + np.sin(x) + 0.3*np.cos(9*x))
#end source_fourier

'''
This is run only if called directly by python
and not imported as a module.
'''
if __name__ == "__main__":

   N = 128
   pi = math.pi

   dx = 2*pi/N
   x = np.arange(N) * dx
   y = source_fourier(x)
   y_new = np.zeros(len(y))

   for iter in range(100):
      for i in range(1,N-1):
         y_new[i] = (y[i-1] + y[i+1])/2.0

      # update old solution values
      y = y_new

      if iter%10 == 0:
         plt.plot(x, source_fourier(x), "ro")
         plt.plot(x, y, "bo")
         plt.show()

   #end interation loop

