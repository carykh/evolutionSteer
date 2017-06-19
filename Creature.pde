class Creature {
  ArrayList<Node> n;
  ArrayList<Muscle> m;
  float d;
  int id;
  boolean alive;
  float creatureTimer;
  float mutability;
  Brain brain;
  int[] name;
  float[][] foodPositions = new float[100][3];
  Creature(int[] tname, int tid, ArrayList<Node> tn, ArrayList<Muscle> tm, float td, boolean talive, float tct, float tmut, Brain newBrain, float[][] tfoodpos) {
    id = tid;
    m = tm;
    n = tn;
    d = td;
    alive = talive;
    creatureTimer = tct;
    mutability = tmut;
    if(newBrain != null){
      brain = newBrain;
    }else{
      brain = new Brain(BRAIN_WIDTH, getBrainHeight());
    }
    if(tname == null){
      name = getNewCreatureName();
    }else{
      name = new int[2];
      name[0] = tname[0];
      name[1] = tname[1];
    }
    if(tfoodpos == null){
      for(int i = 0; i < 100; i++){
        foodPositions[i][0] = random(-foodAngleChange,foodAngleChange);
        foodPositions[i][1] = random(-1.2,-0.55);
        foodPositions[i][2] = random(0,1);
      }
    }else{
      for(int i = 0; i < 100; i++){
        foodPositions[i][0] = tfoodpos[i][0];
        foodPositions[i][1] = tfoodpos[i][1];
        foodPositions[i][2] = tfoodpos[i][2];
      }
    }
  }
  int getBrainHeight(){
    return n.size()+m.size()+1;
  }
  void changeBrainStructure(int rowInsertionIndex, int rowRemovalIndex){
    brain.changeBrainStructure(BRAIN_WIDTH, getBrainHeight(), rowInsertionIndex,rowRemovalIndex);
  }
  public float sigmoid(float input){
    return 1.0/(1.0+pow(2.71828182846,-input));
  }
  Creature modified(int id) {
    ArrayList<Node> newN = new ArrayList<Node>(0);
    ArrayList<Muscle> newM = new ArrayList<Muscle>(0);
    for (int i = 0; i < n.size(); i++) {
      newN.add(n.get(i).modifyNode(mutability,n.size()));
    }
    for (int i = 0; i < m.size(); i++) {
      newM.add(m.get(i).modifyMuscle(n.size(), mutability));
    }
    int[] newName = new int[2];
    newName[0] = name[0];
    newName[1] = CREATURES_PER_PATRON[name[0]];
    CREATURES_PER_PATRON[name[0]]++;
    Creature modifiedCreature = new Creature(newName, id, 
    newN, newM, 0, true, creatureTimer+r()*16*mutability, min(mutability*random(0.8, 1.25), 2), brain.copyMutatedBrain(),null);
    if (random(0, 1) < bigMutationChance*mutability || n.size() <= 2) { //Add a node
      modifiedCreature.addRandomNode();
    }
    if (random(0, 1) < bigMutationChance*mutability) { //Add a muscle
      modifiedCreature.addRandomMuscle(-1, -1);
    }
    if (random(0, 1) < bigMutationChance*mutability && modifiedCreature.n.size() >= 5) { //Remove a node
      modifiedCreature.removeRandomNode();
    }
    if (random(0, 1) < bigMutationChance*mutability && modifiedCreature.m.size() >= 2) { //Remove a muscle
      modifiedCreature.removeRandomMuscle();
    }
    modifiedCreature.checkForOverlap();
    modifiedCreature.checkForLoneNodes();
    modifiedCreature.toStableConfiguration();
    modifiedCreature.moveToCenter();
    return modifiedCreature;
  }
  void moveToCenter(){
    float avX = 0;
    float avZ = 0;
    for(int i = 0; i < n.size(); i++) {
      avX += n.get(i).x;
      avZ += n.get(i).z;
    }
    avX /= n.size();
    avZ /= n.size();
    for(int i = 0; i < n.size(); i++) {
      n.get(i).x -= avX;
      n.get(i).z -= avZ;
    }
  }
  void checkForOverlap() {
    ArrayList<Integer> bads = new ArrayList<Integer>();
    for (int i = 0; i < m.size(); i++) {
      for (int j = i+1; j < m.size(); j++) {
        if (m.get(i).c1 == m.get(j).c1 && m.get(i).c2 == m.get(j).c2) {
          bads.add(i);
        }
        else if (m.get(i).c1 == m.get(j).c2 && m.get(i).c2 == m.get(j).c1) {
          bads.add(i);
        }
        else if (m.get(i).c1 == m.get(i).c2) {
          bads.add(i);
        }
      }
    }
    for (int i = bads.size()-1; i >= 0; i--) {
      int b = bads.get(i)+0;
      if (b < m.size()) {
        m.remove(b);
        changeBrainStructure(-1,n.size()+b);
      }
    }
  }
  void checkForLoneNodes() {
    if (n.size() >= 3) {
      for (int i = 0; i < n.size(); i++) {
        int connections = 0;
        int connectedTo = -1;
        for (int j = 0; j < m.size(); j++) {
          if (m.get(j).c1 == i || m.get(j).c2 == i) {
            connections++;
            connectedTo = j;
          }
        }
        if (connections <= 1) {
          int newConnectionNode = floor(random(0, n.size()));
          while (newConnectionNode == i || newConnectionNode == connectedTo) {
            newConnectionNode = floor(random(0, n.size()));
          }
          addRandomMuscle(i, newConnectionNode);
        }
      }
    }
  }
  void addRandomNode() {
    int parentNode = floor(random(0, n.size()));
    float ang1 = random(0, 2*PI);
    float distance = sqrt(random(0, 1));
    float vertical = random(-1,1);
    float x = n.get(parentNode).x+cos(ang1)*0.5*distance;
    float y = n.get(parentNode).y+vertical*0.5*distance;
    float z = n.get(parentNode).y+sin(ang1)*0.5*distance;
    int newNodeCount = n.size()+1;
    
    n.add(new Node(x, y, z, 0, 0, 0, 0.4, random(0, 1)));
    changeBrainStructure(n.size()-1,-1);
    
    int nextClosestNode = 0;
    float record = 100000;
    for (int i = 0; i < n.size()-1; i++) {
      if (i != parentNode) {
        float dx = n.get(i).x-x;
        float dy = n.get(i).y-y;
        if (sqrt(dx*dx+dy*dy) < record) {
          record = sqrt(dx*dx+dy*dy);
          nextClosestNode = i;
        }
      }
    }
    addRandomMuscle(parentNode, n.size()-1);
    addRandomMuscle(nextClosestNode, n.size()-1);
  }
  void addRandomMuscle(int tc1, int tc2) {
    if (tc1 == -1) {
      tc1 = int(random(0, n.size()));
      tc2 = tc1;
      while (tc2 == tc1 && n.size () >= 2) {
        tc2 = int(random(0, n.size()));
      }
    }
    float len = random(0.5, 1.5);
    if (tc1 != -1) {
      len = dist(n.get(tc1).x, n.get(tc1).y, n.get(tc2).x, n.get(tc2).y);
    }
    m.add(new Muscle(tc1, tc2, len, random(0.02, 0.08)));
    changeBrainStructure(getBrainHeight()-2,-1);
  }
  void removeRandomNode() {
    int choice = floor(random(0, n.size()));
    n.remove(choice);
    changeBrainStructure(-1,choice);
    int i = 0;
    while (i < m.size ()) {
      if (m.get(i).c1 == choice || m.get(i).c2 == choice) {
        m.remove(i);
        changeBrainStructure(-1,n.size()+i);
      }else{
        i++;
      }
    }
    for (int j = 0; j < m.size(); j++) {
      if (m.get(j).c1 >= choice) {
        m.get(j).c1--;
      }
      if (m.get(j).c2 >= choice) {
        m.get(j).c2--;
      }
    }
  }
  void removeRandomMuscle() {
    int choice = floor(random(0, m.size()));
    m.remove(choice);
    changeBrainStructure(-1,n.size()+choice);
  }
  Creature copyCreature(int newID, Boolean changeFood, Boolean withUsableBrain) {
    ArrayList<Node> n2 = new ArrayList<Node>(0);
    ArrayList<Muscle> m2 = new ArrayList<Muscle>(0);
    for (int i = 0; i < n.size(); i++) {
      n2.add(this.n.get(i).copyNode());
    }
    for (int i = 0; i < m.size(); i++) {
      m2.add(this.m.get(i).copyMuscle());
    }
    if (newID == -1) {
      newID = id;
    }
    float[][] newFoodPositions = null;
    if(!changeFood){
      newFoodPositions = foodPositions;
    }
    Brain newBrain = brain.copyBrain();
    if(withUsableBrain){
      newBrain = brain.getUsableCopyOfBrain();
    }
    return new Creature(name, newID, n2, m2, d, alive, creatureTimer, mutability,newBrain,newFoodPositions);
  }
  void drawCreature(PGraphics img, Boolean putInFrontOfBack) {
    if(putInFrontOfBack && false){
      float minZ = 9999;
      for (int i = 0; i < n.size(); i++) {
        float value = n.get(i).z-n.get(i).m*0.5;
        if(value < minZ){
          minZ = value;
        }
      }
      img.pushMatrix();
      img.translate(0,0,-minZ*scaleToFixBug);
    }
    for (int i = 0; i < m.size(); i++) {
      m.get(i).drawMuscle(n, img);
    }
    for (int i = 0; i < n.size(); i++) {
      n.get(i).drawNode(img);
    }
    if(putInFrontOfBack && false){
      img.popMatrix();
    }
  }
  void toStableConfiguration() {
    for (int j = 0; j < 200; j++) {
      for (int i = 0; i < m.size(); i++) {
        m.get(i).applyForce(i, n);
      }
      for (int i = 0; i < n.size(); i++) {
        n.get(i).applyForces();
      }
    }
    for (int i = 0; i < n.size(); i++) {
      n.get(i).vx = 0;
      n.get(i).vy = 0;
    }
  }
  void simulate() {
    brain.useBrain(this);
    for (int i = 0; i < m.size(); i++) {
      m.get(i).applyForce(i, n);
    }
    for (int i = 0; i < n.size(); i++) {
      Node ni = n.get(i);
      ni.applyGravity();
      ni.applyForces();
      ni.hitWalls((i >= 2));
      float distFromFood = dist(ni.x,ni.y,ni.z,foodX,foodY,foodZ);
      if(distFromFood <= 0.4){
        chomps++;
        setFoodLocation();
      }
    }
  }
}
