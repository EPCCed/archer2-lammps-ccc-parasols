---
title: "Advanced input and output commands"
teaching: 30
exercises: 30
---
:::::::::::::::::::::::::::::::::::::: questions

- "How do I calculate a property every N time-steps?"
- "How do I write a calculated property to file?"
- "How can I use variables to make my input files easier to change?"

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- "Understand the use of `compute`, `fix`, and variables."

::::::::::::::::::::::::::::::::::::::::::::::::

## Advanced input commands

LAMMPS has a very powerful suite for calculating, and outputting all kinds of physical properties during the simulation.
Calculations are most often under a [compute command](https://docs.lammps.org/computes.html),
and then the output is handled by a [fix command](https://docs.lammps.org/fixes.html).
We will now look at some examples, but there are (at the time of writing) over 150 different `compute` commands with many options each.

### LAMMPS trajectory files

We can output information about a group of particles in our system by using the LAMMPS `dump` command.
In this example, we will be outputting the particle positions, but you can output many other attributes, such as particle velocities, types, angular momentum, etc.
The list of attributes (and examples of `dump` commands) can be found in the [relevant LAMMPS manual page](https://docs.lammps.org/dump.html).

If we look at the starting input script in `exercises/3-advanced-inputs-exercise/in.lj_start`, we find that the following command has been added:

```
dump            1 all custom 100 rotating_drum.dump id type radius mass x y z
```

The `dump` command defines the properties that we want to output, and how frequently we want these output.
In this case, we have set the ID of the `dump` command to `1` (we could have used any name/number and it would still work).
We want to output properties for `all` particles in our system.
We've set the output type to `custom` to have better control of what's being output
-- there are default `dump` options but `custom` is generally the one that gets used.
We'll be outputting every `100` time-steps to a file called `nvt.lammpstrj`
-- a `*.lammpstrj` file can be recognised by some post-processing and post-analysis tools as a LAMMPS trajectory/dump file,
and can save some time down the line.
Finally, we name the properties we want to output
-- in this case, we want to output the particle ID, type,
(x,y,z) components of position, and the (x, y, z) components of velocity.

We've added a `dump_modify` command to get LAMMPS to sort the output by ID order
-- we tell the `dump_modify` command which `dump` command we'd like to sort by giving the dump-ID
(in this case, our `dump` command had an ID of `1`).
We then specify how we want to modify this `dump` command -- we want to `sort` it by ID,
but there are many more options (that you can find in the [LAMMPS manual](https://docs.lammps.org/dump_modify.html)).

The output `rotating_drum.dump` file looks like this:

```
ITEM: TIMESTEP
100
ITEM: NUMBER OF ATOMS
2741
ITEM: BOX BOUNDS pp pp ff
0.0000000000000000e+00 3.0000000000000000e+01
0.0000000000000000e+00 3.0000000000000000e+01
0.0000000000000000e+00 3.0000000000000000e+01
ITEM: ATOMS id type radius mass x y z
1 1 0.388095 0.244852 25.2758 16.9939 28.3519
2 1 0.485033 0.477973 24.1818 24.6876 27.6903
3 1 0.423595 0.318376 13.2428 21.4007 19.1017
4 1 0.353413 0.184899 7.58115 10.3236 26.5067
5 1 0.434095 0.342644 10.5736 17.2751 19.3327
```

The lines with `ITEM:` let you know what is output on the next lines
(so `ITEM: TIMESTEP` lets you know that the next line will tell you the time-step for this frame -- in this case, 100,000).
A LAMMPS trajectory file will usually contain the time-step, number of atoms, and information on box bounds before outputting the information we'd requested.

### Restart files

To allow the continuation of the simulation (with the caveat that it must continue to run in the same number of cores as was originally used), we can create a restart file.

This binary file contains information about system topology, force-fields, but not about computes, fixes, etc, these need to be re-defined in a new input file.

You can write a restart file with the command:

```
write_restart drum.restart
```

An arguably better solution is to write a data file, which not only is a text file,
but can then be used without restrictions in a different hardware configuration, or even LAMMPS version.

```
write_data  drum.data
```

You can use a restart or data file to start/restart a simulation by using a `read` command.
For example:

```
read_restart drum.restart
```

will read in our restart file and use that final point as the starting point of our new simulation.

Similarly:

```
read_data drum.data
```

will do the same with the data file we've output (or any other data file).

### Radial distribution functions (RDFs)

Next, we will look at the Radial Distribution Function (RDF), _g_(_r_).
This describes how the density of a particles varies as a function of the distance to a reference particle,
compared with a uniform distribution (that is, at r → ∞, _g_(_r_) → 1).
We can make LAMMPS compute the RDF by adding the following lines to our input script:

```
compute        RDF all rdf 150 cutoff 3.5
fix            RDF_OUTPUT all ave/time 25 100 5000 c_RDF[*] file rdf.out mode vector
```

We've named this `compute` command `RDF` and are applying it to the atom-group `all`.
The compute is of style `rdf`, and we have set it to have with 150 bins for the RDF histogram (e.g. there are 150 discrete distances at which atoms can be placed).
We've set a maximum cutoff of 3.5σ, above which we stop considering particles.

Compute commands are instantaneous -- they calculate the values for the current time-step, but that doesn't mean they calculate quantities every time-step.
A compute only calculates quantities when needed, _i.e._, when called by another command.
In this case, we will use our compute with the `fix ave/time` command, that averages a quantity over time, and outputs it over a long timescale.

Our `fix ave/time` has the following parameters:
 - `RDF_OUTPUT` is the name of the fix, `all` is the group of particles it applies to.
 - `ave/time` is the style of fix (there are many others).
 - The group of three numbers `25 100 5000` are the `Nevery`, `Nrepeat`, `Nfreq` arguments.
   These can be quite tricky to understand, as they interplay with each other.
   - `Nfreq` is how often a value is written to file.
   - `Nrepeat` is how many sets of values we want to average over (number of samples)
   - `Nevery` is how many time-steps in between samples.
   - `Nfreq` must be a multiple of `Nevery`, and `Nevery` must be non-zero even if `Nrepeat = 1`.
   - So, for example, an `Nevery` of 2, with `Nrepeat` of 3, and `Nfreq` of 100: at every time-step multiple of 100 (`Nfreq`),
     there will be an average written to file, that was calculated by taking 3 samples (`Nrepeat`), 2 time-steps apart (`Nevery`).
     So, time-steps 96, 98, and 100 are averaged, and the average is written to file.
     Likewise at time-steps 196, 198, and 200, etc.
   - In this case, we take a sample every 25 time-steps, 100 times, and output at time-step number 5000
     -- so from time-step 2500 to 5000, sampling every 25 time-steps.
 - `c_RDF[*]`, is the compute that we want to average over time.
   `c_` defines that we're wanting to use a compute, and `RDF` is our compute name.
   The `[*]` wildcard in conjunction with `mode vector` makes the fix calculate the average for all the columns in the compute ID.
 - The `file rdf_lj.out` argument tells LAMMPS where to write the data to.

For this command, the file looks something like this:

```output
# Time-averaged data for fix RDF_OUTPUT
# TimeStep Number-of-rows
# Row c_RDF[1] c_RDF[2] c_RDF[3]
100000 150
1 0.0116667 0 0
2 0.035 0 0
3 0.0583333 0 0
4 0.0816667 0 0
5 0.105 0 0
...
20 0.455 0 0
21 0.478333 0.334462 0.00227339
22 0.501667 1.9594 0.0169225
23 0.525 3.49076 0.0455044
24 0.548333 7.58762 0.113275
25 0.571667 9.36566 0.204196
...
```

:::::::::::::::::::::::::::::::::::::::: callout

## YAML output

Since version 4May2022 of LAMMPS, writing to YAML files support was added.
To write a YAML file, just change the extension accordingly `file rdf_lj.yaml`.
The file will then be in YAML format:

```YAML
# Time-averaged data for fix RDF_OUTPUT_YAML
# TimeStep Number-of-rows
# Row c_RDF[1] c_RDF[2] c_RDF[3]
---
keywords: ['c_RDF[1]', 'c_RDF[2]', 'c_RDF[3]', ]
data:
  100000:
  - [0.011666666666666691, 0, 0, ]
  - [0.035000000000000045, 0, 0, ]
  - [0.05833333333333334, 0, 0, ]
...
```

::::::::::::::::::::::::::::::::::::::::::::::::


## Variables and loops

LAMMPS input scripts can be quite complex, and it can be useful to run the same script many times with only a small difference (for example, temperature).
For this reason, LAMMPS have implemented variables and loops -- but this doesn't mean that we can only use variables *with* loops.

A variable in LAMMPS is defined with the keyword `variable`, then a `name`, and then style and arguments, for example:

```
variable        StepsPerRotation equal 20000.0
variable        theta equal 2*PI*elapsed/${StepsPerRotation}
```

There are several [variable styles](https://docs.lammps.org/variable.html).
Of particular note are:
 - `equal` is the workhorse of the styles, and it can set a variable to a number, `thermo` keywords, maths operators or functions, among other things.
 - `delete` unsets a variable.
 - `loop` and `index` are similar, and will result in the variable changing to the next value in a list every time a `next` command is seen.
   The difference that `loop` accepts an integer or range, while `index` accepts a list of strings.

To use a variable later in the script, just prepend a dollar sign, like so:

```
thermo_style    custom step atoms ke v_theta
```

Example of loop:

```
variable a loop 10
label loop
dump 1 all atom 100 file.$a
run 10000
undump 1
next a
jump SELF loop
```

and of `index`:

```
variable d index run1 run2 run3 run4 run5 run6 run7 run8
label loop
shell cd $d
read_data data.polymer
run 10000
shell cd ..
clear
next d
jump SELF
```

:::::::::::::::::::::::::::::::::::::: challenge

## Run drum at several speeds

Modify the files from exercise 3 to use a loop like described above that rotates the drum at different speeds,
for example, 5000, 10000, and 20000 steps per rotation.

::::::::::::::::::::::::::::::: solution

```output
# loop
variable        StepsPerRotation index 5000.0 10000.0 20000.0
label loop
# rotate drum
variable        theta equal 2*PI*elapsed/${StepsPerRotation}

dump            2 all custom 100 rotating_drum.$(2*PI/v_StepsPerRotation:%.5f).dump id type radius mass x y z

# run rotation
run             40000

undump 2
next StepsPerRotation
jump SELF loop
```

::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::: keypoints

- "Using `compute` and `fix` commands, it's possible to calculate myriad properties during a simulation."
- "Variables make it easier to script several simulations."

::::::::::::::::::::::::::::::::::::::::::::::::
