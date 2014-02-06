// V&A Computational Design workshop
// Session #2 example: Multiple balls with inheritance
// Uses abstract base class + subclasses to define different shapes
// http://learn.postspectacular.com/

import toxi.geom.*;
import toxi.color.*;

float MAX_SPEED=10;
// absolute constant downward force on Y velocity
float GRAVITY=0.3;
// loss of force due to ground collision (factor)
float RESTITUTION=0.05;
// variance factor for X velocity after ground collision
float JITTER = 0.2;
// max shape radius
float MAX_RADIUS=40;

List<Ball> balls=new ArrayList<Ball>();

void setup() {
  size(680,382);
  ellipseMode(RADIUS);
  rectMode(RADIUS);
  initBalls();
}

void draw() {
  background(224);
  noStroke();
  for(int i=0; i<balls.size(); i++) {
    balls.get(i).update();
    balls.get(i).draw();
  }
}

void initBalls() {
  float rnd=random(1);
  if (rnd<0.33) {
    balls.add(new Dot());
  } else if (rnd<0.66) {
    balls.add(new Square());
  } else {
    balls.add(new Heart());
  }
}

void keyPressed() {
  if (key=='r') {
    initBalls();
  }
  if (key=='x' && balls.size()>0) {
    balls.remove(0);
  }
}
