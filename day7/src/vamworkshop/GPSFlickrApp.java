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

package vamworkshop;

import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import processing.core.PApplet;
import processing.core.PImage;
import toxi.geom.Vec3D;
import toxi.geom.mesh.Mesh3D;
import toxi.geom.mesh.SphereFunction;
import toxi.geom.mesh.SurfaceMeshBuilder;
import toxi.processing.ToxiclibsSupport;

import com.aetrion.flickr.Flickr;
import com.aetrion.flickr.REST;
import com.aetrion.flickr.photos.GeoData;
import com.aetrion.flickr.photos.Photo;
import com.aetrion.flickr.photos.PhotoList;
import com.aetrion.flickr.photos.PhotosInterface;
import com.aetrion.flickr.photos.SearchParameters;

/**
 * <p>
 * This example is building on an exercise done at the V&A Computational Design
 * workshop (Feb/Mar 2011)
 * </p>
 * 
 * <p>
 * Here we demonstrate the use of the Flickrj library in conjunction with
 * toxiclibs & Processing to produce a simple mapping visualization of geotagged
 * images. The images are retrieved via several search terms (tags, time span
 * and GPS bounding box). Furthermore, the basic principle of combining 2D & 3D
 * coordinate systems and visibility checking of objects is shown too.
 * </p>
 * 
 * <p>
 * IMPORTANT NOTE: Before running this example, please put your Flickr API key
 * into the FLICKR_API_KEY constant.
 * </p>
 * 
 * <p>
 * Usage:
 * <ul>
 * <li>Move mouse to rotate view</li>
 * <li>Press '-' / '=' to adjust zoom</li>
 * </ul>
 * </p>
 */
@SuppressWarnings("serial")
public class GPSFlickrApp extends PApplet {

    /**
     * Max number of images to request from flickr
     */
    private static final int MAX_IMAGES = 50;

    /**
     * Number of milliseconds per day
     */
    private static final int DAY_DURATION = 24 * 60 * 60 * 1000;

    /**
     * Radius of our globe
     */
    private static final int EARTH_RADIUS = 300;

    /**
     * Image size in pixels for rendering
     */
    private static final int IMG_SIZE = 32;

    /**
     * Flickr API key
     */
    private static final String FLICKR_API_KEY = "put your API key in here";

    /**
     * Main entry point to run as application
     */
    public static void main(String[] args) {
        PApplet.main(new String[] {
            "vamworkshop.GPSFlickrApp"
        });
    }

    /**
     * List of geotagged images
     */
    List<GPSPhoto> images = new LinkedList<GPSPhoto>();

    /**
     * Earth texture image
     */
    private PImage earthTex;

    /**
     * Globe mesh
     */
    private Mesh3D globe;

    /**
     * Toxiclibs helper class for rendering
     */
    private ToxiclibsSupport gfx;

    /**
     * Camera rotation vector
     */
    private final Vec3D camRot = new Vec3D();

    /**
     * Zoom factors
     */
    private float currZoom = 1;
    private float targetZoom = 1;

    /**
     * Render flag to show/hide labels
     */
    private boolean showLabels = true;

    public void draw() {
        // smoothly interpolate camera rotation
        // to new rotation vector based on mouse position
        // each frame we only approach that rotation by 25% (0.25 value)
        camRot.interpolateToSelf(new Vec3D(mouseY * 0.01f, mouseX * 0.01f, 0),
                0.25f / currZoom);
        // smoothly update zoom as well
        currZoom += (targetZoom - currZoom) * 0.25;
        background(0);
        lights();
        // store default 2D coordinate system
        pushMatrix();
        // switch to 3D coordinate system and rotate view based on mouse
        translate(width / 2, height / 2, 0);
        rotateX(camRot.x);
        rotateY(camRot.y);
        // apply zoom factor
        scale(currZoom);
        // compute the normalized camera position/direction
        // using the same rotation setting as for the coordinate system
        // this vector is used to figure out if images are visible or not
        // (see below)
        Vec3D camPos = new Vec3D(0, 0, 1).rotateX(camRot.x).rotateY(camRot.y);
        camPos.normalize();
        noStroke();
        fill(255);
        // use normalized UV texture coordinates (range 0.0 ... 1.0)
        textureMode(NORMAL);
        // draw earth
        gfx.texturedMesh(globe, earthTex, true);
        for (GPSPhoto img : images) {
            // img.drawAsBox(gfx);
            // compute 2D screen position and check visibility
            img.updateScreenPos(this, camPos);
        }
        // switch back to 2D coordinate system
        popMatrix();
        // disable depth testing to ensure anything drawn next
        // will always be on top/infront of the globe
        hint(DISABLE_DEPTH_TEST);
        // draw images centred around the given positions
        imageMode(CENTER);
        for (GPSPhoto img : images) {
            img.drawAsImage(this, IMG_SIZE * currZoom * 0.9f, showLabels);
        }
        // restore (default) depth testing
        hint(ENABLE_DEPTH_TEST);
    }

