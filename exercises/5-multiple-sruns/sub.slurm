#!/bin/sh
#SBATCH --job-name=lmp_ex5
#SBATCH --nodes=1
#SBATCH --time=0:10:0
#SBATCH --hint=nomultithread
#SBATCH --distribution=block:block

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

# setup loop
for i in $(seq 0 6)
do
  cores=$((2**$i))
  echo "Running seq ${i}: ${cores} cpu cores"
  srun --nodes=1 --ntasks=${cores} --ntasks-per-node=${cores} \
    --cpus-per-task=1 --exact --mem=$((${cores}*1500))M \
    lmp -i in.ethanol -l log.${cores}_cores -var TEMPERATURE $((283 + 5 * $i)) &
done

# wait for all jobs to finish
wait
