class Starr{
  
  int x; 
  int y; 
  int alpha = 0;
  int timer = (int) random (50, 100); //duration of max alpha (how long star stays)
  
    Starr(int x, int y){
      this.x=x;
      this.y=y;
    }
    
  void drawMe(){
    if (alpha < 255)
      alpha+=10; //rate of generation
    else
      timer--;
      
    if (timer <0)
      alpha -=15; //rate of destruction
      
    pushMatrix();
    translate(x,y);
    stroke (255,alpha);
    strokeWeight(3);
    point(0,0); 
    popMatrix();
    
    if (alpha <0);
      
  }
}
