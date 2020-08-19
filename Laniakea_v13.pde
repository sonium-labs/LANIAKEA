import themidibus.*;               //Import the MIDI Bus library for MIDI communication //<>//
import ddf.minim.*;                //Import the Minim Library for sound input
import java.util.*;                //Needed for stack function

Minim minim;                       //Minim instantiation
AudioInput in;                     //Minim audio input
MidiBus triggers, encoders, keys;  //MidiBus instantiation

color[] backColors = {
  #2B2B2B,  //0:    Black
  #2B2B2B,  //1:    Black
  #2B2B2B,  //2:    Black
  #2B2B2B,  //3:    Black
  #2B2B2B,  //4:    Black
  #2B2B2B,  //5:    Black
    #2B2B2B,  //6:    Black
    #2B2B2B,  //7:    Black
    #2B2B2B,  //8:    Black
    #210938,  //9:    Dark Purple
    #34005C,  //10:    Purple
    #C545FF,  //11:   Light Purple
    #FFB3B3,  //12:    Cherry-Blossom Pink
    #F78BDB,  //13:    Pink
    #FF474D,  //14:    Tomato Soup Red
    #850B0E,  //15:    Maroonish
    #3D130C,  //16:   Desaturated Maroon
    #663C00,  //17:    Brown
    #B3562B,  //18:    Light Orange
    #FCEB8B,  //19:    Lemonade
    #7DFF66,  //20:    Spearmint Green
    #40FF95,  //21:    Mint Green
    #59B370,  //22:    Desatureated Evergreen
    #081b09,  //23:    Dark Green
    #0B2B4D,  //24:    Navy Blue
    #050873,  //25:    Dark Blue
    #003440,  //26:  
    #526CC2,  //27:    Light Blue
    #24F3FF,  //28:    Cyan
    #000000   //29:    BLACK ON BLACK
};

color[] drawColors = {
  #FFFFFF,  //0:    White
  #FFFFFF,  //1:    White
  #FFFFFF,  //2:    White
  #FFFFFF,  //3:    White
  #FFFFFF,  //4:    White
  #FFFFFF,  //5:    White
    #FFFFFF,  //6:   White
    #FF0A2B,  //7:   Cool Red
    #40FF95,  //8:   Mint Green
    #FFFFFF,  //9:   White
    #9DF78B,  //10:   Hint of Mintgreen
    #5E0985,  //11:   Waluigi Royal Purple
    #C23C3C,  //12:   Apple-Cinnamon Red
    #1B20BF,  //13:   Dark Blue
    #850B0E,  //14:    Crimson
    #FFDF0A,  //15:   Commisar Yellow
    #90D6A4,  //16:   Melting-Ice Blue
    #B3EBFF,  //17:   The lightest implication of Blue
    #FF9E70,  //18:    Dark Orange
    #5E0985,  //19:   Waluigi Royal Purple
    #04360F,  //20:    Dark Evergreen
    #04360F,  //21:    Dark Evergreen
    #C5F694,  //22:   Light Green-Yellow
    #24a148,  //23:   Light Green
    #86FA23,  //24:   Soursop Green
    #DE0000,  //25:   Bright Red
    #FFFFFF,  //26:   White
    #001866,  //27:   Navy Blue
    #660442,  //28:   Dark Purple
    #FFFFFF   //29:  White
  
};

color[] nodeColors = {
  #A017FF,  //0:    Purple
  #FF0A2B,  //1:    Cool Red 
  #15D6FF,  //2:    Cyan
  #01FF52,  //3:    Lime Green
  #FFFA00,  //4:    Electric Yellow
  #0028FF,  //5:    Dark Blue  
    #FF3DB9,  //18   
    #FFFFFF,  //14:   White
    #FF7B24,  //16:   Neon Orange
    #25C25C,  //15:   Light Green
    #F5E753,  //25:    Corn Husk Yellow
    #D1FF45,  //10:   Lemon-Lime Gatorade
    #5E0985,  //22:     Waluigi Royal Purple
    #79FB70,  //26:    Vaporwave Green
    #48FF79,  //9:    Near-Mint Green
    #FFFFFF,  //23:    White
    #DE0000,   //11:   Bright Red
    #3DB4FF,  //20:    Sky Blue
    #70FFF0,  //8:    Bright Cyan
    #FF19AD,  //12:   Magenta Red
    #B8699D,  //6:    Dark Coral-Pink
    #B0303C,  //7:    Dark Crimson
    #2D3822,  //13:   Dark Cactus Green
    #FF0A16,  //24:    Cooler Red
    #FF19AD,  //21:    Magenta Red
    #FFFFFF,  //27:    White
    #FAD01C,  //28     Lemon Yellow
    #FFCB3D,  //19:    Yellow
   #FF3DB9,  //17:   Magenta
   #FF7B24,
};


