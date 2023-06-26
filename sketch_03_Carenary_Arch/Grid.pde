class Grid {
  
    void drawGrid() {
    //noFill();
    stroke(100);
    strokeWeight(0.7);
    rectMode(CENTER);
    pushMatrix();
    translate(width/2, height/2-300 );
    for (int i=0; i<NUM; i++) {
      pushMatrix();
      translate((i%4)*200, int(i/4)*200);//sets the grid numbers
      fill(heightSliders[i], 10 , 10);
      rect(0, 0, 200, 200);
    //  ellipse(0,0, radiusSliders[i]*2,radiusSliders[i]*2);
      popMatrix();
    }
    popMatrix();
  }
  
}
