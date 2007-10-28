/* version 0.1 Copyright (c) Neil Lawrence 2002 

to compile under solaris with g++ use mex -O -lstdc++ extractRatios.cpp
*/

#include "mex.h"
#include <cmath>
#include <vector>
#include <algorithm>
//#include <cassert>
using namespace std;

const double MAX_INTENSITY = 65535.0;
const double EPS = 1e-16;

double log2(double x)
{
  return log(x)/log(2.0);
}
template <class T>
T vectorMedian(vector<T> dataVector) 
{
  sort(dataVector.begin(), dataVector.end());
  int vectorSize = dataVector.size();
  
  if (vectorSize == 1)
    return dataVector[0];
  else
    
    if((double)vectorSize/2 == (double)(vectorSize/2))
      // even size
      return dataVector[vectorSize/2 - 1];
    else
      // odd size
      return (dataVector[(vectorSize+1)/2 - 1]
        + dataVector[(vectorSize-1)/2 - 1])/2;
}

template <class T>
T vectorSum(vector<T> dataVector) 
{
  int vectorSize = dataVector.size();
  T vectorTotal = dataVector[0];
  for(typename std::vector<T>::iterator i = dataVector.begin(); i != dataVector.end(); i++)
    vectorTotal += *i;
  return vectorTotal;
}
template <class T>
T vectorMean(vector<T> dataVector) 
{
  int vectorSize = dataVector.size();
  T meanVal = vectorSum(dataVector)/vectorSize;
  return meanVal;
}

void ovalratio(double* ratios,
               double* log2Ratios,
               double* greenValues,
               double* redValues,
               double* greenBackground,
               double* redBackground, 
               const int numOvals,
               const double centre[],
               const double xradius[],
               const double yradius[],
               const unsigned short imageData[],
               const int imageRows,
               const int imageCols,
               const int imageChannels)
{
  for(int ovalNo = 0; ovalNo < numOvals; ovalNo++) {
    double lowerLimitX = centre[ovalNo] - xradius[ovalNo] - 1;
    double upperLimitX = centre[ovalNo] + xradius[ovalNo] + 1;
    double lowerLimitY = centre[ovalNo + numOvals] - yradius[ovalNo] - 1;
    double upperLimitY = centre[ovalNo + numOvals] + yradius[ovalNo] + 1;
    // Create a vector container for ease of sorting.
    vector<unsigned int> redVector;
    vector<unsigned int> greenVector;
    vector<unsigned int> redBackgroundVector;
    vector<unsigned int> greenBackgroundVector;
    // get the pixels associated with the oval
    double xRadius2 = xradius[ovalNo]*xradius[ovalNo];
    double yRadius2 = yradius[ovalNo]*yradius[ovalNo];
    
    for(int x = (int)floor(lowerLimitX); x < (int)ceil(upperLimitX)+1; x++) {
      double xPos = (double)x - centre[ovalNo];
      double xPart = (xPos*xPos)/xRadius2;
        for(int y = (int)floor(lowerLimitY); y < (int)ceil(upperLimitY)+1; y++) {
          if(xPart <= 1) { 
            double yPos = (double)y - centre[ovalNo + numOvals];
            double yPart = (yPos*yPos)/yRadius2;
            // check if it is in oval or not and pixel values to the store
            if(xPart + yPart <= 1){
              redVector.push_back(imageData[y-1 + imageRows*(x-1)]);
              greenVector.push_back(imageData[y-1 + imageRows*(x-1) + imageCols*imageRows]); 
            }
            else {
              redBackgroundVector.push_back(imageData[y-1 + imageRows*(x-1)]);
              greenBackgroundVector.push_back(imageData[y-1 + imageRows*(x-1) + imageCols*imageRows]); 
            }
          }
          else {
            redBackgroundVector.push_back(imageData[y-1 + imageRows*(x-1)]);
            greenBackgroundVector.push_back(imageData[y-1 + imageRows*(x-1) + imageCols*imageRows]); 
          }
        } 
    }
   
    /*vector<double> ratioVector;
    // NOW COMPUTE RATIO VALUES
    for(int i = 0; i < redVector.size(); i++) {
      unsigned int green = (greenVector[i] - greenB);
      unsigned int red = (redVector[i] - redB);
      if (green < 1)
        green = 1;
      if (red < 1)
        red = 1;
      ratioVector.push_back(red/green);
    }
    ratios[ovalNo] = vectorMedian(ratioVector);*/

    unsigned int redB = vectorMedian(redBackgroundVector);
    unsigned int greenB = vectorMedian(greenBackgroundVector);
    // Calculate only calculate if there are pixels in the circle and pixels in the 
    // box but outside the circle. Vs 0.3 Bug fix before if the circle was bigger than the box, an error wasn't generated.
    if(!greenVector.empty()) {
      double green = (double)vectorMean(greenVector) - greenB;
      double red = (double)vectorMean(redVector) - redB;
      if (green < 1)
        green = 1;
      if (red < 1)
        red = 1;
      ratios[ovalNo] = red/green;
      greenValues[ovalNo] = green;
      redValues[ovalNo] = red;
      greenBackground[ovalNo] = greenB;
      redBackground[ovalNo] = redB;
      log2Ratios[ovalNo] = log2(red) - log2(green);
    }
    else{
      greenValues[ovalNo] = -9e99;
      redValues[ovalNo] = -9e99;
      greenBackground[ovalNo] = -9e99;
      redBackground[ovalNo] = -9e99;
      ratios[ovalNo] = -9e99;
      log2Ratios[ovalNo] = -9e99;
    }
  }
}


