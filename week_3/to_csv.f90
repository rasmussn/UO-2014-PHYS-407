program to_csf
   implicit none
   real :: lat, long, hours
   integer :: id, speed, pressure, year
   character(len=12) :: name
   character(len=31) :: desc
   
   character(len=*), parameter :: fmt_in  = "(i6, a12, 2f8.1, i5, 2i6, f11.2, a31)"
   character(len=*), parameter :: fmt_out = "(i6, ',', a, ',', 2(f8.1, ','), 3(i6, ','), f10.2, ',', a, ',')"

   !! read the file one line at a time and output csv (comma separated values)
   !
   do while (.true.)
      read (*, fmt_in,  end=13) id, name, lat, long, speed, pressure, year, hours, desc
      write(*, fmt_out, err=13) id, trim(name), lat, long, speed, pressure, year, hours, trim(desc)
   end do

13 continue           ! finished reading the file

end program
end craig
