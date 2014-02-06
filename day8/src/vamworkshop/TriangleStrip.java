package vamworkshop;

import java.util.LinkedList;
import java.util.List;

import toxi.color.TColor;
import toxi.geom.Line2D;
import toxi.geom.Matrix4x4;
import toxi.geom.Quaternion;
import toxi.geom.Triangle2D;
import toxi.geom.Vec2D;
import toxi.geom.Vec3D;
import toxi.geom.mesh.Face;
import toxi.geom.mesh.TriangleMesh;
import toxi.math.MathUtils;

public class TriangleStrip extends TriangleMesh {

    private final boolean hasGlueFlap = true;

    private List<Triangle2D> unwrappedFaces;

    public Vec2D offset = new Vec2D();

    protected void drawGlueFlap(DXFWriter dxf, Vec2D a, Vec2D b, Vec2D ref) {
        dxf.line(a, b, 1, TColor.RED);
        Line2D l = new Line2D(a.copy(), b.copy());
        l.offsetAndGrowBy(25, -10, ref);
        if (l.a.distanceToSquared(a) > l.b.distanceToSquared(a)) {
            Vec2D t = l.a;
            l.a = l.b;
            l.b = t;
        }
        dxf.line(l, 0, TColor.BLACK);
        dxf.line(a, l.a, 0, TColor.BLACK);
        dxf.line(b, l.b, 0, TColor.BLACK);
    }

    public void drawUnwrapped(DXFWriter dxf) {
        dxf.translate(offset);
        for (int i = 0, num = unwrappedFaces.size(); i < num; i++) {
            Triangle2D t = unwrappedFaces.get(i);
            if (0 == i % 2) {
                if (i > 0) {
                    dxf.line(t.a, t.c, 1, TColor.RED);
                } else {
                    dxf.line(t.a, t.c, 0, TColor.BLACK);
                }
                drawGlueFlap(dxf, t.a, t.b, t.computeCentroid());
            } else {
                if (i == num - 1) {
                    // final glue flap
                    drawGlueFlap(dxf, t.a, t.b, t.computeCentroid());
                }
                dxf.line(t.a, t.c, 1, TColor.RED);
                dxf.line(t.b, t.c, 0, TColor.BLACK);
                // drawGlueFlap(dxf, t.b, t.c, t.computeCentroid());
            }
        }
    }

    public void setPosition(int mouseX, int mouseY) {
        offset.set(mouseX, mouseY);
    }

    public List<Triangle2D> unwrap() {
        unwrappedFaces = new LinkedList<Triangle2D>();
        Triangle2D prev = null;
        boolean isEven = true;
        for (Face f : getFaces()) {
            Matrix4x4 mat = Quaternion.getAlignmentQuat(Vec3D.Z_AXIS, f.normal)
                    .toMatrix4x4();
            mat.translateSelf(f.getCentroid().getInverted());
            Triangle2D t = new Triangle2D(mat.applyTo(f.a).to2DXY(), mat
                    .applyTo(f.b).to2DXY(), mat.applyTo(f.c).to2DXY());
            if (prev != null) {
                Vec2D prevPoint, currPoint;
                float thetaPrevEdge, thetaCurrEdge;
                if (isEven) {
                    prevPoint = prev.a;
                    currPoint = t.a;
                    thetaCurrEdge = t.c.sub(currPoint).heading();
                    thetaPrevEdge = prev.b.sub(prevPoint).heading();
                } else {
                    prevPoint = prev.b;
                    currPoint = t.a;
                    thetaCurrEdge = t.c.sub(currPoint).heading();
                    thetaPrevEdge = prev.c.sub(prevPoint).heading();
                }
                if (thetaPrevEdge < 0) {
                    thetaPrevEdge += MathUtils.TWO_PI;
                }
                if (thetaCurrEdge < 0) {
                    thetaCurrEdge += MathUtils.TWO_PI;
                }
                float delta = thetaPrevEdge - thetaCurrEdge;
                if (isEven) {
                    t.b.rotate(delta);
                    currPoint.rotate(delta);
                    t.c.rotate(delta);
                    Vec2D offset = prevPoint.sub(currPoint);
                    currPoint.set(prevPoint);
                    t.b.addSelf(offset);
                    t.c.addSelf(offset);
                } else {
                    t.b.rotate(delta);
                    currPoint.rotate(delta);
                    t.c.rotate(delta);
                    Vec2D offset = prevPoint.sub(currPoint);
                    currPoint.set(prevPoint);
                    t.b.addSelf(offset);
                    t.c.addSelf(offset);
                }
            }
            unwrappedFaces.add(t);
            prev = t;
            isEven = !isEven;
        }
        return unwrappedFaces;
    }
}
