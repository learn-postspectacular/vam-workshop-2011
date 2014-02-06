import processing.opengl.*;

import toxi.physics2d.constraints.*;
import toxi.physics2d.behaviors.*;
import toxi.physics2d.*;

import toxi.geom.*;
import toxi.math.*;

//angular segments - number of strings
int RES = 10;
//radial segments - steps per string
int NUM_RINGS=5; 
// number of particles for cross connections
int CROSS_RES=10;

//angle increment
float ai = TWO_PI/RES;
//half width/height
float hw,hh;

float radius = 300;
float particleSize = 7;

ArrayList<ParticleString2D> strings = new ArrayList<ParticleString2D>();
VerletPhysics2D phys;
Vec2D mousePos = new Vec2D(mouseX,mouseY);
VerletParticle2D selectedP;

void setup(){
  smooth();
  size(1024,768,OPENGL);
  noStroke();
  ellipseMode(CENTER);
  //init physics
  hw = width * .5;
  hh = height * .5;
  phys = new VerletPhysics2D();
  //phys.addBehavior(new GravityBehavior(new Vec2D(0,2)));
  phys.setWorldBounds(new Rect(0,0,1024,760));
  //main: create all spokes and cross connect them
  for(int i = 0 ; i < RES ; i++){
    Vec2D dir=new Vec2D(radius/NUM_RINGS,i*ai).toCartesian();
    ParticleString2D string = new ParticleString2D(phys, new Vec2D(hw,hh),dir,NUM_RINGS,1,1);
    // lock outer end points of each spoke
    string.getTail().lock();
    if(i > 0){
      crossConnect(string,strings.get(i-1));
    }
    strings.add(string);
  }
  // also cross connect last spoke with very first
  crossConnect(strings.get(0),strings.get(RES-1));
}

void crossConnect(ParticleString2D curr, ParticleString2D prev) {
  for(int j = 0; j < curr.getNumParticles() ; j++){
    VerletParticle2D a=curr.particles.get(j);
    VerletParticle2D b=prev.particles.get(j);
    // create X more particles on the line between A & B
    VerletParticle2D prevC=a;
    for(int i=1; i<CROSS_RES; i++) {
      // use interpolatTo compute inbetween points at a fraction of the distance A->B
      // the 1st tweened point will be on that line at 1/CROSS_RES, 2nd at 2/CROSS_RES, 3rd 3/CROSS_RES etc.
      VerletParticle2D c=new VerletParticle2D(a.interpolateTo(b,i*1.0/CROSS_RES));
      // connect to previous point
      phys.addSpring(new VerletSpring2D(prevC,c,prevC.distanceTo(c),1));
      prevC=c;
    }
    // connect B to last created in-between point
    phys.addSpring(new VerletSpring2D(prevC,b,prevC.distanceTo(b),1));
  }
}

void draw(){
  //update
  phys.update();
  //draw
  background(255);
  stroke(0,128,0);
  for(VerletParticle2D p: phys.particles){
    ellipse(p.x,p.y,particleSize,particleSize);
  }
  for(VerletSpring2D s: phys.springs){
    line(s.a.x,s.a.y,s.b.x,s.b.y);
  }
  if(selectedP != null){
    stroke(128,0,0);
    ellipse(selectedP.x,selectedP.y,particleSize*1.5,particleSize*1.5);
  }
}
//mouse handling
void mousePressed(){
  mousePos.set(mouseX,mouseY);
  for(ParticleString2D s: strings){
    for(int i = 1 ; i < NUM_RINGS-1 ; i++){
      VerletParticle2D p = s.particles.get(i);
      if(mousePos.distanceTo(p) < particleSize) {
        selectedP = p;
        selectedP.lock();
      }
    } 
  }
}

void mouseDragged(){
  if(selectedP != null) selectedP.set(mouseX,mouseY);
}

void mouseReleased(){
  if(selectedP != null){
    selectedP.unlock();
    selectedP = null;
  }
}

void keyPressed() {
  phys.springs.remove((int)random(phys.springs.size()));
}
