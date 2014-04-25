module vache

contains

real elemental function moo(a, b)
   implicit none
   real, intent(in) :: a, b

   moo = a + b

end function moo

end module vache
