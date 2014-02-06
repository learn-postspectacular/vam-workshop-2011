import toxi.geom.*;

int NUM_BALLS = 10;

float MAX_SPEED=10;
// absolute constant downward force on Y velocity
float GRAVITY=0.3;
// loss of force due to ground collision (factor)
float RESTITUTION=0.05;
// variance factor for X velocity after ground collision
float JITTER = 0.2;

List<Ball> balls=new ArrayList<Ball>();

void setup() {
  size(400,400);
  ellipseMode(RADIUS);
  initBalls();
}

void draw() {
  background(160);
  noStroke();
  fill(255);
  // update model
  for(Ball b : balls) {
    b.update();
  }
  // draw at current position
  for(Ball b : balls) {
    b.draw();
  }
}

void initBalls() {
  balls.clear();
  for(int i=0; i<NUM_BALLS; i++) {
    balls.add(new Ball());
  }
}

void keyPressed() {
  if (key=='r') {
    initBalls();
  }
}
