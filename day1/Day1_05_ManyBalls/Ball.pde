class Ball {
  Vec2D pos;
  Vec2D vel;
  float radius;
  
  Ball() {
    reset();
  }
  
  void draw() {
    ellipse(pos.x,pos.y,radius,radius);
  }
  
  void update() {
    // apply gravity
    vel.y+=GRAVITY;
    // apply velocity
    pos.addSelf(vel);
    // flip directions on boundary
    if (pos.x<radius || pos.x>width-radius) {
      vel.x*=-1;
      pos.x+=vel.x;
    }
    if (pos.y<radius) {
      vel.y*=-1;
    }
    // special case lower edge...
    if (pos.y>height-radius) {
      // apply restitution to dampen forces
      vel.scaleSelf(1-RESTITUTION, -(1-RESTITUTION));
      // also apply jitter on horizontal velocity
      vel.x*=1+random(-1,1)*JITTER;
      pos.y+=vel.y;
    }
  }

  void reset() {
    // position somewhere central
    pos=new Vec2D(random(0.25,0.75)*width, random(0.25,0.75)*height);
    // random velocity
    vel=Vec2D.randomVector().scale(random(MAX_SPEED));
    radius=random(5,20);
  }
}

