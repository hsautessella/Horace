# Building with CMake

CMake provides a way to generate build files across multiple platforms. It also
ships with a script to aid in compiling Matlab mex libraries.

1) After cloning the Horace repository, open the CMake GUI and select the root
of the repository as the source.
2) Select `<Horace Root>/DLL/` as the binary directory.
3) Click configure. When the dialogue appears select your desired generator.
You should pick a compiler that is compatible with your Matlab version, e.g.
MatlabR2017B is not compatible with Visual Studio 2019, so choose Visual Studio 2017.
4) Make sure to also select your platform/architecture, this should also match
your Matlab version: if you installed a 64-bit version of Matlab choose x64 as
the platform.
5) Now click finish in the dialogue. CMake will find the Matlab compiler and
various libraries.
6) Now click generate. The build files should be generated inside the DLL
directory. On Windows you can open the `<Horace Root>/DLL/Horace.sln` file in
Visual Studio and build the targets. On linux you can `cd` into the
`<Horace Root>/DLL/` directory and run `make` depending on the generator you
selected.

To do steps 3-6 using the command line you can use the following commands (for
linux use `-G "Unix Makefiles"`):

`$ cmake -S <Horace Root> -B <Horace Root>/DLL -G "Visual Studio 15 2017 Win64"`

`$ cmake --build <Horace Root>/DLL`

7) The mex files will be written within `<Horace Root>/DLL/bin/`, which is
added to the Matlab path by the Horace init script.

There's a known issue with running the compiled mex with newer versions of
Matlab, if they were compiled using an older version of CMake. If you get an
error like `Invalid MEX-file: Gateway function is missing`, try updating your
CMake. CMake v3.14 has been confirmed to work for Matlab R2019b.