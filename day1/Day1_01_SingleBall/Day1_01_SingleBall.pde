float MAX_SPEED=10;
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
  // apply velocity
  x+=velX;
  y+=velY;
  // flip directions on boundary
  if (x<SIZE || x>width-SIZE) {
    velX*=-1;
  }
  if (y<SIZE || y>height-SIZE) {
    velY*=-1;
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
