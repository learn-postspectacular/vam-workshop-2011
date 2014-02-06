// the following mini classes all subclass/inherit
// everything from the (abstract) Ball class
// we only really override/customize the draw() functions
// in order to create different shapes

class Dot extends Ball {
  
  void draw() {
    fill(col.toARGB());
    ellipse(pos.x,pos.y,radius,radius);
  }
}

class Square extends Ball {
  
  void draw() {
    fill(col.toARGB());
    rect(pos.x,pos.y,radius,radius);
  }
}

// the Heart class also provides its own constructor
// to customize the one defined by the parent Ball class
class Heart extends Ball {
  
  Heart() {
    // first call the Ball constructor
    super();
    // then pick a random shade of red
    // analog() function varies the original color by:
    // hue: +/-20 degrees and
    /// upto 50% change in saturation & brightness
    col=TColor.RED.getAnalog(20, 0.5);
  }
  void draw() {
    // create spline shape in normalized space
    // extending only to the negative X axis
    Spline2D s=new Spline2D();
    s.add(new Vec2D(0,-0.5));
    s.add(new Vec2D(-0.5,-1));
    s.add(new Vec2D(-1,-0.5));
    s.add(new Vec2D(-0.35,0.35));
    s.add(new Vec2D(0,1));
    // compute curve vertices and store in temp list
    List<Vec2D> points=s.computeVertices(8);
    // now backup current coordinate system
    pushMatrix();
    // move coordinate origin to ball position
    translate(pos.x,pos.y);
    // scale to radius
    scale(radius);
    fill(col.toARGB());
    // create polygon using curve vertices
    beginShape();
    for(int i=0; i<points.size(); i++) {
      Vec2D p=points.get(i);
      vertex(p.x,p.y);
    }
    // now we have to draw the mirrored other half of our heart shape
    // this means all X coordinates are flipped and the vertice list
    // has to be read out backwards in order for our polygon to continue anti-clockwise
    for(int i=points.size()-1; i>=0; i=i-1) {
      Vec2D p=points.get(i);
      vertex(-p.x,p.y);
    }
    // tell Processing to finish the polygon
    endShape();
    // restore coordinate system to earlier state
    popMatrix();
  }
}
