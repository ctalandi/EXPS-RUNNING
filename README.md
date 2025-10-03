# EXPS-RUNNING
Gather all scripts and jobs used to perform a yearly simulation on Datarmor based on NEMO release 4.2.0<br>
It relies on the DCM (DRAKKAR CONFIGURATION MANAGER) to both create, compile a configuration as well as submit a yearly simulation.<br>

1 - DCM installation:<br> 
2 - Build a new configuration environment using DCM <br>
3 - Launch a numerical experiment.<br>
  
---
---

## 1- DCM installation <br> __ TO DO ONLY ONCE UNDER YOUR LOGIN __
The following note rely on the NEMO 4.2.0 official release. But it can be applied the same way to an other release. To do only once. <br>

DCM stands for Drakkar Configuration manager, it allows to  1) build a configuration, 2) compile it and 3) submit an experiment <br>
A complete documentation is available here: https://github.com/ctalandi/DCM-MASTER.git  <br>

This step relies on the 2 following components: NEMO GCM & XIOS library (to manage I/O); the XIOS library must be compiled before any NEMO compilation <br>

Somewhere in your Datarmor HOME, create a new directory, let's call the full path of this directory DCM in the following. <br>

Go into this new directory and clone the associated branch : <br>
```
cd DCM
git clone --branch DCM_4.2.0 https://github.com/ctalandi/DCM-MASTER.git DCM_4.2.0
```

The  DCM_4.2.0 sub-folders structure look like this: <br>
```
DCM_4.2.0/
├── DCMTOOLS
│   ├── bin
│   ├── DRAKKAR
│   │   └── NEMO4
│   ├── NEMOREF
│   │   └── nemo_4.2.0
│   └── templates
├── DOC
├── MODULES
├── License
└── RUNTOOLS
```

