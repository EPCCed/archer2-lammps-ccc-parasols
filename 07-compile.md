---
title: "Compiling LAMMPS"
teaching: 15
exercises: 0
---
:::::::::::::::::::::::::::::::::::::: questions

- "How can I compile LAMMPS using CMake"
- "How do I build LAMMPS with its shared libraries?"

::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::: objectives

- "Know how to compile LAMMPS on ARCHER2 
  (and what to look for when compiling elsewhere)."

::::::::::::::::::::::::::::::::::::::::::::::::

## Building LAMMPS with Python

For this course, we will be using a version of LAMMPS that has been built with the "Python" package and with shared libraries.
These will help us ensure that we can run LAMMPS through Python.

The build instructions used can be found in the
[hpc-uk github](https://github.com/hpc-uk/build-instructions/blob/main/apps/LAMMPS/ARCHER2_2023-12-15_cpe2212.md)
and were:

```bash
# select centrally installed modules needed for compilation
module load cpe/22.12
module load cray-fftw/3.3.10.3
module load cmake/3.21.3
module load cray-python

# Add cray library paths to the LD_LIBRARY_PATH variable
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH

# clone the chosen version of LAMMPS
git clone --depth=1 --branch stable_15Dec2023 https://github.com/lammps/lammps.git lammps-src-2023-12-15

# create and source a virtual environment
python -m venv --system-site-packages  /work/y07/shared/apps/core/lammps/15_Dec_2023/venv/lammps-python-15-Dec-2023
source /work/y07/shared/apps/core/lammps/15_Dec_2023/venv/lammps-python-15-Dec-2023/bin/activate

# creata folder for configuration and compilation
cd lammps-2023-12-15 && mkdir build_cpe && cd build_cpe

# use cmake to configure LAMMPS
cmake -C ../cmake/presets/most.cmake                                       \
      -D BUILD_MPI=on                                                      \
      -D BUILD_SHARED_LIBS=yes                                             \
      -D CMAKE_CXX_COMPILER=CC                                             \
      -D CMAKE_CXX_FLAGS="-O2"                                             \
      -D CMAKE_INSTALL_PREFIX=/path/to/install  \
      -D FFT=FFTW3                                                         \
      -D FFTW3_INCLUDE_DIR=${FFTW_INC}                                     \
      -D FFTW3_LIBRARY=${FFTW_DIR}/libfftw3_mpi.so                         \
      -D PKG_MPIIO=yes                                                     \
      ../cmake/

make -j 8
make install
make install-python
```

Of note here:

  - `-D CMAKE_INSTALL_PREFIX=/path/to/install` defines the path into which your LAMMPS executables and libraries will be built.
    You will need to change `/path/to/install` to whatever you like.
  - `-D BUILD_SHARED_LIBS=yes` will build the shared LAMMPS library required to run LAMMPS in Python.
  - `-D PKG_PYTHON=yes` will build the Python packages.
  - The `-C ../cmake/presets/most.cmake` command adds the packages that we are installing.
    Not all of them are required for this course, but it includes all packages that don't need extra libraries.
  - The rest of the instructions are to ensure that the correct compiler is used,
    the MPI version of LAMMPS is built,
    and that it has access to the correct fast Fourier transform (FFTW) and Eigen3 libraries.

Once this is built, you should be able to run LAMMPS from the compute nodes by loading the appropriate module.

## Building LAMMPS with VTK - local linux system

To vuild LAMMPS with VTK on an Ubuntu/Debian system (or virtual machine),
you will need to install the following pre-requesites:

- Compiler (gcc or clang)
- MPI
- VTK
- FFTW3
- Optionally, python

To do this, you can use the aptitude package manager:

```bash
sudo apt install libvtk9-dev openmpi-bin openmpi-common python3-dev libfftw3-dev
```
### Download LAMMPS

Clone the latest stable version of LAMMPS from the GitHub repository:

```bash
git clone --depth=1 --branch stable_22Jul2025_update1 https://github.com/lammps/lammps.git lammps-2025-09-02
```

### Optional - for Python support

```bash
# create
python -m venv --system-site-packages /path/to/venv/lammps-2025-09-02
# and source a virtual environment
source /path/to/venv/lammps-2025-09-02/bin/activate
```

### Regular MPI executable and python wrappers

Create and go into a build directory:

```bash
cd lammps-2025-09-02 && mkdir build_cpe && cd build_cpe
```

Build using:

```bash
cmake -C ../cmake/presets/most.cmake            \
      -D PKG_VTK=yes                            \
      -D BUILD_MPI=on                           \
      -D BUILD_SHARED_LIBS=yes                  \
      -D CMAKE_CXX_FLAGS="-O2"                  \
      -D CMAKE_INSTALL_PREFIX=/path/to/install  \
      -D FFT=FFTW3                              \
      ../cmake/


make -j 8
make install
make install-python
```

```bash
export LD_LIBRARY_PATH=/path/to/install/lib:$LD_LIBRARY_PATH
export PATH=/path/to/install/bin:$PATH
```

## Building LAMMPS with VTK on ARCHER2

These instructions are for building LAMMPS version 13Feb2024, also known as 07Feb2024 update 1, on ARCHER2 using the Cray clang compilers 15.0.2 // cpe 22.12 with support for VTK files.

### Path setup

```bash
# base-path for download and source files
export DWNLD_DIR="/work/ta215/ta215/shared/download"
export INSTALL_DIR="/work/ta215/ta215/shared/"
export LAMMPS_DWNLD=${DWNLD_DIR}/lammps-2024-02-13
export LAMMPS_BUILD=${LAMMPS_DWNLD}/build
export LAMMPS_INSTALL=${INSTALL_DIR}/lammps
export VTK_DWNLD=${DWNLD_DIR}/vtk
export VTK_BUILD=${VTK_DWNLD}/build
export VTK_INSTALL=${INSTALL_DIR}/vtk-9.5.2
```

### Setup your environment

Load the correct modules:

```bash
module load cpe/22.12
module load cray-fftw/3.3.10.3
module load cmake/3.21.3
module load cray-python

export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH

# create and source a virtual environment
python -m venv --system-site-packages ${LAMMPS_INSTALL}/venv/lammps-python-13-Feb-2024
source ${LAMMPS_INSTALL}/venv/lammps-python-13-Feb-2024/bin/activate
```

### Download and compile the VTK library

```bash
mkdir -p ${VTK_DWNLD}
cd ${VTK_DWNLD}
wget https://vtk.org/files/release/9.5/VTK-9.5.2.tar.gz
tar -xvf VTK-9.5.2.tar.gz
mv VTK-9.5.2 source
mkdir -p ${VTK_BUILD}
cd ${VTK_BUILD}
cmake -DVTK_USE_MPI:BOOL=ON -DVTK_SMP_IMPLEMENTATION_TYPE:STRING=OpenMP -DCMAKE_BUILD_TYPE:STRING=Release ${VTK_DWNLD}/source
cmake --build . -j8
cp -r ${VTK_DWNLD} ${VTK_INSTALL}
```

### Download LAMMPS

Clone the latest stable version of LAMMPS from the GitHub repository:

```bash
cd $DWNLD_DIR
git clone --depth=1 --branch patch_7Feb2024_update1 https://github.com/lammps/lammps.git ${LAMMPS_DWNLD}
```


### Regular MPI executable and python wrappers

Create and go into a build directory:

```bash
mkdir -p ${LAMMPS_BUILD}
cd ${LAMMPS_BUILD}
```

Build using:

```bash
cmake -C ../cmake/presets/most.cmake                \
      -D BUILD_MPI=on                               \
      -D BUILD_SHARED_LIBS=yes                      \
      -D CMAKE_CXX_COMPILER=CC                      \
      -D CMAKE_CXX_FLAGS="-O2"                      \
      -D CMAKE_INSTALL_PREFIX=${LAMMPS_INSTALL}     \
      -D FFT=FFTW3                                  \
      -D FFTW3_INCLUDE_DIR=${FFTW_INC}              \
      -D FFTW3_LIBRARY=${FFTW_DIR}/libfftw3_mpi.so  \
      -D PKG_MPIIO=yes                              \
      -D PKG_VTK=yes                                \
      -D VTK_DIR=${VTK_INSTALL}                     \
      ../cmake/

make -j 8
make install
make install-python
```

:::::::::::::::::::::::::::::::::::::::: callout

### To run LAMMPS from python

`LD_PRELOAD` needs to be modified (this is done in the module file, but
if running the text below without loading a module, it needs to be done
explicitly):

```bash
export LD_PRELOAD=/opt/cray/pe/lib64/libsci_cray_mp.so.5:$LD_PRELOAD
```

### Testing LAMMPS from python

```bash
python -i
>>> import lammps
>>> lmp = lammps.lammps()
LAMMPS (07 Feb 2024 - Update 1)
OMP_NUM_THREADS environment is not set. Defaulting to 1 thread. (src/comm.cpp:98)
  using 1 OpenMP thread(s) per MPI task
```

::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::: keypoints

- "Compiling LAMMPS with CMake is easy and quick on ARCHER2"

::::::::::::::::::::::::::::::::::::::::::::::::
