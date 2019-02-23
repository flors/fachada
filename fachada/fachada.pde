// Daniel Shiffman //<>//
// Depth thresholding example

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

// Original example by Elie Zananiri
// http://www.silentlycrashing.net

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Kinect kinect;

// Depth image
PImage depthImg;

// Which pixels do we care about?
int minDepth =  100;
int maxDepth = 950;
int maxHeight = height;
int dx = 0;
int dy = 0;


//highest point

//int maxHeight = 50000;


// What is the kinect's angle
float angle;

void setup() {
  size(640, 480);

  kinect = new Kinect(this);
  kinect.initDepth();
  angle = kinect.getTilt();

  // Blank image
  depthImg = new PImage(kinect.width, kinect.height);
  println(kinect.width, kinect.height);
}

void draw() {

  //<.

  int[] rawDepth = kinect.getRawDepth();
  for (int i=0; i < rawDepth.length; i++) {


    if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
      depthImg.pixels[i] = color(255);
    } else {
      depthImg.pixels[i] = color(0);
    }
  }

  depthImg.updatePixels();




  int skip = 15;
  for (int x = 0; x < depthImg.width; x+= skip ) {
    for (int y = 0; y < depthImg.height; y+= skip ) {
      int index = x + y * depthImg.width;


      float b = brightness(depthImg.pixels[index]);

      int d = y; 
      if (d < maxHeight) {
        println("hello");
        maxHeight = d;

        dx = x;
        dy = y;
      }


      fill(255, 0, 0);
      ellipse(dx, dy, 30, 30);



      fill(b);
      rect(x, y, skip, skip);
    }
  }
}



// Adjust the angle and the depth threshold min and max
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      angle++;
    } else if (keyCode == DOWN) {
      angle--;
    }
    angle = constrain(angle, 0, 30);
    kinect.setTilt(angle);
  } else if (key == 'a') {
    minDepth = constrain(minDepth+10, 0, maxDepth);
  } else if (key == 's') {
    minDepth = constrain(minDepth-10, 0, maxDepth);
  } else if (key == 'z') {
    maxDepth = constrain(maxDepth+10, minDepth, 2047);
  } else if (key =='x') {
    maxDepth = constrain(maxDepth-10, minDepth, 2047);
  }
}
