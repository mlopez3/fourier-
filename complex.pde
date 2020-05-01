class Complex{
  
 float re;
 float im; 
 
Complex(float real, float imaginary){
  re = real;
  im = imaginary;
}

void display() {
  noStroke();
  fill(255,0,0);
  rectMode(CENTER);
  ellipse(round(re),round(im),5,5);
}


void cPrint(){
  println(re,im);
}

void scale(float r){
 re = re*r;
 im = im*r;
}

}
