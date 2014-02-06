import toxi.geom.*;

float MAX_SPEED=10;
// absolute constant downward force on Y velocity
float GRAVITY=0.3;
// loss of force due to ground collision (factor)
float RESTITUTION=0.05;
// variance factor for X velocity after ground collision
float JITTER = 0.2;

Ball ball;

void setup() {
  size(400,400);
  ellipseMode(RADIUS);
  initBall();
}

void draw() {
  background(160);
  noStroke();
  fill(255);
  // update model
  ball.update();
  // draw at current position
  ball.draw();
}

void initBall() {
  ball=new Ball();
}

void keyPressed() {
  if (key=='r') {
    initBall();
  }
}
