// V&A Computational Design workshop
// Session #2 example: Multiple balls with life span & iterators
// Demonstrates multiple constructor handling, emitting balls at
// mouse position and how to use an iterator to remove old balls
//
// http://learn.postspectacular.com/

import toxi.geom.*;
import toxi.color.*;

float MAX_SPEED=10;
// absolute constant downward force on Y velocity
float GRAVITY=0.35;
// loss of force due to ground collision (factor)
float RESTITUTION=0.05;
// variance factor for X velocity after ground collision
float JITTER = 0.2;
// max shape radius
float MAX_RADIUS=20;
// life span for each ball
int MAX_AGE=500;

List<Ball> balls=new ArrayList<Ball>();

void setup() {
  size(680,382);
  ellipseMode(RADIUS);
  rectMode(RADIUS);
  addBall();
}

void draw() {
  background(224);
  noStroke();
  // delegate list iteration to an Iterator object (a "cursor")
  // that allows dynamic removal of elements during iteration
  // the loop continues for as long the iterator has
  // more elements to come...
  for(Iterator<Ball> i=balls.iterator(); i.hasNext();) {
    Ball b=i.next();
    // update ball and check if still alive
    b.update();
    if (b.isAlive()) {
      b.draw();
    } else {
      // remove from list if too old
      i.remove();
      println("removed old ball, "+balls.size()+" left...");
    }
  }
}

void addBall() {
  Vec2D mousePos=new Vec2D(mouseX,mouseY);
  float rnd=random(1);
  if (rnd<0.33) {
    balls.add(new Dot(mousePos));
  } 
  else if (rnd<0.66) {
    balls.add(new Square(mousePos));
  } 
  else {
    balls.add(new Heart(mousePos));
  }
}

void mousePressed() {
  addBall();
}

void mouseDragged() {
  addBall();
}


void keyPressed() {
  if (key=='x' && balls.size()>0) {
    balls.remove(0);
  }
}