void mexFunction(
                 int nlhs,       mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

  
  // ovals - struct, the structure containing the ovals
  if(mxGetClassID(prhs[0]) != mxSTRUCT_CLASS)
    mexErrMsgTxt("Error ovals should be STRUCT");  
  const int* ovalDims = mxGetDimensions(prhs[0]);
//  const mxArray ovalsType = mxGetField(prhs[0], 0, "type");
  const int numOvals = mxGetNumberOfElements(prhs[0]);
  double* centre = (double*)mxMalloc(2*numOvals*sizeof(double));
  double* xradius = (double*)mxMalloc(numOvals*sizeof(double));
  double* yradius = (double*)mxMalloc(numOvals*sizeof(double));
  double* centrePr;
  double* xradiusPr;
  double *yradiusPr;
  double* temp;
  for(int i = 0; i < numOvals; i++) {
    centrePr = mxGetPr(mxGetField(prhs[0], i, "centre"));
    xradiusPr = mxGetPr(mxGetField(prhs[0], i, "xradius"));
    yradiusPr = mxGetPr(mxGetField(prhs[0], i, "yradius"));
    
    xradius[i] = *xradiusPr;
    yradius[i] = *yradiusPr;

    for(int j = 0; j < 2; j++) 
      centre[i + j*numOvals] = centrePr[j];
  }  
  // imageData is assumed to be uint16
  if(mxGetClassID(prhs[1]) != mxUINT16_CLASS)
    mexErrMsgTxt("Error Image Data should be UINT16");  
  unsigned short *imageData = (unsigned short *)mxGetData(prhs[1]);
  const int *imageDims;
  imageDims = mxGetDimensions(prhs[1]);
  int imageRows = imageDims[0];
  int imageCols = imageDims[1];
  int imageChannels = imageDims[2];

  


  // Return value will be the ratios each oval
  int dims[2];
  dims[0] = numOvals;
  dims[1] = 1;
  plhs[0] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
  double* ratios = mxGetPr(plhs[0]);
  plhs[1] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
  double* log2Ratios = mxGetPr(plhs[1]);
  plhs[2] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
  double* redValues = mxGetPr(plhs[2]);
  plhs[3] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
  double* greenValues = mxGetPr(plhs[3]);
  plhs[4] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
  double* redBackground = mxGetPr(plhs[4]);
  plhs[5] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
  double* greenBackground = mxGetPr(plhs[5]);
  
  
  //mexPrintf("There are %d ovals.\n", numOvals);
  ovalratio(ratios, log2Ratios, greenValues, redValues, greenBackground, redBackground, numOvals, centre, xradius, yradius, imageData, imageRows, imageCols, imageChannels);
  mxFree(centre);
  mxFree(xradius);
  mxFree(yradius);

}