Particle[] p = new Particle[500];
float spring = 0.000001;

//Controller values
float controllerAlpha = 255;       //Alpha value determined by knob 0

//Waveform Controls
float sum, amplitude;              //Smoothing accumulators
float offset, cubeOffset;          //Counts offset for rotation of waveform

float smoothFactor = 0.5;          //Controls jumpiness of waveform lines, less is jumpier
int lineAmount = 10;               //Default is 10, LOWER = MORE LINES
int waveSize = 4;                  //Smaller is bigger

//RingHelix Controls
float piMultiply = 3;                //Determines the amount of helix components in the ring; Increase to get more twists
float ringDivisor = 3;               //Responsible for the number of rectangles spawned; 360 Degrees/RingDivisor = Number of Rectangles
float modulus = 3;

//Node Controls
float circleBound = 1000;           //Radius of pixels in which nodes will react less to input
float nodeConnection = 150;          //Determines the distance that nodes will begin to connect with each other
int innerNodeSensitivity = 5;
int outerNodeSensitivity = 10;
int clusterStrength = 3;            //Determines how much the nodes cluster together and form groups.
color nodeColor = nodeColors[0];

//Perlin noise vars (TAKE OUT IF NOT USING)
float noise, noiseT;

//Color Objects
color drawColor, backColor;
float drawHue;
float drawSat;
float drawBri;

float backHue;
float backSat;
float backBri;

float nodeHue;
float nodeSat;
float nodeBri;

//Color Logic
Deque<Integer> pitchDeque = new LinkedList<Integer>();
int pitchSelect = -99;
int brightDecMax, brightDec;
boolean brightReset;
int colorSelect;

//Lerp
boolean kickReset, snareReset, hatReset, bassReset, padReset;
boolean padOff=true;
float kickLerp, snareLerp, hatLerp, bassLerp;
float padLerp = 0;

//SETUP/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  //VISUAL SETUP
  //size(3840, 2160, P3D);
  fullScreen(P3D);
  background(0);
  smooth(8);

  //COLOR SETUP
  colorMode(HSB);               //Hue, Saturation, Brightness mode
  drawColor = drawColors[7];   
  backColor = color(0,0,0);    
  nodeColor = nodeColors[7];
  
  //AUDIO SETUP
  minim = new Minim(this);
  in = minim.getLineIn();       //Enable mic input

  //MIDI SETUP
  MidiBus.list();                                                  //List all available Midi devices on STDOUT. This will show each device's index and name.
  triggers = new MidiBus(this, "visuals", -1);                     //Create new MidiBus class with the "visuals" port as the input device, and no output
  //encoders = new MidiBus(this, "Midi Fighter Twister", "control"); //Adding MIDI Fighter Twister to project
  //keys = new MidiBus(this, "Keystation 49 MK3", -1);               //Adding MIDI keyboard to project
  
  //PARTICLE SETUP
  for(int i = 0; i < p.length; i++)
  {
    p[i] = new Particle(random(width), random(height), random(8,15));
    p[i].vx = random(-1.5, 1.5);
    p[i].vy = random(-1.5, 1.5);
  }
}

