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
   type(quake), allocatable :: subset(:)
   integer :: begin_year, end_year
   real :: lat, long, dLat, dLong, threshold

   ! local variables
   !
   integer :: i, count, len_data(1)

   ! get the length of the array
   !
   len_data = shape(data)

   ! first we have to find the size of the data subset
   !
   count = 0
   do i = 1, len_data(1)
      if (data(i)%year < begin_year)       continue
      if (data(i)%year > end_year)         continue
      if (data(i)%lat  < lat - dLat/2.)    continue
      if (data(i)%lat  > lat + dLat/2.)    continue
      if (data(i)%long < long - dLong/2.)  continue
      if (data(i)%long > long + dLong/2.)  continue
      if (data(i)%magnitude < threshold)   continue

      ! found an event, count it
      count = count + 1
   end do

   ! now we know the size, allocate memory for the data subset
   !
   allocate(subset(count))

   count = 0
   do i = 1, len_data(1)
      if (data(i)%year < begin_year)       continue
      if (data(i)%year > end_year)         continue
      if (data(i)%lat  < lat - dLat/2.)    continue
      if (data(i)%lat  > lat + dLat/2.)    continue
      if (data(i)%long < long - dLong/2.)  continue
      if (data(i)%long > long + dLong/2.)  continue
      if (data(i)%magnitude < threshold)   continue

      ! found an event, add it to the data subset
      count = count + 1
      subset(count) = data(i)
   end do

end subroutine counter

end module clusters


program main
   use clusters
   implicit none

   type(quake) :: quakes(MAX_SIZE)
   type(quake), allocatable :: subset(:)

   integer :: begin_year, end_year
   real :: lat, long, dLat, dLong, threshold
  
   !! first read in the data (not shown)
   !

   call counter(quakes, lat, long, dLat, dLong, begin_year, end_year, threshold, subset)

   !! free allocated memory
   !
   deallocate(subset)

end program
