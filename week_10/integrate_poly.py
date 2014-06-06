import math
import numpy as np
import matplotlib.pyplot as plt

def poly(x):
   return 2*x
#end poly

'''
This is run only if called directly by python
and not imported as a module.
'''
if __name__ == "__main__":

   N = 100
   integral = 1.0
   err = np.zeros(N)

   '''
     simple sum (zeroth order method)
   '''
   for n in range(1,N+1):
      dx = 1.0/n
      x = np.arange(n) * dx
      y = poly(x)
      err[n-1] = dx*sum(y) - integral

   plt.plot(err, "bo")
   plt.show()

   '''
     random sampling
   '''
   for n in range(1,N+1):
      dx = 1.0/n
      x = np.random.rand(n)
      y = poly(x)
      err[n-1] = dx*sum(y) - integral

   plt.plot(err, "bo")
   plt.show()

   '''
     trapezoidal rule (first order method)
   '''
   for n in range(1,N+1):
      dx = 1.0/n
      x = np.arange(n+1) * dx   # note one more point needed
      y = poly(x)

      ## need to subtract 1/2 times end point values from sum
      #
      err[n-1] = dx*(sum(y) - 0.5*(y[0] + y[-1])) - integral

   plt.plot(err, "bo")
   plt.show()
