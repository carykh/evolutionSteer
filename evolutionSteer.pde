final float windowSizeMultiplier = 1.4;
final int SEED = 31; //7;  ;(

PFont font;
ArrayList<Float[]> percentile = new ArrayList<Float[]>(0);
ArrayList<Integer[]> barCounts = new ArrayList<Integer[]>(0);
ArrayList<Integer[]> speciesCounts = new ArrayList<Integer[]>(0);
ArrayList<Integer> topSpeciesCounts = new ArrayList<Integer>(0);
ArrayList<Creature> creatureDatabase = new ArrayList<Creature>(0);
ArrayList<Rectangle> rects = new ArrayList<Rectangle>(0);
Creature currentCreature;
PGraphics simulationImage;
PGraphics graphImage;
PGraphics screenImage;
PGraphics popUpImage;
PGraphics segBarImage;
boolean haveGround = true;
int histBarsPerMeter = 5;
String fitnessUnit = "chomps";
String fitnessName = "Chomps";
float baselineEnergy = 0.0;
int energyDirection = 1; // if 1, it'll count up how much energy is used.  if -1, it'll count down from the baseline energy, and when energy hits 0, the creature dies.
final float FRICTION = 4;
float bigMutationChance = 0.03;
float hazelStairs = -1;
float cumulativeAngularVelocity = 0;
boolean saveFramesPerGeneration = true;
color gridBGColor = color(220, 253, 102, 255);
float foodAngleChange = 0.0;
float foodX = 0;
float foodY = 0;
float foodZ = 0;
float foodAngle = 0;
int chomps = 0;

int lastImageSaved = -1;
float pressureUnit = 500.0/2.37;
float energyUnit = 20;
float nauseaUnit = 5;
int minBar = -10;
int maxBar = 100;
int barLen = maxBar-minBar;
int gensToDo = 0;
float postFontSize = 0.96;
float scaleToFixBug = 1000;
float energy = 0;
float averageNodeNausea = 0;
float totalNodeNausea = 0;
float CAMERA_MOVE_SPEED = 0.03;

float lineY1 = -0.08; // These are for the lines of text on each node.
float lineY2 = 0.35;

int windowWidth = 1280;
int windowHeight = 720;
int timer = 0;
float camX = 0;
float camY = 0;
float camZ = 0;
float camHA = 0;
float camVA = -0.5;
int frames = 60;
int menu = 0;
int gen = -1;
float sliderX = 1170;
int genSelected = 0;
boolean drag = false;
boolean justGotBack = false;
int creatures = 0;
int creaturesTested = 0;
int fontSize = 0;
int[] fontSizes = {
  50, 36, 25, 20, 16, 14, 11, 9
};
int statusWindow = -4;
int prevStatusWindow = -4;
int overallTimer = 0;
boolean miniSimulation = false;
int creatureWatching = 0;
int simulationTimer = 0;
int[] creaturesInPosition = new int[1000];

float camZoom = 0.015;
float gravity = 0.006;//0.007;
float airFriction = 0.95;
float MIN_FOOD_DISTANCE = 1;
float MAX_FOOD_DISTANCE = 2.5;

float target;
float force;
float averageX;
float averageY;
float averageZ;
int speed;
boolean stepbystep;
boolean stepbystepslow;
boolean slowDies;
int[] p = {
  0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 
  100, 200, 300, 400, 500, 600, 700, 800, 900, 910, 920, 930, 940, 950, 960, 970, 980, 990, 999
};
final int BRAIN_WIDTH = 3;
float STARTING_AXON_VARIABILITY = 1.0;
float AXON_START_MUTABILITY = 0.0005;
String[] patronData;
int PATRON_COUNT = 75;
float TOTAL_PLEDGED = 183.39;
int[] CREATURES_PER_PATRON = new int[PATRON_COUNT];
float startingFoodDistance = 0;

