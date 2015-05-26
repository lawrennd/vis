VIS software
Version 0.31		Monday 29 Oct 2007 at 00:18

Added "typename" into line 44 of extractRatios.cpp for compatability with latest gcc on linux. Note tested on Visual studio.

Added explicit casts in ovalll.cpp to remove warnings about conversions to int on lines 40 and 45.

To run this code on a cDNA array you need to have tif files representing the two channels of the microarray image, they should be called yourNameA.tif for the red channel and yourNameB.tif for the green channel. Also a scanalyze file with the initial rough grid layouts is required called yourName.sag. 

Running the function processImage('yourName') will then save a new file called sample_yourName.sag and yourName_data.csv. The columns of this file are 

log2Var , log2Exp, redChannelValue, redChannelVariance, greenChannelValue, greenChannelVariance, effectNoSamples, flagValue

MATLAB Files
------------

Matlab files associated with the toolbox are:

scanalyzelog2.m: Helper function to get log2 ratio from a scanalyze file
demPaper1.m: This script recreates the first Bioinformatics paper experiment.
blockNeighbours.m: Block out regions in the likelihood image.
modelDataHist.m: Model the foreground and background with a histogram.
indHistogll.m: Compute the log-likelihood of a histogram, assuming data is indpendently sampled.
extractRatios.m: Function for extracting log ratios associated with ovals.
ovalpak.m: Takes the parameters of a set of ovals and returns the ovals.
demPaper2.m: This script recreates a Bioinformatics paper experiment.
ovalVISampler.m: Use the variational importance sampler to refine the oval positions.
spotlog2.m: Helper function to get log2 ratio from a spot file.
ovalsample.m: Sample an oval.
viSampler.m: The variational imporatnce sampler.
saggridpoints.m: Extracts the centres of the ovals from scanalyze grids.
histogcreate.m: Creates a histogram between a specified range.
createGridModel.m: Obtain foreground and background likelihoods for pixels in the grid.
processImage.m: processes a cDNA microarray image.
modelDataLnNorm.m: Model the foreground and background with a log normal.
ovalLikelihood.m: Computes the likelihood of an oval given an integral image.
objectpak.m: Take an object's parameters and create objects from them.
microarrayOvals.m: Plot progress of oval sampling for demos.
saggriddraw.m: Draws a grid of the Scanalyze format.
prepareplot.m: Helper function for tidying up the plot before printing.
sagwrite.m: this function takes a grid from matlab and writes it to a scanalyze grid file.
visToolboxes.m: Toolboxes needed for running the VIS software.
sagread.m: This function loads a scanalyze SAG file into a structure in MATLAB.
ovalll.m: Evaluate the log likelihood of hypothesised ovals.
ratiocsvwrite.m: Takes a structure giving results and writes to a csv file.
saggrid2oval.m: Converts a saggrid into ovals.
demSample.m: This script visualises the algorithm as it runs.
ovalunpak.m: Take an array of ovals and convert into a matrix of their parameters.
ovalsubscript.m: Returns the subscripts of any pixels that would fall inside the oval
demPaper3.m: This script recreates a Bioinformatics paper experiment.
objectunpak.m: Take an object's parameters and create objects from them.
