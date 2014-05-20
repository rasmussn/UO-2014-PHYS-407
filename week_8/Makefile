FC = mpif90

all : fit_data

fit_data : fit_data.f90
	$(FC) -o fit_data fit_data.f90

mpi_ring : mpi_ring.f90
	$(FC) -o mpi_ring mpi_ring.f90

check : fit_data
	@echo "Running fit_data ..."
	@echo
	@mpirun -np 1 fit_data 1000

clean :
	rm -f *.o *.mod fit_data mpi_ring