    /**
     * Create dummy images
     */
    void dummyImages(int num) {
        for (int i = 0; i < num; i++) {
            GPSPhoto gps = new GPSPhoto(null, loadImage("toxi.jpg"));
            gps.setRandomLatLon();
            gps.computePosOnSphere(EARTH_RADIUS);
            images.add(gps);
        }
    }

    /**
     * Loads geotagged images from Flickr using a tag search and time span.
     * 
     * @param tags
     */
    void initFlickr(String[] tags, int maxImages, long timeSpan) {
        try {
            // authenticate with flickr web service
            Flickr flickr = new Flickr(FLICKR_API_KEY, new REST());
            // get photo related component
            PhotosInterface photos = flickr.getPhotosInterface();
            // build search query
            SearchParameters params = new SearchParameters();
            params.setTags(tags);
            params.setTagMode("all");
            // define SE & NE corner of Lat/Lon bounding rect
            // here spanning the entire globe
            params.setBBox("-180", "-90", "180", "90");
            // accept any level of GPS accuracy (1=world, 16=street)
            params.setAccuracy(1);
            // only request images from last week
            // the Date class allows us to do time calculations
            // getTime() returns the unix epoch time, the number of milliseconds
            // since 01/01/1970
            long now = new Date().getTime();
            Date since = new Date(now - timeSpan);
            params.setMinUploadDate(since);
            // pass search params to actually execute
            PhotoList results = photos.search(params, maxImages, 1);
            println(results.size() + " images loaded");
            for (Object r : results) {
                Photo photo = (Photo) r;
                // this was the important function call I missed on Tuesday
                // night
                // without requesting photo info we never got at the GPS data
                photo = photos.getInfo(photo.getId(), photo.getSecret());
                if (photo.hasGeoData()) {
                    GeoData geo = photo.getGeoData();
                    println("photo @ " + geo.getLatitude() + ", "
                            + geo.getLongitude());
                    String url = photo.getSmallSquareUrl();
                    println("loading: " + url);
                    PImage jpg = loadImage(url);
                    // create a pairing of flickr photo metadata & jpg
                    GPSPhoto gps = new GPSPhoto(photo, jpg);
                    // pre-compute position on globe surface from GPS coords
                    gps.computePosOnSphere(EARTH_RADIUS);
                    // add to list
                    images.add(gps);
                    // wait a bit between each request
                    // since our thread might get interrupted due to external
                    // reasons
                    // we need to catch potential errors (but ignore them for
                    // now)
                    try {
                        Thread.sleep(5);
                    } catch (InterruptedException e) {
                    }
                } else {
                    println("skipping image, no gps...");
                }
            }
        } catch (Exception e) {
            println("error connecting to flickr...");
            e.printStackTrace();
        }
    }

    public void keyPressed() {
        if (key == '-') {
            targetZoom = max(targetZoom - 0.1f, 0.5f);
        }
        if (key == '=') {
            targetZoom = min(targetZoom + 0.1f, 1.9f);
        }
        if (key == 'l') {
            showLabels = !showLabels;
        }
    }

    public void setup() {
        size(1024, 768, OPENGL);

        // load tagged images from flickr uploaded in the past x days...
        initFlickr(new String[] {
            "color"
        }, MAX_IMAGES, 7 * DAY_DURATION);
        // ...or create dummy images (in case there's no flickr available)
        // dummyImages(50);

        // load earth texture image
        earthTex = loadImage("earth_4096.jpg");

        // build a sphere mesh with texture coordinates
        // sphere resolution set to 36 vertices
        globe = new SurfaceMeshBuilder(new SphereFunction()).createMesh(null,
                36, EARTH_RADIUS);
        // compute surface orientation vectors for each mesh vertex
        // this is important for lighting calculations when rendering the mesh
        globe.computeVertexNormals();

        // setup helper class (assign to work with this applet)
        gfx = new ToxiclibsSupport(this);

        textFont(createFont("SansSerif", 10));
    }
}