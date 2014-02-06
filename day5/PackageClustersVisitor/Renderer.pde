// another implementation of the TreeVisitor interface this class is responsible to
// visualize the tree structure
class TreeRenderer implements TreeVisitor {
  
  // references to particles currently either selected or hovered over with the mouse
  VerletParticle2D highlighted,selected;
  // switch to show labels or not
  boolean doShowLabels;
  
  // again, due to the nature of the visitor pattern, this function only
  // needs to deal with the visualization of a single tree node
  void visitNode(TreeNode node) {
    // draw connections to all child nodes
    if (!node.isLeaf()) {
      for(TreeNode c : node.children) {
        stroke(c.col.toARGB());
        gfx.line(node.particle,c.particle);
      }
    }
    // draw node using its associated colour
    int c=node.col.toARGB();
    fill(c);
    noStroke();
    gfx.circle(node.particle, 5);
    // draw highlight or selection focus
    if (selected==node.particle) {
      noFill();
      stroke(255, 0, 255);
      ellipse(selected.x, selected.y, 20, 20);
    } else if (highlighted==node.particle) {
      stroke(c);
      noFill();
      gfx.circle(highlighted,20);
    }
    // draw label
    if (doShowLabels) {
      if (node.isLeaf()) {
        fill(51);
      } else {
        // nodes with children are rendered in a different style
        // with semi-transparent background
        // first compute required width with padding
        float w=textWidth(node.name)+4;
        fill(0,192);
        noStroke();
        // draw bg
        rect(node.particle.x-2,node.particle.y-14,w,14);
        fill(255);
      }
      text(node.name, node.particle.x, node.particle.y-4);
    }
  }
  
  void toggleLabels() {
    doShowLabels=!doShowLabels;
  }
  
  // set highlighted particle
  void highlight(VerletParticle2D h) {
    highlighted=h;
  }
  
  // release selected particle
  void deselect() {
    if (selected!=null) {
      selected.unlock();
      selected=null;
    }
  }
  
  // set selected particle reference
  void select(VerletParticle2D s) {
    if (s!=null) {
      selected=s;
      selected.lock();
    }
  }
  
  void updateSelected(Vec2D pos) {
    if (selected!=null) {
      // move selected particle to new pos
      selected.set(pos);
    }
  }
}
