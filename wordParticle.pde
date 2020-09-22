// Makes all particles draw the next word
void nextWord(String word) {
  // Draw messageRadiusword in memory
  PGraphics pg = createGraphics(messageWidth, messageHeight);
  pg.beginDraw();
  pg.fill(0);
  pg.textSize(messageSize);
 // pg.textAlign(LEFT);
  PFont font = createFont(fontName, messageSize);
  pg.textFont(font);
  pg.text(word, 0, 0, messageWidth-5, messageHeight);
  pg.endDraw();
  pg.loadPixels();

  // Next color for all pixels to change to

  for (int i = 0; i < (messageWidth*messageHeight)-1; i+=3) {

    // Only continue if the pixel is not blank
    if (pg.pixels[i] != 0) {
      // Convert index to its coordinates
      int x = i % messageWidth;
      int y = i / messageWidth;

      // Create a new particle
      Particle newParticle = new Particle();     

      newParticle.pos.x = x + messagePositionX-messageWidth*0.5;
      newParticle.pos.y = y + messagePositionY-messageHeight*0.5;
      // Assign the particle's new target to seek
      // newParticle.target.x = random(width/2, width/2+rightMoonSize);


      newParticle.target.y = int(random(-newParticle.yRadius, newParticle.yRadius)); 
      newParticle.ySquared = newParticle.target.y * newParticle.target.y;
      newParticle.target.y += heightPos; // Add the screen position

      newParticle.xValue = sqrt((1 - newParticle.ySquared/newParticle.yRadiusSquared)*xRadiusSquared);
      if  (changeMoon) {
        newParticle.xValue *= -1;
      }
      if(moonPositionX > width*0.5){
              newParticle.maxSpeed = random(2.3, 3.5);
      }
      else{
              newParticle.maxSpeed = random(1.8, 3.1);
      }
      newParticle.maxForce = newParticle.maxSpeed*0.020;
      newParticle.particleSize = random(1, 4);
       float colDistance = dist(messagePositionX, 0, moonPositionX, 0);
       float mapBlend = map(colDistance, 800, 3800, 1.4, 0.8);
      newParticle.colorBlendRate = random(mapBlend*0.0003, mapBlend*0.002);

      particles.add(newParticle);

      // Blend it from its current color
      newParticle.startColor = lerpColor(newParticle.startColor, newParticle.targetColor, newParticle.colorWeight);
      newParticle.targetColor = color(235, 200, 131);
      newParticle.colorWeight = 0;
    }
  }
  sizepercent = particles.size();

  // MIGHT NEED THIS FOR DEBUGGING
  // Kill off any left over particles
  /* if (particleIndex < particleCount) {
   for (int i = particleIndex; i < particleCount; i++) {
   Particle particle = particles.get(i);
   particle.kill();
   }
   } */
}

class Particle {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  PVector target = new PVector(0, 0);

  float closeEnoughTarget = 150;
  float maxSpeed;
  float maxForce;
  float particleSize;
  boolean isKilled = false;

  color startColor = color(newColor);
  color targetColor = color(0);
  float colorWeight = 0;
  float colorBlendRate = 0.015;

  // This stuff has been moved to here because it only needs to be set once
  int yRadius = int(map(moon.width, 2.5, 2500, 2.2, 2250))/2; 
  float yRadiusSquared = yRadius * yRadius;
  float ySquared;
  float proximityMult = 1.0;
  float easing = 0.01;
  float xValue;



  void move() {
    // Check if particle is close enough to its target to slow down
    
    this.target.x = this.xValue;
    this.target.x += moonPositionX;

    float distance = dist(this.pos.x, this.pos.y, this.target.x, this.target.y);
    if (distance < 4) {
      this.particleSize = 1;
    }
    if (distance < 8) {
       this.easing = 0.5;
    }
    if (distance < this.closeEnoughTarget) {
      proximityMult = distance*easing;
    }
    // this.maxSpeed = distance*easing; 
    // Add force towards target
    PVector towardsTarget = new PVector(this.target.x, this.target.y);
    towardsTarget.sub(this.pos);
    towardsTarget.normalize();
    towardsTarget.mult(this.maxSpeed*proximityMult);

    PVector steer = new PVector(towardsTarget.x, towardsTarget.y);
    steer.sub(this.vel);
    if (distance > this.closeEnoughTarget*2) {
      steer.add(0, random(-4, 4));
    }
    steer.normalize();
    steer.mult(this.maxForce);
    this.acc.add(steer);

    // Move particle
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);
    
    if (distance <= 2 || this.pos.x >= width || this.pos.x <= 0 || this.pos.y <= 0-300 || this.pos.y >= height) {
      kill();
    }
  }

  void draw() {
    // Draw particle
    color currentColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);

    noStroke();
    fill(currentColor);
    ellipse(this.pos.x, this.pos.y, this.particleSize, this.particleSize);
  //  ellipse(this.target.x, this.target.y, this.particleSize, this.particleSize);

    // Blend towards its target color
    if (this.colorWeight < 1.0) {
      this.colorWeight = min(this.colorWeight+this.colorBlendRate, 1);
    }
  }

  void kill() {
    if (! this.isKilled) {
      // Set its target outside the scene
      // Begin blending its color to black
      this.startColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);
      this.targetColor = color(0);
      this.colorWeight = 0;
      this.isKilled = true;
      this.particleSize = 0;
    }
  }
}