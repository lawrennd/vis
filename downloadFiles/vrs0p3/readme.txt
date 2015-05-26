README file
-----------

VIS Code Version 0.3 Copyright 2002,2003 Neil D. Lawrence

Changes in version 0.3
----------------------

The code has undergone a major rewrite. 

1) Likelihoods are now computed in an m-file for each sub grid before grid positions are refined. As part of this it is now straightforward to change the likelihood model (log normal distributions have been provided as an alternative. The new files are modelDataHist.m modelDataLnNorm.m and the file that calls them is createGridModel.m

2) Code has been added to allow refinement of the grid position as well as the ovals.

3) When sampling ovals pixels in the eight neighbouring ovals are allocated strongly negative likelihoods of being foreground to prevent spot locations overlapping (this is done through the blockNeighbours.m code).

4) A but which meant that flags were being transposed before they were loaded was fixed.

Changes in version 0.2
----------------------

An extra experiment has been added - demoPaper3 for making a further comparison with the spot package.

There was a bug in saggridpoints.m which comes into effect if the row and column size differ this has now been fixed.

Licensing Information
---------------------

The program is free for academic use. Please contact me,
neil@dcs.sheffield.ac.uk, if you are interested in using the software for
commercial purposes.

The software must not be modified and distributed without prior
permission of the author. If you use the algorithm in your scientific
work, please cite as

Reducing the Variability in cDNA Microarray Images Processing by
Bayesian Inference by Neil D. Lawrence, Marta Milo, Mahesan Niranjan,
Penny Rashbass and Stephan Soullier, Bioinformatics. In Press.

Quick Start:
------------

1) Download all files and expand them into a single directory. 

2) Change to that directory in matlab. 

3) If you are not running under Windows or Solaris you may need to
   compile the C++ files. To do this you need to

   a) run mex -setup to setup a c++ compile if you have not done so
   previously.
   
   b) run mex -O fileName.cpp to compile each of the files.

   The file extractRatios.cpp uses the Standard Template Library which
   you may need to link to using the -l flag on some systems.

4) Run demoSample.m to see things working.

5) The examples from the paper may then be run using the commands
   demoPaper1.m and demoPaper2.m.

Download Files
--------------

The files that are available for download are:

mfiles.zip The matlab m files needed to run the software.
cppfiles.zip The source code for the mex files needed.
mexfiles.zip The compiled mex binaries for PCs and Solaris.
tiffiles.zip The tif images used as an example.
sagfiles.zip Various Scanalyze Grid format files used in the examples.
csvfiles.zip Some comma separated files of results.
datfiles.zip Some data files used in the examples.

Additionally you will require the file gsamp.m from the NETLAB toolbox
available from: http://www.ncrg.aston.ac.uk/netlab/down.html.

About the Code
--------------

The source code is mainly written in Matlab 6.5 with some parts
written in C++ to improve performance.

Pre-compiled mex binaries are supplied for PCs and Solaris.

The code has been tested under PCs and Solaris with Matlab 6.5.


Running own your own Slide
--------------------------

To run this code on a cDNA array you need to have 16 bit tiff files
representing the two channels of the microarray image, they should be
called yourNameA.tif for the red channel and yourNameB.tif for the
green channel.

Also a scanalyze grid file with the initial rough grid layouts is
required called yourName.sag.

Running the function processImage('yourName') will then save a new
file called sample_yourName.sag and yourName_data.csv. The columns of
this csv file are

gridNo, spotNo, log2Exp, log2Var, redSignalValue, redSignalVariance,
greenSignalValue, greenSignalVariance, effectNoSamples, flagValue

    gridNo --- The number of the grid as defined in the scanalyze grid
    file.

    spotNo --- The spot number, starts at 1 at the top left corner and
    moves right to increase by 1.

    log2Exp --- The expected value of the log 2 ratio. The log 2 ratio
    is as calculated in the Scanalyze manual.

    log2Var --- The variance of the log 2 ratio.

    redSignalValue --- The expected value of the red signal, which is
    the foreground reading minus the background reading for the red
    signal, as described in the Scanalyze manual.

    redSignalVariance --- The variance of the red signal.

    greenSignalValue --- The expected value of the green signal.

    greenSignalVariance --- The variance of the green signal

    effectNoSamples --- The effective number of samples associated
    with the posterior.

    flagValue --- is set to 2 if no spot was found and 3 if the
    effective number of samples was less than 1/4 of the total number
    of samples.