The NEMO 4.2.0 official release nemo_4.2.0 code sources has to be downloaded under the NEMOREF sub-folder as shown in the structure above. <br>
Execute the shell script getnemoref.sh to download it. The official [NEMO](https://sites.nemo-ocean.io/user-guide/) web site where to get complete information about NEMO, documentation, how to etc ... <br>
The file xios_revision.md gives information about how the get this XIOS library. <br>

Still in your home directory, at the root of your login, create a directory called modules if you do not have one and create the DCM subfolder <br>
Then copy in it the file called 4.2.0 from where you've just clone the DCM_4.2.0 structure: <br>
```
mkdir -p  modules/DCM
cd modules/DCM
cp ../../DCM/DCM_4.2.0/MODULES/4.2.0  .
```
Open it, and replace the name MYDCMDIR by the full path where DCM_4.2.0 have been cloned (looks like $HOMEDIR/DCM )<br>

In the header of your .bashrc file add the 2 lines below and change the yourlogin word (as the root path as well, i.e. /hom1/datahome if different in your case): <br>
```
source /usr/share/Modules/3.2.10/init/bash
export MODULEPATH="$MODULEPATH:/home1/datahome/yourlogin/modules:.:"
```
And elsewhere in your .bashrc file, add the following lines: <br>
```
# NEMO v4.2.0
module load DCM/4.2.0
alias mkconfdir=$HOMEDCM/bin/dcm_mkconfdir_local
module load NETCDF-test/4.3.3.1-mpt217-intel2018

export UDIR=$HOME/CONFIGS
export PDIR=$HOME/RUNS
export CDIR=$DATAWORK
export SDIR=$SCRATCH
export WORKDIR=$SCRATCH
```
- UDIR is the folder where the configuration will be built and from where the compilation process is launched <br>
- PDIR corresponds to the area from which the simulation is handled <br>

Then the NEMO code should also be downloaded. Go under DCM/DCM_4.2.0/DCMTOOLS/NEMOREF and execute the sript getnemoref.sh <br>

```
./getnemoref.sh
```
Once finished, a sub-directory called nemo_4.2.0 is present. It contains all source code from the official NEMO release (the one mentioned in the script getnemoref.sh).<br>

Finally, last step of this installation, source your .bashrc  to take into account the new changes above <br>
```
source .bashrc
```

Now type the command  mkconfdir  to test if it works, you should get a result close to the following one: <br>
```
(base) ctalandi@datarmor2 /home1/scratch/ctalandi $ mkconfdir
USAGE : mkconfdir [-h] [-v]  CONFIG CASE
       or
       mkconfdir [-h] [-v] CONFIG-CASE
        [-h ] : print this help message
        [-v ] : print a much more extensive explanation message

PURPOSE : This script is used to create the skeleton of a new NEMO config
          It will create many directories and sub-directories in many places
          according to the environment variables UDIR, CDIR, PDIR and SDIR
          that should be set previously (in your .profile of whatever file)
          The -v option  gives you much more details
```

---
---

## 2-  Build a new configuration environment using DCM <br>
This requires to install 2 dedicated sub-directories under master CONFIG & RUNS directories as follows: <br>
For instance, to build a new experiment called NEMO420 (in this exemple) that relies on the CREG025.L75 configuration, <br>
use the following command: <br>
```
mkconfdir CREG025.L75 NEMO420
```
CAUTION: make sure that  the module DCM/4.2.0 is loaded before lanching this command, type module list to check that<br>

This command creates 2 dedicated folders: <br>
- one dedicated to the NEMO code source and from which the compilation is handled under the master CONFIG folder <br>
- one where the user can launch a numerical experiment under the master RUNS folder <br>
	These 2 folders look like this: <br>
- Under the PDIR directory (set in your .bashrc, see above): <br>
```
RUNS/RUN_CREG025.L75/CREG025.L75-NEMO420
├── CTL
└── EXE
```

- And under the UDIR directory (previously set in your .bashrc file):<br>
```
CONFIGS/CONFIG_CREG025.L75/CREG025.L75-NEMO420
── arch
├── cfgs
├── ext
└── src
    ├── ICE
    ├── MY_SRC
    ├── NST
    ├── OCE
    ├── OFF
    ├── SAO
    ├── SAS
    └── TOP
```

Now, the user can fill these directories as it is explained below.<br>

Under the UDIR directory (previously set in your .bashrc file):<br>
```
CONFIGS/CONFIG_CREG025.L75/CREG025.L75-NEMO420
── arch
├── cfgs
├── ext
└── src
    ├── ICE
    ├── MY_SRC
    ├── NST
    ├── OCE
    ├── OFF
    ├── SAO
    ├── SAS
    └── TOP
```
### 2-1 Starting from an existing configuration <br>
The following relies on an existing configuration, but files can be downloaded from anywhere <br>
Download files from an exsiting configuration, create a directory MYDIR (anywhere, it's not important since you can remove it after getting files from it), go into this new directory and clone the associated configuration : <br>
```
cd MYDIR
git clone https://github.com/ctalandi/EXPS-RUNNING.git 
```
The most important sub-directories in the tree above are arch & src/MY_SRC:<br>
	- arch: put there the arch-X64_DATARMORMPI.fcm file which includes the required compilation options specific to Datarmor.<br>
```
cp MYDIR//RUNNING-CREG025.L75/arch-X64_DATARMORMPI.fcm $UDIR/CONFIG_CREG025.L75/CREG025.L75-NEMO420/arch/.
```
Then edit this file and set the variable %XIOS_HOME to the appropriate path for the XIOS library, either yours if you compiled it or leave the default one <br>  

	- src/MY_SRC: put there the specific modules that are modified against the NEMO reference code<br>
```
cd $UDIR/CONFIG_CREG025.L75/CREG025.L75-NEMO420/src/MY_SRC
cp MYDIR//RUNNING-CREG025.L75/MY_SRC/*90 .
```

Control that the following FORTRAN modules are present:<br>
```
ls *90
dtatsd.F90     istate.F90                lbc_lnk_pt2pt_generic.h90  sbcblk.F90   sbcssr.F90   zdftke.F90
iceistate.F90  lbc_lnk_call_generic.h90  mpp_nfd_generic.h90        sbcmod.F90   shapiro.F90
iceupdate.F90  lbclnk.F90                nemogcm.F90                sbc_oce.F90  tradmp.F90
```

Then last step before the compilation, copy the makefile & the CPP.keys files :<br>
```
cp MYDIR/RUNNING-CREG025.L75/makefile  $UDIR/CONFIG_CREG025.L75/CREG025.L75-NEMO420/.
cp MYDIR/RUNNING-CREG025.L75/CPP.keys  $UDIR/CONFIG_CREG025.L75/CREG025.L75-NEMO420/.
```
The makefile set all usefull information for the compilation while the CPP.keys file, set the cpp keys specific to this experiment.<br>

Edit the makefile and check that the CASE name corresponds to the current experiment name your are building, for instance if your build the CREG025.L75-MYEXP experiment, the variable CASE must be set to MYEXP.<br>

Now install the configuration, i.e. build the WORK folder which includes all good links to the NEMO code including the ones in the MY_SRC<br>
and launch the compilation itself:<br>
```
make install
```

The result should be  similar to this:<br>
```
CONFIGS/CONFIG_CREG025.L75/CREG025.L75-NEMO420
├── *.*0 -> ext/src/IOIPSL/*.*0
├── arch
├── arch-X64_DATARMORMPI.fcm -> arch/arch-X64_DATARMORMPI.fcm
├── B4_compilation.bash
├── cfgs
├── CPP.keys
├── DCM_4.0
├── dtatsd.F90 -> src/MY_SRC/dtatsd.F90
├── ext
├── iceistate.F90 -> src/MY_SRC/iceistate.F90
├── iceupdate.F90 -> src/MY_SRC/iceupdate.F90
├── install_history
├── istate.F90 -> src/MY_SRC/istate.F90
├── lbc_lnk_call_generic.h90 -> src/MY_SRC/lbc_lnk_call_generic.h90
├── lbclnk.F90 -> src/MY_SRC/lbclnk.F90
├── lbc_lnk_pt2pt_generic.h90 -> src/MY_SRC/lbc_lnk_pt2pt_generic.h90
├── makefile
├── mpp_nfd_generic.h90 -> src/MY_SRC/mpp_nfd_generic.h90
├── nemogcm.F90 -> src/MY_SRC/nemogcm.F90
├── sbcblk.F90 -> src/MY_SRC/sbcblk.F90
├── sbcmod.F90 -> src/MY_SRC/sbcmod.F90
├── sbc_oce.F90 -> src/MY_SRC/sbc_oce.F90
├── sbcssr.F90 -> src/MY_SRC/sbcssr.F90
├── shapiro.F90 -> src/MY_SRC/shapiro.F90
├── src
├── tradmp.F90 -> src/MY_SRC/tradmp.F90
├── WORK -> /home1/datawork/ctalandi/WCREG025.L75-NEMO420/cfgs/CREG025.L75-NEMO420/WORK
└── zdftke.F90 -> src/MY_SRC/zdftke.F90
```

Then launch the compilation itself:<br>
```
make
```
CAUTION: make sure that the following 3 modules are loaded before launching the compilation:<br>
- NETCDF-test/4.3.3.1-mpt217-intel2018<br>
- intel-fc-18/18.0.1.163<br>
- mpt/2.17<br>
if not, type > module load NETCDF-test/4.3.3.1-mpt217-intel2018 or better add it once for all in your .bashrc file<br>
NB: These librairies might be evolve depending the NEMO version used, you should adapt them to your own computing environment. <br>

At the end of the compilation, the NEMO executable should be stored in the EXE sub-directory as detailed below.<br>

Under the  PDIR  directory:<br>
```
RUNS/RUN_CREG025.L75/CREG025.L75-NEMO420
├── CTL
└── EXE
```

- EXE: location of the nemo4.exe  binary resulting from the compilation process<br>
- CTL: location where the user is going to launch numerical experiments<br>

To handle numerical experiments, few files, scripts have to be installed as it is detailed now<br>
The result should be something similar to this:<br>
```
cd $PDIR/RUN_CREG025.L75/CREG025.L75-NEMO420/CTL
cp -R MYDIR/RUNNING-CREG025.L75/RUNS/* .
```

The following files/folder should be copied :<br>
```
CREG025.L75-NEMO420_datarmor.sh  includefile.sh                namelist_ice.CREG025.L75-NEMO420  run_nemo.sh
CREG025.L75-NEMO420.db           namelist.CREG025.L75-NEMO420  namelist_ref                      XML
```

- XML: contains the XML files to manage outputs<br>
- namelist.CREG025.L75-NEMO420, namelist_ref & namelist_ice.CREG025.L75-NEMO420 are respectively the ocean & sea-ice model namelists<br>

Other files are detailed in the next section<br>

---
---

## 3- Launch a numerical experiment.<br>
No details are given about what/how to set physics/numerics in the NEMO namelists herefater, only how to perform a simulation.<br>

Move into the simulation manager folder:<br>
```
cd $PDIR/RUN_CREG025.L75/CREG025.L75-NEMO420/CTL
```

Only 2 files should be modified to perform a simulation:<br>
-  CREG025.L75-NEMO420.db<br>
The starting date of the simulation is set through the nn_date0 parameter in the ocean namelist, here 1979 January the 1st.<br>
The duration of 1 simulation is based on the total number of model iterations that is set in the CREG025.L75-NEMO420.db file<br>
For instance:<br>
```
cat CREG025.L75-NEMO420.db
```
gives the following result:<br>
```
1 1 3720
```
3 columns with following values from the left to the right :<br>
- 1 : the current stream number, 1 means the beginning of the simulation<br>
- 1: the first model iteration of stream #1<br>
- 3720: the total iteration number to perform relative to the model time step rn_Dt parameter set in the ocean namelist  which is 720s, this corresponds to 31 days (3720x720s/86400)<br>
At the end of the simulation, it should look like this:<br>
```
1 1    3720  19790131
2 3721 7440
```
The final date of the simulation is added at the end of the first line, here 1979 January 31st as expected.<br>
A second line is also added, it corresponds to the next stream (2nd stream) supposing the same length, i.e. 31 days.<br>
This length can be changed for each new stream.<br>

- includefile.sh<br>
		- file in which are set :<br>
				- paths where to find input files such as initial state, surface forcing, runoffs ..etc<br>
					- most "classical" input files set into the namelists will be copied into the running directory<br>
					- for new files, not expected from this NEMO release 4.2.0, new input files should be copied by hand.<br>
				- the effective running directory is set with the variable TMPDIR (to be eventually changed)<br>
		- Check also that the CTL_DIR variable points to your CTL directory where is located your include.sh<br>
		- adapt the following variable MAILTO<br>
		- the location of the XIOS binary is set with the P_XIOS_DIR variable. It is currently set to the version I have compiled.<br>
		- the MAXSUB variable at the end of this file set the maximal number automatic job re-submission, this is usefull when the length of one stream is always the same, for instance a one year-long simulation of 365 days.  This variable can be leaved to 1, in this case, no automatic job re-submission will occur, a new simulation has to be launched by hand.<br>

The job used to perform one simulation is CREG025.L75-NEMO420_datarmor.sh, there is a Datarmor header with also the total number of MPI cores to be used, nothing has to to changed in it.<br>

Launch a simulation<br>
```
./run_nemo.sh
```

To control the job status:<br>
```
qstat -u yourlogin
```

1 year-long  simulation requires ~4h45 elapsed time with a 5d mean output frequency.<br>

