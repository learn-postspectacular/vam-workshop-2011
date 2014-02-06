float MAX_SPEED=10;
// absolute constant downward force on Y velocity
float GRAVITY=0.3;
// loss of force due to ground collision (factor)
float RESTITUTION=0.05;
// variance factor for X velocity after ground collision
float JITTER = 0.2;

float SIZE=10;

float x,y;
float velX,velY;

void setup() {
  size(400,400);
  ellipseMode(RADIUS);
  initBall();
}

void draw() {
  background(160);
  noStroke();
  fill(255);
  // apply gravity
  velY+=GRAVITY;
  // apply velocity
  x+=velX;
  y+=velY;
  // flip directions on boundary
  if (x<SIZE || x>width-SIZE) {
    velX*=-1;
    x+=velX;
  }
  if (y<SIZE) {
    velY*=-1;
  }
  // special case lower edge...
  if (y>height-SIZE) {
    // apply restitution to dampen forces
    velX*=(1-RESTITUTION);
    velY*=-(1-RESTITUTION);
    // also apply jitter on horizontal velocity
    velX*=1+random(-1,1)*JITTER;
    y+=velY;
  }
  // draw at current position
  ellipse(x,y,SIZE,SIZE);
}

void initBall() {
  // position somewhere central
  x=random(0.25,0.75)*width;
  y=random(0.25,0.75)*height;
  // random velocity
  velX=random(-1,1)*MAX_SPEED;
  velY=random(-1,1)*MAX_SPEED;
}

void keyPressed() {
  if (key=='r') {
    initBall();
  }
}
