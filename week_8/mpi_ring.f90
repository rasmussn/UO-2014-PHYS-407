! -*- f90 -*-
!
! Copyright (c) 2010-2012 Cisco Systems, Inc.  All rights reserved.
! Copyright (c) 2009-2012 Los Alamos National Security, LLC.
!                         All rights reserved.
! $COPYRIGHT$

program main
    use mpi
    implicit none
    integer, parameter :: tag = 201
    integer :: rank, size, next, prev, err
    integer :: i, message(1)

    ! Start up MPI

    call MPI_Init(err)

    call MPI_Comm_rank(MPI_COMM_WORLD, rank, err)
    call MPI_Comm_size(MPI_COMM_WORLD, size, err)
 
    ! Calculate the rank of the next process in the ring.  Use the
    !   modulus operator so that the last process "wraps around" to
    !   rank zero.

    next = modulo(rank + 1, size)
    prev = modulo(rank + size - 1, size)

    ! If we are the "master" process (i.e., MPI_COMM_WORLD rank 0),
    !   put the number of times to go around the ring in the
    !   message.

    if (rank == 0) then
        message(1) = 5

        print *, "Process 0, ", size, "processes in ring"
        print *, "Process 0 sending", message(1), "to", next
        
        call MPI_Send(message, 1, MPI_INTEGER, next, tag, MPI_COMM_WORLD)
    end if

    ! Pass the message around the ring.  The exit mechanism works as
    !   follows: the message (a positive integer) is passed around the
    !   ring.  Each time it passes rank 0, it is decremented.  When
    !   each processes receives a message containing a 0 value, it
    !   passes the message on to the next process and then quits.  By
    !   passing the 0 message first, every process gets the 0 message
    !   and can quit normally. */

    message(1) = 1
    do while (message(1) > 0)
        call MPI_Recv(message, 1, MPI_INTEGER, prev, tag, MPI_COMM_WORLD, err)
        print *, "Process", rank, "received", message(1)
        if (rank == 0) then
            message(1) = message(1) - 1
        end if

        call MPI_Send(message, 1, MPI_INTEGER, next, tag, MPI_COMM_WORLD)
        if (message(1) == 0) then
            print *, "Process", rank, "exiting"
        end if
    end do

    ! The last process does one extra send to process 0, which needs
    !   to be received before the program can exit

    if (rank == 0) then
        call MPI_Recv(message, 1, MPI_INTEGER, prev, tag, MPI_COMM_WORLD, err)
    end if
    
    ! All done

    call MPI_Finalize(err)

end program main
