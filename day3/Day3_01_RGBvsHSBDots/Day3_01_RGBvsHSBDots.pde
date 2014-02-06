// comparison between RGB & HSV color space topologies
// this is mainly FYI, we'll treat 3D properly in the next session

import toxi.geom.*;
import toxi.color.*;
import toxi.processing.*;

import processing.opengl.*;

// list to store random color samples
List<TColor> colors=new LinkedList<TColor>();

ToxiclibsSupport gfx;

void setup() {
  // use OPENGL renderer for this sketch
  // (we'll get to this still in detail)
  size(1024,576,OPENGL);
  gfx=new ToxiclibsSupport(this);
}

void draw() {
  background(128);
  noStroke();
  // add a new random color (up to 2000 swatches)
  if (colors.size()>2000) {
    colors.remove(0);
  }
  colors.add(TColor.newRandom());
  // visualize colors in both color spaces
  drawRGB();
  drawHSV();
}

// draws swatches in RGB color cube
void drawRGB() {
  pushMatrix();
  translate(width/3,height/2,0);
  rotateX(mouseY*0.01);
  rotateY(mouseX*0.01);
  for(Iterator<TColor> i=colors.iterator(); i.hasNext();) {
    TColor col=i.next();
    fill(col.toARGB());
    // RGB space is a cube, so we can simply interpret RGB as XYZ
    Vec3D pos=new Vec3D(col.red(),col.green(),col.blue());
    // centre & scale
    pos.subSelf(0.5,0.5,0.5).scaleSelf(200);
    // draw swatch
    gfx.box(new AABB(pos,5));
  }
  // draw bounding volume (a simple box)
  noFill();
  stroke(255,20);
  gfx.box(new AABB(100));
  noStroke();
  popMatrix();
}

// draws swatches in HSV cylinder
void drawHSV() {
  pushMatrix();
  translate(width*2/3,height/2,0);
  rotateX(mouseY*0.01);
  rotateY(mouseX*0.01);
  for(Iterator<TColor> i=colors.iterator(); i.hasNext();) {
    TColor col=i.next();
    fill(col.toARGB());
    // create mapping to produce HSV cylinder
    // hue = angle on color wheel
    // saturation = radius (distance from grey centre)
    // brightness = elevation (centred)
    float xx=sin(col.hue()*TWO_PI)*col.saturation();
    float yy=col.brightness()-0.5;
    float zz=cos(col.hue()*TWO_PI)*col.saturation();
    // scale to match size of RGB cube
    Vec3D pos=new Vec3D(xx,yy,zz).scaleSelf(100,200,100);
    // draw color swatch
    gfx.box(new AABB(pos,5));
  }
  // draw bounding volume (a cylinder)
  noFill();
  stroke(255,20);
  // this looks slightly more complicated,
  // but a cylinder is a (special form of) cone
  // cones are defined using:
  // 1) a ray (point+direction)
  // 2) a top/bottom radius
  // 3) a length
  Cone cylinder=new Cone(new Vec3D(0,0,0),new Vec3D(0,1,0),100,100,200);
  // now we turn the cylinder (resolution=20) into a mesh
  // without caps (sides only)
  gfx.mesh(cylinder.toMesh(null,20,0,false,false));
  noStroke();
  popMatrix();
}
