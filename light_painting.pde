
boolean debug = true;
int screenx = 1024;
int screeny = 768;
int camx = 640;
int camy = 480;  
String camname = "/dev/video1"; // to adjust, uncomment the println(Capture.list()); line below and read the names on the console.

// How different must a pixel be to be a "motion" pixel
float threshold = 50;
// How high of a color value must a pixel be to be a "draw" pixel
int highthreshold = 205; //0 = nothing, 255 = blue; // 0 = black, 765 = white
int whitethreshold = 254; //0 = nothing, 255 = blue; // 0 = black, 765 = white
int spread = 0; // width of threshold
int redspread = 80; // width of threshold
int greenspread = 0; // width of threshold
int bluespread = 40; // width of threshold
// How fast to fade out painting
int decay = 1;


import processing.video.*;
import gifAnimation.*;
// Variable for capture device
Capture video;
// Previous Frame
PImage prevFrame;
// DRAW Frame
PImage drawFrame;
// Black Frame
PImage blackFrame;

// Pixel loop variables
  int loc;
  int screenloc,screenloc2,screenloc3,screenloc4,screenloc5,screenloc6,screenloc7,screenloc8,screenloc9;
  color current;
  color previous;
  color mycolor;
  float r1, r2, g1, g2, b1, b2;
  float diff;
  float videoscalex, videoscaley;
  

//boolean sketchFullScreen() {
//  return true;
//}

void setup() {
  
  //smooth(2);
  size(screenx,screeny);
  //println(Capture.list());
  video = new Capture(this, camx, camy, camname);
  video.start();
  // Create an empty image the same size as the video
  prevFrame = createImage(video.width,video.height,RGB);
  // Create a drawing canvas the same size as the screen
  drawFrame = createImage(width,height,RGB);
  // Create a black frame to blend drawFrame with
  blackFrame = createImage(width,height,RGB);
  blackFrame.loadPixels();
  for (int i = 0; i < blackFrame.pixels.length; i++) {
    blackFrame.pixels[i] = color(255-decay, 255-decay, 255-decay);
  }
  blackFrame.updatePixels();
  
  videoscalex = float(screenx)/float(camx);
  videoscaley = float(screeny)/float(camy);
}