//DRAW//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void draw() {

  //background(0); //DEBUG: 
  float alpha = map(controllerAlpha, 0, 127, 50, 255);              //Read controller value from CC input
  
  //Lerp setup
  if(kickReset)
  {
    kickReset=false;
    kickLerp=1;
  }
  if(snareReset)
  {
    snareReset=false;
    snareLerp=1;
  }
  if(hatReset)
  {
    hatReset=false;
    hatLerp=1;
  }
  if(bassReset)
  {
    bassReset=false;
    bassLerp=1;
  }
  if(padReset)
  {
    padReset=false;
    padLerp=0;
  }
  
  //Lerp calculations
  kickLerp=lerp(kickLerp, 0, 0.1);
  snareLerp=lerp(snareLerp, 0, 0.05);
  hatLerp=lerp(hatLerp, 0, 0.2);
  bassLerp=lerp(bassLerp, 0, 0.05);
  
  if(!padOff){
  padLerp=lerp(padLerp, 1, 0.003);
  }
  else
  {
  if(padLerp!=0)
    {
      padLerp=padLerp-0.01;
    }
  }
  
  nodeConnection = map(padLerp,0,1,70,300);
  
  //PITCH TO COLOR
  if (pitchDeque.size()!=0) 
  {                                       //If note is still being held down...
    if(brightReset)
    {
      brightReset=false;
      brightDecMax=100;  //CAN BE MADE GLOBAL
      brightDec=0;
    }
    
    pitchSelect = pitchDeque.peek();   
    
    switch(pitchSelect)
    {
      case 37:
      colorSelect = 0;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 39:
      colorSelect = 1;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 40:
      colorSelect = 2;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 42:
      colorSelect = 29;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 44:
      colorSelect = 3;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 45:
      colorSelect = 4;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 47:
      colorSelect = 5;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 49:
      colorSelect = 6;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 51:
      colorSelect = 7;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 52:
      colorSelect = 8;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 54:
      colorSelect = 9;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 56:
      colorSelect = 10;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 57:
      colorSelect = 11;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 59:
      colorSelect = 12;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 61:
      colorSelect = 13;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 63:
      colorSelect = 14;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 64:
      colorSelect = 15;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 66:
      colorSelect = 16;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 68:
      colorSelect = 17;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 69:
      colorSelect = 18;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 71:
      colorSelect = 19;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 73:
      colorSelect = 20;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 75:
      colorSelect = 21;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;  
      
      case 76:
      colorSelect = 22;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 78:
      colorSelect = 23;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 80:
      colorSelect = 24;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 81:
      colorSelect = 25;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 82:
      colorSelect = 26;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 83:
      colorSelect = 27;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      case 85:
      colorSelect = 28;
      drawColor = drawColors[colorSelect];   
      backColor = backColors[colorSelect];    
      nodeColor = nodeColors[colorSelect];
      break;
      
      default:
      println("PITCH OUTSIDE DEFINED VALUES!");
      break;
    }
  }
  if(brightDec!=brightDecMax)
    {
      brightDec++;
     }
      
      drawHue = hue(drawColor);                 //Rip values from drawColor object
      drawSat = saturation(drawColor);
      drawBri = brightness(drawColor);

      backHue = hue(backColor);                 //Rip values from backColor object
      backSat = saturation(backColor)-brightDec;
      backBri = brightness(backColor)-brightDec;
      
      nodeHue = hue(nodeColor);
      nodeSat = saturation(nodeColor);
      nodeBri = brightness(nodeColor);
     
  drawColor = color(drawHue, drawSat, drawBri);
  backColor = color(backHue, backSat, backBri, alpha); 
  nodeColor = color(nodeHue, nodeSat, nodeBri);
  
  
  //Rectangle frame
  pushMatrix();
  fill(backColor, alpha);                     //Set fill color
  strokeWeight(kickLerp*100);           //Set line thiccness
  stroke(drawColor);      //Set stroke color
  rect(0, 0, width, height);                  //Draw rectangle
  popMatrix();
  
  //pushMatrix();
  //ellipse(width/2,height/2,height,height);
  //translate(width/2,height/2,50);
  //popMatrix();
  
  //Amplitude smoothing calculation
  amplitude = lerp(amplitude, in.mix.level()*100, 0.05);
  
  //Color control
  
  
   for(int i = 0; i < p.length; i++)
  {
    p[i].x += p[i].vx;
    p[i].y += p[i].vy;
    
    if(p[i].x < 0)
    {
      p[i].x = width;
    }
    else if(p[i].x > width)
    {
      p[i].x = 0;
    }
    
    if(p[i].y < 0)
    {
      p[i].y = height;
    }
    else if(p[i].y > height)
    {
      p[i].y = 0;
    }
    
    for(int j = i + 1; j < p.length; j++)
    {
      
       springTo(p[i], p[j]);    
       
    }
    p[i].display();
  }  
  waveform();
  
  //Cube draw
  cubes();
  ringHelix();
  
  //Rotation offset calculation
  offset += 0.002;
  
  //Perlin noise time parameter (TAKE OUT IF NOT USING)
  noiseT += .01;

  eventHorizon();
}

