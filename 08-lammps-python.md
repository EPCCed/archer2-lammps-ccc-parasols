---
title: "Running LAMMPS through Python"
teaching: 10
exercises: 20
---
:::::::::::::::::::::::::::::::::::::: questions

- "How can I run LAMMPS from within Python?"

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- "Know how run a LAMMPS simulation through Python."

::::::::::::::::::::::::::::::::::::::::::::::::


## Running LAMMPS through Python

Running LAMMPS through Python is quite a simple task: you can import the LAMMPS Python library, start the LAMMPS environment, and run a LAMMPS simulation by running the following commands:

```python
from lammps import lammps

def main():
    lmp = lammps()
    lmp.file("in.pour")

if __name__ == '__main__':
    main()
```

Python will use the shared LAMMPS libraries to run this.
Under the hood, LAMMPS runs the same processes as it would if the script was run directly through the LAMMPS executable,
and jobs run with Python will run in comparable times.

One of the main advantages of running LAMMPS through Python is that it allows  you to make use of Python's dynamic programming.
Also, while LAMMPS offers a large amount of options for writing scripts
(via e.g. `variables` definition, `jump` commands and `if` statements),
these are not as intuitive to a lot of users as a Python interface.

### Exercise

We have prepared an example on how to call LAMMPS from python.
To access this, please `cd exercises/6-python/`.
In this directory you will find three files:

  - `in.drum` is the LAMMPS input file adapted from an earlier exercise with a rotating drum.
  - `lammps_drum.py` is a Python script that initially runs the simulation defined in the `in.drum` LAMMPS configuration file.
    Once that is complete, the script will launch a series of simulations run with changing rotating drum speeds
  - `sub.slurm` is the Slurm submission script for running this simulation on the ARCHER2 compute nodes.

You can submit this simulation to the queue by running:

```bash
sbatch sub.slurm
```

One disadvantage of using the LAMMPS python module is that debugging can be more complicated when things go wrong.
There are more moving parts than with the LAMMPS executable,
and it can often be difficult to trace back errors and attribute them correctly to LAMMPS, Python, or the interface.

:::::::::::::::::::::::::::::::::::::::: callout

> The LAMMPS python module has a number of other features and variables that can be called to improve your use of LAMMPS through Python.
> You can find more information about this in the [LAMMPS manual](https://docs.lammps.org/Python_module.html).

::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::: keypoints

- "Running LAMMPS through Python can have certain advantages."
- "However, finding the root cause of problems when things go wrong is harder 
  to do when running LAMMPS through Python rather than through a LAMMPS 
  executable."

::::::::::::::::::::::::::::::::::::::::::::::::
