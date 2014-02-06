// another implementation of the TreeBuilder interface
// this class recursively lists all files within the given start folder in your filesystem
// actual files become leaf nodes in the tree, subfolders are scanned recursively
class FileTreeBuilder implements TreeBuilder {
  
  String path;
  
  FileTreeBuilder(String path) {
    this.path=path;
  }
  
  TreeNode buildTree() {
    return buildNode(null, path, 0, 1);
  }
  
  // this is the recursive function creating a single tree node at each iteration
  // the hue & hueDelta parameters are used to uniquely color each branch of the tree
  // using HSV color space and splitting the available hue range into ever smaller spectra
  // with each level of recursion..
  TreeNode buildNode(TreeNode parent, String path, float hue, float hueDelta) {
    // create a file reference for the given path
    File f=new File(path);
    // use the file name as node label
    String name=f.getName();
    // remove file extension (e.g. ".png"), if present
    if (name.indexOf(".")!=-1) {
      name=name.substring(0,name.lastIndexOf("."));
    }
    // calculate recursion depth, using information from parent node
    int depth=parent==null ? 0 : parent.depth+1;
    // create new tree node
    TreeNode node=new TreeNode(parent,name,depth,TColor.newHSV(hue,1,1));
    // if the current file is a folder, continue recursion for each file within that folder
    if (f.isDirectory()) {
      println("parsing: "+path);
      // retrieve list of files within folder
      File[] fc=f.listFiles();
      // if folder is not empty, create children
      if (fc.length>0) {
        node.children=new LinkedList<TreeNode>();
        // split available hue spectrum based on number of children
        hueDelta=hueDelta/fc.length;
        // recursively build all child nodes and add to current
        for(File c : fc) {
          node.children.add(buildNode(node,c.getAbsolutePath(),hue,hueDelta));
          hue+=hueDelta;
        }
      }
    }
    // once the recursive process has finished (all files are parsed)
    // this function will return the root node of the tree
    return node;
  }
  
  String getNodeDescription() {
    return "folders";
  }
  
  String getLeafDescription() {
    return "files";
  }
}

