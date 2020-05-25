//note lack of rounding when plotting complex numbers

class Epicycle{
  
  int n; // number of revolutions i.e. e^(it*n) 
  Complex pos; // position the next epicycle will rotate around or the point the last epicycle draws
  float angle; // angle made at position pos
  float dia; //diameter of the epicycle
  Complex center; // center of the circle
  Epicycle ep; 
  
  // Constructor for intial epicycle. The complex number start determines starting position on the circle e^(i*t).
  // rev is the number of revolutions in [0,2pi] 
  Epicycle(Complex start, Complex centerpt,int rev){
   angle = angle(start);
   center = centerpt;
   n = rev;
   dia = 2*sqrt(pow(start.re,2)+pow(start.im,2));
   pos = cAdd(center,start);   
   Complex num = new Complex(1,-1);
   print(angle(num));   
  }
  
  // Constructor for subsequent epicyces. Has its center at the position pos of the prev epicycle epic.
   Epicycle(Complex start, int rev, Epicycle epic){
   n = rev;
   ep = epic;
   center = epic.pos;
   angle = angle(start);
   dia = 2*sqrt(pow(start.re,2)+pow(start.im,2));
   pos = cAdd(center,start);
  }
  
  float angle(Complex z){
    if (z.re == 0){
      return PI/2;
    } else{
      float theta = atan(abs(z.im)/abs(z.re));
      if(z.re > 0 && z.im > 0){
        return theta;
      } else if (z.re < 0 && z.im > 0){
        return PI - theta;
      }
      else if (z.re<0 && z.im<0){
      return PI + theta;
      }
      else{
        return 2*PI - theta;
      }
    }
  }
  
  // draw the epicycle in draw()
  void display(){
   rectMode(CENTER);
   strokeWeight(3);
   
   pushMatrix();
   translate(center.re,center.im); // translates x,y coords below by center of epicycle
   noFill();
   stroke(0);
   ellipse(0,0,dia,dia);
      
   stroke(0);
   line(0,0, dia/2 * cos(angle), dia/2 * sin(angle)); // line connecting center to pos
   
   fill(255,0,0);
   noStroke();
   ellipse(dia/2 * cos(angle) , dia/2 * sin(angle),10,10);
   
   popMatrix();
  }
  
  // move the epicycle one time step for draw()
  void move(){
    angle = angle + n*0.05;
    float newposx = dia/2 * cos(angle);
    float newposy = dia/2 * sin(angle);
    if (ep==null){
      Complex newpos = new Complex(newposx,newposy);
      pos = cAdd(center,newpos);
    } else{
      center = ep.pos;
      Complex newpos = new Complex(newposx,newposy);
      pos = cAdd(center,newpos);
    }
  }
}
