package vamworkshop;

import processing.core.PApplet;
import toxi.color.TColor;
import toxi.geom.mesh.Face;
import toxi.processing.ToxiclibsSupport;
import toxi.util.DateUtils;

public class MeshUnwrapApp extends PApplet {

    public static void main(String[] args) {
        PApplet.main(new String[] {
            "vamworkshop.MeshUnwrapApp"
        });
    }

    private ToxiclibsSupport gfx;
    private LatheMesh mesh;
    private DXFWriter dxf;
    private int drawMode;
    private int stripID;

    private boolean doExport;

    public void draw() {
        background(255);
        switch (drawMode) {
            case 0:
                draw3D();
                break;
            case 1:
                draw3DHSV();
                break;
            case 2:
                drawUnwrapped();
                break;
        }
    }

    /**
     * Draw mesh normally in 3D with basic cam control.
     */
    public void draw3D() {
        lights();
        translate(width / 2, height / 2, 0);
        rotateX(mouseY * 0.01f);
        rotateY(mouseX * 0.01f);
        gfx.origin(300);
        fill(255);
        noStroke();
        gfx.mesh(mesh.mesh, false, 20);
    }

    /**
     * Draw mesh in 3D with basic cam control. Faces are tinted based on their
     * position in mesh face list. Good for visualizing order of faces when
     * debugging.
     */
    public void draw3DHSV() {
        lights();
        translate(width / 2, height / 2, 0);
        rotateX(mouseY * 0.01f);
        rotateY(mouseX * 0.01f);
        gfx.origin(300);
        noStroke();
        for (int i = 0, num = mesh.mesh.getNumFaces(); i < num; i++) {
            Face f = mesh.mesh.getFaces().get(i);
            gfx.fill(TColor.newHSV(i * 1f / num, 1, 1));
            gfx.triangle(f.toTriangle());
        }
    }

    /**
     * Draw the unwrapped triangle strips and possibly export as DXF.
     */
    private void drawUnwrapped() {
        // we need to tell the DXFWriter to do some internal house keeping &
        // start a new frame
        dxf.newFrame();
        // move the currently selected strip to the mouse position
        TriangleStrip strip = mesh.strips.get(stripID);
        strip.setPosition(mouseX, mouseY);
        // draw all strips
        for (TriangleStrip s : mesh.strips) {
            s.drawUnwrapped(dxf);
        }
        // done
        dxf.endFrame();
        if (doExport) {
            dxf.save("export/mesh-" + DateUtils.timeStamp() + ".dxf");
            doExport = false;
        }
    }

    public void keyPressed() {
        if (key >= '1' && key < '1' + mesh.strips.size()) {
            stripID = key - '1';
        }
        switch (key) {
            case 'x':
                doExport = true;
                drawMode = 2;
                break;
            case 'u':
                drawMode = 2;
                break;
            case 'h':
                drawMode = 1;
                break;
            case 'd':
                drawMode = 0;
                break;
            case 'r':
                mesh.randomize(5);
                mesh.buildMesh(20);
                stripID = 0;
                break;
        }
    }

    public void setup() {
        size(1024, 768, P3D);
        gfx = new ToxiclibsSupport(this);
        // build a random LatheMesh instance
        mesh = new LatheMesh();
        mesh.buildMesh(20);
        // setup DXF
        dxf = new DXFWriter(gfx);
    }
}
