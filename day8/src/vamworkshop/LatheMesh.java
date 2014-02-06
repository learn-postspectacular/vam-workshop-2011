package vamworkshop;

import java.util.ArrayList;
import java.util.List;

import toxi.geom.LineStrip2D;
import toxi.geom.Vec2D;
import toxi.geom.Vec3D;
import toxi.geom.mesh.TriangleMesh;
import toxi.math.MathUtils;
import toxi.math.noise.SimplexNoise;

/**
 * This class takes a {@link LineStrip2D} and revolves it around the Y axis to
 * construct a 3D surface. The construction is strip based and in addition to
 * the full mesh, each strip is kept individually for later use (e.g. for
 * unwrapping into 2D).
 * 
 * @author Karsten Schmidt
 * 
 */
public class LatheMesh {

    public LineStrip2D strip2D;
    public TriangleMesh mesh;
    public List<TriangleStrip> strips = new ArrayList<TriangleStrip>();

    public LatheMesh() {
        randomize(5);
    }

    public TriangleMesh buildMesh(float res) {
        mesh = new TriangleMesh();
        strips.clear();
        List<Vec3D> prev = null;
        for (int i = 0, len = strip2D.vertices.size(); i < len; i++) {
            List<Vec3D> curr = new ArrayList<Vec3D>();
            TriangleStrip currStrip = new TriangleStrip();
            for (int j = 0; j <= res; j++) {
                float amp = MathUtils.sin(j * 4 * MathUtils.TWO_PI / res) * 0.5f + 1;
                Vec3D v = strip2D.vertices.get(i).to3DXY().scale(amp)
                        .rotateY(j * MathUtils.TWO_PI / res);
                if (i > 0 && j > 0) {
                    currStrip.addFace(prev.get(j - 1), prev.get(j),
                            curr.get(j - 1));
                    currStrip.addFace(prev.get(j), v, curr.get(j - 1));
                }
                curr.add(v);
            }
            prev = curr;
            if (i > 0) {
                mesh.addMesh(currStrip);
                strips.add(currStrip);
                currStrip.unwrap();
            }
        }
        return mesh;
    }

    /**
     * Create a random {@link LineStrip2D} used as lathe shape.
     * 
     * @param numStrips
     *            number of strips to create
     */
    public void randomize(int numStrips) {
        strip2D = new LineStrip2D();
        float radius = MathUtils.random(50, 100);
        float rnd = MathUtils.random(100);
        for (int i = 0; i < numStrips; i++) {
            float gap = MathUtils.random(10, 50);
            strip2D.add(new Vec2D(radius + i * gap, (float) SimplexNoise.noise(
                    i, rnd) * 100));
        }
    }
}
