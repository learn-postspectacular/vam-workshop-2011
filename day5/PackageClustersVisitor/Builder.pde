// this interface simply describes a required protocol/behavior for
// a class to build a tree representation of some input data
//
// the functions listed here have no implementation, but any class who
// wants to implement (realize) this interface MUST also provide these functions
// the result & main benefit of using interfaces is a loose-coupling between
// different code components: our main application code does not need to know
// how a tree is being created nor does it care about which input data the resulting tree
// is based on. The interface simply guarantees that there's a thing which can do it
// this is mechanism is one of the most powerful devices to build flexible systems
//
// this example provides two implementations: CSVBuilder & FileTreeBuilder

// http://en.wikipedia.org/wiki/Interface_(object-oriented_programming)
// http://en.wikipedia.org/wiki/Interface_(computer_science)
// http://en.wikipedia.org/wiki/Loose_coupling

interface TreeBuilder {
  // a function which can build a tree structure from a given input
  TreeNode buildTree();
  
  // returns a description for all tree nodes WITH children
  String getNodeDescription();
  
  // returns a description for all tree nodes WITHOUT children
  // (these are called the leaves of a tree)
  String getLeafDescription();
}

