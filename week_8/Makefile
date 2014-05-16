FC = mpif90

all : mpi_ring

mpi_ring : mpi_ring.f90
	$(FC) -o mpi_ring mpi_ring.f90

check : mpi_ring
	@echo "Running mpi_ring ..."
	@echo
	@mpirun -np 2 mpi_ring

clean :
	rm -f *.pyc *.o *.mod mpi_ring
