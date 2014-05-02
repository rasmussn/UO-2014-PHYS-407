FC = gfortran

all : read_data

read_data : read_data.f90
	$(FC) read_data.f90 -o read_data

check : read_data
	python sea_ice.py -i icedata.txt
#	cat icedata.txt | read_data

clean :
	rm -f *.o read_data