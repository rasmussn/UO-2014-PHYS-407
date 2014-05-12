#!/bin/bash -l

## Lines preceded by "#PBS" are directives for Torque/PBS
## this line tells Torque the name of the batch job
##
#PBS -N advection

## this line tells Torque which queue to submit to
## see /INFO/queues.txt for a description of available queues
##
#PBS -q generic

## resource list:
##   1 nodes and 1 processor(s) per node
##   2 min
##
#PBS -l nodes=1:ppn=1:mpi
#PBS -l walltime=00:00:02

## directory list:
##
#PBS -d /your_home_directory_path/PHYS-410/week_7
#PBS -o /your_home_directory_path/PHYS-410/week_7
#PBS -e /your_home_directory_path/PHYS-410/week_7

## email
##
#PBS -m ea
#PBS -M your_email_address

# load modules
# see /INFO/modules-howto.txt for a mini-howto on Modules

module load python
module load gcc
module load mpi-tor/openmpi-1.7_gcc-4.8

# execute program
#
cd /your_home_directory_path/PHYS-410/week_7
./advect

## look at free nodes with
#
# pbsnodes -l "free"  ("active", "all", "busy", "down", "free", "offline", "unknown", "up")
#
