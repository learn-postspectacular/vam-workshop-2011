import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;

import com.aetrion.flickr.Flickr;
import com.aetrion.flickr.FlickrException;
import com.aetrion.flickr.REST;
import com.aetrion.flickr.Transport;
import com.aetrion.flickr.photos.Photo;
import com.aetrion.flickr.photos.PhotoList;
import com.aetrion.flickr.photos.PhotosInterface;
import com.aetrion.flickr.photos.SearchParameters;

import processing.core.PApplet;
import processing.core.PImage;

public class HelloFlickr extends PApplet {

	public static void main(String[] args) {
		PApplet.main(new String[] { "HelloFlickr" });
	}

	List<PImage> results = new LinkedList<PImage>();

	public void setup() {
		size(800, 600);
		initFlickr();
	}

	private void initFlickr() {
		try {
			// authenticate with flickr web service
			Flickr flickr = new Flickr("93d754995a4481a6cafd4b170c3f9be5",
					new REST());
			// get photo related component
			PhotosInterface photos = flickr.getPhotosInterface();
			// build search query
			SearchParameters params = new SearchParameters();
			String[] tags = new String[] { "v&a", "london" };
			params.setTags(tags);
			params.setTagMode("all");
			// pass search params to actually execute
			PhotoList images = photos.search(params, 10, 1);
			println(images.size() + " images loaded");
			for (Object img : images) {
				Photo photo = (Photo) img;
				String url = photo.getSmallSquareUrl();
				// String url = photo.getSmallUrl();
				println("loading: " + url);
				PImage jpg = loadImage(url);
				results.add(jpg);
				try {
					Thread.sleep(1000);
				} catch (InterruptedException e) {
				}
			}
		} catch (ParserConfigurationException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (FlickrException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void draw() {
		background(0);
		int x = 0;
		int y = 0;
		for (PImage img : results) {
			image(img, x, y);
			x += img.width;
			if (x > width - img.width) {
				x = 0;
				y += img.height;
			}
		}
	}
}
