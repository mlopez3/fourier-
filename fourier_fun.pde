
//------------------------------------
// Functions for complex arithmetic 
//------------------------------------


Complex cAdd(Complex z, Complex w){
  float real = z.re + w.re;
  float imaginary = z.im + w.im;
  Complex v = new Complex(real,imaginary);
  return v;
}

Complex cMult(Complex z, Complex w){
  float real = z.re * w.re - z.im * w.im;
  float imaginary = z.im * w.re + w.im * z.re;
  Complex v = new Complex(real,imaginary);
  return v;
}


//---------------------------------------------
//Complex valued function defintions
//---------------------------------------------


// Piecewise function defined for user generated points. 
Complex[] piecewiseF(int numpts,Complex[] points){
  int counter = 0;
  int len = points.length;
  int linepts = numpts/len;
  Complex[] func = new Complex[numpts];
  for(int i=0; i < len; i++){
    for(int j=0; j < linepts; j++){
      float t = map(j,0,linepts,0,1); //maps interal [0,linepts] -> [0,1]
      Complex a = new Complex(t,0);
      Complex b = new Complex(1-t,0);
      func[counter] = cAdd( cMult(points[i],b), cMult(points[(i+1) % len],a));
      counter++;
    }
  }
  for(int rest = counter; rest< numpts-1; rest++){
    func[rest] = func[counter-1];
  }
  func[numpts-1] = points[0];
  return func;
}


// Function for testing
Complex[] testFunc(int numpts){
  Complex[] func = new Complex[numpts];
  for(int i=0;i< numpts; i++){
   float t = map(i,0,numpts,0,2*PI);  
   Complex z = new Complex(t,0);
   func[i] = z;
  }
  return func;
}


// Complex Exponential
Complex[] expo(int n, int numpts){
 Complex expo[] = new Complex[numpts];
 for(int i=0;i< numpts; i++){
   float t = map(i,0,numpts,0,2*PI);  
   Complex z = new Complex (cos(n*t),sin(n*t));
   expo[i] = z;
 }
 return expo;
}


// Use to plot functions during draw()
void plotfunc(Complex[] func){
  pushMatrix();
  translate(0,0);
  for(int i=0; i < func.length - 1;i++){
    line(func[i].re,func[i].im,func[i+1].re,func[i+1].im);
  }
  popMatrix();
}


//-----------------------------
//Functions for approximation
//------------------------------


// Integral of a complex valued function func
Complex integrate(Complex[] func){
  Complex total = new Complex(0,0);
  Complex delta = new Complex(2*PI/func.length,0);
  for( int i=0; i < func.length; i++){
    total = cAdd(total,func[i]);
  }
  return  cMult(delta,total);
}


// The Inner Product
/* The inner product of two periodic functions func1 and func2 
is the integral of func1*func2 from 0 to 2pi. Note this doesn't 
conjugate the 2nd function like a Hermitian product on complex
valued functions. that's taken care of later */
Complex innerProd(Complex[] func1, Complex[] func2){
  int len = func1.length;
  Complex[] prod = new Complex[len];
  for(int i=0; i<len;i++){
    prod[i] = cMult(func1[i],func2[i]);
  }
  Complex total = integrate(prod);
  return total;
}



// Approximate the input function func by computing
// its inner product with the congujate of the ith exponential.
// epinum represnts the number of exponentials one wants to 
// approximate with (including negatives).
// Returns coefficients c_n for c_n*e^(int) in Fourier series.
Complex[] approx(int epinum, Complex[] func, int numpts){
  Complex[] coefs = new Complex[2*epinum+1]; 
  Complex normFac = new Complex(1.0/(2*PI),0);
  coefs[0] = cMult(integrate(func),normFac); // 0th coef is the center of the first epicycle
  for(int i=1; i <= epinum; i++){
    coefs[2*i-1] = cMult( normFac, innerProd(func,expo(-i,numpts)) );  // conjugate the ith exponential 
    coefs[2*i] = cMult( normFac, innerProd(func,expo(i,numpts)) );
  }
  return coefs;
}


//-----------------------------
// Epicycle Functions
//-----------------------------


// creates array of epicycles given their precomputed coefficients c_n and number of desired cycles.
Epicycle[] createEpi(int epinum, Complex[] coefs){
  Epicycle[] eplst = new Epicycle[2*epinum];
  Complex center = coefs[0];
  eplst[0] = new Epicycle(coefs[1],center,1);
  eplst[1] = new Epicycle(coefs[2],-1,eplst[0]);
  
  for(int i=1; i < epinum; i++){
    eplst[2*i] = new Epicycle(coefs[2*i+1], i+1, eplst[2*i-1]);
    eplst[2*i+1] = new Epicycle(coefs[2*i+2],-(i+1),eplst[2*i]);
  } 
  return eplst;
}


//-------------------------
// Program Start
//-------------------------


// Gobal Variables
int epinum = 50;  // Number of cycles desired.
Epicycle[] epilst; // List containing each epicycle.
int numpts = 2000; // Number of output points for each function. Increase for higher precision.
Complex[] userpts; 
Complex[] userfunc;
Complex[] coefs;  
Complex[] curve;
boolean closecurve = false; // Variable used determine if the user is finished inputting points


// Code in setup is ran once before draw()
void setup() {
  size(1000,800);  // screen size in pixels
  epilst = new Epicycle[2*epinum]; 
  userpts = new Complex[0];
  curve = new Complex[0];
}

// theis function loops automatically to draw animated output.
void draw(){
  frameRate(20); //fps
  background(255,255,255);  
  
  
  //Interactivity: Gather points from user
  if (mousePressed){
    Complex z = new Complex(mouseX,mouseY);
    userpts = (Complex[])append(userpts,z); 
    delay(300); // 300 millisec delay until user can enter next point     
  }
  
  // Draw user curve by connecting points 
  for(int i=0; i < userpts.length -1; i++){
    line(userpts[i].re,userpts[i].im,userpts[i+1].re,userpts[i+1].im);
    ellipse(round(userpts[i].re),round(userpts[i].im),5,5);
    ellipse(round(userpts[i+1].re),round(userpts[i+1].im),5,5);
  }
  
  // When Enter is pressed the curve will close to the sarting point
  if(closecurve){ 
    line(userpts[userpts.length-1].re, userpts[userpts.length-1].im, userpts[0].re, userpts[0].im);
    stroke(0,0,200);
    plotfunc(userfunc); // plot the user function in blue
  }
  
  //Epicycles generated to approximate curve when Enter is pressed
   if(closecurve){
    for(int i =0; i < 2*epinum; i++){
      epilst[i].display();
      epilst[i].move();
    }
    curve = (Complex[])append(curve,epilst[epilst.length-1].pos); // curve produced by the last epicycle in green
    if (curve.length > 2){
      stroke(0,200,0);
      plotfunc(curve);
    }
  }
  
  
  // saveFrame("output/gif-"+nf(counter,4)+".png");
    
}
  // Event function for when Enter is pressed. Closes the users curve and starts epicycle approximation.
  void keyPressed(){
    if( (key==ENTER) || (key==RETURN)){
      closecurve = true;
      for(int i=0; i < userpts.length;i++){ // print user points for testing
        userpts[i].cPrint();
      }
      println("-------------");
      
      userfunc = piecewiseF(numpts,userpts);

      for(int i=0; i < numpts;i++){
        userfunc[i].cPrint();
      }

      coefs = approx(epinum,userfunc,numpts); //compute coefficients c_n
      epilst = createEpi(epinum,coefs);

    }
    
}
