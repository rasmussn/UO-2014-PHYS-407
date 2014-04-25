FC = gfortran

all : clusters

clusters : clusters.f90
	$(FC) -g -o clusters clusters.f90

check :
	@echo "\nRunning Fortran program clusters ........\n\n"
	@clusters
	@echo "\nRunning Python program clustering .......\n\n"
	@python clustering.py -i quake.txt

clean :
	rm -f *.pyc *.o *.mod clusters
