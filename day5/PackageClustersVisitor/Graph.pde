// this class is responsible for creating a physics based layout of a given tree structure
// it is an implementation of the TreeVisitor interface (see visitNode() function)
// as the name indicates the layout is self-organizing based on the graph of springs and
// attraction/repulsion force fields created

class ForceDirectedGraph implements TreeVisitor {

  VerletPhysics2D physics;
  VerletParticle2D hoverParticle,selectedParticle;
  int width,height;

  ForceDirectedGraph(int w, int h) {
    this.width=w;
    this.height=h;
  }
  
  void update() {
    physics.update();
  }
  
  Rect getBounds() {
    return getBoundingRect(physics.particles);
  }
  
  List<VerletParticle2D> getParticles() {
    return physics.particles;
  }
  
  void init() {
    physics=new VerletPhysics2D();
    physics.setDrag(0.1);
    physics.setWorldBounds(new Rect(-width,-height,width*2,height*2));
  }
  
  // this is the actual application of the visitor pattern
  // this function is being called by the tree class recursively for each node
  // the result is that we therefore only need to deal with a single node here
  // and in terms of layout only need to worry about our relationship with the
  // node's parent node. this simplifies the whole process.
  // I'd also like to point out that much of these hard coded physics parameters used
  // here should be parameterized and you're encouraged to play around with them and
  // see their impact on the overall layout (it definitely can be improved!)
  void visitNode(TreeNode node) {
    // default distance to parent
    float len=70;
    // if root node, centre it & lock in space
    if (node.depth==0) {
      node.particle=new VerletParticle2D(0,0).lock();
      // also attach large repulsive force field pushig all nodes away from centre
      physics.addBehavior(new AttractionBehavior(node.particle,width*0.6,-2));
    } else {
      // all other nodes are positioned close to their parent
      node.particle=new VerletParticle2D(node.parent.particle.add(Vec2D.randomVector()));
      // increase rest length based on number of children
      if (node.children!=null) {
        len+=node.children.size()*3.5;
      }
      // connect node to parent
      physics.addSpring(new VerletSpring2D(node.parent.particle,node.particle,len,0.1));
    }
    physics.addParticle(node.particle);
    // attach smaller repulsive force fields around each node
    if (!node.isLeaf()) {
      physics.addBehavior(new AttractionBehavior(node.particle,len,-1));
    } else {
      physics.addBehavior(new AttractionBehavior(node.particle,50,-1));
    }
  }
}

