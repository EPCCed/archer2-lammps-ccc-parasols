#!/usr/bin/env python3
"""Exercise showing how to use LAMMPS from python"""

from lammps import lammps


def main():
    lmp = lammps()
    lmp.file("in.drum")

    for steps_per_rotation in [5000, 10000, 20000]:
        lmp.command(f"dump       1 all custom 100 rotating_drum.{steps_per_rotation}.dump id type radius mass x y z")
        lmp.command(f"log        log.{steps_per_rotation}")
        lmp.command(f"variable   theta equal 2*PI*elapsed/{steps_per_rotation}")
        lmp.command("run         40000")
        lmp.command("undump      1")


if __name__ == '__main__':
    main()
