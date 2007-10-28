/* version 0.3 Copyright (c) Neil Lawrence 2002,2003 Moved likelihood calculation into matlab code.*/

#include "mex.h"
#include <cmath>
//#include <cassert>

void ovalll(double* logLikelihoods,
            const int numOvals,
            const double centre[],
            const double xradius[],
            const double yradius[],
            const double backgroundLl[],
            const double foregroundLl[],
            const double minRow,
            const double minCol,
            const int imageRows,
            const int imageCols)
{
  // Box location should be laid out as top left point, bottom right
  int x; // the x position in the whole image
  int gridX; // the x position in the grid we are in (first column is 0)
  int y; // the y position in the whole image
  int gridY; // the y position in the grid we are in (first row is 0)
  int boxLeftMost, boxTopMost, boxRightMost, boxBottomMost, boxNumRows, boxNumCols;
  for(int ovalNo = 0; ovalNo < numOvals; ovalNo++) {
    boxLeftMost = (int)floor(centre[ovalNo]-xradius[ovalNo]);
    boxTopMost = (int)floor(centre[ovalNo+numOvals]-yradius[ovalNo]);
    boxRightMost = (int)ceil(centre[ovalNo]+xradius[ovalNo]);
    boxBottomMost = (int)ceil(centre[ovalNo+numOvals]+yradius[ovalNo]);
    boxNumRows = boxBottomMost - boxTopMost + 1;
    boxNumCols = boxRightMost - boxLeftMost + 1;

    // get the pixels associated with the oval
    logLikelihoods[ovalNo] = 0;
    double xRadius2 = xradius[ovalNo]*xradius[ovalNo];
    double yRadius2 = yradius[ovalNo]*yradius[ovalNo];
    int index;
    for(int j = 0; j < boxNumCols; j++) {
      x = j + boxLeftMost;
      gridX = (int)(x - minCol);
      double xPos = (double)x - centre[ovalNo];
      double xPart = (xPos*xPos)/xRadius2;
      for(int i = 0; i < boxNumRows; i++) {
        y = i + boxTopMost;
        gridY = (int)(y - minRow);
        if(xPart <= 1) { 
          double yPos = (double)y - centre[ovalNo + numOvals];
          double yPart = (yPos*yPos)/yRadius2;
          // check if it is in oval or not and add to log likelihood.
          // no point in further checks if xPart > 1
          if(xPart + yPart <= 1) {
            index = gridY + imageRows*(gridX);
            logLikelihoods[ovalNo] += foregroundLl[index] - backgroundLl[index];
          }
        }
      }
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
  double* yradiusPr;
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
  
  // ovals - struct, the structure containing the ovals
  if(mxGetClassID(prhs[1]) != mxSTRUCT_CLASS)
    mexErrMsgTxt("Error imageLikelihood should be STRUCT");  
  double* pMinCol = mxGetPr(mxGetField(prhs[1], 0, "minCol"));
  double* pMinRow = mxGetPr(mxGetField(prhs[1], 0, "minRow"));
  double minCol = *pMinCol;
  double minRow = *pMinRow;

  double* backgroundLl = mxGetPr(mxGetField(prhs[1], 0, "gridBackLl"));
  double* foregroundLl = mxGetPr(mxGetField(prhs[1], 0, "gridForeLl"));

  const int* imageDims = mxGetDimensions(mxGetField(prhs[1], 0, "gridBackLl"));
  const int* checkDims = mxGetDimensions(mxGetField(prhs[1], 0, "gridForeLl"));

  int imageRows = imageDims[0];
  int imageCols = imageDims[1];

  if(imageRows != checkDims[0])
    mexErrMsgTxt("Error row dimensions do not match between fore/background log-likelihood maps");
  if(imageCols != checkDims[1])
    mexErrMsgTxt("Error column dimensions do not match between fore/background log-likelihood maps");


  int dims[2];
  dims[0] = numOvals;
  dims[1] = 1;
  plhs[0] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
  double* logLikelihoods = mxGetPr(plhs[0]);
  
  
  //mexPrintf("There are %d ovals.\n", numOvals);
  ovalll(logLikelihoods, numOvals, 
         centre, xradius, yradius, 
         backgroundLl, foregroundLl, minRow, minCol,
         imageRows, imageCols);
  mxFree(centre);
  mxFree(xradius);
  mxFree(yradius);

}
