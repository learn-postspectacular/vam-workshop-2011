/**
 * <p>This example is an exercise done at the
 * V&A Computational Design workshop (Feb/Mar 2011)</p>
 *
 * <p>This exercise deals with the application of three important
 * design patterns:
 *
 * Model-View-Controller (MVC): to separate an application into
 * focused and re-usable components, each only dealing with a sub-set
 * of an application's functionality (data, interaction, visualization)
 *
 * Builder: to allow an abstract data structure (here a tree) to be
 * re-used with different data sources (here either the existing CSV file
 * from the previous RoomClusters example or an entire file system/folder structure)
 *
 * Visitor: to separate various operations from the underlying data structure
 * and ensure the tree only constitutes pure data & hierarchy. Here we use
 * visitors for building a force-directed graph layout using Verlet physics,
 * rendering the graph and retrieving tree statistics (number of folder & files)</p>
 *
 * More information about these 3 design patterns:
 * http://en.wikipedia.org/wiki/Model-View-Controller
 * http://en.wikipedia.org/wiki/Builder_pattern
 * http://en.wikipedia.org/wiki/Visitor_pattern
 *
 * <p>Usage:<ul>
 * <li>Click and drag mouse to select & move particles</li>
 * <li>Press 'r' to reset</li>
 * <li>Press 'l' to toggle labels</li>
 * </ul></p>
 */

/* 
 * Copyright (c) 2011 Karsten Schmidt
 * 
 * This demo & library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

import processing.opengl.*;

import toxi.physics2d.constraints.*;
import toxi.physics2d.behaviors.*;
import toxi.physics2d.*;
import toxi.geom.*;
import toxi.math.*;
import toxi.color.*;
import toxi.util.*;
import toxi.processing.*;
import java.awt.FileDialog;

// squared snap distance for mouse selection
float SNAP_DIST = 10 * 10;

TreeNode tree;

boolean doSave;

int numNodes,numLeaves;

ToxiclibsSupport gfx;
Vec2D currOrigin;

// choose one of the possible tree builders:
// either the CSV file of workshop participants or
// a folder structure on YOUR hard drive

//TreeBuilder builder = new CSVTreeBuilder("people.csv");
TreeBuilder builder = new FileTreeBuilder("/Users/toxi/tmp/toxiclibsgraph/toxi/");

// the graph class is responsible for
// turning the tree of our hierarchical data set into
// a physics driven, self-organizing layout
ForceDirectedGraph graph;

// the component to visualize the graph/tree structure
TreeRenderer renderer;

void setup() {
  size(1280,960,OPENGL);
  // use the configured builder to create a tree from its data source
  tree=builder.buildTree();
  // create some statistics of the data
  TreeNodeCounter nc=new TreeNodeCounter();
  tree.applyVisitor(nc);
  numNodes=nc.count;
  TreeLeafCounter lc=new TreeLeafCounter();
  tree.applyVisitor(lc);
  numLeaves=lc.count;

  // create an instance of the graph class
  graph=new ForceDirectedGraph(width,height);
  graph.init();
  // apply the visitor pattern to create the graph recursively
  tree.applyVisitor(graph);

  // create an instance of the tree renderer
  renderer=new TreeRenderer();

  textFont(createFont("SansSerif",10));
  gfx=new ToxiclibsSupport(this);
}

void draw() {
  // update the graph layout
  graph.update();
  background(224);
  fill(0);
  // show the stats computed in setup()
  text(builder.getNodeDescription()+": "+numNodes,20,20);
  text(builder.getLeafDescription()+": "+numLeaves,20,40);

  // centre graph on screen:
  // first calculate bounding rect of all nodes
  // (the graph is always centred around the point (0,0))
  // but its extent might not be symmetrical
  Rect bounds=graph.getBounds();
  // compute the difference vector between:
  // the centre of the screen and the centre of the bounding rect
  currOrigin=new Vec2D(width/2,height/2).sub(bounds.getCentroid());
  // shift our coordinate system by this difference
  // (this will centre the graph on screen)
  gfx.translate(currOrigin);
  // draw the bounding rect
  stroke(255,160);
  noFill();
  gfx.rect(bounds);

  // render the graph/tree using again the visitor design pattern
  tree.applyVisitor(renderer);

  // check if user wants to save screenshot
  if (doSave) {
    saveFrame("packageclusters-"+DateUtils.timeStamp()+".png");
    doSave=false;
  }
}

// this function is used to select particles near the mouse position
// since our graph is using its own coordinate system
// we'll need to translate mouse coordinates into the graph's local space
// this is simply done by subtracting the currOrigin vector (which is
// updated every frame) from the mouse position
VerletParticle2D findParticleUnderMouse() {
  List<VerletParticle2D> particles=graph.getParticles();
  // mouse pos in graph space
  Vec2D mousePos=new Vec2D(mouseX,mouseY).sub(currOrigin);
  // check all particles apart from the 1st one (unmovable root)
  for(int i=1; i<particles.size(); i++) {
    VerletParticle2D p=particles.get(i);
    if (mousePos.distanceToSquared(p)<SNAP_DIST) {
      return p;
    }
  }
  return null;
}

void mouseMoved() {
  // update highlighted particle reference in renderer
  renderer.highlight(findParticleUnderMouse());
}

void mousePressed() {
  // update selected particle reference in renderer
  renderer.select(findParticleUnderMouse());
}

void mouseDragged() {
  // update position of selected particle in renderer
  renderer.updateSelected(new Vec2D(mouseX,mouseY).sub(currOrigin));
}

void mouseReleased() {
  renderer.deselect();
}

void keyPressed() {
  // re-initialize graph
  if (key=='r') {
    graph.init();
    tree.applyVisitor(graph);
  }
  // turn labels on/off
  if (key=='l') {
    renderer.toggleLabels();
  }
  // request screenshot
  if (key==' ') {
    doSave=true;
  }
}

// these 2 functions are taken from the upcoming toxiclibs-0021 release
// where they'll be part of the Rect class...

Rect getBoundingRect(List<? extends Vec2D> points) {
  final Vec2D first = points.get(0);
  final Rect bounds = new Rect(first.x, first.y, 0, 0);
  for (int i = 1, num = points.size(); i < num; i++) {
    growToContainPoint(bounds, points.get(i));
  }
  return bounds;
}

void growToContainPoint(Rect r, ReadonlyVec2D p) {
  if (!r.containsPoint(p)) {
    if (p.x() < r.x) {
      r.width = r.getRight() - p.x();
      r.x = p.x();
    } 
    else if (p.x() > r.getRight()) {
      r.width = p.x() - r.x;
    }
    if (p.y() < r.y) {
      r.height = r.getBottom() - p.y();
      r.y = p.y();
    } 
    else if (p.y() > r.getBottom()) {
      r.height = p.y() - r.y;
    }
  }
}

