module clusters

! constants
!
integer, parameter :: MAX_SIZE = 13541 ! obtained from wc (word count) of quake.txt

real, parameter :: rEarth  = 3959.     ! radius Earth miles
real, parameter :: seaLat  = 47.6      ! latitude Seattle
real, parameter :: seaLong = -122.3    ! longitude Seattle

! define a data type to contain a quake event
!
type :: quake
   integer :: year
   real :: lat, long, depth, magnitude
end type quake


CONTAINS


!!!
!   Returns the data values that fall within lat (+/- dLat), long (+/- dLong) range,
!   begin_year, end_year date, and quake magnitude > threshold.
!!!
subroutine counter(data, lat, long, dLat, dLong, begin_year, end_year, threshold, &
                   subset)
   implicit none
   type(quake) :: data(:)
   type(quake), allocatable :: subset(:), tmp(:)
   integer :: begin_year, end_year
   real :: lat, long, dLat, dLong, threshold

   ! local variables
   !
   integer :: i, count, len_data(1)

   ! get the length of the array
   !
   len_data = shape(data)

   ! allocate temporary storage big enough to store all values
   !
   allocate(tmp(len_data(1)))

   ! first we have to find the size of the data subset
   !
   count = 0
   do i = 1, len_data(1)
      if (data(i)%year < begin_year)       go to 10
      if (data(i)%year > end_year)         go to 10
      if (data(i)%lat  < lat - dLat/2.)    go to 10
      if (data(i)%lat  > lat + dLat/2.)    go to 10
      if (data(i)%long < long - dLong/2.)  go to 10
      if (data(i)%long > long + dLong/2.)  go to 10
      if (data(i)%magnitude < threshold)   go to 10

      ! found an event, count it
      count = count + 1
      tmp(count) = data(i)

10    continue

   end do

   ! now we know the size, allocate memory for the data subset and copy
   !
   allocate(subset(count))
   do i = 1, count
      subset(i) = tmp(i)
   end do

   ! deallocate temporary storage
   !
   deallocate(tmp)

end subroutine counter

end module clusters


program main
   use clusters
   implicit none

   type(quake) :: quakes(MAX_SIZE)
   type(quake), allocatable :: subset(:)

   integer :: year, begin_year, end_year, funit, i, len_data(1)
   real :: dLat, dLong, threshold
  
   character(len=*), parameter :: fmt = "(12x, i4, f7.1, f10.3, f7.1, f5.1)"

   !! first open data file
   !
   funit = 13
   open(UNIT=funit, FILE="quake.txt", ACTION="READ")

   !! read in the data
   !
   do i = 1, MAX_SIZE
      read(UNIT=funit, FMT=fmt, END=20) quakes(i)%year, quakes(i)%lat, quakes(i)%long, quakes(i)%depth, quakes(i)%magnitude
   end do

20 continue

   dLat  = 2.9
   dLong = 4.3
   threshold = 1
   call counter(quakes, seaLat, seaLong, dLat, dLong, 1900, 2010, threshold, subset)

   ! get the length of the array
   !
   len_data = shape(subset)
   do i = 1, len_data(1)
      print *, subset(i)
   end do

   !! free allocated memory and close file
   !
   deallocate(subset)
   close(funit)

end program
