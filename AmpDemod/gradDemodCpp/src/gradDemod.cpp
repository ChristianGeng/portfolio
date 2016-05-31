/*
 * function [scincos,osc]=gradDempdCpp(CarrierFreqs,fs,data,mue);
 * Stochastisches Gradientenverfahren zur Demodulation
 * In contrast to the implementations by Herr Evert,
 * this version returns the data in a different shape
 * - the two outputs arguments (sincos / osc)  are  formatted as complex arrays
 * - The number of frequences (currently 9) is represented in the number of rows,
 * 	 the data samples are represented in columns
 *
 *
 * Input Args:
 *
 * CarrierFreqs:   [f1 f2 f3 ...], Frequenzen der einzelen Sinussignale
 * fs:  Samplingfrequenz
 * mue: Schrittweitenparameter (mue!<2/length(f))
 * d:   Eingangssignal
 *
 *
 * Output Args:
 *
 * wc,ws: Koeffizienten as the first output, A=sqrt(wc.^2+ws.^2), phi=atan2(wc,ws), and
 * oscCos, oscSin: the oscillators as the second output.
 * As mentioned, both are complex matrices
 *
 *  Usage Examples:
 *  [sincos, osc]=gradDemodCpp(CarrierAG900,fs,dataUse(1:nSampsUse,myChan),[0.01]);
 *  [sincos]=gradDemodCpp(CarrierAG900,fs,dataUse(1:nSampsUse,myChan),[0.01]);
 *
 *  TODO: If only one output is specified, the memory used for the sinusoids is
 *  cleaned up by the Matlatb Garbage Collector. As far as I can tell this should only be a question of
 *  performance
 *
 * $CGeng 31/07/2012$
 *
 * */

#include "mex.h"
#include "math.h"
#include "mex.h"
#include <string.h>
#define _USE_MATH_DEFINES

int max_array(int a[], int num_elements);
void recosc(double * CarFreq, double * fs, double * mue, double  * rawData, int nF, int nSamps, double *xc, double *xs);
void doGradDemod(double * CarFreq, double * fs, double * rawData, double * mue, int nF, int nSamps, double *xc, double *xs, double *campCos, double *campSin);


void mexFunction(
		int nlhs, mxArray *plhs[],
		int nrhs, const mxArray *prhs[]) {
	int i;

	//mexPrintf("\nThere are %d right-hand-side argument(s).", nrhs);
	for (i=0; i<nrhs; i++)  {
		//mexPrintf("\n\tInput Arg %i is of type:\t%s ",i,mxGetClassName(prhs[i]));
	}


	if( (nrhs != 4) ){
		mexErrMsgTxt("Wrong number of input arguments\nRequired: Arguments:4");
	}

	else if (nlhs >  2) {
		mexErrMsgTxt("Wrong number of output arguments: Only 1 or 2 arguments allowed");
	}

	// Parste Input: CARRIER
	int mrowsCarrier=mxGetM(prhs[0]);
	int ncolsCarrier = mxGetN(prhs[0]);

	if (mrowsCarrier>1 && ncolsCarrier>1) {
		mexErrMsgTxt("Expecting a 1-D vector for arg 1, (carrier Freqs)");
	}
	//mexPrintf("\n Carriers: \n");
	//mexCallMATLAB(0, NULL, 1, &carrierFreqs, "disp");
	int tmp[2] = {mrowsCarrier, ncolsCarrier};
	int nFreqs=max_array(tmp, 2);

	/* Parse Input: FS: */
	if (mxGetM(prhs[1])>1 || mxGetN(prhs[1])>1 ) {
		mexErrMsgTxt("Expecting scalar input for arg 1, (fs)");
	}

	/* Parse Input: MUE: */

	if (mxGetM(prhs[3])>1 || mxGetN(prhs[3])>1 ) {
		mexErrMsgTxt("Expecting scalar input for arg 4, (mue)");
	}

	/* Parse Input: DATA: */
	int mrowsData = mxGetM(prhs[2]);
	int ncolsData = mxGetN(prhs[2]);
	int lenV[2] = {mrowsData, ncolsData};
	int nSamps=max_array(lenV, 2);

	if (mrowsData>1 && ncolsData>1) {
		mexErrMsgTxt("Expecting a 1-D vector for arg 3, (input data)");
	}

	/* Create dummy matrices for the return arguments. */
	plhs[0] = mxCreateDoubleMatrix( (int) nFreqs, (int) nSamps , mxCOMPLEX);
	plhs[1] = mxCreateDoubleMatrix( (int) nFreqs, (int) nSamps , mxCOMPLEX);

	double * campCos = mxGetPr(plhs[0]);
	double * campSin = mxGetPi(plhs[0]);

	double * wcos = mxGetPr(plhs[1]);
	double * wsin = mxGetPi(plhs[1]);

	// mxArray *wcos;
	//wcos = mxCreateDoubleMatrix((int) nFreqs, (int) nSamps, mxREAL);
	//mxSetData(wcos, mxMalloc(sizeof(double)*nFreqs*nSamps)); /* Allocate memory for the array

	//mxArray *wsin;
	//wsin = mxCreateDoubleMatrix((int) nFreqs, (int) nSamps, mxREAL);
	//mxSetData(wsin, mxMalloc(sizeof(double)*nFreqs*nSamps)); /* Allocate memory for the array */

	//double_t *wcos;
	//double_t *wsin;
	//wcos = mxCalloc(nFreqs *nSamps, double_t);

	//SAMPLE **a;
	//a = (SAMPLE **) mxCalloc(xDim, sizeof(SAMPLE *)); // Use mxCalloc instead of calloc
	// a = (SAMPLE **) mxCalloc(xDim, sizeof(SAMPLE *)); /
	//mxFree

	recosc(mxGetPr(prhs[0]), mxGetPr(prhs[1]), mxGetPr(prhs[2]), mxGetPr(prhs[3]), nFreqs, nSamps,wcos,wsin);
	doGradDemod(mxGetPr(prhs[0]), mxGetPr(prhs[1]), mxGetPr(prhs[2]), mxGetPr(prhs[3]), nFreqs, nSamps,wcos,wsin,campCos,campSin);

	//mxFree(wcos);
	/* double 	 *img, *out_h, *out_v;
	plhs[0] = mxCreateDoubleMatrix(cols, rows, mxREAL);
	out_v =  mxGetPr(plhs[1]);
	sobel ...
	 */

	return;
}



