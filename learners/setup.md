---
title: Setup
---

## Data Sets

We will only be using the exercises contained in the [exercise folder on the github](https://github.com/epcced/archer2-lammps-ccc-parasols/tree/main/exercises).

You can download the exercises directly on the command line (on an operating system that supports `wget` and `tar`) with:

```
wget -O - https://github.com/EPCCed/archer2-lammps-ccc-parasols/archive/main.tar.gz | tar -xz --strip=2 "archer2-lammps-ccc-parasols-main/exercises"
```

## Software Setup

::::::::::::::::::::::::::::::::::::::: discussion

### Details

We recommend the use of a \*NIX system, such as any Linux distribution, or MacOS.
If you have a windows laptop, consider installing Windows Subsystems for Linux
-- a Microsoft application that runs a Linux VM natively on Windows.
Couple it with Windows Terminal for best results

:::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::: spoiler

### Windows

Use WSL if possible, MobaXTerm as an alternative
-- although you might not be able to do the compilation exercise in that case

To install the Windows Terminal, search for "Windows Terminal" on the Microsoft Store App.

To install WSL, search for "Ubuntu 24.04" on the Microsoft Store App, and follow the instructions (you will need to run a command on the terminal and reboot your sytem).

In-detail instructions [here](https://learn.microsoft.com/en-us/windows/wsl/install).

::::::::::::::::::::::::

:::::::::::::::: spoiler

### MacOS

Use Terminal.app

::::::::::::::::::::::::


:::::::::::::::: spoiler

### Linux

Use any Terminal emulator.

::::::::::::::::::::::::

