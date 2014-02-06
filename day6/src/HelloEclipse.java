import processing.core.PApplet;

/**
 * 
 *
 */
public class HelloEclipse extends PApplet {

	public static void main(String[] args) {
		PApplet.main(new String[] { "HelloEclipse" });
	}

	public void setup() {
		size(400, 400);
	}

	public void draw() {
		background(map(sin(frameCount*0.025f),-1,1,0,255));
		textAlign(CENTER);
		text("Hello World!", width / 2, height / 2);
	}
}
