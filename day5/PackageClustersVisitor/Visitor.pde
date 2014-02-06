// this interface is part of the mechanism of the Visitor design pattern
// (see comments/links in main sketch file & TreeNode class)
// more information about "interfaces" is also in the Builder tab of this sketch
interface TreeVisitor {
  void visitNode(TreeNode n);
}

// this simple visitor counts all nodes WITH children
class TreeNodeCounter implements TreeVisitor {
  
  int count=0;
  
  void visitNode(TreeNode n) {
    if (n.children!=null) {
      count++;
    }
  }
}

// this simple visitor counts all nodes WITHOUT children
class TreeLeafCounter implements TreeVisitor {
  
  int count=0;
  
  void visitNode(TreeNode n) {
    if (n.children==null) {
      count++;
    }
  }
}
