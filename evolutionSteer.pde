import java.io.*;
import java.io.BufferedReader;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonEncoding;
import com.fasterxml.jackson.core.JsonToken;
import com.fasterxml.jackson.dataformat.smile.SmileGenerator;
import com.fasterxml.jackson.dataformat.smile.SmileFactory;


float windowSizeMultiplier = 1;
int SEED = 314; //7;  ;(

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

static int nbCreatures = 2000; // please set even number
int gridX = 50; // X * Y must be equal to nbCreatures !
int gridY = 40;
int thresholdName = 25; // name of species is showed over this threshold

int autoSave = 200; // autosave every x generation in ALAP mode
boolean autoSaveTimecode = true; // set to false is disk space limited
boolean hasAutosaveWorked = false;
int autoPause = 10000; // pauses ALAP each x generation

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
int gridHeightCrop = 100;
int timer = 0;
float camX = 0;
float camY = 0;
float camZ = 0;
float camHA = 0;
float camVA = -0.5;
int frames = 60;
int simDuration = 15; // in seconds
int jumperDuration = 1; // definition of jumper : chomp < this value (in seconds)
int maxFrames = simDuration*frames;
int maxSimulationFrames = simDuration*frames;
int jumperFrames = jumperDuration*frames;
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
int[] creaturesInPosition = new int[nbCreatures];
Creature[] c = new Creature[nbCreatures];

float camZoom = 0.015;
float gravity = 0.006;//0.007;
float airFriction = 0.95;
float MIN_FOOD_DISTANCE = 1;
float MAX_FOOD_DISTANCE = 2.5;

int speed;
boolean stepbystep;
boolean stepbystepslow;
boolean slowDies;
int[] pPercentages = {
  0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 
  100, 200, 300, 400, 500, 600, 700, 800, 900, 910, 920, 930, 940, 950, 960, 970, 980, 990, 999
};
int[] p = new int[29];
final int BRAIN_WIDTH = 3;
float STARTING_AXON_VARIABILITY = 1.0;
float AXON_START_MUTABILITY = 0.0005;

boolean enableRadioactivity = false;
int radioactiveNumber = 400; // number of highly mutated creatures
int freshBloodNumber = 0; // number of brand new creatures
float radioactiveMutator = 1.5;

boolean massExtinction = false;

String[] patronData;
int PATRON_COUNT = 75;
float TOTAL_PLEDGED = 183.39;
int[] CREATURES_PER_PATRON = new int[PATRON_COUNT];
float startingFoodDistance = 0;

