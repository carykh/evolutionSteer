class Muscle {
  int c1, c2;
  float len;
  float rigidity;
  float previousTarget;
  float brainOutput;
  Muscle(int tc1, int tc2, float tlen, float trigidity) {
    this.previousTarget = len = tlen;
    this.c1 = tc1;
    this.c2 = tc2;
    this.rigidity = trigidity;
    this.brainOutput = 1;
  }
  void applyForce(int i, ArrayList<Node> n, Creature owner) {
    float target = previousTarget;
    if(energyDirection == 1 || owner.energy >= 0.0001){
      target = this.len*toMuscleUsable(this.brainOutput);
    }else{
      target = this.len;
    }
    Node ni1 = n.get(this.c1);
    Node ni2 = n.get(this.c2);
    float distance = dist(ni1.x, ni1.y, ni1.z, ni2.x, ni2.y, ni2.z);
    if(distance >= 0.0001){
      float normX = (ni1.x-ni2.x)/distance;
      float normY = (ni1.y-ni2.y)/distance;
      float normZ = (ni1.z-ni2.z)/distance;
      float force = min(max(1-(distance/target), -1.7), 1.7);
      ni1.vx += normX*force*rigidity/ni1.m;
      ni1.vy += normY*force*rigidity/ni1.m;
      ni1.vz += normZ*force*rigidity/ni1.m;
      ni2.vx -= normX*force*rigidity/ni2.m;
      ni2.vy -= normY*force*rigidity/ni2.m;
      ni2.vz -= normZ*force*rigidity/ni2.m;
      owner.energy = max(owner.energy+energyDirection*abs(previousTarget-target)*rigidity*energyUnit,0);
      this.previousTarget = target;
    }
  }
  Muscle copyMuscle() {
    return new Muscle(this.c1, this.c2, this.len, this.rigidity);
  }
  Muscle modifyMuscle(int nodeNum, float mutability) {
    int newc1 = this.c1;
    int newc2 = this.c2;
    if(random(0,1)<bigMutationChance*mutability){
      newc1 = int(random(0,nodeNum));
    }
    if(random(0,1)<bigMutationChance*mutability){
      newc2 = int(random(0,nodeNum));
    }
    float newR = min(max(rigidity*(1+r()*0.9*mutability),0.015),0.06);
    float newLen = min(max(len+r()*mutability,0.4),1.25);

    return new Muscle(newc1, newc2, newLen, newR);
  }
  void drawMuscle(ArrayList<Node> n, PGraphics img) {
    Node ni1 = n.get(this.c1);
    Node ni2 = n.get(this.c2);
    float w = toMuscleUsable(this.brainOutput)*0.15;
    img.strokeWeight(w*scaleToFixBug);
    float brownness = rigidity*13;
    img.stroke(255-180*brownness, 255-210*brownness, 255-255*brownness, 255);
    img.line(ni1.x*scaleToFixBug, ni1.y*scaleToFixBug, 
    ni1.z*scaleToFixBug, 
    ni2.x*scaleToFixBug, ni2.y*scaleToFixBug,
    ni2.z*scaleToFixBug);
  }
  
  public void saveToJson(JsonGenerator g){
    try{
      g.writeNumberField("c1", this.c1);
      g.writeNumberField("c2", this.c2);
      g.writeNumberField("len", this.len);
      g.writeNumberField("rigidity", this.rigidity);
      g.writeNumberField("previousTarget", this.previousTarget);
      g.writeNumberField("brainOutput", this.brainOutput);
    } catch(Exception e){
        writeToErrorLog(e);
    }
  }
  
  public void loadFromJson(JsonParser p){
    try{
       while(p.nextToken() != JsonToken.END_OBJECT){
         String fieldName = p.getCurrentName();
         p.nextToken();
         if(fieldName.equals("c1")){ this.c1 = p.getIntValue(); }
         else if(fieldName.equals("c2")){ this.c2 = p.getIntValue(); }
         else if(fieldName.equals("len")){ this.len = p.getFloatValue(); }
         else if(fieldName.equals("rigidity")){ this.rigidity = p.getFloatValue(); }
         else if(fieldName.equals("previousTarget")){ this.previousTarget = p.getFloatValue(); }
         else if(fieldName.equals("brainOutput")){ this.brainOutput = p.getFloatValue(); }
       }
    } catch(Exception e){
      writeToErrorLog(e);
    }
  }

}