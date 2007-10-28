Added "typename" into line 44 of extractRatios.cpp for compatability with latest gcc on linux. Note tested on Visual studio.

Added explicit casts in ovalll.cpp to remove warnings about conversions to int on lines 40 and 45.

To run this code on a cDNA array you need to have tif files representing the two channels of the microarray image, they should be called yourNameA.tif for the red channel and yourNameB.tif for the green channel. Also a scanalyze file with the initial rough grid layouts is required called yourName.sag. 

Running the function processImage('yourName') will then save a new file called sample_yourName.sag and yourName_data.csv. The columns of this file are 

log2Var , log2Exp, redChannelValue, redChannelVariance, greenChannelValue, greenChannelVariance, effectNoSamples, flagValue