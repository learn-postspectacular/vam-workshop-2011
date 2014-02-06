// declaring this class "abstract" ensures only subclasses
// can be instantiated, but not this class itself...
// (also see draw() function below!)

abstract class Ball {

  Vec2D pos;
  Vec2D vel;
  float radius;
  TColor col;

  Ball() {
    // position somewhere central
    pos=new Vec2D(random(0.25,0.75)*width, random(0.25,0.75)*height);
    // random velocity
    vel=Vec2D.randomVector().scale(random(MAX_SPEED));
    radius=random(0.25,1)*MAX_RADIUS;
    col=TColor.newRandom();
  }

  void update() {
    // apply gravity
    vel.y+=GRAVITY;
    // apply velocity
    pos.addSelf(vel);
    // flip directions on boundary
    if (pos.x<radius) {
      pos.x=radius;
      vel.x*=-1;
    }
    else if (pos.x>=width-radius-1) {
      pos.x=width-radius-1;
      vel.x*=-1;
    }
    if (pos.y<radius) {
      pos.y=radius;
      vel.y*=-1;
    }
    else if (pos.y>height-radius-1) {
      pos.y=height-radius-1;
      // apply restitution to dampen & invert forces
      vel.scaleSelf(1-RESTITUTION, -(1-RESTITUTION));
      // also apply jitter on horizontal velocity
      vel.x*=1+random(-1,1)*JITTER;
    }
  }
  
  // declaring a this function "abstract" forces
  // subclasses to implement this function...
  abstract void draw();
}

