import toxi.geom.*;
import toxi.math.*;

int RES=8;

void setup() {
  size(680,480);
  textFont(createFont("SansSerif",10));
}

void draw() {
  background(0);
  fill(255);
  noStroke();
  Vec2D centroid=new Vec2D(width/2,height/2);
  for(int i=0; i<RES; i++) {
    // polar coords are specified in this order:
    // radius, angle (in radians)
    Vec2D p=new Vec2D(200,radians(i*360.0/RES)).toCartesian();
    p.addSelf(centroid);
    ellipse(p.x,p.y,10,10);
  }
  // convert mouse pos to polar coords
  Vec2D mousePos=new Vec2D(mouseX,mouseY);
  // first remove screen offset of circle centre
  mousePos.subSelf(centroid);
  mousePos.toPolar();
  // create a copy of that polar point
  Vec2D snap=mousePos.copy();
  // snap to closest angle based on the given resolution
  snap.y=MathUtils.roundTo(mousePos.y,TWO_PI/RES);
  // keep a reference for showing as label further down
  float rounded=snap.y;
  // draw circle on snapped direction/angle:
  // go back to cartesian screenspace
  snap.toCartesian().addSelf(width/2,height/2);
  fill(0,255,255);
  ellipse(snap.x,snap.y,5,5);
  stroke(0,255,255);
  line(centroid.x,centroid.y,snap.x,snap.y);
  // draw labels
  fill(255,0,0);
  text("radius: "+mousePos.x, mouseX, mouseY-20);
  text("angle: "+degrees(mousePos.y)+" / "+degrees(rounded),mouseX,mouseY-8);  
}

