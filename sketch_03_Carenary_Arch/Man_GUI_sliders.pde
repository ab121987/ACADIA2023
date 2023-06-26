//nothing really needs changed in here as it is just for the sliders  

class ManSilderList extends Controller<ManSilderList> {

  float pos, npos;
  int itemHeight = 60;
  int scrollerLength = 40;
  int sliderWidth = 150;
  int sliderHeight = 15;
  int sliderX = 10;
  int sliderY = 25;

  int dragMode = 0;
  int dragIndex = -1;

  List< Map<String, Object>> items = new ArrayList< Map<String, Object>>();
  PGraphics menu;
  boolean updateMenu;

  ManSilderList(ControlP5 c, String theName, int theWidth, int theHeight) {
    super( c, theName, 0, 0, theWidth, theHeight );
    c.register( this );
    menu = createGraphics(getWidth(), getHeight());

    setView(new ControllerView<ManSilderList>() {

      public void display(PGraphics pg, ManSilderList t ) {
        if (updateMenu) {
          updateMenu();
        }
        if (inside() ) { // draw scrollbar
          menu.beginDraw();
          int len = -(itemHeight * items.size()) + getHeight();
          int ty = int(map(pos, len, 0, getHeight() - scrollerLength - 2, 2 ) );
          menu.fill( 100 );
          menu.rect(getWidth()-6, ty, 4, scrollerLength );
          menu.endDraw();
        }
        pg.image(menu, 0, 0);
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
    );
    updateMenu();
    
    //cp5.setAutoDraw(false);
    
    //if (cp5.isMouseOver()) { //This bit stops it peasycam from rotating when using sliders
    //  cam.setActive(false);
    //} else {
    //  cam.setActive(true);
    //}
    //hint(DISABLE_DEPTH_TEST); //Centres around the object
    //cam.beginHUD();
    //cp5.draw();
    //cam.endHUD();
    //hint(ENABLE_DEPTH_TEST);
  }

  // only update the image buffer when necessary - to save some resources
  void updateMenu() {
    int len = -(itemHeight * items.size()) + getHeight();
    npos = constrain(npos, len, 0);
    pos += (npos - pos) * 0.1;

    /// draw the SliderList
    menu.beginDraw();
    menu.noStroke();
    menu.background(100);
    menu.textFont(cp5.getFont().getFont());
    menu.pushMatrix();
    menu.translate( 0, int(pos) );
    menu.pushMatrix();

    int i0 = PApplet.max( 0, int(map(-pos, 0, itemHeight * items.size(), 0, items.size())));
    int range = ceil((float(getHeight())/float(itemHeight))+1);
    int i1 = PApplet.min( items.size(), i0 + range );

    menu.translate(0, i0*itemHeight);

    for (int i=i0; i<i1; i++) {
      Map m = items.get(i);
      menu.noStroke();
      menu.fill(200);
      menu.rect(0, itemHeight-1, getWidth(), 1 );
      menu.fill(150);
      // uncomment the following line to use a different font than the default controlP5 font
      menu.textFont(f1); 
      String txt = String.format("%s   %.2f", m.get("label").toString().toUpperCase(), f(items.get(i).get("sliderValue")));//slider text on screen 
      menu.text(txt, 10, 20 );
      menu.fill(255);
      menu.rect(sliderX, sliderY, sliderWidth, sliderHeight);
      menu.fill(10, 10, 150);//slider colour
      float min = f(items.get(i).get("sliderValueMin"));
      float max = f(items.get(i).get("sliderValueMax"));
      float val = f(items.get(i).get("sliderValue"));
      menu.rect(sliderX, sliderY, map(val, min, max, 0, sliderWidth), sliderHeight);
      menu.translate( 0, itemHeight );
    }
    menu.popMatrix();
    menu.popMatrix();
    menu.endDraw();
    updateMenu = abs(npos-pos)>0.01 ? true:false;

    //if (cp5.isMouseOver()) { //This bit stops it peasycam from rotating when using sliders
    //  cam.setActive(false);
    //} else {
    //  cam.setActive(true);
    //}
    //hint(DISABLE_DEPTH_TEST); //Centres around the object
    //cam.beginHUD();
    //cp5.draw();
    //cam.endHUD();
    //hint(ENABLE_DEPTH_TEST);
  }

  // when detecting a click, check if the click happend to the far right,  
  // if yes, scroll to that position, otherwise do whatever this item of 
  // the list is supposed to do.
  public void onClick() {
    if (getPointer().x()>getWidth()-10) {
      npos= -map(getPointer().y(), 0, getHeight(), 0, items.size()*itemHeight);
      updateMenu = true;

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


  public void onPress() {
    int x = getPointer().x();
    int y = (int)(getPointer().y()-pos)%itemHeight;
    boolean withinSlider = within(x, y, sliderX, sliderY, sliderWidth, sliderHeight); 
    dragMode =  withinSlider ? 2:1;
    if (dragMode==2) {
      dragIndex = getIndex();
      float min = f(items.get(dragIndex).get("sliderValueMin"));
      float max = f(items.get(dragIndex).get("sliderValueMax"));
      float val = constrain(map(getPointer().x()-sliderX, 0, sliderWidth, min, max), min, max);
      items.get(dragIndex).put("sliderValue", val);
      setValue(dragIndex);
    }
    updateMenu = true;
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

  public void onDrag() {
    switch(dragMode) {
      case(1): // drag and scroll the list
      npos += getPointer().dy() * 2;
      updateMenu = true;
      break;
      case(2): // drag slider
      float min = f(items.get(dragIndex).get("sliderValueMin"));
      float max = f(items.get(dragIndex).get("sliderValueMax"));
      float val = constrain(map(getPointer().x()-sliderX, 0, sliderWidth, min, max), min, max);
      items.get(dragIndex).put("sliderValue", val);
      setValue(dragIndex);
      updateMenu = true;
      break;
    }
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

  public void onScroll(int n) {
    npos += ( n * 4 );
    updateMenu = true;
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

  void addItem(Map<String, Object> m) {
    items.add(m);
    updateMenu = true;
  }

  Map<String, Object> getItem(int theIndex) {
    return items.get(theIndex);
  }

  private int getIndex() {
    int len = itemHeight * items.size();
    int index = int( map( getPointer().y() - pos, 0, len, 0, items.size() ) ) ;
    return index;
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

public static float f( Object o ) {
  return ( o instanceof Number ) ? ( ( Number ) o ).floatValue( ) : Float.MIN_VALUE;
}

public static boolean within(int theX, int theY, int theX1, int theY1, int theW1, int theH1) {
  return (theX>theX1 && theX<theX1+theW1 && theY>theY1 && theY<theY1+theH1);
}



/*import controlP5.*;
 ControlP5 cp5;
 
 CheckBox checkbox;
 
 Slider Dia, NumX, NumY, Loc, Col, Texture, Comp, Timer, On;
 
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
 
 //Add sliders and buttons.
 void generateGUI() {
 
 Dia = cp5.addSlider("Diameter")
 //.setScrollSensitivity(10)
 //.setSensitivity(1)
 //.setSliderMode(Slider.FLEXIBLE) or .setSliderMode(Slider.FIX)
 .setPosition(xPos + 25, yPos+150)
 .setSize(20, 500)
 //.showTickMarks(true)
 //.setNumberOfTickMarks (200)
 //.snapToTickMarks(true)
 .setRange(1, 50)
 .setDecimalPrecision(0)
 .setValue(10);
 
 NumX = cp5.addSlider("Number X")
 .setScrollSensitivity(10)
 .setSensitivity(1)
 .setPosition(xPos + 75, yPos+150)
 .setSize(20, 500)
 .showTickMarks(true)
 .setNumberOfTickMarks (21)
 .snapToTickMarks(true)
 .setRange(0, 20)
 .setDecimalPrecision(0)
 .setValue(1);
 
 NumY = cp5.addSlider("Number Y")
 .setScrollSensitivity(10)
 .setSensitivity(1)
 .setPosition(xPos + 125, yPos+150)
 .setSize(20, 500)
 .showTickMarks(true)
 .setNumberOfTickMarks (21)
 .snapToTickMarks(true)
 .setRange(0, 20)
 .setDecimalPrecision(0)
 .setValue(1);
 
 Loc = cp5.addSlider("Location") // Random placement within 3D space
 .setScrollSensitivity(10)
 .setSensitivity(1)
 .setPosition(xPos + 175, yPos+150)
 .setSize(20, 500)
 .showTickMarks(true)
 .setNumberOfTickMarks (21)
 .snapToTickMarks(true)
 .setRange(0, 20)
 .setDecimalPrecision(0)
 .setValue(1);
 
 Col = cp5.addSlider("Colour")
 .setPosition(xPos + 225, yPos+150)
 .setSize(20, 500)
 //.showTickMarks(true)
 //.setNumberOfTickMarks (253)
 //.snapToTickMarks(true)
 .setRange(0, 254)
 .setDecimalPrecision(0)
 .setValue(0);
 
 Texture = cp5.addSlider("Texure") //Noise value generator for sphere texture map
 .setPosition(xPos + 275, yPos+150)
 .setSize(20, 500)
 .setRange(0, 255)
 .setDecimalPrecision(0)
 .setValue(0);
 
 Comp = cp5.addSlider("Composition") //Colour values to have gradient surface colours
 .setPosition(xPos + 325, yPos+150)
 .setSize(20, 500)
 .setRange(0, 255)
 .setDecimalPrecision(0)
 .setValue(0);
 ;    
 cp5.setAutoDraw(false);
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
 
 float getDia() {
 return int(Dia.getValue());
 }
 float getNumX() {
 return int(NumX.getValue()); // Cast to an int
 }
 float getNumY() {
 return NumY.getValue();
 }
 float getLoc() {
 return Loc.getValue();
 } 
 float getTexture() {
 return Texture.getValue();
 } 
 float getCol() {
 return Col.getValue();
 }
 float getComp() {
 return Comp.getValue();
 }
 } */
