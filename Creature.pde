class Creature {
  ArrayList<Node> n;
  ArrayList<Muscle> m;
  float d;
  int id;
  boolean alive;
  float mutability;
  Brain brain;
  int[] name;
  float[][] foodPositions = new float[maxChomp][3];
  float foodAngle = 0.0;
  float foodX = 0;
  float foodY = 0;
  float foodZ = 0;
  int chomps = 0;
  float timePerChomp = 0;
  float averageX = 0;
  float averageY = 0;
  float averageZ = 0;
  float energy = baselineEnergy;
  float startingFoodDistance = 9999;
  int lastChompTime = 0;
  
  Creature(int[] tname, int tid, ArrayList<Node> tn, ArrayList<Muscle> tm, float tmut, Brain newBrain, float[][] tfoodpos) {
    this.id = tid;
    this.m = tm;
    this.n = tn;
    this.d = 0;
    this.alive = true;
    this.mutability = tmut;
    this.initParameters();
    if(newBrain != null){
      this.brain = newBrain;
    }else{
      this.brain = new Brain(BRAIN_WIDTH, this.getBrainHeight());
    }
    if(tname == null){
      this.name = getNewCreatureName();
    }else{
      this.name = new int[2];
      this.name[0] = tname[0];
      this.name[1] = tname[1];
    }
    if(tfoodpos == null){
      for(int i = 0; i < maxChomp; i++){
        if(i < angleMultiplier.length){
          this.foodPositions[i][0] = angleMultiplier[i]*random(-foodAngleChange,foodAngleChange);
        } else {
          this.foodPositions[i][0] = random(-foodAngleChange,foodAngleChange);
        }
        this.foodPositions[i][1] = random(-1.2,-0.55);
        this.foodPositions[i][2] = random(0,1);
      }
    } else {
      this.foodPositions = tfoodpos.clone();
    }
  }
  void initParameters(){
    this.chomps = 0;
    this.lastChompTime = 0;
    this.timePerChomp = 0;
  }
  int getBrainHeight(){
    return this.n.size()+this.m.size()+3;
  }
  void changeBrainStructure(int rowInsertionIndex, int rowRemovalIndex){
    this.brain.changeBrainStructure(this.brain.BRAIN_WIDTH, this.getBrainHeight(), rowInsertionIndex, rowRemovalIndex);
  }
  Creature modified(int id, float mutationFactor) {
    float modMut;
    if(mutationFactor == 1.0){ mutationFactor = mutability; modMut = mutability; }
    else{ modMut = mutability; }
    ArrayList<Node> newN = new ArrayList<Node>(0);
    ArrayList<Muscle> newM = new ArrayList<Muscle>(0);
    for (int i = 0; i < this.n.size(); i++) {
      newN.add(this.n.get(i).modifyNode(modMut,this.n.size()));
    }
    for (int i = 0; i < this.m.size(); i++) {
      newM.add(this.m.get(i).modifyMuscle(this.n.size(), modMut));
    }
    
    boolean bigMutAddNode = false, bigMutRemoveNode = false, bigMutAddMuscle = false, bigMutRemoveMuscle = false;
    boolean bigMutExpandBrain = false;
    if (random(0, 1) < bigMutationChance*mutationFactor || this.n.size() <= 2){ bigMutAddNode = true; }
    if (random(0, 1) < bigMutationChance*mutationFactor) { bigMutAddMuscle = true; }
    if (random(0, 1) < bigMutationChance*mutationFactor && this.n.size() >= 5) { bigMutRemoveNode = true; }
    if (random(0, 1) < bigMutationChance*mutationFactor && this.m.size() >= 2) { bigMutRemoveMuscle = true; }
    if (random(0, 1) < bigMutationChance*mutationFactor*(5-this.brain.BRAIN_WIDTH)/2 && this.brain.BRAIN_WIDTH < 5) { 
      bigMutExpandBrain = true; 
      bigMutAddNode = false; bigMutRemoveNode = false; bigMutAddMuscle = false; bigMutRemoveMuscle = false;
    }
    
    int[] newName = new int[2];
    if(bigMutAddNode || bigMutRemoveNode || bigMutAddMuscle || bigMutRemoveMuscle || bigMutExpandBrain){
      newName = getNewCreatureName();
    } else {
      newName[0] = name[0];
      newName[1] = CREATURES_PER_PATRON[name[0]];
      CREATURES_PER_PATRON[name[0]]++;
    }
    
    Brain tmpBrain;
    if(bigMutExpandBrain){
      tmpBrain = this.brain.copyExpandedBrain();
    } else {
      tmpBrain = this.brain.copyMutatedBrain();
    }
    float newMut;
    if(mutationFactor > 1){
        newMut = max(min(mutability*random((float)0.8, (float)1.25), 2), (float)0.2);
    } else {
        newMut = min(mutability*random((float)0.8, (float)1.25), 2);
    }
    Creature modifiedCreature = new Creature(newName, id, newN, newM, newMut, tmpBrain, null);
    if (bigMutAddNode) { //Add a node
      modifiedCreature.addRandomNode();
    }
    if (bigMutAddMuscle) { //Add a muscle
      modifiedCreature.addRandomMuscle(-1, -1);
    }
    if (bigMutRemoveNode) { //Remove a node
      modifiedCreature.removeRandomNode();
    }
    if (bigMutRemoveMuscle) { //Remove a muscle
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
    for(int i = 0; i < this.n.size(); i++) {
      avX += this.n.get(i).x;
      avZ += this.n.get(i).z;
    }
    avX /= this.n.size();
    avZ /= this.n.size();
    for(int i = 0; i < this.n.size(); i++) {
      this.n.get(i).x -= avX;
      this.n.get(i).z -= avZ;
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
        changeBrainStructure(-1,this.n.size()+b);
      }
    }
  }
  void checkForLoneNodes() {
    if (this.n.size() >= 3) {
      for (int i = 0; i < this.n.size(); i++) {
        int connections = 0;
        int connectedTo = -1;
        for (int j = 0; j < this.m.size(); j++) {
          if (this.m.get(j).c1 == i || this.m.get(j).c2 == i) {
            connections++;
            connectedTo = j;
          }
        }
        if (connections <= 1) {
          int newConnectionNode = floor(random(0, this.n.size()));
          while (newConnectionNode == i || newConnectionNode == connectedTo) {
            newConnectionNode = floor(random(0, this.n.size()));
          }
          addRandomMuscle(i, newConnectionNode);
        }
      }
    }
  }
  void addRandomNode() {
    int parentNode = floor(random(0, this.n.size()));
    float ang1 = random(0, 2*PI);
    float distance = sqrt(random(0, 1));
    float vertical = random(-1,1);
    float x = this.n.get(parentNode).x+cos(ang1)*0.5*distance;
    float y = this.n.get(parentNode).y+vertical*0.5*distance;
    float z = this.n.get(parentNode).y+sin(ang1)*0.5*distance;
    int newNodeCount = n.size()+1;
    
    this.n.add(new Node(x, y, z, 0, 0, 0, 0.4, random(0, 1)));
    changeBrainStructure(this.n.size()-1,-1);
    
    int nextClosestNode = 0;
    float record = 100000;
    for (int i = 0; i < this.n.size()-1; i++) {
      if (i != parentNode) {
        float dx = this.n.get(i).x-x;
        float dy = this.n.get(i).y-y;
        if (sqrt(dx*dx+dy*dy) < record) {
          record = sqrt(dx*dx+dy*dy);
          nextClosestNode = i;
        }
      }
    }
    addRandomMuscle(parentNode, this.n.size()-1);
    addRandomMuscle(nextClosestNode, this.n.size()-1);
  }
  void addRandomMuscle(int tc1, int tc2) {
    if (tc1 == -1) {
      tc1 = int(random(0, this.n.size()));
      tc2 = tc1;
      while (tc2 == tc1 && this.n.size () >= 2) {
        tc2 = int(random(0, this.n.size()));
      }
    }
    float len = random(0.5, 1.5);
    if (tc1 != -1) {
      len = dist(this.n.get(tc1).x, this.n.get(tc1).y, this.n.get(tc2).x, this.n.get(tc2).y);
    }
    m.add(new Muscle(tc1, tc2, len, random(0.02, 0.08)));
    changeBrainStructure(getBrainHeight()-2,-1);
  }
  void removeRandomNode() {
    int choice = floor(random(0, this.n.size()));
    this.n.remove(choice);
    changeBrainStructure(-1,choice);
    int i = 0;
    while (i < this.m.size ()) {
      if (this.m.get(i).c1 == choice || this.m.get(i).c2 == choice) {
        this.m.remove(i);
        changeBrainStructure(-1,this.n.size()+i);
      }else{
        i++;
      }
    }
    for (int j = 0; j < m.size(); j++) {
      if (this.m.get(j).c1 >= choice) {
        this.m.get(j).c1--;
      }
      if (m.get(j).c2 >= choice) {
        this.m.get(j).c2--;
      }
    }
  }
  void removeRandomMuscle() {
    int choice = floor(random(0, m.size()));
    m.remove(choice);
    changeBrainStructure(-1,this.n.size()+choice);
  }
  Creature copyCreature(int newID, Boolean changeFood, Boolean withUsableBrain) {
    final ArrayList<Node> n2 = new ArrayList<Node>(0);
    final ArrayList<Muscle> m2 = new ArrayList<Muscle>(0);
    for (int i = 0; i < this.n.size(); i++) {
      n2.add(this.n.get(i).copyNode());
    }
    for (int i = 0; i < this.m.size(); i++) {
      m2.add(this.m.get(i).copyMuscle());
    }
    if (newID == -1) {
      newID = this.id;
    }
    float[][] newFoodPositions = null;
    if(!changeFood){
      newFoodPositions = foodPositions.clone();
    }
    Brain newBrain = this.brain.copyBrain();
    if(withUsableBrain){
      newBrain = this.brain.getUsableCopyOfBrain();
    }
    Creature copiedCreature = new Creature(this.name, newID, n2, m2, this.mutability, newBrain, newFoodPositions);
    copiedCreature.d = this.d;
    copiedCreature.chomps = this.chomps;
    copiedCreature.timePerChomp = this.timePerChomp;
    copiedCreature.alive = this.alive;
    return copiedCreature;
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
    for (int i = 0; i < this.m.size(); i++) {
      this.m.get(i).drawMuscle(this.n, img);
    }
    for (int i = 0; i < this.n.size(); i++) {
      this.n.get(i).drawNode(img);
    }
    if(putInFrontOfBack && false){
      img.popMatrix();
    }
  }
  void setAverages() {
    this.averageX = 0;
    this.averageY = 0;
    this.averageZ = 0;
    for (int i = 0; i < this.n.size(); i++) {
      Node ni = this.n.get(i);
      this.averageX += ni.x;
      this.averageY += ni.y;
      this.averageZ += ni.z;
    }
    this.averageX = this.averageX/this.n.size();
    this.averageY = this.averageY/this.n.size();
    this.averageZ = this.averageZ/this.n.size();
  }
  void calculateNextFoodLocation() {
    if(this.chomps >= maxChomp){ return; }
    this.setAverages();
    this.foodAngle += this.foodPositions[chomps][0];
    float sinA = sin(this.foodAngle);
    float cosA = cos(this.foodAngle);
    float furthestNodeForward = 0;
    for(int i = 0; i < this.n.size(); i++){
      Node ni = this.n.get(i);
      float newX = (ni.x-this.averageX)*cosA-(ni.z-this.averageZ)*sinA;
      if(newX >= furthestNodeForward){
        furthestNodeForward = newX;
      }
    }
    this.d = MIN_FOOD_DISTANCE+(MAX_FOOD_DISTANCE-MIN_FOOD_DISTANCE)*this.foodPositions[chomps][2];
    this.foodX = this.foodX+cos(foodAngle)*(furthestNodeForward+d);
    this.foodZ = this.foodZ+sin(foodAngle)*(furthestNodeForward+d);
    this.foodY = this.foodPositions[chomps][1];
    this.startingFoodDistance = this.getCurrentFoodDistance();
  }
  float getCurrentFoodDistance() {
    float closestDist = 9999;
    for(int i = 0; i < this.n.size(); i++){
      Node N = this.n.get(i);
      float distFromFood = dist(N.x,N.y,N.z,this.foodX,this.foodY,this.foodZ)-0.4;
      if(distFromFood < closestDist){
        closestDist = distFromFood;
      }
    }
    return closestDist;
  }
  float getFitness(){
    Boolean hasNodeOffGround = false;
    for(int i = 0; i < this.n.size(); i++){
      if(this.n.get(i).y <= -0.2001){
        hasNodeOffGround = true;
      }
    }
    if(hasNodeOffGround){
      float withinChomp = max(1.0-this.getCurrentFoodDistance()/this.startingFoodDistance,0);
      if(withinChomp >= 1){ withinChomp = 0.99; }
      float chompfit;
      if(this.chomps >= maxChomp){ chompfit = this.chomps; }
      else { chompfit = this.chomps+withinChomp; }
      
      float speedfit = 0;
      if(this.chomps > 0){
        timePerChomp = float(lastChompTime/frames)/float(this.chomps);
        if(this.chomps > angleMultiplier.length){
          if(lastChompTime/frames <= 1){ speedfit = 0; }
          else if(timePerChomp < 1 && lastChompTime > 0){ speedfit = timePerChompWeight; }
          else if(timePerChomp > timePerChompWeight/timePerChompSlope+1){ speedfit = 0; }
          else if(lastChompTime == 0 || timePerChomp == 0){ speedfit = 0; }
          else{ speedfit = -timePerChompSlope*(timePerChomp-(timePerChompWeight/timePerChompSlope)-1); }
        }
      }
      
      float loss = (this.brain.BRAIN_WIDTH - 2)*lossPerLayer; // loss function for brain width
      if(this.chomps >= maxChomp/2){ loss = 0; }
      
      return 100*(chompfit+speedfit-loss)/(maxChomp+timePerChompWeight);
    }else{
      return 0;
    }
  }
  void toStableConfiguration() {
    for (int j = 0; j < 200; j++) {
      for (int i = 0; i < this.m.size(); i++) {
        this.m.get(i).applyForce(i, this.n, this);
      }
      for (int i = 0; i < this.n.size(); i++) {
        this.n.get(i).applyForces();
      }
    }
    for (int i = 0; i < this.n.size(); i++) {
      this.n.get(i).vx = 0;
      this.n.get(i).vy = 0;
    }
  }
  boolean simulate() {
    boolean hasEaten = false;
    this.brain.useBrain(this);
    for (int i = 0; i < this.m.size(); i++) {
      this.m.get(i).applyForce(i, this.n, this);
    }
    for (int i = 0; i < this.n.size(); i++) {
      Node ni = this.n.get(i);
      ni.applyGravity();
      ni.applyForces();
      ni.hitWalls((i >= 2));
      float distFromFood = dist(ni.x,ni.y,ni.z,this.foodX,this.foodY,this.foodZ);
      if(distFromFood <= 0.4){
        this.chomps++;
        lastChompTime = this.brain.timesUsed;
        hasEaten = true;
        this.calculateNextFoodLocation();
      }
    }
    return hasEaten;
  }
  
  public void saveToJson(JsonGenerator g, int overwriteId){
    try{
      g.writeNumberField("d", d);
      if(overwriteId == -1) { g.writeNumberField("id", id); }
      else { g.writeNumberField("id", overwriteId); }
      g.writeBooleanField("alive", alive);
      g.writeNumberField("mutability", mutability);
      g.writeNumberField("chomps", chomps);
      g.writeNumberField("timePerChomp", timePerChomp);
      g.writeArrayFieldStart("name");g.writeNumber(name[0]);g.writeNumber(name[1]);g.writeEndArray();
      if(n != null){
        g.writeArrayFieldStart("nodes");
        for(int i = 0 ; i < this.n.size(); i++){
          g.writeStartObject(); this.n.get(i).saveToJson(g); g.writeEndObject();
        }
        g.writeEndArray();
      }
      if(m != null){
        g.writeArrayFieldStart("muscles");
        for(int i = 0 ; i < this.m.size(); i++){
          g.writeStartObject(); this.m.get(i).saveToJson(g); g.writeEndObject();
        }
        g.writeEndArray();
      }
      g.writeObjectFieldStart("brain"); this.brain.saveToJson(g); g.writeEndObject();
    } catch(Exception e){
        writeToErrorLog(e);
    }
   
  }
  public void loadFromJson(JsonParser p){
    try{
       while(p.nextToken() != JsonToken.END_OBJECT){
         String fieldName = p.getCurrentName();
         JsonToken token = p.nextToken();
         if(fieldName.equals("d")){ d = p.getFloatValue(); }
         if(fieldName.equals("chomps")){ chomps = p.getIntValue(); }
         if(fieldName.equals("timePerChomp")){ timePerChomp = p.getFloatValue(); }
         else if(fieldName.equals("id")){ id = p.getIntValue(); }
         else if(fieldName.equals("alive")){ alive = p.getBooleanValue(); }
         else if(fieldName.equals("mutability")){ mutability = p.getFloatValue(); }
         else if(fieldName.equals("name")){ 
           if (token != JsonToken.START_ARRAY) { throw new IOException("Expected Array"); }
           int i = 0;
           while(p.nextToken() != JsonToken.END_ARRAY){
              name[i] = p.getIntValue();
              i += 1;
           }
         }
         else if(fieldName.equals("nodes")){
           this.n = new ArrayList<Node>();
           if (token != JsonToken.START_ARRAY) { throw new IOException("Expected Array"); }
           while((token = p.nextToken()) != JsonToken.END_ARRAY){
             if (token == JsonToken.START_OBJECT){
               Node node = new Node(0, 0, 0, 0, 0, 0, 0, 0);
               node.loadFromJson(p);
               this.n.add(node);
             }
           }
         }
         else if(fieldName.equals("muscles")){
           this.m = new ArrayList<Muscle>();
           if (token != JsonToken.START_ARRAY) { throw new IOException("Expected Array"); }
           while((token = p.nextToken()) != JsonToken.END_ARRAY){
             if (token == JsonToken.START_OBJECT){
               Muscle muscle = new Muscle(0, 0, 0, 0);
               muscle.loadFromJson(p);
               this.m.add(muscle);
             }
           }
         }
         else if(fieldName.equals("brain")){
           if (token != JsonToken.START_OBJECT) { throw new IOException("Expected Object"); }
           brain = new Brain(1, 1);
           brain.loadFromJson(p);
         }
       }
    } catch(Exception e) {  writeToErrorLog(e); }
  }
}