//NOTE ON////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Receive a noteOn and trigger events
void noteOn(int channel, int pitch, int velocity) 
{  
  //DEBUG: see all the incoming messages
  println();  
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);

  if ((channel==0)&&(pitch==60)) //Kick
  { 
    kickReset=true;
  } 
  else if ((channel==0)&&(pitch==62))//Snare
  {
    snareReset=true;
  }
  else if ((channel==0)&&(pitch==64))//Hat
  {
    hatReset=true;
  }
  else if (channel==1) //Bass note
  {
    bassReset=true;
  }
  else if (channel==3)           //Channel 3 is Push
  { 
    pitchDeque.push(pitch);
    brightReset=true;
    //drawColor = color(pitch+5, 100, 75);
    //backColor = color(pitch-5, 100, 50);
  }
  else if(channel==4)
  {
    padReset=true;
    padOff=false;
  }
}

//NOTE OFF///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void noteOff(int channel, int pitch, int velocity) 
{
  if(channel==3)
  {
    pitchDeque.remove(pitch);
  }
  else if(channel==4)
  {
  padOff=true;
  }
  //DEBUG: see all the incoming messages
  println();  
  println("Note Off");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
}

//WAVEFORM/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Draw waveform in center of image
void waveform() 
{
  for (int a=0; a<360; a+=lineAmount)          //Determines number of radial lines drawn
  {        
    //Smoothing calculation
    sum += (in.mix.level() - sum) * smoothFactor; 

    //float scaled = sum * (height/waveSize) + 
    float jitter = random(in.mix.level()*754); //TODO: adjust jitter to remove weird behavior

    //Draw lines
    pushMatrix();  
    translate(width/2, height/2);              //Set up new coordinate system
    rotate(radians(a)+offset);                 //Rotate coordinate system by current degree plus rotation offset
    strokeWeight(4+in.mix.level()*25);             //Determine stroke weight based on amplitude
    stroke(drawColor);  //Set line using drawColor, and alpha based on mic in level
    scale(2);
    line((amplitude*1.25)+40+jitter, 0, 200, (amplitude*5)+50+jitter, 0, 200); //Draw line with scaled amplitude parameter and minimum values
    popMatrix();
  }
}
//CUBES/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Draw in cubes in radial fashion
void cubes() 
{
  for (int a=0; a<360; a+=36) {

    //Smoothing calculation
    sum += (in.mix.level() - sum) * smoothFactor; 

    noFill();
    pushMatrix();  
    
    translate(width/2, height/2);          //Set up new coordinate system
    cubeOffset += snareLerp*0.004;     //Calculate additional rotational speed based on current mic in level
    rotate(-(radians(a)+offset+cubeOffset));  //Rotate coordinate system by current degree plus rotation offset and cubeOffset
    translate(width/8, 0, 200);          //Coordinate system now results in cubes being drawn
    strokeWeight(4+kickLerp*5);
    //strokeWeight(4+in.mix.level()*25);     //Determine stroke weight based on amplitude
    stroke(drawColor);                     //Set line using drawColor, and NO ALPHA based on mic in level
    
    rotateX(radians(a)+offset+snareLerp*0.5); //Rotate randomly at pace of rotation offset, with additional speed based on amplitude
    rotateY(radians(a)+offset+snareLerp*0.5);
    rotateZ(radians(a)+offset+snareLerp*0.5);
    scale(2);
    box(snareLerp*50+40);                      //Draw box with scaled amplitude parameter and minimum values
    popMatrix();
  }
}

