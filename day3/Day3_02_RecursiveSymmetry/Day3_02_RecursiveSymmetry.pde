// introductory example to recursive symmetry
// slightly expanded to add dynamic radius control and
// mapping recursion depth to color palette...

import toxi.geom.*;
import toxi.color.*;

// maximum recursion level
int MAX_DEPTH = 5;

// radius scale factor for next level/depth (shrink to 50% of current size)
float RADIUS_DECAY = 0.5;

// a color palette for mapping recursion depth
// i.e. circles at level 1 use 1st color, at level 2 use 2nd color, etc.
// the colors are defined as normalized red,green,blue,alpha components
TColor[] cols=new TColor[]{
  TColor.newRGBA(1,0,1,0.66), // magenta, 66% alpha
  TColor.newRGBA(0,0,0,0.25), // black, 25% alpha
  TColor.newRGBA(0,1,1,0.75), // cyan, 75% alpha
  TColor.newRGBA(0,0,0,0.25), // black, 25% alpha
  TColor.newRGBA(0.5,0,1,0.125), // purple, 12.5% alpha
  TColor.newRGBA(0,0,0,0.25) // black, 25% alpha
};

// a switch to indicate if we should save a screenshot
// triggered via keyPressed() function
boolean doSave=false;

void setup() {
  size(600,600);
  // turn on anti-aliasing for more detail
  smooth();
}

void draw() {
  background(255);
  noFill();
  // use the horizontal mouse position to adjust root radius
  float radius=mouseX*2;
  // start recursive drawing at level 1
  drawDepth(0,0,width,height,radius,1);
  // check if we need to save current image
  if (doSave) {
    saveFrame("sym-"+radius+".png");
    doSave=false;
  }
}

// recursive drawing function
// takes a top-left offset point/origin
// a drawing region width/height
// a radius and recursion depth
void drawDepth(int offsetX, int offsetY, int w, int h, float radius, int depth) {
  int w2=w/2;
  int h2=h/2;
  // choose color from palette
  stroke(cols[depth-1].toARGB());
  // store current coordinate system
  pushMatrix();
  {
    // draw top-left
    translate(offsetX,offsetY);
    ellipse(w2/2,h2/2,radius,radius);
    pushMatrix();
    {
      // handle top-right symmetry
      translate(w2,0);
      ellipse(w2/2,h2/2,radius,radius);
    }
    popMatrix();
    pushMatrix();
    {
      // handle bottom-left symmetry
      translate(0,h2);
      ellipse(w2/2,h2/2,radius,radius);
    }
    popMatrix();
    pushMatrix();
    {
      // handle bottom-right symmetry
      translate(w2,h2);
      ellipse(w2/2,h2/2,radius,radius);
    }
    popMatrix();
  }
  // restore coord system to previous state
  popMatrix();
  // actual recursion...
  if (depth < MAX_DEPTH) {
    // shrink radius for next level
    radius*=RADIUS_DECAY;
    // call the same function 4x times with half size
    // (and offset to correct quadrants)
    // 1st child: top-left
    drawDepth(offsetX,offsetY,w2,h2,radius,depth+1);
    // 2nd child: top-right
    drawDepth(offsetX+w2,offsetY,w2,h2,radius,depth+1);
    // 3rd child: bottom-left
    drawDepth(offsetX,offsetY+h2,w2,h2,radius,depth+1);
    // 4th child: bottom-right
    drawDepth(offsetX+w2,offsetY+h2,w2,h2,radius,depth+1);
  }
}

void keyPressed() {
  // turn on save (once) when SPACE is pressed
  if (key==' ') {
    doSave=true;
  }
}
