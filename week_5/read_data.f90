program read_data
  implicit none
  integer, parameter :: DATA_LEN = 144
  integer :: i, year(DATA_LEN)
  real :: july(DATA_LEN), aug(DATA_LEN), sept(DATA_LEN)
  
  do i = 1, DATA_LEN
     read(*,*) year(i), july(i), aug(i), sept(i)
  end do

  do i = 1, DATA_LEN
     write(*,*) year(i), july(i), aug(i), sept(i)
  end do

!! What will this do?
!
!   write(*,*) year, july, aug, sept

end program