int THREAD_COUNT = 14;
boolean activateMultiThreading = true;

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
  float averageX = 0;
  float averageY = 0;
  float averageZ = 0;
  if(currentCreature != null) {
    averageX = currentCreature.averageX;
    averageY = currentCreature.averageY;
    averageZ = currentCreature.averageZ;
  }
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
  float averageX = 0;
  float averageY = 0;
  float averageZ = 0;
  if(currentCreature != null) {
    averageX = currentCreature.averageX;
    averageY = currentCreature.averageY;
    averageZ = currentCreature.averageZ;
  }
  float foodX = 0;
  float foodY = 0;
  float foodZ = 0;
  if(currentCreature != null) {
    foodX = currentCreature.foodX;
    foodY = currentCreature.foodY;
    foodZ = currentCreature.foodZ;
  }
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
  String fitnessString = nf(currentCreature.getFitness(),0,2)+" "+fitnessUnit;
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
      if (c >= thresholdName) {
        float y = ((s[i]+s[i-1])/2)/float(nbCreatures)*100+573;
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
      segBarImage.vertex(barX1, y+speciesCounts.get(i)[j]/float(nbCreatures)*graphHeight);
      segBarImage.vertex(barX1, y+speciesCounts.get(i)[j+1]/float(nbCreatures)*graphHeight);
      segBarImage.vertex(barX2, y+speciesCounts.get(i2)[j+1]/float(nbCreatures)*graphHeight);
      segBarImage.vertex(barX2, y+speciesCounts.get(i2)[j]/float(nbCreatures)*graphHeight);
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
//Creature[] c = new Creature[nbCreatures];
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
  maxSimulationFrames = simDuration*frames;
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
  }else if(menu == 0 && abs(mX -windowWidth/2) <=150 && abs(mY - 600) <=50){
    setMenu(14);
    selectInput("Select a file to load", "fileSelected");
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
  }else if(menu == 1 && gen !=  -1 && abs(mX - 650) <= 50 && abs(mY - 90) <= 20){
    setMenu(15);
    selectOutput("Select file to save simulation to",  "saveSelected");
  }else if (menu == 3 && abs(mX-1030) <= 130 && abs(mY-684) <= 20) {
    gen = 0;
    setMenu(1);
  } else if (menu == 7 && abs(mX-1030) <= 130 && abs(mY-684) <= 20) {
    setMenu(8);
  } else if((menu == 5 || menu == 4) && mY >= windowHeight-40){
    if(mX < 90){
      maxFrames = simDuration*frames;
      for (int s = timer; s < maxFrames; s++) {
        if(simulateCurrentCreature()){ maxFrames += simDuration*frames; }
      }
      timer = 1021;
    }else if(mX >= 120 && mX < 360){
      speed *= 2;
      if(speed == 1024) speed = simDuration*frames;
      if(speed >= 1800) speed = 1;
    }else if(mX >= windowWidth-120){
      maxFrames = simDuration*frames;
      for (int s = timer; s < maxFrames; s++) {
        if(simulateCurrentCreature()){ maxFrames += simDuration*frames; }
      }
      timer = 0;
      creaturesTested++;
      for (int i = creaturesTested; i < nbCreatures; i++) {
        maxFrames = simDuration*frames;
        for (int s = 0; s < maxFrames; s++) {
          if(simulateCurrentCreature()){ maxFrames += simDuration*frames; }
        }
        currentCreature.setAverages();
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
boolean simulateCurrentCreature(){
  boolean hasEaten = currentCreature.simulate();
  averageNodeNausea = totalNodeNausea/currentCreature.n.size();
  simulationTimer++;
  timer++;
  return hasEaten;
}
void drawScreenImage(int stage) {
  screenImage.beginDraw();
  screenImage.pushMatrix();
  screenImage.scale(10.0*windowSizeMultiplier/scaleToFixBug);
  screenImage.background(gridBGColor);
  screenImage.noStroke();
  for (int j = 0; j < nbCreatures; j++) {
    Creature cj = c2.get(j);
    if (stage == 3) cj = c[cj.id-(gen*nbCreatures)-(nbCreatures+1)];
    int j2 = j;
    if (stage == 0) {
      j2 = cj.id-(gen*nbCreatures)-1;
      creaturesInPosition[j2] = j;
    }
    int x = j2%gridX;
    int y = floor(j2/gridX);
    float xWidth = windowWidth / (gridX+1) / 10.0;
    float yHeight = (windowHeight - gridHeightCrop)  / (gridY+1) / 10.0;
    //if (stage >= 1) y++;
    screenImage.pushMatrix();
    screenImage.translate(((x+1)*xWidth)*scaleToFixBug, ((y+0.5)*yHeight+(gridHeightCrop/20.0))*scaleToFixBug, 0);
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
    screenImage.text("All "+nbCreatures+" creatures have been tested.  Now let's sort them!", windowWidth/2-200, 690);
    screenImage.text("Sort", windowWidth-250, 690);
  } else if (stage == 1) {
    screenImage.rect(900, 670, 260, 40);
    screenImage.fill(0);
    screenImage.text("Fastest creatures at the top!", windowWidth/2, 30);
    screenImage.text("Slowest creatures at the bottom. (Going backward = slow)", windowWidth/2-200, 700);
    screenImage.text("Kill "+(nbCreatures/2), windowWidth-250, 700);
  } else if (stage == 2) {
    screenImage.rect(1050, 670, 160, 40);
    screenImage.fill(0);
    screenImage.text("Faster creatures are more likely to survive because they can outrun their predators.  Slow creatures get eaten.", windowWidth/2, 30);
    screenImage.text("Because of random chance, a few fast ones get eaten, while a few slow ones survive.", windowWidth/2-130, 700);
    screenImage.text("Reproduce", windowWidth-150, 700);
    for (int j = 0; j < nbCreatures; j++) {
      Creature cj = c2.get(j);
      int x = j%gridX;
      int y = floor(j/gridX);//+1;
      float xWidth = windowWidth / (gridX+1);
      float yHeight = (windowHeight - gridHeightCrop) / (gridY+1);
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
        screenImage.vertex((x+1)*xWidth-15, (y+0.5)*yHeight+(gridHeightCrop/2)-12,0.01);
        screenImage.vertex((x+1)*xWidth+15, (y+0.5)*yHeight+(gridHeightCrop/2)-12,0.01);
        screenImage.vertex((x+1)*xWidth+15, (y+0.5)*yHeight+(gridHeightCrop/2)+12,0.01);
        screenImage.vertex((x+1)*xWidth-15, (y+0.5)*yHeight+(gridHeightCrop/2)+12,0.01);
        screenImage.endShape();
      }
    }
  } else if (stage == 3) {
    screenImage.rect(1050, 670, 160, 40);
    screenImage.fill(0);
    screenImage.text("These are the "+nbCreatures+" creatures of generation #"+(gen+2)+".", windowWidth/2, 30);
    screenImage.text("What perils will they face?  Find out next time!", windowWidth/2-130, 700);
    screenImage.text("Back", windowWidth-150, 700);
  }
  screenImage.popMatrix();
  screenImage.endDraw();
}
void drawpopUpImage() {
  currentCreature.setAverages();
  moveCamera();
  popUpImage.beginDraw();
  
  float camDist = (450/2.0) / tan(PI*30.0 / 180.0);
  popUpImage.pushMatrix();
  
  popUpImage.camera(camX/camZoom+camDist*sin(camHA)*cos(camVA),
  camY/camZoom+camDist*sin(camVA), camZ/camZoom+camDist*cos(camHA)*cos(camVA),
  camX/camZoom, camY/camZoom, camZ/camZoom, 0, 1, 0);
  
  popUpImage.scale(1.0/camZoom/scaleToFixBug);
  
  if (simulationTimer < maxSimulationFrames) {
    popUpImage.background(120, 200, 255);
  } else {
    popUpImage.background(60, 100, 128);
  }
  drawPosts(popUpImage);
  drawGround(popUpImage);
  currentCreature.drawCreature(popUpImage,false);
  drawArrow(currentCreature.averageX,currentCreature.averageY,currentCreature.averageZ,popUpImage);
  popUpImage.noStroke();
  popUpImage.endDraw();
  popUpImage.popMatrix();
}
void moveCamera(){
  float averageX = 0;
  float averageY = 0;
  float averageZ = 0;
  if(currentCreature != null) {
    averageX = currentCreature.averageX;
    averageY = currentCreature.averageY;
    averageZ = currentCreature.averageZ;
  }
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
  float xWidth = windowWidth / (gridX+1);
  float yHeight = (windowHeight - gridHeightCrop) / (gridY+1);
  Creature cj;
  stroke(abs(overallTimer%30-15)*17);
  strokeWeight(3);
  noFill();
  if (statusWindow >= 0) {
    cj = c2.get(statusWindow);
    if (menu == 7) {
      int id = ((cj.id-1)%nbCreatures);
      x = id%gridX;
      y = floor(id/gridX);
    } else {
      x = statusWindow%gridX;
      y = floor(statusWindow/gridX);//+1;
    }
    px = floor((x+1)*xWidth);
    py = floor((y+0.5)*yHeight+(gridHeightCrop/2)-19);
    if (px <= 1140) {
      px += 80;
    } else {
      px -= 80;
    }
    rect((x+1)*xWidth-15, (y+0.5)*yHeight+(gridHeightCrop/2)-12, 30, 25);
  } else {
    cj = creatureDatabase.get((genSelected-1)*3+statusWindow+3);
    x = 760+(statusWindow+3)*160;
    y = 180;
    px = x;
    py = y;
    rect(x, y, 140, 140);
    int[] ranks = {
      nbCreatures, nbCreatures/2, 1
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
    
    if(simulateCurrentCreature()){ maxSimulationFrames += simDuration*frames; }
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
void settings(){
  size(int(windowWidth*windowSizeMultiplier), int(windowHeight*windowSizeMultiplier),P3D);
  smooth();
}
void initPercentiles(){
  for (int i = 1; i < 29; i++) {
    p[i] = int(floor(float(pPercentages[i])*float(nbCreatures)/1000.0));
  };
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
  initPercentiles();
  frameRate(60);
  randomSeed(SEED);
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
    beginSpecies[i] = nbCreatures/2;
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
  segBarImage.background(220);
  segBarImage.endDraw();
  popUpImage.beginDraw();
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
    rect(windowWidth/2-150, 550, 300, 100);
    fill(0);
    textSize(60);
    text("EVOLUTION!", windowWidth/2, 200);
    text("START", windowWidth/2, 430);
    textSize(26);
    text("Load simulation", windowWidth/2, 600);
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
      text("Since there are no creatures yet, create "+nbCreatures+" creatures!", 20, 160);
      text("They will be randomly created, and also very simple.", 20, 200);
      text("CREATE", 56, 312);
    } else {
      fill(100, 200, 100);
      rect(760, 20, 460, 40);
      rect(760, 70, 460, 40);
      rect(760, 120, 230, 40);
      rect(600, 70, 100, 40);
      if (gensToDo >= 2) {
        fill(128, 255, 128);
      } else {
        fill(70, 140, 70);
      }
      rect(990, 120, 230, 40);
      fill(0);
      //text("Survivor Bias: "+percentify(getSB(genSelected)), 437, 50);
      text("Curve: ±"+nf(foodAngleChange/(2*PI)*360,0,2)+" degrees", 420, 50);
      if(enableRadioactivity){
         text("Radioactive mode", 460, 130);
      }
      text("Do 1 step-by-step generation.", 770, 50);
      text("Do 1 quick generation.", 770, 100);
      text("Do 1 gen ASAP.", 770, 150);
      text("Do gens ALAP.", 1000, 150);
      text("Median "+fitnessName, 50, 160);
      text("Save", 610, 100);
      textAlign(CENTER);
      textAlign(RIGHT);
      text(float(round(percentile.get(min(genSelected, percentile.size()-1))[14]*nbCreatures))/nbCreatures+" "+fitnessUnit, 700, 160);
      drawHistogram(760, 410, 460, 280);
      drawGraphImage();
      //if(saveFramesPerGeneration && gen > lastImageSaved){
      //  saveFrame("imgs//"+zeros(gen,5)+".png");
      //  lastImageSaved = gen;
      //}
      if(massExtinction){
         text("MASS EXTINCTION", 400, 210);
      }
    }
    if (gensToDo >= 1) {
      gensToDo--;
      if (gensToDo >= 1) {
        startASAP();
      }
    }
  }else if (menu == 2) {
    creatures = 0;
    for (int y = 0; y < gridY; y++) {
      for (int x = 0; x < gridX; x++) {
        c[y*gridX+x] = createNewCreature(y*gridX+x);
        c[y*gridX+x].checkForOverlap();
        c[y*gridX+x].checkForLoneNodes();
        c[y*gridX+x].toStableConfiguration();
        c[y*gridX+x].moveToCenter();
      }
    }
    creatures = 0;
    screenImage.beginDraw();
    screenImage.background(gridBGColor);
    screenImage.scale(windowSizeMultiplier);
    screenImage.pushMatrix();
    screenImage.scale(10.0/scaleToFixBug);
    float xWidth = windowWidth / (gridX+1) / 10.0;
    float yHeight = (windowHeight - gridHeightCrop) / (gridY+1) / 10.0;
    for (int y = 0; y < gridY; y++) {
      for (int x = 0; x < gridX; x++) {
        screenImage.pushMatrix();
        screenImage.translate(((x+1)*xWidth)*scaleToFixBug, ((y+1)*yHeight+gridHeightCrop/20.0)*scaleToFixBug, 0);
        c[y*gridX+x].drawCreature(screenImage,true);
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
    screenImage.text("Here are your "+nbCreatures+" randomly generated creatures!!!", windowWidth/2-200, 690);
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
      long start = System.nanoTime();
      Thread[] threads = new Thread[THREAD_COUNT];
      int previousLastIndex = 0;
      for(int i = 0; i < threads.length; i++) {
        int firstIndex = previousLastIndex;
        int lastIndex;
        if(i == threads.length - 1) {
          lastIndex = nbCreatures;
        } else {
          lastIndex = (int)((i+1) * float(nbCreatures) / threads.length);
        }
        threads[i] = new Thread(new ComputingThread(firstIndex, lastIndex, simDuration*frames));
        if(activateMultiThreading){
          threads[i].start();
        }
        previousLastIndex = lastIndex;
      }
      for(int i = 0; i < threads.length; i++) {
        try {
          if(activateMultiThreading){
            threads[i].join();
          } else {
            threads[i].run();
          }
        } catch (InterruptedException ie) {
          ie.printStackTrace(); // :(
        }
      }
      double simulationTime = Math.round((System.nanoTime() - start) / 100000D) / 10;
      surface.setTitle("evolutionSteer | simulationTime: " + simulationTime + " ms");
      //println(simulationTime);
      setMenu(6);
    }
  }
  if (menu == 5) { //simulate running
    maxFrames = simDuration*frames;
    if (timer <= maxFrames) {
      background(255);
      keysToMoveCamera();
      simulationImage.beginDraw();
      simulationImage.background(120, 200, 255);
      for (int s = 0; s < speed; s++) {
        if (timer < simDuration*frames) {
          if(simulateCurrentCreature()){ maxFrames += simDuration*frames; }
        }
      }
      currentCreature.setAverages();
      if (speed < 30) {
        for (int s = 0; s < speed; s++) {
          moveCamera();
        }
      } else {
        camX = currentCreature.averageX;
        camY = currentCreature.averageY;
        camZ = currentCreature.averageZ;
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
      drawArrow(currentCreature.averageX,currentCreature.averageY,currentCreature.averageZ,simulationImage);
      simulationImage.popMatrix();
      simulationImage.endDraw();
      image(simulationImage,0,0,width/windowSizeMultiplier,
      height/windowSizeMultiplier);
      drawBrain(40,20,0,5,currentCreature);
      drawStats(windowWidth-10,0,0,0.7);
      drawSkipButton();
      drawOtherButtons();
    }
    if (timer == maxFrames) {
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
        text(nf(currentCreature.getFitness(),0,2) + " "+fitnessUnit, windowWidth/2, 400);
      } else {
        timer = maxFrames+(2*frames);
      }
      setFitness(creaturesTested);
    }
    if (timer >= maxFrames+(2*frames)) {
      setMenu(4);
      creaturesTested++;
      if (creaturesTested == nbCreatures) {
        setMenu(6);
      }
      camX = 0;
    }
    if (timer >= simDuration*frames) {
      timer += speed;
    }
  }
  if (menu == 6) {
    //sort
    c2 = new ArrayList<Creature>(0);
    for(int i = 0; i < nbCreatures; i++){
      c2.add(c[i]);
    }
    c2 = quickSort(c2);
    percentile.add(new Float[29]);
    for (int i = 0; i < 29; i++) {
      percentile.get(gen+1)[i] = c2.get(p[i]).d;
    }
    creatureDatabase.add(c2.get(nbCreatures-1).copyCreature(-1,false,false));
    creatureDatabase.add(c2.get(nbCreatures/2-1).copyCreature(-1,false,false));
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
    for (int i = 0; i < nbCreatures; i++) {
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
    float xWidth = windowWidth / (gridX+1) / 10.0;
    float yHeight = (windowHeight - gridHeightCrop) / (gridY+1) / 10.0;
    for (int j = 0; j < nbCreatures; j++) {
      Creature cj = c2.get(j);
      int j2 = cj.id-(gen*nbCreatures)-1;
      int x1 = j2%gridX;
      int y1 = floor(j2/gridX);
      int x2 = j%gridX;
      int y2 = floor(j/gridX)+1;
      float x3 = inter(x1, x2, transition);
      float y3 = inter(y1, y2, transition);
      screenImage.translate(((x3+1)*xWidth)*scaleToFixBug, ((y3+0.5)*yHeight-(gridHeightCrop/2))*scaleToFixBug, 0);
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
  } else if(menu == 14){
    fill(0);
    background(255, 200, 130);
    textSize(60);
    text("Please wait while loading...", windowWidth/2, 200);
  } else if(menu == 15){
    fill(0);
    background(255, 200, 130);
    textSize(60);
    text("Please wait while saving...", windowWidth/2, 200);
  }
  float mX = mouseX/windowSizeMultiplier;
  float mY = mouseY/windowSizeMultiplier;
  float xWidth = windowWidth / (gridX+1);
  float yHeight = (windowHeight - gridHeightCrop) / (gridY+1);
  prevStatusWindow = statusWindow;
  if (abs(menu-9) <= 2 && gensToDo == 0 && !drag) {
    int mXI = floor((mX-(xWidth/2))/xWidth);
    int mYI = floor((mY-(gridHeightCrop/2))/yHeight);
    if(mXI < 0 || mXI >= gridX){ mXI = -1; }
    if(mYI < 0 || mYI >= gridY){ mYI = -1; }
    if (menu == 7 && mXI >= 0 && mYI >= 0) {
        statusWindow = creaturesInPosition[mXI+mYI*gridX];
    } else if (menu >= 9 && mXI >= 0 && mYI >= 0) {
        statusWindow = mXI+mYI*gridX;
    } else {
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
    for (int j = 0; j < nbCreatures/2; j++) {
      if(random(0,1) < getSB(gen)){
        float f = float(j)/nbCreatures;
        float rand = (pow(random(-1, 1), 3)+1)/2; //cube function
        slowDies = (f <= rand);
      }else{
        slowDies = (random(0,1) < 0.5);
      }
      int j2;
      int j3;
      if (slowDies) {
        j2 = j;
        j3 = nbCreatures-1-j;
      } else {
        j2 = nbCreatures-1-j;
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
    for (int j = 0; j < nbCreatures/2; j++) {
      int j2 = j;
      if (!c2.get(j).alive) j2 = nbCreatures-1-j;
      Creature cj = c2.get(j2);
      Creature cj2 = c2.get(nbCreatures-1-j2);
      
      if(massExtinction && random(0,1) < 0.5){ // mass extinction
        c2.set(j2, createNewCreature(cj.id+nbCreatures-1)); // new creatures arises !
        c2.set(nbCreatures-1-j2, createNewCreature(cj2.id+nbCreatures-1));
      } else {
        c2.set(j2, cj.copyCreature(cj.id+nbCreatures,true,false));        //duplicate
        if(enableRadioactivity && j >= nbCreatures/2 - freshBloodNumber) {
          c2.set(nbCreatures-1-j2, createNewCreature(cj2.id+nbCreatures-1));   //brand new creatures  
        } else if(enableRadioactivity && j >= nbCreatures/2 - radioactiveNumber - freshBloodNumber){
          c2.set(nbCreatures-1-j2, cj.modified(cj2.id+nbCreatures, radioactiveMutator));   //radioactive offspring        
        } else {
          c2.set(nbCreatures-1-j2, cj.modified(cj2.id+nbCreatures, 1.0));   //mutated offspring 1
        }
      }
    }
    for (int j = 0; j < nbCreatures; j++) {
      Creature cj = c2.get(j);
      c[cj.id-(gen*nbCreatures)-nbCreatures-1] = cj.copyCreature(-1,false,false);
    }
    drawScreenImage(3);
    gen++;
    massExtinction = false;
    if (stepbystep) {
      setMenu(13);
    } else {
      if(autoSave > 0 && gen > 0){
          if(gen%autoSave == 0){
            hasAutosaveWorked = false;
            saveSelected(new File(dataPath("")+"/autosave-tmp.gz"));
            if(hasAutosaveWorked){
              String finalfilename = "";
              if(autoSaveTimecode){
                finalfilename = dataPath("")+"/autosave-"+year()+"-"+month()+"-"+day()+"_"+hour()+"-"+minute()+"-"+second()+".gz";
              } else {
                finalfilename = dataPath("")+"/autosave.gz";
              }
              try{
                Path source = Paths.get(dataPath("")+"/autosave-tmp.gz");
                File autosaveGenuine = new File(finalfilename);
                if(autosaveGenuine.isFile()) { 
                    autosaveGenuine.delete();
                }
                Files.move(source, Paths.get(finalfilename));
              } catch(Exception e){
                writeToErrorLog(e);
              }
            }
          }
      }
      if(autoPause > 0){ 
         if(gen%autoPause == 0){
           gensToDo = 0;
         }
      }
      setMenu(1);
    }
  }
  if(menu%2 == 1 && abs(menu-10) <= 3){
    background(gridBGColor);
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
  if(key == 'r'){
    enableRadioactivity = !enableRadioactivity;
    setMenu(1);
  }
  if(key == 'k'){
    massExtinction = true;
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
  text("Time: "+nf(float(timer)/float(frames),0,2)+" / "+simDuration+" sec.", 0, 96);
  text("Playback Speed: x"+max(1,speed), 0, 128);
  String extraWord = "used";
  if(energyDirection == -1){
    extraWord = "left";
  }
  text("X: "+nf(currentCreature.averageX/5.0,0,2)+"", 0, 160);
  text("Y: "+nf(-currentCreature.averageY/5.0,0,2)+"", 0, 192);
  text("Z: "+nf(-currentCreature.averageZ/5.0,0,2)+"", 0, 224);
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
  totalNodeNausea = 0;
  averageNodeNausea = 0;
  cumulativeAngularVelocity = 0;
  currentCreature.calculateNextFoodLocation();
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
void setFitness(int i){
  c[i].d = currentCreature.getFitness();
}

Creature createNewCreature(int index){
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
  return new Creature(null, index+1, new ArrayList<Node>(n), new ArrayList<Muscle>(m), 0, true, heartbeat, 1.0, null, null); 
}
public void writeToErrorLog(Exception e){
      String[] error = new String[100];
      error[0] = e.toString();
      for(int i = 0; i < e.getStackTrace().length; i++){
        error[i+1] = e.getStackTrace()[i].toString();
      }
      saveStrings("error.log", error);
}

public void fileSelected(File file){
  if(file != null){
    try{
      JsonFactory factory = new SmileFactory();
      JsonParser p = factory.createParser(new GZIPInputStream(new FileInputStream(file.getAbsolutePath())));
      loadFromJson(p);
      setMenu(1);
      randomSeed(SEED);
    }catch(Exception e){
      writeToErrorLog(e);
    }
  } else {
    setMenu(1);
  }
}

public void saveSelected(File file){
  if(file != null){
    try{
      JsonFactory factory = new SmileFactory();
      GZIPOutputStream out = new GZIPOutputStream(new FileOutputStream(file.getAbsolutePath()));
      JsonGenerator generator = factory.createGenerator(out, JsonEncoding.UTF8);
      generator.writeStartObject();
      saveToJson(generator);
      generator.writeEndObject();
      generator.close();
      out.close();
      hasAutosaveWorked = true;
      setMenu(1);
    }catch(Exception e){
      writeToErrorLog(e);
    }
  } else {
    setMenu(1);
  }
}

public void saveToJson(JsonGenerator g){
  try{
    g.writeNumberField("version", 1);
    g.writeNumberField("seed", SEED);
    g.writeNumberField("foodChange", foodAngleChange);
    g.writeNumberField("gen", gen);
    g.writeNumberField("nbcreatures", nbCreatures);
    g.writeNumberField("gridX", gridX);
    g.writeNumberField("gridY", gridY);
    g.writeArrayFieldStart("creatureDatabase");
    for(int i = 0; i < creatureDatabase.size(); i++){
      if(creatureDatabase.get(i) != null){
        g.writeStartObject(); creatureDatabase.get(i).saveToJson(g); g.writeEndObject();
      }
    }
    g.writeEndArray();
    g.writeArrayFieldStart("barCounts");
    for(int i = 0; i < barCounts.size();  i++){
      g.writeStartArray();
      for(int j = 0; j < barCounts.get(i).length; j++){
        g.writeNumber(barCounts.get(i)[j]);
      }
      g.writeEndArray();
    }
    g.writeEndArray();
    g.writeArrayFieldStart("percentiles");
    for(int i = 0; i < percentile.size();  i++){
      g.writeStartArray();
      for(int j = 0; j < percentile.get(i).length; j++){
        g.writeNumber(percentile.get(i)[j]);
      }
      g.writeEndArray();
    }
    g.writeEndArray();
    g.writeArrayFieldStart("species");
    for(int i = 0; i < speciesCounts.size();  i++){
      g.writeStartArray();
      for(int j = 0; j < speciesCounts.get(i).length; j++){
        g.writeNumber(speciesCounts.get(i)[j]);
      }
      g.writeEndArray();
    }
    g.writeEndArray();
    g.writeArrayFieldStart("creatureArray");
    for(int i = 0; i < c.length; i++){
      g.writeStartObject(); c[i].saveToJson(g); g.writeEndObject();
    }
    g.writeEndArray();
    g.writeArrayFieldStart("topSpecies");
    for(int i = 0; i < topSpeciesCounts.size(); i++){
      g.writeNumber(topSpeciesCounts.get(i));
    }
    g.writeEndArray();
  } catch(Exception e){
    writeToErrorLog(e);
  }
}

public void loadFromJson(JsonParser p){
  try{
    if (p.nextToken() != JsonToken.START_OBJECT) {
      throw new IOException("Expected data to start with an Object");
    }
    while(p.nextToken() != JsonToken.END_OBJECT){
      String fieldName = p.getCurrentName();
      JsonToken token = p.nextToken();
      if(fieldName.equals("seed")){ SEED = p.getIntValue(); }
      else if(fieldName.equals("foodChange")){ foodAngleChange = p.getFloatValue(); }
      else if(fieldName.equals("gen")){ gen = p.getIntValue(); genSelected = gen; }
      else if(fieldName.equals("nbcreatures")){ nbCreatures = p.getIntValue(); initPercentiles(); }
      else if(fieldName.equals("gridX")){ gridX = p.getIntValue(); }
      else if(fieldName.equals("gridY")){ gridX = p.getIntValue(); }
      else if(fieldName.equals("creatureDatabase")){
        creatureDatabase.clear();
        if (token != JsonToken.START_ARRAY) { throw new IOException("Expected Array"); }
        while((token = p.nextToken()) != JsonToken.END_ARRAY){
          if (token == JsonToken.START_OBJECT){
            Creature creature = new Creature(new int[2], 0, new ArrayList<Node>(),  new ArrayList<Muscle>(), 0, false, 0, 0, null, new float[100][3]);
            creature.loadFromJson(p);
            creatureDatabase.add(creature);
          }
        }
      }
      else if(fieldName.equals("barCounts")){
        barCounts.clear();
        if (token != JsonToken.START_ARRAY) { throw new IOException("Expected Array"); }
        int i = 0;
        while((token = p.nextToken()) != JsonToken.END_ARRAY){
          if (token == JsonToken.START_ARRAY){
            int j = 0;
            Integer[] tmpBar = new Integer[barLen];
            while(p.nextToken() != JsonToken.END_ARRAY){
              tmpBar[j] = p.getIntValue();
              j += 1;
            }
            barCounts.add(tmpBar);
            i += 1;
          }
        }          
      }
      else if(fieldName.equals("percentiles")){
        percentile.clear();
        if (token != JsonToken.START_ARRAY) { throw new IOException("Expected Array"); }
        while((token = p.nextToken()) != JsonToken.END_ARRAY){
          if (token == JsonToken.START_ARRAY){
            int j = 0;
            Float[] tmpPercentile = new Float[29];
            while(p.nextToken() != JsonToken.END_ARRAY){
              tmpPercentile[j] = p.getFloatValue();
              j += 1;
            }
            percentile.add(tmpPercentile);
          }
        }          
      }
      else if(fieldName.equals("species")){
        speciesCounts.clear();
        if (token != JsonToken.START_ARRAY) { throw new IOException("Expected Array"); }
        while((token = p.nextToken()) != JsonToken.END_ARRAY){
          if (token == JsonToken.START_ARRAY){
            int j = 0;
            Integer[] tmpSpecies = new Integer[101];
            while(p.nextToken() != JsonToken.END_ARRAY){
              tmpSpecies[j] = p.getIntValue();
              j += 1;
            }
            speciesCounts.add(tmpSpecies);
          }
        }          
      }
      else if(fieldName.equals("topSpecies")){
        topSpeciesCounts.clear();
        if (token != JsonToken.START_ARRAY) { throw new IOException("Expected Array"); }
        while(p.nextToken() != JsonToken.END_ARRAY){
          topSpeciesCounts.add(p.getIntValue());
        }
      }
      else if(fieldName.equals("creatureArray")){
        c = new Creature[nbCreatures];
        if (token != JsonToken.START_ARRAY) { throw new IOException("Expected Array"); }
        int i = 0;
        while((token = p.nextToken()) != JsonToken.END_ARRAY){
          if (token == JsonToken.START_OBJECT){
            Creature creature = new Creature(new int[2], 0, new ArrayList<Node>(),  new ArrayList<Muscle>(), 0, false, 0, 0, null, new float[100][3]);
            creature.loadFromJson(p);
            c[i] = creature;
            c2.add(c[i]);
            i += 1;
          }
        }
      }
    } 
  } catch(Exception e){
    writeToErrorLog(e);
  }
}