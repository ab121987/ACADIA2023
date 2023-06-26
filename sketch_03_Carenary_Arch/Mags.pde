class Magnets {



  float[][] boxPositions;
  float[] boxZPositions;

  Magnets() {
    boxPositions = new float[NUM][3];
    boxZPositions = new float[NUM];

    // calculate the positions of the boxes in a 4x4 grid
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        float x = (j) * 200;
        float y = (i) * 200;
        boxPositions[i * 4 + j] = new float[]{x, y, 0};
        // if (ManualControl == true && ShellVals == false){
        boxZPositions[i * 4 + j] = heightSliders[i] + 15;
        // } else if (ManualControl == false && ShellVals == true){
        // boxZPositions[i * 4 + j] = (10 + radiusSliders[i]); //change radius sliders to data from shell
        // }
        //boxZPositions[i * 4 + j] = random(10, 110);
        // boxZPositions[i * 4 + j] = 15;
      }
    }
  }

  void setBoxZPosition(int index, float z) {
    boxZPositions[index] = z;
  }

  void drawMags() {
    for (int i = 0; i < 16; i++) {
      pushMatrix();
      fill(100, 100, 100, 50);
      noStroke();
      translate(width/2 + boxPositions[i][0], ((height/2 - 300) + boxPositions[i][1]), heightSliders[i]+15);
      box(60, 60, 30);
      popMatrix();
    }
  }
}
