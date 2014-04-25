FC = gfortran

all : clusters

clusters : clusters.f90
	$(FC) -o clusters clusters.f90

check :
	python clustering.py -i quake.txt

clean :
	rm -f *.pyc *.o *.mod clusters
