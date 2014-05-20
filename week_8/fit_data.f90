module fit_data_mod
              
   integer, parameter :: MAX_SIZE = 4000

   !! setup parameters, you may need to modify these
   !
   real, parameter :: xStepMin  =  200,  xStepMax  =  300     ! phase time step
   real, parameter :: xSlopeMin =    2,  xSlopeMax =    3     ! slope of linear fit
   real, parameter :: zpMin     = 7600,  zpMax     = 7800     ! zero point
   real, parameter :: pMin      =   50,  pMax      =   60     ! period
   real, parameter :: phiMin    =  -20,  phiMax    =   20     ! phase
   real, parameter :: aMin      =  250,  aMax      =  350     ! amplitude

   real, parameter :: PI = 3.1415

   !! module variables
   !
   integer :: numIterations   ! number of random searches per process
   real :: xstep              ! time step
   real :: slope              ! slope
   real :: zp                 ! zero point
   real :: p                  ! period
   real :: phi, phi1          ! phases
   real :: a                  ! amplitude

   real :: xx(MAX_SIZE), yy(MAX_SIZE)

contains

!!!!!!!!
! Read in data from file (unit # 1)
!
subroutine read_data()
   implicit none
   integer :: i, k
   real    :: x, y

   k = 0
   do i = 1, 1000
      read(1,*) x, y
      k = k + 1
      xx(i) = k
      yy(i) = y
   end do

end subroutine read_data

!!!!!!!!
! Smooth raw data
!
subroutine smooth_data()
   implicit none
   integer :: i
   real    :: smoothy

   do i = 1, 1000
      smoothy = (yy(i) + yy(i+1) + yy(i+2) + yy(i+3) + yy(i+4))/5.0
      write(20,*) xx(i), smoothy
   end do

end subroutine smooth_data

!!!!!!!!
! Calculate random variables for an interation
!
subroutine randomize()
   implicit none
   real :: r

   call random_number(xstep)      ! uniformly distributed on internal [0.0, 1.0)
   xstep = xStepMin + (xStepMax - xStepMin)*xstep

   call random_number(slope)      ! slope
   slope = xSlopeMin + (xSlopeMax - xSlopeMin)*slope

   call random_number(zp)         ! zero point
   zp = zpMin + (zpMax - zpMin)*zp

   call random_number(p)          ! period
   p = pMin + (pMax - pMin)*p

   call random_number(phi)        ! phase
   phi = phiMin + (phiMax - phiMin)*phi

   call random_number(phi1)       ! phase
   phi1 = phiMin + (phiMax - phiMin)*phi1

   call random_number(a)          ! phase
   a = aMin + (aMax - aMin)*a

end subroutine randomize

end module fit_data_mod


program fit_data
   use mpi
   use fit_data_mod
   implicit none
   character(len=32) :: arg
   integer :: i, err, iter, seed(12), rank, size, out_unit
   real :: chi, chimin, chisq, resid, sk, yk, ykk

   !! initialize MPI
   !
   call MPI_Init(err)

   call MPI_Comm_rank(MPI_COMM_WORLD, rank, err)
   call MPI_Comm_size(MPI_COMM_WORLD, size, err)

   !! get number of iterations from the command line
   !
   call get_command_argument(1, arg)
   read(arg, '(i12)') numIterations

   if (len_trim(arg) == 0) then
      if (rank == 0) then
         print *, 'usage: fit_data num_iterations'
         print *, '       please input # interations as a command line argument'
         print *
      end if
      call MPI_Finalize(err)
      stop
   end if

   call read_data()
   call smooth_data()

   if (rank == 0) then
      print *, "Running MPI with size of", size
      print *, "Number of iterations is ", numIterations
      print *
      ! write(*,*) 'Going to work on the first 600 data points'
      ! write(*,*) 'fitting line + sin wave + phase adjustement at later time steps'
      ! write(*,*) 'From class for initial values'
      ! write(*,*) 'slope = 2.8 (slope)'
      ! write(*,*) 'zeropoint = 7700 (zp)'
      ! write(*,*) 'period = 54 (p)'
      ! write(*,*) 'amplitude = 300 (a)'
      ! write(*,*) 'phase = -7 (phi)'
      ! write(*,*) 'phase1 = 2 (phi1)'
      ! write(*,*) 'timestep = 250 (xstep)'
      ! write(*,*)
   end if

   ! Initialize random number generator to something based on MPI rank so
   !   that it is different for every MPI process.
   !
   call random_seed(get=seed)
   seed = (rank + 1)*seed           ! some modification based on the MPI rank
   call random_seed(put=seed)

   out_unit = 21 + rank    ! files must be different for each MPI rank
   chimin = 50

   do iter = 1, numIterations
      call randomize()

      do i = 1, 600
         yk = slope*xx(i) + zp
         if (i .lt. xstep) then 
            sk = a*sin(2*PI*(xx(i)/p) + phi)
         else
            sk = a*sin(2*PI*(xx(i)/p) + phi + phi1)
         end if
         ykk = yk + sk
         resid = (ykk - yy(i))
         resid = (resid*resid)/yy(i)
         chi = chi + resid
      end do

      chisq = chi/600
      chi = 0
      if (chisq .lt. chimin) then
         write(*,*) rank, iter, chimin, slope, a, p
         write(out_unit,'(i3,1x,i9,7f8.2,f10.2)') rank, iter, chimin, slope, a, p, phi, phi1, xstep, zp
         chimin = chisq
      end if
   end do

   call MPI_Finalize(err)

end program
