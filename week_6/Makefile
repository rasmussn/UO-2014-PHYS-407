FC = gfortran

all : advect

advect : advect.f90
	$(FC) -o advect advect.f90

check : advect
	@echo "Running advect ..."
	@echo
	@advect

clean :
	rm -f *.pyc *.o *.mod advect