void doGradDemod(double * CarFreq, double * fs, double * rawData, double * mue, int nF, int nSamps, double *xc, double *xs, double *campCos, double *campSin){
	// xc,xs: Referenz-cosinus und -sinus

	double y, e;
	int idx; int idy;

    
    /*
     *Das folgende geht unter MSVCC nicht: Dort kann ein Array keine variable Groesse haben. 
     * Alternative aus der standard library: 
     *#include <vector>
     *std::vector<int> v;    // declares a vector of integers
     *oder: using namespace std;
     *vector<int> v;         // no need to prepend std:: any more
     */
	double w[2][nF]; //w=zeros(2,fnum); statische Arrays sollten als Null initialisiert sein!
	memset(w, 0, 2*nF*sizeof(double));

	int tgi;
	double tmp=0;


	for(idx = 0; idx<nSamps; ++idx){ // idx: Samples
		y=0.0;
		for (idy = 0; idy < nF; ++idy) { // idy: Freqs
			tgi=idy+(nF*idx);
			tmp = w[0][idy]*xc[tgi] + w[1][idy]*xs[tgi];
			y+=tmp;
		}

		e=rawData[idx]-y; // Fehlerberechnung

		for(idy = 0; idy < nF; ++idy){
			tgi=idy+(nF*idx);

			w[0][idy] = w[0][idy] + xc[tgi] * mue[0] * e;
			w[1][idy] = w[1][idy] + xs[tgi] * mue[0] * e;

			campCos[tgi]=w[0][idy];
			campSin[tgi]=w[1][idy];
		}
	}
}


void recosc(double * CarFreq, double * fs, double * mue, double  * rawData, int nF, int nSamps, double *xc, double *xs){
	// xc,xs: Referenz-cosinus und -sinus

	int A=1; // Amplituden
	int y,x;
	double tmpCos,tmpSin;

	//mexPrintf("MAT SIZE: %i/%i\n",(int)nF,(int)nSamps);
	int runIdx=0;

	double w0[nF]; double cw0[nF]; double cw02[nF]; double sw0[nF]; double qneu[nF];
	double q[2][nF];

	for (y=0; y<nF; ++y){
		w0[y]= ( 2 * M_PI * CarFreq[y] ) / fs[0];
		cw0[y]=cos(w0[y]);
		cw02[y]= 2.0 * cw0[y];
		sw0[y]=sin(w0[y]);
		q[0][y]=A;
		q[1][y]=0;
	}

	for(x = 1; x<=nSamps; ++x){
		for (y = 1; y<=nF; ++y){
			tmpCos = q[0][y-1] - ( cw0[y-1] *  q[1][y-1] );
			tmpSin = -sw0[y-1] * q[1][y-1]; // Vorzeichenwechsel im Vergleich zu der Originalversion
			// das erlaubt, die Ergebnisse als komplexe Matrix nach
			// Matlab zu exportieren, CG.
			xc[runIdx]=tmpCos;
			xs[runIdx]=tmpSin;

			runIdx=runIdx+1;
			qneu[y-1] = ( cw02[y-1] * q[0][y-1] ) - q[1][y-1];
			q[1][y-1]=q[0][y-1];
			q[0][y-1]=qneu[y-1];
		}
	}
}

int max_array(int a[], int num_elements) {
	int i, max=-32000;
	for (i=0; i<num_elements; i++) {
		if (a[i]>max) {
			max=a[i];
		}
	}
	return(max);
}
