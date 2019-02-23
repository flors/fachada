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
//int minDepth =  100;
//int maxDepth = 950;

int maxDepth = 700;
int minDepth =  30;

//Variables para buscar el punto mas alto de la escena
int maxHeight = 700;
int maxX = -1;
int maxY = -1;

int minWidth = 700;
int minX = -1;
int minY = -1;


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
  //Cargamos los datos de la kinect
  int[] rawDepth = kinect.getRawDepth();

  /*Segun los limites definidos ponemos a blanco los pixes de la imagen que estan a la distancia que nos interesa y a negro los pixes que quedan fueran del rango definido con
   minDepth & maxDepth*/
  for (int i=0; i < rawDepth.length; i++) {
    if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
      depthImg.pixels[i] = color(255);
    } else {
      depthImg.pixels[i] = color(0);
    }
  }

  //Actualizamos la imagen con los cambios hechos
  depthImg.updatePixels();

  /*En este punto tenemos una imagen con pixels blancos y pixels negros
   Para no recorrer la imagen de pixel en pixel definimos skip que representa la cantidad de pixels que nos saltamos y no leemos*/
  int skip = 15;
  for (int x = 0; x < depthImg.width; x+= skip ) {
    for (int y = 0; y < depthImg.height; y+= skip ) {

      int index = x + y * depthImg.width;//formula para calcular el indice (en el array de pixels de la imagen) del punto XY
      float b = brightness(depthImg.pixels[index]);// obtenemos el nivel de brillo del pixel XY (sera 0 o 255)

      /*Miramos si la y actual es mas pequeña que la maxima altura definida (maxHeight) y que el brillo (b) sea 255 
       (significara que es uno de los pixels que esta en el rango de distancias que nos interesa entre minDepth & maxDepth) */
      if (y < maxHeight && b == 255 ) {

        maxHeight = y;//Actualizamos la altura maxima

        //actualizamos las coordenadas del punto mas alto
        maxX = x;
        maxY = y;
      }

      if (x < minWidth && b == 255 ) {

        minWidth = x;//Actualizamos la altura maxima

        //actualizamos las coordenadas del punto mas alto
        minX = x;
        minY = y;
      }

      /*Si en algun momento maxX y maxY estan en un pixel donde la b == 0 significara que y > maxHeight
       Por lo tanto hay que resetear el punto mas alto para que en la siguiente vuelta del draw se vuelva a realizar el calculo
       */
      if ( b == 0 && maxX== x && maxY == y) {
        maxHeight = 700;
      }

      if ( b == 0 && minX== x && minY == y) {
        minWidth = 700;
      }


      //Dibujamos punto mas alto
      fill(255, 0, 0);
      rect(maxX, maxY, skip, skip);
      rect(minX, minY, skip, skip);
      
      ellipse(minX, maxY, skip, skip);



      //Dibujamos deteccion en el rango determinado por minDepth & maxDepth
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
