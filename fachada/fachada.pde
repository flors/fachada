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
int skip = 15;

// Which pixels do we care about?
//int minDepth =  100;
//int maxDepth = 950;

int maxDepth = 700;
int minDepth =  30;

//Variables para buscar el punto mas alto de la escena
int minHeight = 700;
int minH_x = -1;
int minH_y = -1;

int maxHeight = 0;
int maxH_x = -1;
int maxH_y = -1;

int minWidth = 700;
int minW_x = -1;
int minW_y = -1;

int maxWidth = 0;
int maxW_x = -1;
int maxW_y = -1;



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
  
  for (int x = 0; x < depthImg.width; x+= skip ) {
    for (int y = 0; y < depthImg.height; y+= skip ) {

      int index = x + y * depthImg.width;//formula para calcular el indice (en el array de pixels de la imagen) del punto XY
      float b = brightness(depthImg.pixels[index]);// obtenemos el nivel de brillo del pixel XY (sera 0 o 255)

      /*Miramos si la y actual es mas pequeña que la maxima altura definida (maxHeight) y que el brillo (b) sea 255 
       (significara que es uno de los pixels que esta en el rango de distancias que nos interesa entre minDepth & maxDepth) */
      if (y < minHeight && b == 255 ) {

        minHeight = y;//Actualizamos la altura maxima

        //actualizamos las coordenadas del punto mas alto
        minH_x = x;
        minH_y = y;
      }

      if (y > maxHeight && b == 255 ) {

        maxHeight = y;//Actualizamos la altura maxima

        //actualizamos las coordenadas del punto mas alto
        maxH_x = x;
        maxH_y = y;
      }

      if (x < minWidth && b == 255 ) {

        minWidth = x;//Actualizamos la altura maxima

        //actualizamos las coordenadas del punto mas a la izquierda de la pantalla
        minW_x = x;
        minW_y = y;
      }

      if (x > maxWidth && b == 255 ) {

        maxWidth = x;//Actualizamos la altura maxima

        //actualizamos las coordenadas del punto mas alto
        maxW_x = x;
        maxW_y = y;
      }




      /*Si en algun momento maxX y maxY estan en un pixel donde la b == 0 significara que y > maxHeight
       Por lo tanto hay que resetear el punto mas alto para que en la siguiente vuelta del draw se vuelva a realizar el calculo
       */
      if ( b == 0 && minH_x == x && minH_y == y) {
        minHeight = 700;
      }

      if ( b == 0 && minW_x == x && minW_y == y) {
        minWidth = 700;
      }

      if ( b == 0 && maxH_x == x && maxH_y == y) {
        maxHeight = -90;
      }

      if ( b == 0 && maxW_x == x && maxW_y == y) {
        maxWidth = -90;
      }


      //Dibujamos punto mas alto
      fill(255, 0, 0);
      rect(minH_x, minH_y, skip, skip);
      rect(minW_x, minW_y, skip, skip);

      fill(0, 255, 0);
      rect(maxW_x, maxW_y, skip, skip);
      rect(maxH_x, maxH_y, skip, skip);

      stroke(255);
      noFill();
    
      
      rectMode(CORNERS);
      rect(minW_x, minH_y, maxW_x , maxH_y );




      //Dibujamos deteccion en el rango determinado por minDepth & maxDepth
      fill(b);
      noStroke();
      rectMode(CORNER);
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
