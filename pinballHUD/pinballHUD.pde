import processing.serial.*; //<>//
import processing.sound.*;
import gifAnimation.*;

//press spacebar to play for now//

Serial myPort;
float light=0;
float pressure=0;
int motion=0;

float angle=0;

//main states
int currentState, state0=0, state1=1, state2=2, state3=3, state4=4, state5=5;
//starting fade in animation
int startFade;

//sounds
SoundFile ship, comms, beep, hum, blast, error, ballGone, eject;

//graphics
PImage frame0,frame1,frame2,frame3,bgImg,cockPitImg;
int frameWidth,frameHeight,centerX,centerY,screenDescenderY;
Gif grain,pole,poleOn;

boolean cockPitRight,screenDescend,screenAscend;

ArrayList<Starr> stars = new ArrayList<Starr>();

PFont font;

//pole animations and positions
boolean descending,poleHit;
int fade, poleStartFade;
boolean [] poleDescenders, poleHits;
int [] poleFades, poleAngles;
int [][] polePositions = {{-150,0},{+150,0},{0,-150}};

boolean ballLost;
boolean cheating;

int score, lives, endScreenTimer, penaltyTimer, ballLostTimer;

void setup(){
  fullScreen();
  background(0);
  
  myPort = new Serial(this,Serial.list()[0],9600);
  myPort.bufferUntil('&');
  
  currentState=0;
  
  startFade=0;
  
  eject = new SoundFile(this, "assets/eject.mp3");
  
  ship = new SoundFile(this, "assets/interior.mp3");
  comms = new SoundFile(this, "assets/comms.mp3");
  beep = new SoundFile(this, "assets/beep.wav");
  hum = new SoundFile(this, "assets/humOn.mp3");
  blast = new SoundFile(this, "assets/blaster.mp3");
  error = new SoundFile(this, "assets/error.mp3");
  ballGone = new SoundFile(this, "assets/ballGone.mp3");
  comms.amp(0.2);
  ship.amp(0.6);
  comms.loop();
  ship.loop();
  
  
  for (int i=0; i<100; i++){
    stars.add(new Starr ((int) random (displayWidth/50, displayWidth - (displayWidth/50)),(int) random (displayHeight/50, displayHeight - (displayHeight/50))));
  }
  cockPitImg = loadImage("assets/cockpit.png");
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
  
  cockPitRight=true;
  screenDescend=true;
  screenAscend=false;
  screenDescenderY=-frame0.height;
  
  frameWidth=880;
  frameHeight=687;
  
  font = createFont("assets/SceletAF.otf", 32);
  textFont(font);
  
  score=0;
  lives=3;
  endScreenTimer=0;
  penaltyTimer=0;
  ballLostTimer=0;
  
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
  
  ballLost = false;
  cheating = false;
  
  smooth(4);
  
  eject.play();
}

void draw(){
  background(0);
  drawBackground();
  translate(displayWidth/2,displayHeight/2);
  rotater();
  rotate(angle);
  drawCockpit();
  pushMatrix();
  screenEjecter();
  drawScreenBottom();
  tint(255,startFade);
  drawPoles(currentState);
  poleHitEvent();
  drawScore(startFade,currentState);
  tint(255,255);
  drawScreenTop();
  eventListener();
  handleStates();
  popMatrix();
}

void eventListener(){
  if (light<210){
    ballLost=true;
  }
  else if (pressure<254){
    poleHits[0]=true;
    blast.play();
  }
  else if (motion==1){
    cheating=true;
  }
}

void serialEvent(Serial myPort){
  String inString = myPort.readStringUntil('&');
  String[] lightStr = splitTokens(inString,"a");
  String[] pressureStr = splitTokens(inString,"b");
  String[] motionStr = splitTokens(inString,"c");
  
  light = map(int(lightStr[0]),0,1023,0,255);
  pressure = map(int(pressureStr[1]),0,1023,0,255);
  motion=int(motionStr[1]);
}

