---
title: "Understanding the logfile"
teaching: 30
exercises: 0
---
:::::::::::::::::::::::::::::::::::::: questions

- "What information does LAMMPS print to screen/logfile?"
- "What does that information mean?"

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- "Understand the information that LAMMPS prints to screen / writes to the logfile before, during, and after a simulation."

::::::::::::::::::::::::::::::::::::::::::::::::

## Log file

The logfile is where we can find thermodynamic information of interest.
By default, LAMMPS will write to a file called `log.lammps`.
All info output to the terminal is replicated in this file.
We can change the name of the logfile by adding a `log` command to your script:

```
log     new_file_name.extension
```

We can change which file to write to multiple times during a simulation, and even `append` to a file if, for example,
we want the thermodynamic data separate from the logging of other assorted commands.
The thermodynamic data, which we setup with the `thermo` and `thermo_style` command, create the following (truncated) output:

```
   Step        Atoms
         0           0
       100        3402
       200        3402
       300        3402
       400        3402
```

At the start, we get a header with the column names, and then a line for each time-step that's a multiple of the value we set `thermo` to.
In this example we can see the number of particle change as the simulation progresses.
At the end of each `run` command, we get the analysis of how the simulation time is spent:

```
Loop time of 27.0361 on 128 procs for 10000 steps with 20000 atoms

Performance: 31957.239 tau/day, 369.875 timesteps/s, 7.398 Matom-step/s
99.8% CPU use with 128 MPI tasks x 1 OpenMP threadsLoop time of 27.0361 on 128 procs for 10000 steps with 20000 atoms

MPI task timing breakdown:
Section |  min time  |  avg time  |  max time  |%varavg| %total
---------------------------------------------------------------
Pair    | 0.00044784 | 0.72334    | 18.078     | 340.9 |  2.68
Neigh   | 0.0029201  | 0.059077   | 1.0824     |  73.2 |  0.22
Comm    | 0.94043    | 15.311     | 20.813     | 142.0 | 56.63
Output  | 0.27547    | 0.84274    | 2.1389     |  59.9 |  3.12
Modify  | 5.4303     | 5.6532     | 6.4467     |   7.9 | 20.91
Other   |            | 4.447      |            |       | 16.45

Nlocal:         156.25 ave        2361 max           0 min
Histogram: 110 2 5 7 0 0 0 0 2 2
Nghost:        139.727 ave        1474 max           0 min
Histogram: 108 0 0 8 4 2 2 0 2 2
Neighs:        1340.88 ave       28536 max           0 min
Histogram: 112 7 5 0 0 0 0 0 2 2

Total # of neighbors = 171633
Ave neighs/atom = 8.58165
Neighbor list builds = 1000
Dangerous builds = 994
Total wall time: 0:00:28
```

The data shown here is very important to understand the computational performance of our simulation,
and we can it to help improve the speed at which our simulations run substantially.
The first line gives us the details of the last `run` command - how many seconds it took,
on how many processes it ran on, how many time-steps, and how many atoms.
This can be useful to compare between different systems.

Then we get some benchmark information:

```
Performance: 31957.239 tau/day, 369.875 timesteps/s, 7.398 Matom-step/s
99.8% CPU use with 128 MPI tasks x 1 OpenMP threadsLoop time of 27.0361 on 128 procs for 10000 steps with 20000 atoms
```

This tells us how many time units per day, how many time-steps per second we are running,
and how many "Mega-atom-step per second" which is an easier measure to compare systems of different sizes (i.e., number of particles).
 It also tells us how much of the available CPU resources LAMMPS was able to use, and how many MPI tasks and OpenMP threads.

The next table shows a breakdown of the time spent on each task by the MPI library:

```
MPI task timing breakdown:
Section |  min time  |  avg time  |  max time  |%varavg| %total
---------------------------------------------------------------
Pair    | 0.00044784 | 0.72334    | 18.078     | 340.9 |  2.68
Neigh   | 0.0029201  | 0.059077   | 1.0824     |  73.2 |  0.22
Comm    | 0.94043    | 15.311     | 20.813     | 142.0 | 56.63
Output  | 0.27547    | 0.84274    | 2.1389     |  59.9 |  3.12
Modify  | 5.4303     | 5.6532     | 6.4467     |   7.9 | 20.91
Other   |            | 4.447      |            |       | 16.45
```

There are 8 possible MPI tasks in this breakdown:

 - `Pair` refers to non-bonded force computations
 - `Bond` includes all bonded interactions, (so angles, dihedrals, and impropers)
 - `Kspace` relates to long-range interactions (Ewald, PPPM or MSM)
 - `Neigh` is the construction of neighbour lists
 - `Comm` is inter-processor communication (AKA, parallelisation overhead)
 - `Output` is the writing of files (log and dump files)
 - `Modify` is the fixes and computes invoked by fixes
 - `Other` is everything else

Each category shows a breakdown of the least, average, and most amount of wall time any processor spent on each category
 -- large variability in this (calculated as `%varavg`) indicates a load imbalance (which can be caused by the atom distribution between processors not being optimal).
 The final column, `%total`, is the percentage of the loop time spent in the category.


:::::::::::::::::::::::::::::::::::::::: callout

## A rule-of-thumb for %total on each category

- `Pair` and `modify`: as much as possible.
- `Neigh` and `Comm`: as little as possible. If it's growing large, it's a clear sign that too many computational resources are being assigned to a simulation.

::::::::::::::::::::::::::::::::::::::::::::::::


The next section is about the distribution of work amongs the different threads:

```
Nlocal:         156.25 ave        2361 max           0 min
Histogram: 110 2 5 7 0 0 0 0 2 2
Nghost:        139.727 ave        1474 max           0 min
Histogram: 108 0 0 8 4 2 2 0 2 2
Neighs:        1340.88 ave       28536 max           0 min
Histogram: 112 7 5 0 0 0 0 0 2 2
```

The three subsections all have the same format: a title followed by average, maximum, and minimum number of particles per processor,
followed by a 10-bin histogram of showing the distribution.
The total number of histogram counts is equal to the number of processors used.
The three properties listed are:
 - `Nlocal`: number of owned atoms;
 - `Nghost`: number of ghost atoms;
 - `Neighs`: pairwise neighbours.


The final section shows aggregate statistics accross all processors for pairwise neighbours:

```
Total # of neighbors = 171633
Ave neighs/atom = 8.58165
Neighbor list builds = 1000
Dangerous builds = 994
```

It includes the number of total neighbours, the average number of neighbours per atom, the number of neighbour list rebuilds, and the number of _potentially dangerous_ rebuilds.
The _potentially dangerous_ rebuilds are ones that are triggered on the first timestep that is checked.
If this number is not zero, you should consider reducing the delay factor on the `neigh_modify` command.

The last line on every LAMMPS simulation will be the total wall time for the entire input script, no matter how many `run` commands it has:

```
Total wall time: 0:00:28
```

:::::::::::::::::::::::::::::::::::::: keypoints

- "Thermodynamic information outputted by LAMMPS can be used to track whether a simulations is running OK."
- "Performance data at the end of a logfile can give us insights into how to make a simulation faster."

::::::::::::::::::::::::::::::::::::::::::::::::
