/*  defaultMessage[0] = "Send a message to be displayed on screen right now! Just tweet using #web3d2017 and wait a minute or two.";
 defaultMessage[1] = "Greetings from NZ! Say hello by sending a tweet with the hashtag #web3d2017.";
 defaultMessage[2] = "Fill in the moon by sending a tweet with hashtag #web3d2017.";
 defaultMessage[3] = "'The Media on the Moon' is part of the 22nd International conference on Web Technology in Brisbane. To interact, send in a tweet with #web3d2017.";
 defaultMessage[4] = "#web3d2017 is all you need to make this moon grow!";
 defaultMessage[5] = "Thanks to AUT and Colab for their contribution for getting this installation to #web3d2017. Created by Matthew Martin and Jenna Gavin.";
 */

int fullMoonSize = 480;
int moonAdjust = int(map(fullMoonSize, 150, 1500, 250, 2500));
float maskSize = fullMoonSize/2;
float moonPositionX = -280; //-280
int heightPos = 480/2;
float moonProgress = ((3840 + fullMoonSize*2)/30/600); //0.266;
float moonRotation = 0;

String Tlines[];
int cycleEndTime = 1980; // This IS THE MAIN end TIME
int cycleTimer; // This is the main timer
boolean timerFinished = false;

int messageWidth = 580;
int messageHeight = 280;
int messagePositionX = int(3840 - messageWidth/1.5);
int messagePositionY = 480/2;
int messageSize = 24;
boolean generateWord = true;
boolean wordsTyping = false;
Boolean particlesFly = false;
boolean pastFullMoon = false;
boolean changeMoon = false;

int currentTweet;
int tweetCounter = 0;
int stringCount = 0;
String message;
String thisTwit;

// Word particle variables
ArrayList<Particle> particles = new ArrayList<Particle>();
boolean isOneDead = false;
int wordIndex = 0;

color bgColor = color(0, 20, 40, 40);
String fontName = "Ariel";
PFont font;
color newColor;
int QColorInt = 0;
color[] QColor = new color[10];

//// Moon masking
PGraphics moon_Masking, theMoon;
//// Moon sizes

//int arcAdjust = int(map(moonAdjust, 250, 2500, 225, 2250));
PImage moon, rightMoon, leftMoon, cropLeftMoon, moonShade, rightMoonShade;
float messageRadius;
float sizepercent = 0;

//// Fireflies
ArrayList poop; // Star Particles

/// BG
color b1, b2, c1, c2;
int Y_AXIS = 1;
PGraphics BG;
PImage gradBackground;

//float xValue;
float xRadiusSquared;
int moonFrameCount = 7;
boolean swapsCount = false;
int totalParticles;
int rotFrameCount = 30;
int stopTwitCount = 0;

void setup()
{
  frameRate(60);
  size(3840, 480, P2D);

  // fullScreen();
  noCursor();
  smooth();

  //Fireflies
  poop = new ArrayList();
  creatFireflies(1, 80);
  creatFireflies(2, 75);
  creatFireflies(3, 30);
  creatFireflies(4, 12);

  // Define colors for background
  b1 = color(0);
  b2 = color(0, 15, 50);
  //  b2 = color(0, 26, 38);
  c1 = color(0, 15, 50);
  c2 = color(102, 51, 0);

  QColor[0] = color(255, 102, 0); // orange
  QColor[1] = color(54, 200, 50); // green
  QColor[2] = color(35, 177, 201); // blue
  QColor[3] = color(255, 42, 0); // red
  QColor[4] = color(113, 24, 196); // purple
  QColor[5] = color(132,84,34); // brown
  QColor[6] = color(255, 255, 255); // white
  QColor[7] = color(10, 230, 10); // bright green
  QColor[8] = color(244, 0, 105); // pink
  QColor[9] = color(125,249,255); // light blue

  BG = createGraphics(width, height);
  //I have put it so you create the BG in the function
  setGradient(0, 400, width, height, c1, c2, Y_AXIS);
  setGradient(0, 0, width, 400, b1, b2, Y_AXIS);  
  gradBackground = BG.get();

  currentTweet = 0;

  ////// Moon
  resetMoonSetup();
  updateMoon();

  String TlinesReal[] = loadStrings("lib/tweets.txt"); 
  Tlines = TlinesReal;

  font = createFont(fontName, messageSize);
}




