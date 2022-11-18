import processing.sound.*; //<>//
import gifAnimation.*;

//press spacebar to play for now//

//main states
int currentState, state0=0, state1=1, state2=2;
//starting fade in animation
int startFade;

//sounds
SoundFile ship, comms, beep, hum, blast;

//graphics
PImage frame0,frame1,frame2,frame3,bgImg;
int frameWidth,frameHeight,centerX,centerY;
Gif grain,pole,poleOn;

PFont font;

//pole animations and positions
boolean descending,poleHit;
int fade, poleStartFade;
boolean [] poleDescenders, poleHits;
int [] poleFades, poleAngles;
int [][] polePositions = {{-150,0},{+150,0},{0,-150}};

int score;

void setup(){
  fullScreen();
  background(0);
  
  currentState=0;
  
  startFade=0;
  
  ship = new SoundFile(this, "assets/interior.mp3");
  comms = new SoundFile(this, "assets/comms.mp3");
  beep = new SoundFile(this, "assets/beep.wav");
  hum = new SoundFile(this, "assets/humOn.mp3");
  blast = new SoundFile(this, "assets/blaster.mp3");
  comms.amp(0.2);
  ship.amp(0.6);
  comms.loop();
  ship.loop();
  
  bgImg = loadImage("assets/background.png");
  frame0 = loadImage("assets/frame0.png");
  frame1 = loadImage("assets/frame1.png");
  frame2 = loadImage("assets/frame2.png");
  frame3 = loadImage("assets/frame3.png");
  grain = new Gif(this, "assets/grain.gif");
  pole = new Gif(this, "assets/poleOff.gif");
  poleOn = new Gif(this, "assets/poleOn.gif");
  
  grain.play();
  pole.play();
  poleOn.play();
  
  frameWidth=880;
  frameHeight=687;
  
  font = createFont("assets/SceletAF.otf", 32);
  textFont(font);
  
  score=0;
  
  descending=false;
  poleHit=false;
  fade=0;
  poleStartFade=0;
  poleDescenders = new boolean[3];
  poleHits = new boolean[3];
  poleFades = new int[3];
  poleAngles = new int[3];
  
  for (int i = 0;i<3;i++){
    poleHits[i]=false;
    poleDescenders[i]=false;
    poleFades[i]=0;
    poleAngles[i]=0;
  }
  
  smooth(4);
}

void draw(){
  drawBackground();
  drawScreenBottom();
  tint(255,startFade);
  drawPoles(currentState);
  poleHitEvent();
  drawScore(startFade,currentState);
  tint(255,255);
  drawScreenTop();
  
  handleStates();
}

//controls, this function can be changed into a function that listens for signals from the arduino serial connection, just change the name and keep it in the draw function
//because it wont be callback anymore
void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      if (poleHits[0]==false){
        poleHits[0]=true;
      }
      blast.play();
    } 
    else if (keyCode == RIGHT) {
      if (poleHits[1]==false){
        poleHits[1]=true;
      }
      blast.play();
    }
    else if (keyCode == UP) {
      if (poleHits[2]==false){
        poleHits[2]=true;
      }
      blast.play();
    }
  }
  //spacebar to play for now
  else if (keyCode == ' '){
    currentState=state1;
    beep.play();
    hum.play();
  }
}

//All the ui code
void handleStates(){
  if (currentState==0){
    if (startFade<=255){
      startFade+=17;
    }
  }
  else if (currentState==1){
    if (poleStartFade<=255){
      poleStartFade+=5;
    }
  }
}

String formatScore(int inScore){
  String outScore = str(inScore);
  while (outScore.length()<=4){
    outScore="0"+outScore;
  }
  return outScore;
}

void drawScore(int inFade, int inState){
  pushMatrix();
  
  textFont(font, 60);
  textAlign(CENTER);
  
  if (inState==0){
    fill(226,206,153,inFade);
    text("Play game", displayWidth/2 , displayHeight/2 + 230); 
  }
  else if (inState==1){
    fill(222,49,33,inFade);
    text(formatScore(score), displayWidth/2 , displayHeight/2 + 230); 
  }
  noFill();
  stroke(226,206,153,inFade);
  strokeWeight(4);
  rect(displayWidth/2-225,displayHeight/2 + 160,450,90,25);
  popMatrix();
}

void drawPoles(int inState){  
  if (inState==1){
    pushMatrix();
    tint(255,poleStartFade);
    for (int i=0;i<3;i++){
      rotate(poleAngles[i]);
      image(pole, displayWidth/2 - 146/2 + polePositions[i][0], displayHeight/2 - 179/2 + polePositions[i][1]);
      rotate(-poleAngles[i]);
      //red pole flashes
      if (poleHits[i] == true){
        tint(255,poleFades[i]);
        image(poleOn, displayWidth/2 - 146/2 + polePositions[i][0], displayHeight/2 - 179/2 + polePositions[i][1]);
        tint(255,255);
      }
    }
    tint(255,255);
    popMatrix();
  }
}

//listens for when pole is hit and animates its flash
void poleHitEvent(){
  for (int i=0; i<3;i++){
    if (poleHits[i] == true){
      poleAngles[i]=wobble(poleAngles[i]+1);
      if (poleDescenders[i]==false){
        if (poleFades[i]<=255){
          poleFades[i]+=85;
        }
        else{
          poleDescenders[i]=true;
          poleFades[i]=255;
        }
      }
      else{
        if (poleFades[i]>=0){
          poleFades[i]-=85;
        }
        else{
          poleAngles[i]=0;
          poleFades[i]=0;
          poleDescenders[i]=false;
          poleHits[i]=false;
          score++;
        }
      }
    }
  }
}

//tried to animate a wobble for the poles but it did something else that looks more accurate to the targeting system
//idk actually know what this is doing but the way it works had a suprising pleasant effect so I'm keeping it, feel free to try actually make them wobble when hit
int wobble(int inAngle){
  if (abs(inAngle)<PI/3){
    inAngle+=inAngle;
  }
  else{
    inAngle-=inAngle;
  }
  return inAngle;
}

void drawScreenBottom(){
  pushMatrix();
  translate(displayWidth/2 -frameWidth/2,displayHeight/2 -frameHeight/2);
  tint(200,180,200);
  image(frame0, 0, 0);
  tint(255);
  popMatrix();
}

void drawScreenTop(){
  pushMatrix();
  translate(displayWidth/2 -frameWidth/2,displayHeight/2 -frameHeight/2);

  pushMatrix();
  
  pushMatrix();
  blendMode(SCREEN);
  tint(255,126);
  image(grain, 0, 0, frameWidth,frameHeight);
  tint(255,255);
  popMatrix();
  
  blendMode(MULTIPLY);
  image(frame1, 15, 7);
  blendMode(SCREEN);
  image(frame2, 0, 0);
  
  popMatrix();
  
  blendMode(BLEND);
  image(frame3, 0, 0);
  popMatrix();
}

void drawBackground(){
  pushMatrix();
  tint(70,70,70);
  scale(1.39);
  image(bgImg,0,-170);
  scale(0.66,0.6);
  tint(100,100,100);
  image(bgImg,250,30);
  popMatrix();
}