float inter(int a, int b, float offset) {
  return float(a)+(float(b)-float(a))*offset;
}
float r() {
  return pow(random(-1, 1), 19);
}
int rInt() {
  return int(random(-0.01, 1.01));
}
void drawGround(PGraphics img) {
  int stairDrawStart = max(1,(int)(-averageY/hazelStairs)-10);
  img.noStroke();
  if (haveGround){
    float groundTileSize = 5.0;
    int cx = round(averageX/5);
    int cz = round(averageZ/5);
    for(int x = cx-5; x < cx+5; x++){
      for(int z = cz-5; z < cz+5; z++){
        float lowX = (groundTileSize*x)*scaleToFixBug;
        float highX = (groundTileSize*(x+1))*scaleToFixBug;
        float lowZ = (groundTileSize*z)*scaleToFixBug;
        float highZ = (groundTileSize*(z+1))*scaleToFixBug;
        img.fill(0, 100+((x+z+100)%2)*30, 0);
        img.beginShape();
        img.vertex(lowX, 0, lowZ);
        img.vertex(highX, 0, lowZ);
        img.vertex(highX, 0, highZ);
        img.vertex(lowX, 0, highZ);
        img.endShape(CLOSE);
      }
    }
  }
  /*for (int i = 0; i < rects.size(); i++) {
    Rectangle r = rects.get(i);
    img.rect(r.x1*scaleToFixBug, r.y1*scaleToFixBug, (r.x2-r.x1)*scaleToFixBug, (r.y2-r.y1)*scaleToFixBug);
  }
  if(hazelStairs > 0){
    for(int i = stairDrawStart; i < stairDrawStart+20; i++){
      img.fill(255,255,255,128);
      img.rect((averageX-20)*scaleToFixBug,-hazelStairs*i*scaleToFixBug,40*scaleToFixBug,hazelStairs*0.3*scaleToFixBug);
      img.fill(255,255,255,255);
      img.rect((averageX-20)*scaleToFixBug,-hazelStairs*i*scaleToFixBug,40*scaleToFixBug,hazelStairs*0.15*scaleToFixBug);
    }
  }*/
}
float toMuscleUsable(float f){
  return min(max(f,0.8),1.2);
}
void drawPosts(PGraphics img) {
  int startPostY = min(-8,(int)(averageY/4)*4-4);
  img.noStroke();
  img.textAlign(CENTER);
  img.textFont(font, postFontSize*scaleToFixBug); 
  /*for(int postY = startPostY; postY <= startPostY+8; postY += 4){
    for (int i = (int)(averageX/5-5); i <= (int)(averageX/5+5); i++) {
      img.fill(255);
      img.rect((i*5.0-0.1)*scaleToFixBug, (-3.0+postY)*scaleToFixBug, 0.2*scaleToFixBug, 3.0*scaleToFixBug);
      img.rect((i*5.0-1)*scaleToFixBug, (-3.0+postY)*scaleToFixBug, 2.0*scaleToFixBug, 1.0*scaleToFixBug);
      img.fill(120);
      img.textAlign(CENTER);
      img.text(i+" m", i*5.0*scaleToFixBug, (-2.17+postY)*scaleToFixBug);
    }
  }*/
  img.fill(0,0,255);
  img.beginShape();
  float s = 0.4*scaleToFixBug;
  float y = -0.001*scaleToFixBug;
  img.vertex(0,y,s);
  img.vertex(-s,y,0);
  img.vertex(0,y,-s);
  img.vertex(s,y,0);
  img.endShape(CLOSE);
  
  colorMode(HSB,1.0);
  color c = color((timer%40)/40.0,1.0,1.0);
  img.fill(c);
  img.noStroke();
  img.lights();
  
  img.pushMatrix();
  img.translate(foodX*scaleToFixBug,foodY*scaleToFixBug,foodZ*scaleToFixBug);
  img.sphere(0.4*scaleToFixBug*0.5);
  img.popMatrix();
  
  img.noLights();
  
  colorMode(RGB,255);
  img.fill(0,60,0);
  img.pushMatrix();
  img.translate(foodX*scaleToFixBug,0,foodZ*scaleToFixBug);
  img.scale(1,0.02,1);
  img.sphere(0.4*scaleToFixBug*0.5);
  img.popMatrix();
}
void drawArrow(float x, float y, float z, PGraphics img) {
  img.noLights();
  img.pushMatrix();
  img.translate(x*scaleToFixBug,0,z*scaleToFixBug);
  img.rotateY(camHA);
  img.rotateX(-camVA);
  img.textAlign(CENTER);
  img.textFont(font, postFontSize*scaleToFixBug); 
  img.noStroke();
  img.fill(255, 0, 0);
  img.beginShape();
  float dist = 2.7*scaleToFixBug;
  img.vertex(dist, -3.8*scaleToFixBug, 0);
  img.vertex(dist, -2.7*scaleToFixBug, 0);
  img.vertex(-dist, -2.7*scaleToFixBug, 0);
  img.vertex(-dist, -3.8*scaleToFixBug, 0);
  img.endShape();
  img.beginShape();
  img.vertex(0, -2.2*scaleToFixBug);
  img.vertex(-0.5*scaleToFixBug, -2.7*scaleToFixBug);
  img.vertex(0.5*scaleToFixBug, -2.7*scaleToFixBug);
  img.endShape(CLOSE);
  String fitnessString = nf(getFitness(),0,2)+" "+fitnessUnit;
  img.fill(255);
  img.text(fitnessString, 0, -2.91*scaleToFixBug,0.1*scaleToFixBug);
  img.popMatrix();
}
void drawGraphImage() {
  image(graphImage, 50, 180, 650, 380);
  image(segBarImage, 50, 580, 650, 100);
  if (gen >= 1) {
    stroke(0, 160, 0, 255);
    strokeWeight(3);
    float genWidth = 563.333333333/gen;
    float lineX = 136.66666+genSelected*genWidth;
    line(lineX, 180, lineX, 500+180);
    Integer[] s = speciesCounts.get(genSelected);
    textAlign(RIGHT);
    textFont(font, 12);
    noStroke();
    for (int i = 1; i < 101; i++) {
      int c = s[i]-s[i-1];
      if (c >= 25) {
        float y = ((s[i]+s[i-1])/2)/1000.0*100+573;
        if (i-1 == topSpeciesCounts.get(genSelected)) {
          stroke(0);
          strokeWeight(2);
        }
        else {
          noStroke();
        }
        fill(255, 255, 255);
        rect(lineX+3, y, 56, 14);
        
        fill(0);
        text(toRealSpeciesName(i-1)+": "+c, lineX+58, y+11);
        
        //colorMode(HSB, 1.0);
        //fill(getColor(i-1, true));
        //text("S"+floor((i-1)/10)+""+((i-1)%10)+": "+c, lineX+5, y+11);
        //colorMode(RGB, 255);
      }
    }
    noStroke();
  }
}
color getColor(int i, boolean adjust) {
  colorMode(HSB, 1.0);
  float col = (i*1.618034)%1;
  if (i == 46) {
    col = 0.083333;
  }
  float light = 1.0;
  if (abs(col-0.333) <= 0.18 && adjust) {
    light = 0.7;
  }
  color c = color(col, 1.0, light);
  colorMode(RGB, 255);
  return c;
}
void drawGraph(int graphWidth, int graphHeight) { 
  graphImage.beginDraw();
  graphImage.smooth();
  graphImage.background(220);
  if (gen >= 1) {
    drawLines(130, int(graphHeight*0.05), graphWidth-130, int(graphHeight*0.9));
    drawSegBars(130, 0, graphWidth-130, 150);
  }
  graphImage.endDraw();
}
void drawLines(int x, int y, int graphWidth, int graphHeight) {
  float gh = float(graphHeight);
  float genWidth = float(graphWidth)/gen;
  float best = extreme(1);
  float worst = extreme(-1);
  float meterHeight = float(graphHeight)/(best-worst);
  float zero = (best/(best-worst))*gh;
  float unit = setUnit(best, worst);
  graphImage.stroke(150);
  graphImage.strokeWeight(2);
  graphImage.fill(150);
  graphImage.textFont(font, 18);
  graphImage.textAlign(RIGHT);
  for (float i = ceil((worst-(best-worst)/18.0)/unit)*unit; i < best+(best-worst)/18.0;i+=unit) {
    float lineY = y-i*meterHeight+zero;
    graphImage.line(x, lineY, graphWidth+x, lineY);
    graphImage.text(showUnit(i, unit)+" "+fitnessUnit, x-5, lineY+4);
  }
  graphImage.stroke(0);
  for (int i = 0; i < 29; i++) {
    int k;
    if (i == 28) {
      k = 14;
    }
    else if (i < 14) {
      k = i;
    }
    else {
      k = i+1;
    }
    if (k == 14) {
      graphImage.stroke(255, 0, 0, 255);
      graphImage.strokeWeight(5);
    }
    else {
      stroke(0);
      if (k == 0 || k == 28 || (k >= 10 && k <= 18)) {
        graphImage.strokeWeight(3);
      }
      else {
        graphImage.strokeWeight(1);
      }
    }
    for (int j = 0; j < gen; j++) {
      graphImage.line(x+j*genWidth, (-percentile.get(j)[k])*meterHeight+zero+y, 
      x+(j+1)*genWidth, (-percentile.get(j+1)[k])*meterHeight+zero+y);
    }
  }
}
void drawSegBars(int x, int y, int graphWidth, int graphHeight) {
  segBarImage.beginDraw();
  segBarImage.smooth();
  segBarImage.noStroke();
  segBarImage.colorMode(HSB, 1);
  segBarImage.background(0, 0, 0.5);
  float genWidth = float(graphWidth)/gen;
  int gensPerBar = floor(gen/500)+1;
  for (int i = 0; i < gen; i+=gensPerBar) {
    int i2 = min(i+gensPerBar, gen);
    float barX1 = x+i*genWidth;
    float barX2 = x+i2*genWidth;
    int cum = 0;
    for (int j = 0; j < 100; j++) {
      segBarImage.fill(getColor(j, false));
      segBarImage.beginShape();
      segBarImage.vertex(barX1, y+speciesCounts.get(i)[j]/1000.0*graphHeight);
      segBarImage.vertex(barX1, y+speciesCounts.get(i)[j+1]/1000.0*graphHeight);
      segBarImage.vertex(barX2, y+speciesCounts.get(i2)[j+1]/1000.0*graphHeight);
      segBarImage.vertex(barX2, y+speciesCounts.get(i2)[j]/1000.0*graphHeight);
      segBarImage.endShape();
    }
  }
  segBarImage.endDraw();
  colorMode(RGB, 255);
}
float extreme(float sign) {
  float record = -sign;
  for (int i = 0; i < gen; i++) {
    float toTest = percentile.get(i+1)[int(14-sign*14)];
    if (toTest*sign > record*sign) {
      record = toTest;
    }
  }
  return record;
}
float setUnit(float best, float worst) {
  float unit2 = 3*log(best-worst)/log(10)-2;
  if ((unit2+90)%3 < 1) {
    return pow(10, floor(unit2/3));
  } else if ((unit2+90)%3 < 2) {
    return pow(10, floor((unit2-1)/3))*2;
  } else {
    return pow(10, floor((unit2-2)/3))*5;
  }
}
String showUnit(float i, float unit) {
  if (unit < 1) {
    return nf(i, 0, 2)+"";
  }
  else {
    return int(i)+"";
  }
}
ArrayList<Creature> quickSort(ArrayList<Creature> c) {
  if (c.size() <= 1) {
    return c;
  }
  else {
    ArrayList<Creature> less = new ArrayList<Creature>();
    ArrayList<Creature> more = new ArrayList<Creature>();
    ArrayList<Creature> equal = new ArrayList<Creature>();
    Creature c0 = c.get(0);
    equal.add(c0);
    for (int i = 1; i < c.size(); i++) {
      Creature ci = c.get(i);
      if (ci.d == c0.d) {
        equal.add(ci);
      }
      else if (ci.d < c0.d) {
        less.add(ci);
      }
      else {
        more.add(ci);
      }
    }
    ArrayList<Creature> total = new ArrayList<Creature>();
    total.addAll(quickSort(more));
    total.addAll(equal);
    total.addAll(quickSort(less));
    return total;
  }
}
void adjustToCenter(int nodeNum) {
  float avx = 0;
  float lowY = -1000;
  for (int i = 0; i < nodeNum; i++) {
    Node ni = currentCreature.n.get(i);
    avx += ni.x;
    if (ni.y+ni.m/2 > lowY) {
      lowY = ni.y+ni.m/2;
    }
  }
  avx /= nodeNum;
  for (int i = 0; i < nodeNum; i++) {
    Node ni = currentCreature.n.get(i);
    ni.x -= avx;
    ni.y -= lowY;
  }
}
void setAverages() {
  averageX = 0;
  averageY = 0;
  averageZ = 0;
  for (int i = 0; i < currentCreature.n.size(); i++) {
    Node ni = currentCreature.n.get(i);
    averageX += ni.x;
    averageY += ni.y;
    averageZ += ni.z;
  }
  averageX = averageX/currentCreature.n.size();
  averageY = averageY/currentCreature.n.size();
  averageZ = averageZ/currentCreature.n.size();
}
Creature[] c = new Creature[1000];
ArrayList<Creature> c2 = new ArrayList<Creature>();

