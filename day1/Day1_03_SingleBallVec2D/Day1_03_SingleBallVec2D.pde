import toxi.geom.*;

float MAX_SPEED=10;
// absolute constant downward force on Y velocity
float GRAVITY=0.3;
// loss of force due to ground collision (factor)
float RESTITUTION=0.05;
// variance factor for X velocity after ground collision
float JITTER = 0.2;

float SIZE=10;

Vec2D pos;
Vec2D vel;

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
  vel.y+=GRAVITY;
  // apply velocity
  pos.addSelf(vel);
  // flip directions on boundary
  if (pos.x<SIZE || pos.x>width-SIZE) {
    vel.x*=-1;
    pos.x+=vel.x;
  }
  if (pos.y<SIZE) {
    vel.y*=-1;
  }
  // special case lower edge...
  if (pos.y>height-SIZE) {
    // apply restitution to dampen forces
    vel.scaleSelf(1-RESTITUTION, -(1-RESTITUTION));
    // also apply jitter on horizontal velocity
    vel.x*=1+random(-1,1)*JITTER;
    pos.y+=vel.y;
  }
  // draw at current position
  ellipse(pos.x,pos.y,SIZE,SIZE);
}

void initBall() {
  // position somewhere central
  pos=new Vec2D(random(0.25,0.75)*width, random(0.25,0.75)*height);
  // random velocity
  vel=Vec2D.randomVector().scale(random(MAX_SPEED));
}

void keyPressed() {
  if (key=='r') {
    initBall();
  }
}
