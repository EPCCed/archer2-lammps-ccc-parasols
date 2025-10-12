#!/bin/sh
#SBATCH --job-name=lmp_ex3
#SBATCH --nodes=1
#SBATCH --time=0:10:0
#SBATCH --hint=nomultithread
#SBATCH --distribution=block:block
#SBATCH --tasks-per-node=128
#SBATCH --cpus-per-task=1

# The budget code of the project
#SBATCH --account=ta215
# Standard partition
#SBATCH --partition=standard
# Short QoS since our runtime is under 20m
#SBATCH --qos=short

# load the lammps module
module load lammps/29Aug2024

# Set the number of threads to 1
#   This prevents any threaded system libraries from automatically
#   using threading.
export OMP_NUM_THREADS=1

# Launch the parallel job
srun lmp -i in.drum -l log.${SLURM_NPROCS}_cpus