void mouseWheel(MouseEvent event) {
  float delta = event.getCount();
  if (menu == 5 || statusWindow >= -3) {
    if (delta == -1) {
      camZoom *= 0.9090909;
      if (camZoom < 0.002) {
        camZoom = 0.002;
      }
      textFont(font, postFontSize);
    } else if (delta == 1) {
      camZoom *= 1.1;
      if (camZoom > 0.1) {
        camZoom = 0.1;
      }
      textFont(font, postFontSize);
    }
  }
}

void mousePressed() {
  if (gensToDo >= 1) {
    gensToDo = 0;
  }
  float mX = mouseX/windowSizeMultiplier;
  float mY = mouseY/windowSizeMultiplier;
  if (menu == 1 && gen >= 1 && abs(mY-365) <= 25 && abs(mX-sliderX-25) <= 25) {
    drag = true;
  }
}

void openMiniSimulation() {
  simulationTimer = 0;
  if (gensToDo == 0) {
    miniSimulation = true;
    int id;
    Creature cj;
    if (statusWindow <= -1) {
      cj = creatureDatabase.get((genSelected-1)*3+statusWindow+3);
      id = cj.id;
    } else {
      id = statusWindow;
      cj = c2.get(id);
    }
    setGlobalVariables(cj);
    creatureWatching = id;
  }
}
void setMenu(int m) {
  menu = m;
  if (m == 1) {
    drawGraph(975, 570);
  }
}
String zeros(int n, int zeros){
  String s = n+"";
  for(int i = s.length(); i < zeros; i++){
    s = "0"+s;
  }
  return s;
}

