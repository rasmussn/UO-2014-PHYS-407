module advection

   implicit none

   !! initialize constants
   !
   integer, parameter ::   N   = 32           ! number of interior cells
   integer, parameter ::   NH  = 2            ! number of halo cells on each side of the spatial domain
   integer, parameter ::   nt  = 16           ! number of time steps
   real,    parameter ::   u0  = 1.0          ! constant velocity > 0
   real,    parameter ::   dx  = 1.0          ! cell width
   real,    parameter ::   dt  = 0.5          ! time step is 1/2 of dx/u0

   !! declare arrays for dependent variables
   !
   real :: Rho(-NH:N-1+NH)    ! mass density rho, located on cell centers, first interior cell is R(0)
   real :: U(0:N)             ! velocity, located at cell boundaries, first boundary is U(0)

contains

subroutine initialize_box()
   implicit none

   U = u0                ! constant value everywhere
   Rho = 0.0             ! initialize 0 everywhere, fix left half below
   Rho(0:N/2-1) = 1.0    ! 0 everywhere, except for left half of domain

   call set_periodic_boundaries()

end subroutine initialize_box

subroutine initialize_sin()
   implicit none
   integer :: i
   real, parameter :: pi = 3.14159

   U = u0                ! constant value everywhere

   do i = 0, N-1
      Rho(i) = 0.5*(1.0 + sin(i*dx*2.0*pi/(N-1)))
   end do

   call set_periodic_boundaries()

end subroutine initialize_sin

subroutine set_periodic_boundaries()
   implicit none

   Rho(-NH)   = Rho(N-NH)     ! left  boundary cells equals right-most interior cells
   Rho(-NH+1) = Rho(N-NH+1)   ! left  boundary cells equals right-most interior cells
   Rho(N)     = Rho(0)        ! right boundary cells equals left- most interior cells
   Rho(N+1)   = Rho(1)        ! right boundary cells equals left- most interior cells

end subroutine set_periodic_boundaries

subroutine output_variables()
   implicit none
   integer :: i
   
   write(*,*)
   do i = -NH, N-1+NH
      write(*,*) i, Rho(i)
   end do
   
end subroutine output_variables

subroutine advect_first_order
   implicit none
   real :: e1, rho_l, rho_r, Tmp(-NH:N-1+NH)    ! need temporary storage for mass density
   integer :: i

   e1 = u0*(dt/dx)   ! Courant number, % of cell fluid moves in one time step

   !
   ! Remap (interpolate) transported densities back to cell centers.  Since
   ! this is a first order method assume the density is constant throughout
   ! each cell.  Since U > 0, the donor cell is always to the left.
   ! Since U is constant, the Courant number is also constant.
   !  
   do i = 0, N-1
      rho_l  = Rho(i-1)                       ! equation 4.42 with D = 0
      rho_r  = Rho(i)                         ! equation 4.42 with D = 0
      Tmp(i) = Rho(i) - e1*(rho_r - rho_l)    ! equation 4.41
   end do

   Rho = Tmp    ! finished with temporary storage
   call set_periodic_boundaries()

end subroutine advect_first_order

subroutine advect_second_order
   implicit none
   real :: e1, rho_l, rho_r, Tmp(-NH:N-1+NH)    ! need temporary storage for mass density
   integer :: i

   e1 = u0*(dt/dx)   ! Courant number, % of cell fluid moves in one time step

   !
   ! Remap (interpolate) transported densities back to cell centers using second
   ! order method, equation (4.43b).
   !
   do i = 0, N-1
      rho_l  = Rho(i-1) + 0.5*(1.0 - e1)*(Rho(i  ) - Rho(i-1))  ! equation 4.42, second order
      rho_r  = Rho(i  ) + 0.5*(1.0 - e1)*(Rho(i+1) - Rho(i  ))  ! equation 4.42, second order
      Tmp(i) = Rho(i) - e1*(rho_r - rho_l)                      ! equation 4.41
   end do

   Rho = Tmp    ! finished with temporary storage
   call set_periodic_boundaries()

end subroutine advect_second_order

!!!!!
! return the sign of the flux limiter
!
pure real function flux_limiter_sign(upw, dnw)
   real, intent(in) :: upw, dnw
   real :: s   

   if (upw*dnw <= 0.0) then
      s = 0.0
   else
      if (upw > 0.0) then
         s = +1.0
      else
         s = -1.0
      end if
   end if

   flux_limiter_sign = s

end function flux_limiter_sign

subroutine advect_third_order
   implicit none
   integer :: i
   real :: e1, e3, e4, s, don, dnw, upw, rho_l, rho_r
   real :: Tmp(-NH:N-1+NH)        ! need temporary storage for mass density

   e1 = u0*(dt/dx)       ! Courant number, % of cell fluid moves in one time step
   e3 = (1.0 + e1)/6.0
   e4 = (2.0 - e1)/6.0

   !
   ! Remap (interpolate) transported densities back to cell centers using third
   ! order method, equation (4.43c).
   !
   do i = 0, N-1
      ! right-hand interface (see Appendix E.5 from the Pagosa manual)
      !
      don = Rho(i)                   ! donor cell
      upw = Rho(i)   - Rho(i-1)      ! upwind   gradient
      dnw = Rho(i+1) - Rho(i)        ! downwind gradient

      s = flux_limiter_sign(upw, dnw)

      upw = abs(upw)
      dnw = abs(dnw)
      rho_r = don + s*(1.0 - e1)*min(upw, dnw, e3*upw + e4*dnw)

      ! left-hand interface (see Appendix E.5 from the Pagosa manual)
      !
      don = Rho(i-1)                 ! donor cell
      upw = Rho(i-1) - Rho(i-2)      ! upwind   gradient
      dnw = Rho(i  ) - Rho(i-1)      ! downwind gradient

      s = flux_limiter_sign(upw, dnw)

      upw = abs(upw)
      dnw = abs(dnw)
      rho_l = don + s*(1.0 - e1)*min(upw, dnw, e3*upw + e4*dnw)

      Tmp(i) = Rho(i) - e1*(rho_r - rho_l)                ! equation 4.41
   end do

   Rho = Tmp    ! finished with temporary storage
   call set_periodic_boundaries()

end subroutine advect_third_order

end module advection


program advect
   use advection
   implicit none
   integer :: t

   call initialize_box()
   print *, 0, "Total mass is", sum(Rho(0:N-1))

   do t = 1, nt
      ! no need for Lagrangian phase in this assignment as no dU/dx
      call advect_third_order()
      print *, t, "Total mass is", sum(Rho(0:N-1))
   end do

   call output_variables()

end program