//HELIX///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void ringHelix() 
{
  for (int a=0; a<360; a+= ringDivisor) {
    float cubeOffset2 = 0;

    noFill();
    pushMatrix();  
    
    translate(width/2, height/2);          //Set up new coordinate system
    cubeOffset2 += in.mix.level()*0.001;     //Calculate additional rotational speed based on current mic in level
    rotate(radians(a)+offset+cubeOffset2);  //Rotate coordinate system by current degree plus rotation offset and cubeOffset
    translate(width/4.5, 0, 100);          //Coordinate system now results in cubes being drawn
    strokeWeight(3+kickLerp*5);     //Determine stroke weight based on amplitude
    stroke(drawColor);                     //Set line using drawColor, and NO ALPHA based on mic in level
    
    //rotateX(radians(a)+offset+amplitude*0.3); //Rotate randomly at pace of rotation offset, with additional speed based on amplitude
    rotateY((radians(a*piMultiply)+offset+hatLerp*2));
    //rotateZ((radians(a)+offset+amplitude*0.3));
    scale(2);
    
    if(a%modulus == 0){
      
       box(hatLerp*20+90,15,90);                      //Draw box with scaled amplitude parameter and minimum values
    }
    
    box(hatLerp*5+30,15,90);                      //Draw box with scaled amplitude parameter and minimum values
    popMatrix();
  }
}

void eventHorizon()
{
  //stroke(backColor);
  pushMatrix();
  noStroke();
  fill(backColor);  
  ellipse(width/2,height/2,height,height);
  translate(width/2,height/2,50);
  sphere(height/21.6);
  popMatrix();
}

//NODES/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class Particle
{
    float x;
    float y;
    float vx;
    float vy;
    float r;
    color c = nodeColor;
    
    Particle(float _x, float _y, float _r)
    {
        x = _x;
        y = _y;
        r = _r;    
    }
    
    void display()
    {
        fill(c);
        noStroke();
        ellipse(x, y, bassLerp*40, bassLerp*40);
    }
    
    void move()
    {
      x += vx;
      y += vy;
    }
}

void springTo(Particle p1, Particle p2)
{
  p1.c = nodeColor;
  p2.c = nodeColor;
  float dx = p2.x - p1.x;
  float dy = p2.y - p1.y;
  float dist = sqrt(dx * dx + dy * dy);
  
  if(dist < nodeConnection)
  {
    float circCalc1 = sqrt(pow(p1.x-displayWidth/2,2)+pow(p1.y-displayHeight/2,2));
    float circCalc2 = sqrt(pow(p2.x-displayWidth/2,2)+pow(p2.y-displayHeight/2,2));
    
    //First part of if statement is for the inner circle boundaries
    if((circCalc1  < circleBound) && (circCalc2 < circleBound)){
      float ax = dx * spring*clusterStrength;
      float ay = dy * spring*clusterStrength;    
      p1.vx += ax;
      p1.vy += ay;
      p2.vx -= ax;
      p2.vy -= ay;
      strokeWeight((padLerp*innerNodeSensitivity)+0.5);   
      stroke(nodeColor,map(padLerp,0,1,0,255));
      line(p1.x, p1.y, p2.x, p2.y);
    } else{
      //Responsible 
      
      float ax = dx * spring*clusterStrength;
      float ay = dy * spring*clusterStrength;    
      p1.vx += ax;
      p1.vy += ay;
      p2.vx -= ax;
      p2.vy -= ay;
    
      strokeWeight((padLerp*outerNodeSensitivity)+0.5);   
      stroke(nodeColor,map(padLerp,0,1,0,255));
      line(p1.x, p1.y, p2.x, p2.y);
    }
  }
}

//CONTROLLER/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Takes in values from MIDI Fighter Twister
//void controllerChange(int channel, int number, int value) 
//{
//  println();  //DEBUG: see all the incoming messages
//  println("Controller:");
//  println("--------");
//  println("Channel:"+channel);
//  println("Number:"+number);
//  println("Value:"+value);

//  if (number==0) {
//    controllerAlpha = value; //Sets value of global variable used to control alpha levels throughout piece
//  }
//  else if(number==1)
//  {
//    nodeConnection = map(value,0,127,20,500);
//  }

//  encoders.sendControllerChange(channel, number, value); //Forward CC to Ableton
//}
