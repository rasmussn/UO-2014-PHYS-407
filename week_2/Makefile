FC = gfortran

all : moo

moo : vache.o moo.o
	$(FC) -o moo moo.o vache.o

moo.o : moo.f90
	$(FC) -c moo.f90

vache.o : vache.f90
	$(FC) -c vache.f90

check : moo
	@echo
	@moo
	@echo

clean :
	rm -f moo *.o *.mod
