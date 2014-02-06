package vamworkshop;

import processing.core.PApplet;
import processing.core.PImage;
import toxi.color.TColor;
import toxi.geom.AABB;
import toxi.geom.Vec2D;
import toxi.geom.Vec3D;
import toxi.math.MathUtils;
import toxi.processing.ToxiclibsSupport;

import com.aetrion.flickr.photos.Photo;

public class GPSPhoto {

    public Photo photo;
    public PImage jpg;

    protected Vec2D gps;

    protected Vec3D pos;
    protected Vec2D screenPos = new Vec2D();
    protected boolean isVisible;

    public GPSPhoto(Photo photo, PImage jpg) {
        this.photo = photo;
        this.jpg = jpg;
        // try to use actual flickr data
        if (photo != null && photo.hasGeoData()) {
            this.gps = new Vec2D(photo.getGeoData().getLongitude(), photo
                    .getGeoData().getLatitude());
        } else {
            setRandomLatLon();
        }
    }

    /**
     * Computes the position of the image on a sphere of the given radius.
     * 
     * @param earthRadius
     * @return position in cartesian space
     */
    public Vec3D computePosOnSphere(int earthRadius) {
        // build a spherical position from lat/lon and convert into XYZ space
        pos = new Vec3D(earthRadius, MathUtils.radians(gps.x) + MathUtils.PI,
                MathUtils.radians(gps.y)).toCartesian();
        return pos;

    }

    /**
     * Draw a box on the sphere surface.
     * 
     * @param gfx
     */
    public void drawAsBox(ToxiclibsSupport gfx) {
        // AABB = axis-aligned bounding box
        gfx.fill(TColor.newRGB(1, 0, 0));
        gfx.box(new AABB(pos, 2));
    }

    /**
     * Draws image at computed position in space.
     * 
     * @param app
     *            parent applet
     * @param size
     *            image size
     * @param showLabel
     *            true, to draw image label
     */
    public void drawAsImage(PApplet app, float size, boolean showLabel) {
        // because this GPSPhoto class has no relation to PApplet
        // we need to pass in our applet as parameter in order
        // to utilize Processing functionality
        if (isVisible) {
            app.image(jpg, screenPos.x, screenPos.y, size, size);
            if (showLabel && photo != null) {
                String label = photo.getTitle();
                Vec2D labelPos = new Vec2D(screenPos.x - size / 2, screenPos.y
                        + size / 2 + 2);
                app.fill(0, 160);
                app.rect(labelPos.x, labelPos.y, app.textWidth(label) + 4, 14);
                app.fill(255);
                app.text(label, labelPos.x + 2, labelPos.y + 11);
            }
        }
    }

    public void setRandomLatLon() {
        // random GPS location for testing
        this.gps = new Vec2D(MathUtils.random(-180, 180), MathUtils.random(-90,
                90));
        // set to london
        // this.gps = new Vec2D(0,51.1f);
    }

    public void updateScreenPos(PApplet app, Vec3D camPos) {
        screenPos.set(app.screenX(pos.x, pos.y, pos.z),
                app.screenY(pos.x, pos.y, pos.z));
        // the dot product between 2 normalized vectors is an indication
        // how closely aligned those 2 directions are
        // if the result is >0.5 then the angle between the vectors
        // is less than 90 degrees...
        // here we check the difference between (normalized) camera position
        // and the position of our image
        // we use this as a tool to hide images if they are on the
        // back side of the currently visible globe section
        // the isVisible flag is used below in drawAsImage()
        float dot = pos.getNormalized().dot(camPos);
        isVisible = dot > 0.66;
    }
}
