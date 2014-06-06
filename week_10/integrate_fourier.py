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

   pi = math.pi
   integral = 2*pi

   N = 100
   err = np.zeros(N)

   '''
     plot source function
   '''
   dx = 2*pi/N
   x = np.arange(N) * dx
   y = source_fourier(x)

   plt.plot(x, y, "bo")
   plt.show()

   '''
     simple sum (zeroth order method)
   '''
   for n in range(1,N+1):
      dx = 2*pi/n
      x = np.arange(n) * dx
      y = source_fourier(x)
      err[n-1] = dx*sum(y) - integral

   plt.plot(err, "bo")
   plt.show()

   '''
     random sampling
   '''
   for n in range(1,N+1):
      dx = 2*pi/n
      x = 2*pi*np.random.rand(n)
      y = source_fourier(x)
      err[n-1] = dx*sum(y) - integral

   plt.plot(err, "bo")
   plt.show()