void draw() {
  image(drawFrame,0,0);
  drawFrame.blend(blackFrame,0,0,blackFrame.width,blackFrame.height,0,0,drawFrame.width,drawFrame.height,MULTIPLY);
  
  // Capture video
  if (video.available()) {
    // Save previous frame for motion detection!!
    prevFrame.copy(video,0,0,video.width,video.height,0,0,video.width,video.height); // Before we read the new frame, we always save the previous frame for comparison!
    prevFrame.updatePixels();
    video.read();
  }
  
  loadPixels();
  video.loadPixels();
  drawFrame.loadPixels();
  
  // Begin loop to walk through every 4th pixel
  for (int x = 0; x < video.width-1; x = x+4 ) {
    for (int y = 0; y < video.height-1; y = y+4 ) {
      
      loc = x + y*video.width;            // Step 1, what is the 1D pixel location
      current = video.pixels[loc];      // Step 2, what is the current color
      previous = prevFrame.pixels[loc]; // Step 3, what is the previous color
      
      // Step 4, compare colors (previous vs. current)
      r1 = red(current); 
      g1 = green(current); 
      b1 = blue(current);
      r2 = red(previous); 
      g2 = green(previous); 
      b2 = blue(previous);
      diff = dist(r1,g1,b1,r2,g2,b2);
      
      // Step 5, How different are the colors?
      // If the color at that pixel is bright blue, then there is a drawing tool at that pixel.
      if (b1 > highthreshold || r1 > highthreshold || g1 > highthreshold) {
        
        // show webcam onscreen (2x2 pixels wide:
        screenloc =  width-int(x*videoscalex)    + int(y*videoscaley)*width;  // translate to a location onscreen so we can see
        screenloc2 =  width-int(x*videoscalex)+1 + int(y*videoscaley)*width;  // translate to a location onscreen so we can see
        screenloc3 =  width-int(x*videoscalex)+2 + int(y*videoscaley)*width;  // translate to a location onscreen so we can see
        screenloc4 =  width-int(x*videoscalex)   + int((y*videoscaley)+1)*width;  // translate to a location onscreen so we can see
        screenloc5 =  width-int(x*videoscalex)   + int((y*videoscaley)+2)*width;  // translate to a location onscreen so we can see
        screenloc6 =  width-int(x*videoscalex)+1 + int((y*videoscaley)+1)*width;  // translate to a location onscreen so we can see
        screenloc7 =  width-int(x*videoscalex)+2 + int((y*videoscaley)+1)*width;  // translate to a location onscreen so we can see
        screenloc8 =  width-int(x*videoscalex)+1 + int((y*videoscaley)+2)*width;  // translate to a location onscreen so we can see
        screenloc9 =  width-int(x*videoscalex)+2 + int((y*videoscaley)+2)*width;  // translate to a location onscreen so we can see
        
        boolean draw = false;
        if(r1 > highthreshold && g1 < highthreshold-redspread && b1 < highthreshold-redspread){ mycolor = color(255,0,0); draw = true; } // 225, 160, 160
        if(g1 > highthreshold && r1 < highthreshold-spread && b1 < highthreshold-greenspread){ mycolor = color(0,255,0); draw = true; } // 211, 234, 120
        if(b1 > highthreshold && r1 < highthreshold-bluespread && g1 < highthreshold-spread){ mycolor = color(0,0,255); draw = true; } // 145, 239, 249
        if(b1 > whitethreshold && r1 > whitethreshold && b1 > whitethreshold){ mycolor = color(255,255,255); draw = true; }
        if(draw){
          drawFrame.pixels[screenloc] = mycolor;
          drawFrame.pixels[screenloc2] = mycolor;
          drawFrame.pixels[screenloc3] = mycolor;
          drawFrame.pixels[screenloc4] = mycolor;
          drawFrame.pixels[screenloc5] = mycolor;
          drawFrame.pixels[screenloc6] = mycolor;
          drawFrame.pixels[screenloc7] = mycolor;
          drawFrame.pixels[screenloc8] = mycolor;
          drawFrame.pixels[screenloc9] = mycolor;
        }
       
      } 
      // If the color at that pixel has changed, then there is motion at that pixel.
      else if (diff > threshold) {
        
        // show webcam onscreen (2x2 pixels wide:
        screenloc =  width-int(x*videoscalex)    + int(y*videoscaley)*width;  // translate to a location onscreen so we can see
        screenloc2 =  width-int(x*videoscalex)+2 + int(y*videoscaley)*width;  // translate to a location onscreen so we can see
        screenloc3 =  width-int(x*videoscalex)   + int((y*videoscaley)+2)*width;  // translate to a location onscreen so we can see
        screenloc4 =  width-int(x*videoscalex)+2 + int((y*videoscaley)+2)*width;  // translate to a location onscreen so we can see
        pixels[screenloc] = color(255,255,255);
        pixels[screenloc2] = color(255,0,0);
        pixels[screenloc3] = color(0,255,0);
        pixels[screenloc4] = color(0,0,255);
       
      } 
    }
  }
  
  updatePixels();
  drawFrame.updatePixels();
  
  
  if(debug){
    fill(255, 255, 255);
    text("Threshold: "+threshold,40,40);
    text("Highthreshold: "+highthreshold,40,60);
    text("Whitethreshold: "+whitethreshold,40,80);
    text("Spread: "+spread,40,100);
    text("Redspread: "+redspread,40,110);
    text("Greenspread: "+greenspread,40,120);
    text("Bluespread: "+bluespread,40,130);
  }
}

void keyPressed() {
  if (key == CODED) {
      if (keyCode == UP) {
        
      } else if (keyCode == DOWN) {
        
      } 
  }
  else if (key == 'd'){
    debug = !debug;
  }
  else if (key == 't'){
    threshold++;
  }
  else if (key == 'T'){
    threshold--;
  }
  else if (key == 'h'){
    highthreshold++;
  }
  else if (key == 'H'){
    highthreshold--;
  }
  else if (key == 'w'){
    whitethreshold++;
  }
  else if (key == 'W'){
    whitethreshold--;
  }
  else if (key == 's'){
    spread++;
  }
  else if (key == 'S'){
    spread--;
  }
  else if (key == 'r'){
    redspread++;
  }
  else if (key == 'R'){
    redspread--;
  }
  else if (key == 'g'){
    greenspread++;
  }
  else if (key == 'G'){
    greenspread--;
  }
  else if (key == 'b'){
    bluespread++;
  }
  else if (key == 'B'){
    bluespread--;
  }
}
