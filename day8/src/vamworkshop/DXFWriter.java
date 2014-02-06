package vamworkshop;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.logging.Level;
import java.util.logging.Logger;

import toxi.color.ReadonlyTColor;
import toxi.geom.Line2D;
import toxi.geom.Polygon2D;
import toxi.geom.Vec2D;
import toxi.math.MathUtils;
import toxi.processing.ToxiclibsSupport;
import toxi.util.FileUtils;

/**
 * Bare bones DXF exporter only supporting line segments (and shapes
 * re-constructible from lines). Requires {@link ToxiclibsSupport} class.
 * 
 * @author Karsten Schmidt
 */
public class DXFWriter {

    protected static final Logger logger = Logger.getLogger(DXFWriter.class
            .getSimpleName());

    protected StringBuilder buf;
    protected ToxiclibsSupport gfx;
    protected Vec2D origin = new Vec2D();

    public int circleRes = 4;

    public DXFWriter(ToxiclibsSupport gfx) {
        this.gfx = gfx;
    }

    public void circle(Vec2D o, float r, int colID, ReadonlyTColor col) {
        Vec2D prev = null;
        for (int i = 0; i <= circleRes; i++) {
            Vec2D p = new Vec2D(r, i * MathUtils.TWO_PI / circleRes)
                    .toCartesian().addSelf(o);
            if (prev != null) {
                line(prev, p, colID, col);
            }
            prev = p;
        }
    }

    public void endFrame() {
        buf.append("0\nENDSEC\n0\nEOF\n");
    }

    public void line(Line2D l, int colID, ReadonlyTColor col) {
        line(l.a, l.b, colID, col);
    }

    public void line(Vec2D a, Vec2D b, int colID, ReadonlyTColor col) {
        buf.append("0\nLINE\n8\n0\n62\n");
        buf.append(colID);
        buf.append("\n");
        buf.append("10\n");
        buf.append(a.x + origin.x);
        buf.append("\n20\n");
        buf.append(a.y + origin.y);
        buf.append("\n30\n0\n11\n");
        buf.append(b.x + origin.x);
        buf.append("\n21\n");
        buf.append(b.y + origin.y);
        buf.append("\n31\n0\n");
        gfx.stroke(col);
        gfx.line(a.add(origin), b.add(origin));
    }

    public void newFrame() {
        buf = new StringBuilder();
        buf.append("0\nSECTION\n2\nENTITIES\n");
        origin.clear();
    }

    public void polygon2D(Polygon2D p, int colID, ReadonlyTColor col) {
        for (int i = 0, num = p.vertices.size(); i < num; i++) {
            line(p.vertices.get(i), p.vertices.get((i + 1) % num), colID, col);
        }
    }

    public void save(String path) {
        logger.info("saving dxf: " + path);
        PrintWriter writer = null;
        try {
            writer = FileUtils.createWriter(new File(path));
            writer.write(buf.toString());
            writer.flush();
        } catch (IOException e) {
            logger.log(Level.SEVERE, e.getMessage(), e);
        } finally {
            if (writer != null) {
                writer.close();
            }
        }
        logger.info("export done");
    }

    public void translate(Vec2D offset) {
        this.origin.set(offset);
    }
}