//controls, this function can be changed into a function that listens for signals from the arduino serial connection, just change the name and keep it in the draw function
//because it wont be callback anymore
void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      if (poleHits[0]==false){
        poleHits[0]=true;
      }
    } 
    else if (keyCode == RIGHT) {
      if (poleHits[1]==false){
        poleHits[1]=true;
      }
    }
    else if (keyCode == UP) {
      if (poleHits[2]==false){
        poleHits[2]=true;
      }
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
    
    else if (ballLost==true){
      lives--;
      currentState=3;
      ballGone.play();
    }
    
    else if (cheating==true){
      currentState=4;
      error.play();
    }
  }
  else if (currentState==3){
    if (ballLostTimer<20){
      ballLostTimer++;
    }
    else{
      ballLost=false;
      ballLostTimer=0;
      if (lives<=0){
        currentState=5;
      }
      else{
        currentState=1;
      }
    }
  }
  else if (currentState==4){
    if (penaltyTimer<40){
      penaltyTimer++;
    }
    else{
      if(motion!=1){
        currentState=1;
        cheating=false;
        score=0;
        penaltyTimer=0;
      }
    }
  }
  else if (currentState==5){
    if (endScreenTimer<80){
      endScreenTimer++;
    }
    else{
      endScreenTimer=0;
      lives=3;
      score=0;
      currentState=0;
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
    text("Play game", 0 ,  + 230); 
  }
  else if (inState==1){
    fill(222,49,33,inFade);
    text(formatScore(score), 0,  + 230);
    pushMatrix();
    textAlign(LEFT);
    textFont(font, 20);
    fill(222,49,33,inFade);
    text("Lives: "+lives, -360 , -260);
    popMatrix();
  }
  else if (inState==3){
    fill(226,206,153);
    text("Ball lost", 0 ,  + 230); 
  }
  else if (inState==4){
    fill(226,206,153);
    text("CHEATING", 0 ,  + 230); 
  }
  else if (inState==5){
    fill(226,206,153);
    text("GAME OVER", 0,  + 110);
    fill(222,49,33,inFade);
    textFont(font, 100);
    text(score, 0 , 0);
  }
  noFill();
  if (inState!=5){
    stroke(226,206,153,inFade);
    strokeWeight(4);
    rect(-225, + 160,450,90,25);
  }
  popMatrix();
}

void drawPoles(int inState){  
  if (inState==1){
    pushMatrix();
    tint(255,poleStartFade);
    for (int i=0;i<3;i++){
      rotate(poleAngles[i]);
      image(pole,  - 146/2 + polePositions[i][0], - 179/2 + polePositions[i][1]);
      rotate(-poleAngles[i]);
      //red pole flashes
      if (poleHits[i] == true){
        tint(255,poleFades[i]);
        image(poleOn, - 146/2 + polePositions[i][0], - 179/2 + polePositions[i][1]);
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
      poleAngles[i]=wobble(poleAngles[i]);
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

void screenEjecter(){
  if (screenDescend==true && currentState ==0){
    if (screenDescenderY>-frame0.height/2){
      screenDescend=false;
    }
    translate(0,screenDescenderY);
    screenDescenderY+=100;
  }
}

void rotater(){
  if (cockPitRight==true){
    if (angle>0.03){
      cockPitRight=false;
    }
    angle+=0.001;
  }
  else{
    if (angle<-0.03){
      cockPitRight=true;
    }
    angle-=0.001;
  }
}

void drawScreenBottom(){
  pushMatrix();
  tint(70,70,70);
  scale(1.39);
  scale(0.66,0.6);
  tint(100,100,100);
  image(bgImg,-bgImg.width/2,-bgImg.height/2);
  popMatrix();
  pushMatrix();
  translate(-frameWidth/2,-frameHeight/2);
  tint(200,180,200);
  image(frame0, 0, 0);
  tint(255);
  popMatrix();
}

void drawScreenTop(){
  pushMatrix();
  translate(-frameWidth/2,-frameHeight/2);

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
  for (int i=0; i<stars.size(); i++){
     Starr s = stars.get(i);
     s.drawMe();
     if (s.alpha < 0){
       stars.remove(s);
       stars.add(new Starr ((int) random (displayWidth/50, displayWidth - (displayWidth/50)),(int) random (displayHeight/50, displayHeight - (displayHeight/50))));
     }     
  }
}

void drawCockpit(){
  pushMatrix();
  tint(100,100,100);
  image(cockPitImg,-cockPitImg.width/2,-cockPitImg.height/2);
  popMatrix();
}