void startASAP() {
  setMenu(4);
  creaturesTested = 0;
  stepbystep = false;
  stepbystepslow = false;
}
void mouseReleased() {
  drag = false;
  miniSimulation = false;
  float mX = mouseX/windowSizeMultiplier;
  float mY = mouseY/windowSizeMultiplier;
  if (menu == 0 && abs(mX-windowWidth/2) <= 200 && abs(mY-400) <= 100) {
    setMenu(1);
  }else if (menu == 1 && gen == -1 && abs(mX-120) <= 100 && abs(mY-300) <= 50) {
    setMenu(2);
  }else if (menu == 1 && gen >= 0 && abs(mX-990) <= 230) {
    if (abs(mY-40) <= 20) {
      setMenu(4);
      speed = 1;
      creaturesTested = 0;
      stepbystep = true;
      stepbystepslow = true;
    }
    if (abs(mY-90) <= 20) {
      setMenu(4);
      creaturesTested = 0;
      stepbystep = true;
      stepbystepslow = false;
    }
    if (abs(mY-140) <= 20) {
      if (mX < 990) {
        gensToDo = 1;
      } else {
        gensToDo = 1000000000;
      }
      startASAP();
    }
  }else if (menu == 3 && abs(mX-1030) <= 130 && abs(mY-684) <= 20) {
    gen = 0;
    setMenu(1);
  } else if (menu == 7 && abs(mX-1030) <= 130 && abs(mY-684) <= 20) {
    setMenu(8);
  } else if((menu == 5 || menu == 4) && mY >= windowHeight-40){
    if(mX < 90){
      for (int s = timer; s < 900; s++) {
        simulateCurrentCreature();
      }
      timer = 1021;
    }else if(mX >= 120 && mX < 360){
      speed *= 2;
      if(speed == 1024) speed = 900;
      if(speed >= 1800) speed = 1;
    }else if(mX >= windowWidth-120){
      for (int s = timer; s < 900; s++) {
        simulateCurrentCreature();
      }
      timer = 0;
      creaturesTested++;
      for (int i = creaturesTested; i < 1000; i++) {
        setGlobalVariables(c[i]);
        for (int s = 0; s < 900; s++) {
          simulateCurrentCreature();
        }
        setAverages();
        setFitness(i);
      }
      setMenu(6);
    }
  } else if(menu == 8 && mX < 90 && mY >= windowHeight-40){
    timer = 100000;
  } else if (menu == 9 && abs(mX-1030) <= 130 && abs(mY-690) <= 20) {
    setMenu(10);
  }else if (menu == 11 && abs(mX-1130) <= 80 && abs(mY-690) <= 20) {
    setMenu(12);
  }else if (menu == 13 && abs(mX-1130) <= 80 && abs(mY-690) <= 20) {
    setMenu(1);
  }
}
void simulateCurrentCreature(){
  currentCreature.simulate();
  averageNodeNausea = totalNodeNausea/currentCreature.n.size();
  simulationTimer++;
  timer++;
}
void drawScreenImage(int stage) {
  screenImage.beginDraw();
  screenImage.pushMatrix();
  screenImage.scale(10.0*windowSizeMultiplier/scaleToFixBug);
  screenImage.smooth();
  screenImage.background(gridBGColor);
  screenImage.noStroke();
  for (int j = 0; j < 1000; j++) {
    Creature cj = c2.get(j);
    if (stage == 3) cj = c[cj.id-(gen*1000)-1001];
    int j2 = j;
    if (stage == 0) {
      j2 = cj.id-(gen*1000)-1;
      creaturesInPosition[j2] = j;
    }
    int x = j2%40;
    int y = floor(j2/40);
    if (stage >= 1) y++;
    screenImage.pushMatrix();
    screenImage.translate((x*3+5.5)*scaleToFixBug, (y*2.5+3)*scaleToFixBug, 0);
    cj.drawCreature(screenImage,true);
    screenImage.popMatrix();
  }
  timer = 0;
  screenImage.popMatrix();
  screenImage.noLights();
  
  screenImage.pushMatrix();
  screenImage.scale(windowSizeMultiplier); // Arbitrary, do not change.
  
  screenImage.textAlign(CENTER);
  screenImage.textFont(font, 24);
  screenImage.fill(100, 100, 200);
  screenImage.noStroke();
  if (stage == 0) {
    screenImage.rect(900, 664, 260, 40);
    screenImage.fill(0);
    screenImage.text("All 1,000 creatures have been tested.  Now let's sort them!", windowWidth/2-200, 690);
    screenImage.text("Sort", windowWidth-250, 690);
  } else if (stage == 1) {
    screenImage.rect(900, 670, 260, 40);
    screenImage.fill(0);
    screenImage.text("Fastest creatures at the top!", windowWidth/2, 30);
    screenImage.text("Slowest creatures at the bottom. (Going backward = slow)", windowWidth/2-200, 700);
    screenImage.text("Kill 500", windowWidth-250, 700);
  } else if (stage == 2) {
    screenImage.rect(1050, 670, 160, 40);
    screenImage.fill(0);
    screenImage.text("Faster creatures are more likely to survive because they can outrun their predators.  Slow creatures get eaten.", windowWidth/2, 30);
    screenImage.text("Because of random chance, a few fast ones get eaten, while a few slow ones survive.", windowWidth/2-130, 700);
    screenImage.text("Reproduce", windowWidth-150, 700);
    for (int j = 0; j < 1000; j++) {
      Creature cj = c2.get(j);
      int x = j%40;
      int y = floor(j/40)+1;
      if (cj.alive) {
        /*screenImage.pushMatrix();
        screenImage.scale(10.0*windowSizeMultiplier/scaleToFixBug);
        
        screenImage.translate(x*18+500, y*16+200, 570);
        screenImage.scale(0.13);
        cj.drawCreature(screenImage,false);
        screenImage.popMatrix();*/
      } else {
        screenImage.fill(0);
        screenImage.beginShape();
        screenImage.vertex(x*30+40, y*25+17,0.01);
        screenImage.vertex(x*30+70, y*25+17,0.01);
        screenImage.vertex(x*30+70, y*25+42,0.01);
        screenImage.vertex(x*30+40, y*25+42,0.01);
        screenImage.endShape();
      }
    }
  } else if (stage == 3) {
    screenImage.rect(1050, 670, 160, 40);
    screenImage.fill(0);
    screenImage.text("These are the 1000 creatures of generation #"+(gen+2)+".", windowWidth/2, 30);
    screenImage.text("What perils will they face?  Find out next time!", windowWidth/2-130, 700);
    screenImage.text("Back", windowWidth-150, 700);
  }
  screenImage.popMatrix();
  screenImage.endDraw();
}
void drawpopUpImage() {
  setAverages();
  moveCamera();
  popUpImage.beginDraw();
  popUpImage.smooth();
  
  float camDist = (450/2.0) / tan(PI*30.0 / 180.0);
  popUpImage.pushMatrix();
  
  popUpImage.camera(camX/camZoom+camDist*sin(camHA)*cos(camVA),
  camY/camZoom+camDist*sin(camVA), camZ/camZoom+camDist*cos(camHA)*cos(camVA),
  camX/camZoom, camY/camZoom, camZ/camZoom, 0, 1, 0);
  
  popUpImage.scale(1.0/camZoom/scaleToFixBug);
  
  if (simulationTimer < 900) {
    popUpImage.background(120, 200, 255);
  } else {
    popUpImage.background(60, 100, 128);
  }
  drawPosts(popUpImage);
  drawGround(popUpImage);
  currentCreature.drawCreature(popUpImage,false);
  drawArrow(averageX,averageY,averageZ,popUpImage);
  popUpImage.noStroke();
  popUpImage.endDraw();
  popUpImage.popMatrix();
}
void moveCamera(){
  camX += (averageX-camX)*0.2;
  camY += (averageY-camY)*0.2;
  camZ += (averageZ-camZ)*0.2;
}
void drawHistogram(int x, int y, int hw, int hh) {
  int maxH = 1;
  for (int i = 0; i < barLen; i++) {
    if (barCounts.get(genSelected)[i] > maxH) {
      maxH = barCounts.get(genSelected)[i];
    }
  }
  fill(200);
  noStroke();
  rect(x, y, hw, hh);
  fill(0, 0, 0);
  float barW = (float)hw/barLen;
  float multiplier = (float)hh/maxH*0.9;
  textAlign(LEFT);
  textFont(font, 16);
  stroke(128);
  strokeWeight(2);
  int unit = 100;
  if (maxH < 300) unit = 50;
  if (maxH < 100) unit = 20;
  if (maxH < 50) unit = 10;
  for (int i = 0; i < hh/multiplier; i += unit) {
    float theY = y+hh-i*multiplier;
    line(x, theY, 0, x+hw, theY, 0);
    if (i == 0) theY -= 5;
    text(i, x+hw+5, theY+7, 0);
  }
  textAlign(CENTER);
  for (int i = minBar; i <= maxBar; i += 10) {
    if (i == 0) {
      stroke(0, 0, 255);
    }
    else {
      stroke(128);
    }
    float theX = x+(i-minBar)*barW;
    text(nf((float)i/histBarsPerMeter, 0, 1), theX, y+hh+14, 0);
    line(theX, y, 0, theX, y+hh, 0);
  }
  noStroke();
  for (int i = 0; i < barLen; i++) {
    float h = min(barCounts.get(genSelected)[i]*multiplier, hh);
    if (i+minBar == floor(percentile.get(min(genSelected, percentile.size()-1))[14]*histBarsPerMeter)) {
      fill(255, 0, 0);
    }
    else {
      fill(0, 0, 0);
    }
    rect(x+i*barW, y+hh-h, barW, h);
  }
}
void drawStatusWindow(boolean isFirstFrame) {
  int x, y, px, py;
  int rank = (statusWindow+1);
  Creature cj;
  stroke(abs(overallTimer%30-15)*17);
  strokeWeight(3);
  noFill();
  if (statusWindow >= 0) {
    cj = c2.get(statusWindow);
    if (menu == 7) {
      int id = ((cj.id-1)%1000);
      x = id%40;
      y = floor(id/40);
    } else {
      x = statusWindow%40;
      y = floor(statusWindow/40)+1;
    }
    px = x*30+55;
    py = y*25+10;
    if (px <= 1140) {
      px += 80;
    } else {
      px -= 80;
    }
    rect(x*30+40, y*25+17, 30, 25);
  } else {
    cj = creatureDatabase.get((genSelected-1)*3+statusWindow+3);
    x = 760+(statusWindow+3)*160;
    y = 180;
    px = x;
    py = y;
    rect(x, y, 140, 140);
    int[] ranks = {
      1000, 500, 1
    };
    rank = ranks[statusWindow+3];
  }
  noStroke();
  fill(255);
  rect(px-60, py, 120, 52);
  fill(0);
  textFont(font, 12);
  textAlign(CENTER);
  text("#"+rank, px, py+12);
  text("ID: "+cj.id, px, py+24);
  text("Fitness: "+nf(cj.d, 0, 3), px, py+36);
  colorMode(HSB, 1);
  int sp = (cj.n.size()%10)*10+(cj.m.size()%10);
  fill(getColor(sp, true));
  text("Species: S"+(cj.n.size()%10)+""+(cj.m.size()%10), px, py+48);
  colorMode(RGB, 255);
  if (miniSimulation) {
    keysToMoveCamera();
    int py2 = py-175;
    if (py >= 360) {
      py2 -= 190;
    }else {
      py2 += 238;
    }
    py = min(max(py,0),420);
    int px2 = min(max(px-90, 10), 900);
    drawpopUpImage();
    pushMatrix();
    translate(0,0,1);
    image(popUpImage, px2, py2, 360, 360);
    popMatrix();
    drawBrain(px2-130, py2, 1,5, cj);
    drawStats(px2+355, py2+239, 1, 0.45);
    
    simulateCurrentCreature();
    int shouldBeWatching = statusWindow;
    if (statusWindow <= -1) {
      cj = creatureDatabase.get((genSelected-1)*3+statusWindow+3);
      shouldBeWatching = cj.id;
    }
    if (creatureWatching != shouldBeWatching || isFirstFrame) {
      openMiniSimulation();
    }
  }
}
void setup() {
  String[] prePatronData = loadStrings("PatronReport_2017-06-12.csv");
  patronData = new String[PATRON_COUNT];
  int lineAt = 0;
  for(int i = 0; i < prePatronData.length; i++){
    if(i != 0 && prePatronData[i].indexOf("Reward") == -1){
      patronData[lineAt] = prePatronData[i];
      lineAt++;
    }
  }
  for(int i = 0; i < PATRON_COUNT; i++){
    CREATURES_PER_PATRON[i] = 0;
  }
  frameRate(60);
  randomSeed(SEED);
  noSmooth();
  size((int)(windowWidth*windowSizeMultiplier), (int)(windowHeight*windowSizeMultiplier),P3D);
  ellipseMode(CENTER);
  Float[] beginPercentile = new Float[29];
  Integer[] beginBar = new Integer[barLen];
  Integer[] beginSpecies = new Integer[101];
  for (int i = 0; i < 29; i++) {
    beginPercentile[i] = 0.0;
  }
  for (int i = 0; i < barLen; i++) {
    beginBar[i] = 0;
  }
  for (int i = 0; i < 101; i++) {
    beginSpecies[i] = 500;
  }

  percentile.add(beginPercentile);
  barCounts.add(beginBar);
  speciesCounts.add(beginSpecies);
  topSpeciesCounts.add(0);

  simulationImage = createGraphics(width, height, P3D);
  graphImage = createGraphics(975, 570);
  screenImage = createGraphics(width, height, P3D);
  popUpImage = createGraphics(450, 450, P3D);
  segBarImage = createGraphics(975, 150);
  segBarImage.beginDraw();
  segBarImage.smooth();
  segBarImage.background(220);
  segBarImage.endDraw();
  popUpImage.beginDraw();
  popUpImage.smooth();
  popUpImage.background(220);
  popUpImage.endDraw();
  
  font = loadFont("Helvetica-Bold-96.vlw"); 
  textFont(font, 96);
  textAlign(CENTER);
  
  /*rects.add(new Rectangle(4,-7,9,-3));
   rects.add(new Rectangle(6,-1,10,10));
   rects.add(new Rectangle(9.5,-1.5,13,10));
   rects.add(new Rectangle(12,-2,16,10));
   rects.add(new Rectangle(15,-2.5,19,10));
   rects.add(new Rectangle(18,-3,22,10));
   rects.add(new Rectangle(21,-3.5,25,10));
   rects.add(new Rectangle(24,-4,28,10));
   rects.add(new Rectangle(27,-4.5,31,10));
   rects.add(new Rectangle(30,-5,34,10));
   rects.add(new Rectangle(33,-5.5,37,10));
   rects.add(new Rectangle(36,-6,40,10));
   rects.add(new Rectangle(39,-6.5,100,10));*/
   
  //rects.add(new Rectangle(-100,-100,100,-2.8));
  //rects.add(new Rectangle(-100,0,100,100));
  //Snaking thing below:
  /*rects.add(new Rectangle(-400,-10,1.5,-1.5));
   rects.add(new Rectangle(-400,-10,3,-3));
   rects.add(new Rectangle(-400,-10,4.5,-4.5));
   rects.add(new Rectangle(-400,-10,6,-6));
   rects.add(new Rectangle(0.75,-0.75,400,4));
   rects.add(new Rectangle(2.25,-2.25,400,4));
   rects.add(new Rectangle(3.75,-3.75,400,4));
   rects.add(new Rectangle(5.25,-5.25,400,4));
   rects.add(new Rectangle(-400,-5.25,0,4));*/
}
void draw() {
  scale(windowSizeMultiplier);
  if (menu == 0) {
    background(255);
    fill(100, 200, 100);
    noStroke();
    rect(windowWidth/2-200, 300, 400, 200);
    fill(0);
    text("EVOLUTION!", windowWidth/2, 200);
    text("START", windowWidth/2, 430);
  }else if (menu == 1) {
    noStroke();
    fill(0);
    background(255, 200, 130);
    textFont(font, 32);
    textAlign(LEFT);
    textFont(font, 96);
    text("GEN "+max(genSelected, 0), 20, 100);
    textFont(font, 28);
    if (gen == -1) {
      fill(100, 200, 100);
      rect(20, 250, 200, 100);
      fill(0);
      text("Since there are no creatures yet, create 1000 creatures!", 20, 160);
      text("They will be randomly created, and also very simple.", 20, 200);
      text("CREATE", 56, 312);
    } else {
      fill(100, 200, 100);
      rect(760, 20, 460, 40);
      rect(760, 70, 460, 40);
      rect(760, 120, 230, 40);
      if (gensToDo >= 2) {
        fill(128, 255, 128);
      } else {
        fill(70, 140, 70);
      }
      rect(990, 120, 230, 40);
      fill(0);
      //text("Survivor Bias: "+percentify(getSB(genSelected)), 437, 50);
      text("Curve: ±"+nf(foodAngleChange/(2*PI)*360,0,2)+" degrees", 420, 50);
      text("Do 1 step-by-step generation.", 770, 50);
      text("Do 1 quick generation.", 770, 100);
      text("Do 1 gen ASAP.", 770, 150);
      text("Do gens ALAP.", 1000, 150);
      text("Median "+fitnessName, 50, 160);
      textAlign(CENTER);
      textAlign(RIGHT);
      text(float(round(percentile.get(min(genSelected, percentile.size()-1))[14]*1000))/1000+" "+fitnessUnit, 700, 160);
      drawHistogram(760, 410, 460, 280);
      drawGraphImage();
      //if(saveFramesPerGeneration && gen > lastImageSaved){
      //  saveFrame("imgs//"+zeros(gen,5)+".png");
      //  lastImageSaved = gen;
      //}
    }
    if (gensToDo >= 1) {
      gensToDo--;
      if (gensToDo >= 1) {
        startASAP();
      }
    }
  }else if (menu == 2) {
    creatures = 0;
    for (int y = 0; y < 25; y++) {
      for (int x = 0; x < 40; x++) {
        int nodeNum = int(random(4, 8));
        int muscleNum = int(random(nodeNum, nodeNum*3));
        ArrayList<Node> n = new ArrayList<Node>(nodeNum);
        ArrayList<Muscle> m = new ArrayList<Muscle>(muscleNum);
        for (int i = 0; i < nodeNum; i++) {
          n.add(new Node(random(-1, 1), random(-1, 1), random(-1, 1),
          0, 0, 0, 0.4, random(0, 1))); //replaced all nodes' sizes with 0.4, used to be random(0.1,1), random(0,1)
        }
        for (int i = 0; i < muscleNum; i++) {
          int tc1 = 0;
          int tc2 = 0;
          if (i < nodeNum-1) {
            tc1 = i;
            tc2 = i+1;
          } else {
            tc1 = int(random(0, nodeNum));
            tc2 = tc1;
            while (tc2 == tc1) {
              tc2 = int(random(0, nodeNum));
            }
          }
          float s = 0.8;
          if (i >= 10) {
            s *= 1.414;
          }
          float len = random(0.5,1.5);
          m.add(new Muscle(tc1, tc2, len, random(0.015, 0.06)));
        }
        float heartbeat = random(40, 80);
        c[y*40+x] = new Creature(null, y*40+x+1, new ArrayList<Node>(n), new ArrayList<Muscle>(m), 0, true, heartbeat, 1.0, null, null);
        c[y*40+x].checkForOverlap();
        c[y*40+x].checkForLoneNodes();
        c[y*40+x].toStableConfiguration();
        c[y*40+x].moveToCenter();
      }
    }
    creatures = 0;
    screenImage.beginDraw();
    screenImage.background(gridBGColor);
    screenImage.scale(windowSizeMultiplier);
    screenImage.pushMatrix();
    screenImage.scale(10.0/scaleToFixBug);
    for (int y = 0; y < 25; y++) {
      for (int x = 0; x < 40; x++) {
        screenImage.pushMatrix();
        screenImage.translate((x*3+5.5)*scaleToFixBug, (y*2.5+3)*scaleToFixBug, 0);
        c[y*40+x].drawCreature(screenImage,true);
        screenImage.popMatrix();
      }
    }
    screenImage.noLights();
    screenImage.popMatrix();
    screenImage.noStroke();
    screenImage.fill(100, 100, 200);
    screenImage.rect(900, 664, 260, 40);
    screenImage.fill(0);
    screenImage.textAlign(CENTER);
    screenImage.textFont(font, 24);
    screenImage.text("Here are your 1000 randomly generated creatures!!!", windowWidth/2-200, 690);
    screenImage.text("Back", windowWidth-250, 690);
    screenImage.endDraw();
    setMenu(3);
  }else if(menu == 3){
    background(0,0,255);
    image(screenImage, 0, 0, 1280, 720);
  }else if (menu == 4) {
    setGlobalVariables(c[creaturesTested]);
    setMenu(5);
    if (!stepbystepslow) {
      for (int i = 0; i < 1000; i++) {
        setGlobalVariables(c[i]);
        for (int s = 0; s < 900; s++) {
          simulateCurrentCreature();
        }
        setAverages();
        setFitness(i);
      }
      setMenu(6);
    }
  }
  if (menu == 5) { //simulate running
    if (timer <= 900) {
      keysToMoveCamera();
      simulationImage.beginDraw();
      simulationImage.background(120, 200, 255);
      for (int s = 0; s < speed; s++) {
        if (timer < 900) {
          simulateCurrentCreature();
        }
      }
      setAverages();
      if (speed < 30) {
        for (int s = 0; s < speed; s++) {
          moveCamera();
        }
      } else {
        camX = averageX;
        camY = averageY;
        camZ = averageZ;
      }
      float camDist = (height/2.0) / tan(PI*30.0 / 180.0);
      simulationImage.pushMatrix();
      simulationImage.camera(camX/camZoom+camDist*sin(camHA)*cos(camVA),
      camY/camZoom+camDist*sin(camVA), camZ/camZoom+camDist*cos(camHA)*cos(camVA),
      camX/camZoom, camY/camZoom, camZ/camZoom, 0, 1, 0);

      simulationImage.scale(1.0/camZoom/scaleToFixBug);
      
      drawPosts(simulationImage);
      drawGround(simulationImage);
      currentCreature.drawCreature(simulationImage,false);
      drawArrow(averageX,averageY,averageZ,simulationImage);
      simulationImage.popMatrix();
      simulationImage.endDraw();
      image(simulationImage,0,0,width/windowSizeMultiplier,
      height/windowSizeMultiplier);
      drawBrain(40,20,0,5,currentCreature);
      drawStats(windowWidth-10,0,0,0.7);
      drawSkipButton();
      drawOtherButtons();
    }
    if (timer == 900) {
      if (speed < 30) {
        noStroke();
        fill(0, 0, 0, 130);
        rect(0, 0, windowWidth, windowHeight);
        fill(0, 0, 0, 255);
        rect(windowWidth/2-500, 200, 1000, 240);
        fill(255, 0, 0);
        textAlign(CENTER);
        textFont(font, 96);
        text("Creature's "+fitnessName+":", windowWidth/2, 300);
        text(nf(getFitness(),0,2) + " "+fitnessUnit, windowWidth/2, 400);
      } else {
        timer = 1020;
      }
      setFitness(creaturesTested);
    }
    if (timer >= 1020) {
      setMenu(4);
      creaturesTested++;
      if (creaturesTested == 1000) {
        setMenu(6);
      }
      camX = 0;
    }
    if (timer >= 900) {
      timer += speed;
    }
  }
  if (menu == 6) {
    //sort
    c2 = new ArrayList<Creature>(0);
    for(int i = 0; i < 1000; i++){
      c2.add(c[i]);
    }
    c2 = quickSort(c2);
    percentile.add(new Float[29]);
    for (int i = 0; i < 29; i++) {
      percentile.get(gen+1)[i] = c2.get(p[i]).d;
    }
    creatureDatabase.add(c2.get(999).copyCreature(-1,false,false));
    creatureDatabase.add(c2.get(499).copyCreature(-1,false,false));
    creatureDatabase.add(c2.get(0).copyCreature(-1,false,false));

    Integer[] beginBar = new Integer[barLen];
    for (int i = 0; i < barLen; i++) {
      beginBar[i] = 0;
    }
    barCounts.add(beginBar);
    Integer[] beginSpecies = new Integer[101];
    for (int i = 0; i < 101; i++) {
      beginSpecies[i] = 0;
    }
    for (int i = 0; i < 1000; i++) {
      int bar = floor(c2.get(i).d*histBarsPerMeter-minBar);
      if (bar >= 0 && bar < barLen) {
        barCounts.get(gen+1)[bar]++;
      }
      int species = c2.get(i).name[0];//(c2.get(i).n.size()%10)*10+c2.get(i).m.size()%10;
      beginSpecies[species]++;
    }
    speciesCounts.add(new Integer[101]);
    speciesCounts.get(gen+1)[0] = 0;
    int cum = 0;
    int record = 0;
    int holder = 0;
    for (int i = 0; i < 100; i++) {
      cum += beginSpecies[i];
      speciesCounts.get(gen+1)[i+1] = cum;
      if (beginSpecies[i] > record) {
        record = beginSpecies[i];
        holder = i;
      }
    }
    topSpeciesCounts.add(holder);
    if (stepbystep) {
      drawScreenImage(0);
      setMenu(7);
    } else {
      setMenu(10);
    }
  }
  if (menu == 8) {
    timer = 100000; // DOY IM IMPATIENT
    //cool sorting animation
    screenImage.beginDraw();
    screenImage.background(gridBGColor);
    screenImage.pushMatrix();
    screenImage.scale(10.0/scaleToFixBug*windowSizeMultiplier);
    float transition = 0.5-0.5*cos(min(float(timer)/60, PI));
    for (int j = 0; j < 1000; j++) {
      Creature cj = c2.get(j);
      int j2 = cj.id-(gen*1000)-1;
      int x1 = j2%40;
      int y1 = floor(j2/40);
      int x2 = j%40;
      int y2 = floor(j/40)+1;
      float x3 = inter(x1, x2, transition);
      float y3 = inter(y1, y2, transition);
      screenImage.translate((x3*3+5.5)*scaleToFixBug, (y3*2.5+4)*scaleToFixBug, 0);
      cj.drawCreature(screenImage,true);
    }
    screenImage.popMatrix();
    if (stepbystepslow) {
      timer+=5;
    }else{
      timer+=20;
    }
    screenImage.endDraw();
    image(screenImage, 0, 0, 1280, 720);
    drawSkipButton();
    if (timer > 60*PI) {
      drawScreenImage(1);
      setMenu(9);
    }
  }
  float mX = mouseX/windowSizeMultiplier;
  float mY = mouseY/windowSizeMultiplier;
  prevStatusWindow = statusWindow;
  if (abs(menu-9) <= 2 && gensToDo == 0 && !drag) {
    if (abs(mX-639.5) <= 599.5) {
      if (menu == 7 && abs(mY-329) <= 312) {
        statusWindow = creaturesInPosition[floor((mX-40)/30)+floor((mY-17)/25)*40];
      }
      else if (menu >= 9 && abs(mY-354) <= 312) {
        statusWindow = floor((mX-40)/30)+floor((mY-42)/25)*40;
      }
      else {
        statusWindow = -4;
      }
    }
    else {
      statusWindow = -4;
    }
  } else if (menu == 1 && genSelected >= 1 && gensToDo == 0 && !drag) {
    statusWindow = -4;
    if (abs(mY-250) <= 70) {
      if (abs(mX-990) <= 230) {
        float modX = (mX-760)%160;
        if (modX < 140) {
          statusWindow = floor((mX-760)/160)-3;
        }
      }
    }
  } else {
    statusWindow = -4;
  }
  if (menu == 10) {
    //Kill!
    for (int j = 0; j < 500; j++) {
      if(random(0,1) < getSB(gen)){
        float f = float(j)/1000;
        float rand = (pow(random(-1, 1), 3)+1)/2; //cube function
        slowDies = (f <= rand);
      }else{
        slowDies = (random(0,1) < 0.5);
      }
      int j2;
      int j3;
      if (slowDies) {
        j2 = j;
        j3 = 999-j;
      } else {
        j2 = 999-j;
        j3 = j;
      }
      Creature cj = c2.get(j2);
      cj.alive = true;
      Creature ck = c2.get(j3);
      ck.alive = false;
    }
    if (stepbystep) {
      drawScreenImage(2);
      setMenu(11);
    } else {
      setMenu(12);
    }
  }
  if (menu == 12) { //Reproduce and mutate
    justGotBack = true;
    for (int j = 0; j < 500; j++) {
      int j2 = j;
      if (!c2.get(j).alive) j2 = 999-j;
      Creature cj = c2.get(j2);
      Creature cj2 = c2.get(999-j2);
      
      c2.set(j2, cj.copyCreature(cj.id+1000,true,false));        //duplicate
      c2.set(999-j2, cj.modified(cj2.id+1000));   //mutated offspring 1
    }
    for (int j = 0; j < 1000; j++) {
      Creature cj = c2.get(j);
      c[cj.id-(gen*1000)-1001] = cj.copyCreature(-1,false,false);
    }
    drawScreenImage(3);
    gen++;
    if (stepbystep) {
      setMenu(13);
    } else {
      setMenu(1);
    }
  }
  if(menu%2 == 1 && abs(menu-10) <= 3){
    image(screenImage, 0, 0, 1280, 720);
  }
  if (menu == 1 || gensToDo >= 1) {
    mX = mouseX/windowSizeMultiplier;;
    mY = mouseY/windowSizeMultiplier;;
    noStroke();
    if (gen >= 1) {
      textAlign(CENTER);
      if (gen >= 5) {
        genSelected = round((sliderX-760)*(gen-1)/410)+1;
      } else {
        genSelected = round((sliderX-760)*gen/410);
      }
      if (drag) sliderX = min(max(sliderX+(mX-25-sliderX)*0.2, 760), 1170);
      fill(100);
      rect(760, 340, 460, 50);
      fill(220);
      rect(sliderX, 340, 50, 50);
      int fs = 0;
      if (genSelected >= 1) {
        fs = floor(log(genSelected)/log(10));
      }
      fontSize = fontSizes[fs];
      textFont(font, fontSize);
      fill(0);
      text(genSelected, sliderX+25, 366+fontSize*0.3333);
    }
    if (genSelected >= 1) {
      simulationImage.beginDraw();
      simulationImage.clear();
      simulationImage.endDraw();
      for (int k = 0; k < 3; k++) {
        fill(220);
        rect(760+k*160, 180, 140, 140);
        simulationImage.beginDraw();
        simulationImage.pushMatrix();
        simulationImage.translate(830+160*k, 260,0);
        simulationImage.scale(60.0/scaleToFixBug);
        creatureDatabase.get((genSelected-1)*3+k).drawCreature(simulationImage,true);
        simulationImage.popMatrix();
        simulationImage.endDraw();
      }
      image(simulationImage,0,0,width,height);
      
      textAlign(CENTER);
      fill(0);
      textFont(font, 16);
      text("Worst Creature", 830, 310);
      text("Median Creature", 990, 310);
      text("Best Creature", 1150, 310);
    }
    if (justGotBack) justGotBack = false;
  }
  if (statusWindow >= -3) {
    drawStatusWindow(prevStatusWindow == -4);
    if (statusWindow >= -3 && !miniSimulation) {
      openMiniSimulation();
    }
  }
  /*if(menu >= 1){
   fill(255);
   rect(0,705,100,15);
   fill(0);
   textAlign(LEFT);
   textFont(font,12);
   int g = gensToDo;
   if(gensToDo >= 10000){
   g = 1000000000-gensToDo;
   }
   text(g,2,715);
   }*/
  overallTimer++;
}
String percentify(float n){
  return nf(n*100,0,2)+"%";
}
float getSB(int g){
  return 1.0;
  //return 0.7+0.3*cos(g*(2*PI)/50.0);
}
void keysToMoveCamera(){
  if(keyPressed){
    if(key == 'w'){
      camVA -= CAMERA_MOVE_SPEED;
    }
    if(key == 's'){
      camVA += CAMERA_MOVE_SPEED;
    }
    if(key == 'a'){
      camHA -= CAMERA_MOVE_SPEED;
    }
    if(key == 'd'){
      camHA += CAMERA_MOVE_SPEED;
    }
    /*if(key == 'i'){
      for(int i = 2; i < n.size(); i++){
        n.get(i).vy -= 0.03;
      }
    }
    if(key == 'j'){
      for(int i = 2; i < n.size(); i++){
        n.get(i).vx -= 0.03;
      }
    }
    if(key == 'k'){
      for(int i = 2; i < n.size(); i++){
        n.get(i).vy += 0.03;
      }
    }
    if(key == 'l'){
      for(int i = 2; i < n.size(); i++){
        n.get(i).vx += 0.03;
      }
    }*/
  }
  camVA = min(max(camVA,-PI*0.499),-PI*0.001);
}
void keyPressed(){
  if(key == 't'){
    foodAngleChange += 5.0/360.0*(2*PI);
    setMenu(1);
  }
  if(key == 'g'){
    foodAngleChange -= 5.0/360.0*(2*PI);
    setMenu(1);
  }
}
void drawStats(float x, float y, float z, float size){
  textAlign(RIGHT);
  textFont(font, 32);
  fill(0);
  pushMatrix();
  translate(x,y,z);
  scale(size);
  text(toRealName(currentCreature.name), 0, 32);
  text("Creature ID: "+currentCreature.id, 0, 64);
  text("Time: "+nf(timer/60.0,0,2)+" / 15 sec.", 0, 96);
  text("Playback Speed: x"+max(1,speed), 0, 128);
  String extraWord = "used";
  if(energyDirection == -1){
    extraWord = "left";
  }
  text("X: "+nf(averageX/5.0,0,2)+"", 0, 160);
  text("Y: "+nf(-averageY/5.0,0,2)+"", 0, 192);
  text("Z: "+nf(-averageZ/5.0,0,2)+"", 0, 224);
  //text("Energy "+extraWord+": "+nf(energy,0,2)+" yums", 0, 256);
  //text("A.N.Nausea: "+nf(averageNodeNausea,0,2)+" blehs", 0, 256);
  
  popMatrix();
}
String toRealName(int[] n){
  String[] parts = patronData[n[0]].split(",");
  if(parts[1].length() == 0){
    return parts[0]+"'s "+rankify(n[1]+1)+" creature";
  }else{
    return parts[0]+" "+parts[1]+"'s "+rankify(n[1]+1)+" creature";
  }
}
String toRealSpeciesName(int n){
  String[] parts = patronData[n].split(",");
  if(parts[1].length() == 0){
    return parts[0];
  }else{
    return parts[0]+" "+parts[1];
  }
}
void drawBrain(float x, float y, float z, float size, Creature c){
  pushMatrix();
  translate(x,y,z);
  scale(size);
  currentCreature.brain.drawBrain(size,currentCreature);
  popMatrix();
}
void drawSkipButton(){
  fill(0);
  rect(0,windowHeight-40,90,40);
  fill(255);
  textAlign(CENTER);
  textFont(font, 32);
  text("SKIP",45,windowHeight-8);
}
void drawOtherButtons(){
  fill(0);
  rect(120,windowHeight-40,240,40);
  fill(255);
  textAlign(CENTER);
  textFont(font, 32);
  text("PB speed: x"+speed,240,windowHeight-8);
  fill(0);
  rect(windowWidth-120,windowHeight-40,120,40);
  fill(255);
  textAlign(CENTER);
  textFont(font, 32);
  text("FINISH",windowWidth-60,windowHeight-8);
}
void setGlobalVariables(Creature thisCreature) {
  currentCreature = thisCreature.copyCreature(-1,false,true);
  timer = 0;
  camZoom = 0.01;
  camX = 0;
  camY = 0;
  camVA = -0.5;
  camHA = 0.0;
  simulationTimer = 0;
  energy = baselineEnergy;
  totalNodeNausea = 0;
  averageNodeNausea = 0;
  cumulativeAngularVelocity = 0;
  foodAngle = 0.0;
  chomps = 0;
  foodX = 0;
  foodY = 0;
  foodZ = 0;
  setFoodLocation();
}
void setFoodLocation(){
  setAverages();
  foodAngle += currentCreature.foodPositions[chomps][0];
  float sinA = sin(foodAngle);
  float cosA = cos(foodAngle);
  float furthestNodeForward = 0;
  for(int i = 0; i < currentCreature.n.size(); i++){
    Node ni = currentCreature.n.get(i);
    float newX = (ni.x-averageX)*cosA-(ni.z-averageZ)*sinA;
    if(newX >= furthestNodeForward){
      furthestNodeForward = newX;
    }
  }
  float d = MIN_FOOD_DISTANCE+(MAX_FOOD_DISTANCE-MIN_FOOD_DISTANCE)*currentCreature.foodPositions[chomps][2];
  foodX = foodX+cos(foodAngle)*(furthestNodeForward+d);
  foodZ = foodZ+sin(foodAngle)*(furthestNodeForward+d);
  foodY = currentCreature.foodPositions[chomps][1];
  startingFoodDistance = getCurrentFoodDistance();
}
float getCurrentFoodDistance(){
  float closestDist = 9999;
  for(int i = 0; i < currentCreature.n.size(); i++){
    Node n = currentCreature.n.get(i);
    float distFromFood = dist(n.x,n.y,n.z,foodX,foodY,foodZ)-0.4;
    if(distFromFood < closestDist){
      closestDist = distFromFood;
    }
  }
  return closestDist;
}
int[] getNewCreatureName(){
  float indexOfChoice = random(0,TOTAL_PLEDGED);
  float runningTotal = 0;
  for(int i = 0; i < patronData.length; i++){
    String[] parts = patronData[i].split(",");
    runningTotal += Float.parseFloat(parts[3]);
    if(runningTotal >= indexOfChoice){
      int[] result = new int[2];
      result[0] = i;
      result[1] = CREATURES_PER_PATRON[i];
      CREATURES_PER_PATRON[i]++;
      return result;
    }
  }
  return null;
}
String rankify(int s){
  if(s >= 11 && s <= 19){
    return s+"th";
  }else if(s%10 == 1){
    return s+"st";
  }else if(s%10 == 2){
    return s+"nd";
  }else if(s%10 == 3){
    return s+"rd";
  }else{
    return s+"th";
  }
}
float getFitness(){
  Boolean hasNodeOffGround = false;
  for(int i = 0; i < currentCreature.n.size(); i++){
    if(currentCreature.n.get(i).y <= -0.2001){
      hasNodeOffGround = true;
    }
  }
  if(hasNodeOffGround){
    float withinChomp = max(1.0-getCurrentFoodDistance()/startingFoodDistance,0);
    return chomps+withinChomp;//cumulativeAngularVelocity/(n.size()-2)/pow(averageNodeNausea,0.3);//   /(2*PI)/(n.size()-2); //dist(0,0,averageX,averageZ)*0.2; // Multiply by 0.2 because a meter is 5 units for some weird reason.
  }else{
    return 0;
  }
}
void setFitness(int i){
  c[i].d = getFitness();
}
