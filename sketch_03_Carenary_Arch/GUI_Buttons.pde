CheckBox checkbox;
ControlTimer c;
Textlabel t;
Textarea myTextarea;

CheckBox c1, c2, c3; //c1 and c2 for turning on, c3 for switching off


class GUI {

  int xPos, yPos;

  public GUI(int originX, int originY, PApplet p5) {

    //You can change the position of the GUI by changing these values in the main class. 
    xPos = originX;
    yPos = originY;
    cp5 = new ControlP5(p5);
    //Method to generate all GUI elements. 
    generateGUI();
  }

  void generateGUI() {
    //Add bangs - I have used "bangs" here because they seem to work and are simplier than checkboxes. 

    cp5.addToggle("ShellDataToggle")
      .setPosition(width/2 - 520, height/2-400)
      .setSize(50, 20)
      .setValue(true)
      .setLabel ("Shell Data")
      .setMode(ControlP5.SWITCH);

    cp5.addToggle("ManualControlToggle")//manual
      .setPosition(width/2 - 520, height/2-350)
      .setSize(50, 20)
      .setValue(true)
      .setLabel ("Manual Control")
      .setMode(ControlP5.SWITCH);

    cp5.addToggle("SendValuesToggle")//manual
      .setPosition(width/2 - 520, height/2-300)
      .setSize(50, 20)
      .setValue(true)
      .setLabel ("Send Values")
      .setMode(ControlP5.SWITCH);

    cp5.addBang("UpdateMags")
      .setPosition(width/2 - 520, height/2-250)
      .setSize(50, 30)
      .setTriggerEvent(Bang.PRESS)
      .setLabel("Manually Update Pos.")
      .setLabelVisible(true);
  }

  void drawGUI() {
    if (cp5.isMouseOver()) { //This bit stops it peasycam from rotating when using sliders
      cam.setActive(false);
    } else {
      cam.setActive(true);
    }
    hint(DISABLE_DEPTH_TEST); //Centres around the object
    cam.beginHUD();
    cp5.draw();
    cam.endHUD();
    hint(ENABLE_DEPTH_TEST);
  }
}

//These are located outside of the GUI "class" but I have left them in the tab to make it neater.
//These methods are pressed when the buttons are pressed. 


//toggle to control the sliders
public void ManualControlToggle(boolean theFlag) {
  if (theFlag==true) {
    ManualControl = false;// boolean statement to send a char at end of value string to switch on or off heating matt
  } else {
    ManualControl = true;
  }
}

public void SendValuesToggle(boolean theFlag) {
  if (theFlag==true) {
    SendVals = false;// boolean statement to send a char at end of value string to switch on or off heating matt
  } else {
    SendVals = true;
  }
}

public void ShellDataToggle(boolean theFlag) {
  if (theFlag==true) {
    ShellVals = false;// boolean statement to send a char at end of value string to switch on or off heating matt
  } else {
    ShellVals = true;
  }
}

//BANG envents
public void UpdateMags() {//when bang is clicked send the slider values to the magnets
  //ManualControl = true;
  //if (ManualControl == true && ShellVals == false && SendVals == true) {
  println(currentStringSliderVals + '\n');
  // myPort.write(currentStringSliderVals + '\n');
  // } else if (ManualControl == false && ShellVals == true && SendVals == true) {
  // println("VALUES GENERATED FROM SHELL DATA"+ '\n');
  // myPort.write(currentStringSliderVals + '\n');
  // }
}



//build a string from slider values and the number in the array of that slider. Also, set the decimal accuray
void buildStringSliderVals(int arraySize, float[] arr) {
  currentStringSliderVals = "";
  for (int i = 0; i < arraySize; i++) { 
    float x = arr[i];
    String s = nf(x, 0, 1);//set the decimal accuracy
    currentStringSliderVals += (i+1) + "," + s + ";"; //
  }
}
