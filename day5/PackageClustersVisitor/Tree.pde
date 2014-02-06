// this is our actual tree structure
// each node has a reference to its parent, as well as an (optional) list of children
class TreeNode {
  
  TreeNode parent;
  List<TreeNode> children;
  String name;
  int depth;
  
  VerletParticle2D particle;
  TColor col;
  
  public TreeNode(TreeNode parent, String name, int depth, TColor col) {
    this.parent=parent;
    this.name=name;
    this.depth=depth;
    this.col=col;
  }
  
  // this function is the heart of the super flexible visitor design pattern
  // it takes a TreeVisitor implementation and applies it to itself and each child nodes
  void applyVisitor(TreeVisitor visitor) {
    visitor.visitNode(this);
    if (children!=null) {
      for(TreeNode c : children) {
        c.applyVisitor(visitor);
      }
    }
  }
  
  // helper function to check if a node is a leaf
  boolean isLeaf() {
    return children==null;
  }
}
