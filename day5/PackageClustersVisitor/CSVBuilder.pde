// this class is a concrete implementation of the TreeBuilder interface
// it parses a simple CSV file relating people to table ID numbers and
// creates a tree structure from that information, resulting in this structure:
// workshop ->
//    table ->
//      name1
//      name2
// ...
class CSVTreeBuilder implements TreeBuilder {
  
  String path;
  
  CSVTreeBuilder(String path) {
    this.path=path;
  }
  
  String getNodeDescription() {
    return "tables";
  }
  
  String getLeafDescription() {
    return "people";
  }
  
  TreeNode buildTree() {
    // parsing CSV file process as discussed in previous RoomClusters exercise (day 4)
    String[] lines=loadStrings(path);
    // hashmap is used to group people by their table IDs
    HashMap<Integer, ArrayList<String>> tables=new HashMap<Integer, ArrayList<String>>();
    for(String l : lines) {
      if (l.length()>0) {
        String[] items=split(l,",");
        int id=int(items[1]);
        ArrayList<String> names=tables.get(id);
        if (names==null) {
          names=new ArrayList<String>();
          tables.put(id,names);
        }
        names.add(items[0]);
      }
    }
    // once all data is parsed, translate hashmap into actual recursive tree structure
    TreeNode root=new TreeNode(null,"workshop",0,TColor.BLACK.copy());
    root.children=new LinkedList<TreeNode>();
    // iterate over all tables
    for(int tableID : tables.keySet()) {
      // create a tree node for each table and attach to "workshop" root
      TreeNode table=new TreeNode(root,"table #"+tableID,1,TColor.RED.copy());
      table.children=new LinkedList<TreeNode>();
      root.children.add(table);
      // add all names related to current table and attach as children
      for(String name : tables.get(tableID)) {
        TreeNode person=new TreeNode(table,name,2,TColor.BLUE.copy());
        table.children.add(person);
      }
    }
    // return the tree root node (which now also contains all other nodes)
    return root;
  }
}
