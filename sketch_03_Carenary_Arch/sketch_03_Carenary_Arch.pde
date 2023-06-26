import toxi.color.*;
import toxi.volume.*;
import toxi.processing.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.physics3d.*;
import toxi.physics3d.behaviors.*;

import java.util.List;

import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;
import processing.opengl.*;
import controlP5.*; //cp5 library
import java.util.*;
import processing.serial.*; //arduino communication library


VerletPhysics3D physics;
TriangleMesh globe;
ToxiclibsSupport gfx;
PeasyCam cam;
ControlP5 cp5;
ManSilderList m;
GUI gui;
Grid grid;
Magnets mags;

//CP5 variables and grid visualisation vars
int NUM = 16;
int cols = 4;
int rows = 4;
PFont f1;
float[] heightSliders = new float[16];
float MansliderValue = 0;
boolean ManualControl; //statement to stream live sensor data to the magnets
boolean ShellVals; //toggle to control what data to send
boolean SendVals; //toggle to control what data to send
String currentStringSliderVals; //string to send values from sliders or shell data

//catenery structure
int DIM=80;
int REST_LENGTH=10;
float STRENGTH = 0.9;

int normalLength;
boolean doUpdate=true;
boolean isWireframe=true;

List<ParticleMesh> meshes=new ArrayList<ParticleMesh>();

void setup() {
  size(1700, 900, P3D);
  smooth();
  frameRate(24);
  f1 = createFont("Helvetica", 12);//for for the write the incoming data on the sketch
  textFont(f1);

  grid = new Grid (); //4x4 magnet grid
  mags = new Magnets (); //class for 4x4 (16)grid of elipses to show magnet heights

  //Make a GUI Class. This is where all GUI related stuff happens, this keeps your sketches nice and neat.
  cp5 = new ControlP5( this ); //user interface sliders and bangs
  gui = new GUI (10, 50, this); //user interface sliders and bangs



  m = new ManSilderList( cp5, "menu", 250, 600 ); // create a custom SilderList with name menu, notice that function 
  m.setPosition(width/2 -800, height/2 - 400 ); // menu will be called when a menu item has been clicked.
  for (int i=0; i<NUM; i++) { // add some items to our SilderList
    m.addItem(makeItem("slider-"+i, 0, 1, 99 ));//set the range of the slider
  }

  ManualControl = false; //statement to stream live sensor data to the magnets
  ShellVals = false;
  SendVals = false;

  cam = new PeasyCam(this, width/2, height/2, 0, 1000);

  gfx = new ToxiclibsSupport(this);
  initPhysics();
}

void draw() {
  background(0);
  //PavilionLocation();
  m.drawGUI();
  gui.drawGUI();
  
  grid.drawGrid();
  mags.drawMags();
  buildStringSliderVals(NUM, heightSliders); //build a string from slider values

  
  //meshes.PavilionParam();
  PavilionLocation();
}

  void PavilionLocation() {
  if (doUpdate) {
    physics.update();
  }
  noStroke();
  translate(width/2 +300 , height/2 + 0, 0); // this moves the mesh but fucks everything else up

  lights();
  for (ParticleMesh m : meshes) {
    if (isWireframe) {
      stroke(m.col.toARGB());
      noFill();
    } else {
      fill(m.col.toARGB());
      noStroke();
    }
    m.buildMesh();
    gfx.mesh(m.mesh, true, normalLength);
  }
}


//CP5 slider function
// a convenience function to build a map that contains our key-value  
// pairs which we will then use to render each item of the SilderList.
Map<String, Object> makeItem(String theLabel, float theValue, float theMin, float theMax) {
  Map m = new HashMap<String, Object>();
  m.put("label", theLabel);
  m.put("sliderValue", theValue);
  m.put("sliderValueMin", theMin);
  m.put("sliderValueMax", theMax);
  return m;
}
//changes the height of the box/magnet when the sliders are moved
public void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom("menu")) {
    int index = int(theEvent.getValue());
    Map m = ((ManSilderList)theEvent.getController()).getItem(index);
    heightSliders[index] = f(m.get("sliderValue"));
  }
}

void keyPressed() {
  switch(key) {
  case ' ':
    TriangleMesh export=new TriangleMesh();
    for (ParticleMesh m : meshes) {
      export.addMesh(m.mesh);
    }
    export.saveAsSTL(sketchPath("catanary.stl"));
    break;
  case 'n':
    normalLength=(normalLength==0) ? 10 : 0;
    break;
  case 'u':
    doUpdate=!doUpdate;
    break;
  case 'v':
    saveVoxelized();
    break;
  case 'r':
    initPhysics();
    break;
  case 'w':
    isWireframe=!isWireframe;
    break;
  }
}

void initPhysics() {
  physics=new VerletPhysics3D();
  physics.addBehavior(new GravityBehavior3D(new Vec3D(0, 0, 0.5)));
  physics.setWorldBounds(new AABB(new Vec3D(0, 0, 0), 500)); // the last number is the hieght of the arch. CHALLENGE If make 100 it messes up. Need to co-ordering this the height of the actuators length      

  meshes.clear();
  ParticleMesh m1 = new ParticleMesh(DIM, REST_LENGTH, STRENGTH, TColor.CYAN);
  meshes.add(m1);  

  // pin corners of 1st mesh in space
  m1.getParticleAt(new Vec2D(0, 0)).lock(); // move these values with a CP5 Slider
  m1.getParticleAt(new Vec2D(DIM-1, 0)).lock();
  m1.getParticleAt(new Vec2D(DIM-1, DIM-1)).lock();
  m1.getParticleAt(new Vec2D(0, DIM-1)).lock();
  m1.getParticleAt(new Vec2D(DIM/2, DIM/2)).lock();
}

/*
This method will take the cp5 slider list and return a delimited
 string of the current slider values. You need to specify how many
 sliders you want to use in this method. I assume this is 16 at the moment.
 */
String getSliderString(int numSliders) {

  String s = "";

  //turn them into a string with delimiters
  for (int i = 0; i < numSliders; i++) {

    if (i < numSliders-1) {
      s+= m.getItem(i).get("sliderValue") + ";";
    } else {
      s += m.getItem(i).get("sliderValue");
    }
  }
  //return the string.
  return s;
}
