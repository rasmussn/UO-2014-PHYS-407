! -*- f90 -*-
!
! Copyright (c) 2010-2012 Cisco Systems, Inc.  All rights reserved.
! Copyright (c) 2009-2012 Los Alamos National Security, LLC.
!                         All rights reserved.
! $COPYRIGHT$

program main
    use mpi
    implicit none
    double precision :: t1, t2
    integer :: t, rank, size, left, right, err
    real    :: boundary(1)

    integer, parameter :: nt  = 3           ! number of time steps
    integer, parameter :: sleep_sec = 5     ! number of seconds to sleep
    integer, parameter :: tag = 201         ! for MPI matching, number unimportant

    ! Start up MPI

    call MPI_Init(err)

    call MPI_Comm_rank(MPI_COMM_WORLD, rank, err)
    call MPI_Comm_size(MPI_COMM_WORLD, size, err)
 
    ! Calculate the rank of the process to the right in the ring.  Use the
    !   modulus operator so that the last process "wraps around" to
    !   rank zero (periodic boundary conditions).

    right = modulo(rank + 1, size)
    left = modulo(rank + size - 1, size)

    if (rank == 0) then
        t1 = MPI_Wtime()
        print *, "Process 0, ", size, "processes in ring"
        print *
     end if

    ! Perform the time advance loop
    !
    do t = 1, 2
        boundary(1) = 10*rank   ! you need to set an appropriate boundary condition
        call MPI_Send(boundary, 1, MPI_REAL, right, tag, MPI_COMM_WORLD, err)
        print *, "Process", rank, "sent    ", boundary(1), "to  ", right

        call MPI_Recv(boundary, 1, MPI_REAL, left, tag, MPI_COMM_WORLD, MPI_STATUS_IGNORE, err)
        print *, "Process", rank, "received", boundary(1), "from", left

        !
        ! Perform wave propagation using new information from left
        !   just sleep for now.  Since work per process shrinks as
        !   processes are added, divide by work size.
        !
        call sleep(sleep_sec/size)

        if (rank == 0) print *

    end do

    call MPI_Barrier(MPI_COMM_WORLD, err)

    if (rank == 0) then
        t2 = MPI_Wtime()

        print *, "elapse time:", 1000*REAL(t2-t1), "ms"
        print *
    end if
    
    ! All done

    call MPI_Finalize(err)

end program main
