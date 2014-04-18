FC = gfortran

all : to_csv

to_csv : to_csv.f90
	$(FC) -o to_csv to_csv.f90

check : to_csv
	cat master1.txt | ./to_csv | grep -i hurricane | python storms.py > chart.txt

clean :
	rm -f to_csv *.o *.mod *.pyc
