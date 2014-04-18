FC = gfortran

all : to_csv

to_csv : to_csv.f90
	$(FC) -o to_csv to_csv.f90

clean :
	rm -f to_csv *.o *.mod