void draw()
{
  //background(244);
  //background(0, 20, 40);
  imageMode(CENTER);
  tint(255, 255, 102);
  image(gradBackground, width/2, height/2, width, height);
  noTint();

  // These are the stars, not the moon dust!!
  for (int i=0; i<poop.size(); i++) {
    Fireflies Pn1 = (Fireflies) poop.get(i);
    Pn1.display();
    // Pn1.update();
  }

  drawMoon();
  updateMessage();   

  /////////////////// Particles Roll out ////////////////
  // particlesFly && timerFinished || 
  if (particles.size() > 0) {
    for (int x = particles.size() -1; x > -1; x--) {
      // Simulate and draw pixels
      Particle particle = particles.get(x);
      if (!particle.isKilled) {
        particle.move();
        particle.draw();
      }
      // Remove any dead pixels out of bounds
      else {
        particles.remove(particle);
        float pixelPercent = 1/sizepercent; // The amount one tweet will add in pixel amount
        if ((!changeMoon && !pastFullMoon) || (pastFullMoon && changeMoon)) {
          float halfCircle = pixelPercent*(fullMoonSize/2); // The first half amount
          float oneHalfOfMoon = halfCircle/5; // Adjust this based on how much is to fill in one day
          maskSize -= oneHalfOfMoon; // This is how much a tweet can do in one day 
          if (maskSize <= 1) {
            maskSize = 0;
            changeMoon = !pastFullMoon;
          }
        } else {
          float halfCircle = pixelPercent*(moonAdjust);
          float otherHalfMoon = halfCircle/5;
          maskSize += otherHalfMoon;
          if (maskSize >= moonAdjust) {
            maskSize = moonAdjust;
            pastFullMoon = changeMoon;
          }
        }
        isOneDead = true;
      }
    }
    if (isOneDead) {

      updateMoon(); 
      isOneDead = false;
      for (int x = particles.size() -1; x > -1; x--) {
        Particle particle = particles.get(x);
        if (!particle.isKilled) {

          particle.xValue = sqrt((1 - particle.ySquared/particle.yRadiusSquared)*xRadiusSquared);
          if  (changeMoon) {
            particle.xValue *= -1;
          }
        }
      }
    }

    //Stop adding to only one per frame

    if (particles.size() <= sizepercent/2 && particlesFly) {
      println("NOW");
     // particlesFly = false; 
      timerFinished = false;
      wordsTyping = false;
      generateWord = true;
      cycleTimer = frameCount;
      if(moonPositionX > width*0.5){
     cycleEndTime = 300; 
      }
      else{
        cycleEndTime = 620;
      }
      
      particlesFly = false;
    }
  }
  ///////////////// END OF PARTICLES ///////////////////
  ////////// MESSAGE //////////
  fill(newColor);
  textSize(messageSize);
  textAlign(LEFT);

  textFont(font);
  if (wordsTyping) {
    text(message, messagePositionX-messageWidth/2, messagePositionY-messageHeight/2, messageWidth, messageHeight);
  }
  //int moonArcAdjust = int(map(moon.width, 250, 2500, 225, 2250));
  //int moonArcAdjustX = int(map(maskSize, 0, fullMoonSize/2, 0, moonArcAdjust));

  //  arc(width/2, heightPos,  moonArcAdjustX,moonArcAdjust, -HALF_PI, HALF_PI);

  //popMatrix();

// If we are doing this at 60 fps then we want to run the moon at every 7.5fps with total 3600
  if (frameCount == moonFrameCount) {
   // if(swapsCount){
      moonFrameCount += 8;
   // }
   // else{
  //    moonFrameCount += 7;
   // }
    moonPositionX += 1;
   // swapsCount = !swapsCount;
  }
 // fill(255);
 // text("FPS: " + frameRate, mouseX, mouseY);
 //  text("Frames: " + frameCount, mouseX, mouseY + 40);
  // text("Time: " + millis()/1000, mouseX, mouseY + 80);
  saveFrame("saveFrames/frame" + frameCount + ".tga");
}

void mask(PImage target, PImage mask) {
  mask.loadPixels();
  target.loadPixels();
  if (mask.pixels.length != target.pixels.length) {
    println("Images are not the same size");
  } else {
    for (int i=0; i<target.pixels.length; i++) {
      target.pixels[i] = ((mask.pixels[i] & 0xff) << 24) | (target.pixels[i] & 0xffffff);
    }
    target.updatePixels();
  }
}


void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {
  noFill();
  BG.beginDraw();
  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      BG.stroke(c);
      BG.line(x, i, x+w, i);
    }
  }
  BG.endDraw();
}

// Toggle draw modes
void keyPressed() {
}