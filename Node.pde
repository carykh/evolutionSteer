class Node {
  float x, y, z, vx, vy, vz, prevX, prevY, prevZ, pvx, pvy, pvz, m, initf, f;
  float pressure, brainOutput;
  Node(float tx, float ty, float tz,
  float tvx, float tvy, float tvz,
  float tm, float tf) {
    this.prevX = x = tx;
    this.prevY = y = ty;
    this.prevZ = z = tz;
    this.pvx = vx = tvx;
    this.pvy = vy = tvy;
    this.pvz = vz = tvz;
    this.m = tm;
    this.initf = tf;
    this.f = this.initf;
    this.pressure = 0;
    this.brainOutput = (2*this.initf)-1;
  }
  void applyForces() {
    this.f = toNodeUsable();
    this.vx *= airFriction;
    this.vy *= airFriction;
    this.vz *= airFriction;
    this.y += vy;
    this.x += vx;
    this.z += vz;
    float acc = dist(vx,vy,vz,pvx,pvy,pvz);
    totalNodeNausea += acc*acc*nauseaUnit;
    this.pvx = vx;
    this.pvy = vy;
    this.pvz = vz;
  }
  float toNodeUsable(){
    return (this.brainOutput+1)/2;
  }
  void applyGravity() {
    this.vy += gravity;
  }
  void pressAgainstGround(float groundY){
    float dif = y-(groundY-m/2);
    this.pressure += dif*pressureUnit;
    this.y = (groundY-m/2);
    this.vy = 0;
    this.x -= vx*f;
    this.z -= vz*f;
    if (this.vx > 0) {
      this.vx -= this.f*dif*FRICTION;
      if (this.vx < 0) {
        this.vx = 0;
      }
    } else {
      this.vx += this.f*dif*FRICTION;
      if (this.vx > 0) {
        this.vx = 0;
      }
    }
    if (this.vz > 0) {
      this.vz -= this.f*dif*FRICTION;
      if (this.vz < 0) {
        this.vz = 0;
      }
    } else {
      this.vz += this.f*dif*FRICTION;
      if (vz > 0) {
        vz = 0;
      }
    }
  }
  void hitWalls(Boolean addToAngular) {
    this.pressure = 0;
    float dif = y+m/2;
    if (dif >= 0 && haveGround) {
      pressAgainstGround(0);
    }
    if(this.y > this.prevY && hazelStairs >= 0){
      float bottomPointNow = y+m/2;
      float bottomPointPrev = prevY+m/2;
      int levelNow = (int)(ceil(bottomPointNow/hazelStairs));
      int levelPrev = (int)(ceil(bottomPointPrev/hazelStairs));
      if(levelNow > levelPrev){
        float groundLevel = levelPrev*hazelStairs;
        pressAgainstGround(groundLevel);
      }
    }
    /*for (int i = 0; i < rects.size(); i++) {
      Rectangle r = rects.get(i);
      boolean flip = false;
      float px, py;
      if (abs(x-(r.x1+r.x2)/2) <= (r.x2-r.x1+m)/2 && abs(y-(r.y1+r.y2)/2) <= (r.y2-r.y1+m)/2) {
        if (x >= r.x1 && x < r.x2 && y >= r.y1 && y < r.y2) {
          float d1 = x-r.x1;
          float d2 = r.x2-x;
          float d3 = y-r.y1;
          float d4 = r.y2-y;
          if (d1 < d2 && d1 < d3 && d1 < d4) {
            px = r.x1;
            py = y;
          }else if (d2 < d3 && d2 < d4) {
            px = r.x2;
            py = y;
          }else if (d3 < d4) {
            px = x;
            py = r.y1;
          } else {
            px = x;
            py = r.y2;
          }
          flip = true;
        } else {
          if (x < r.x1) {
            px = r.x1;
          }else if (x < r.x2) {
            px = x;
          }else {
            px = r.x2;
          }
          if (y < r.y1) {
            py = r.y1;
          }else if (y < r.y2) {
            py = y;
          }else {
            py = r.y2;
          }
        }
        float distance = dist(x, y, px, py);
        float rad = m/2;
        float wallAngle = atan2(py-y, px-x);
        if (flip) {
          wallAngle += PI;
        }
        if (distance < rad || flip) {
          dif = rad-distance;
          pressure += dif*pressureUnit;
          float multi = rad/distance;
          if (flip) {
            multi = -multi;
          }
          x = (x-px)*multi+px;
          y = (y-py)*multi+py;
          float veloAngle = atan2(vy, vx);
          float veloMag = dist(0, 0, vx, vy);
          float relAngle = veloAngle-wallAngle;
          float relY = sin(relAngle)*veloMag*dif*FRICTION;
          vx = -sin(relAngle)*relY;
          vy = cos(relAngle)*relY;
        }
      }
    }*/
    this.prevY = this.y;
    this.prevX = this.x;
  }
  Node copyNode() {
    return (new Node(this.x, this.y, this.z, 0, 0, 0, this.m, this.f));
  }
  Node modifyNode(float mutability, int nodeNum) {
    float newX = this.x+r()*0.5*mutability;
    float newY = this.y+r()*0.5*mutability;
    float newZ = this.z+r()*0.5*mutability;
    //float newM = m+r()*0.1*mutability;
    //newM = min(max(newM, 0.3), 0.5);
    float newM = 0.4;
    float newF = min(max(this.initf+r()*0.1*mutability, 0), 1);
    Node newNode = new Node(newX, newY, newZ, 0, 0, 0, newM, newF);
    return newNode;//max(m+r()*0.1,0.2),min(max(f+r()*0.1,0),1)
  }
  void drawNode(PGraphics img) {
    color c = color(0,0,0);
    if (this.f <= 0.5) {
      c = colorLerp(color(255,255,255),color(180,0,255),this.f*2);
    }else{
      c = colorLerp(color(180,0,255),color(0,0,0),this.f*2-1);
    }
    img.fill(c);
    img.noStroke();
    img.lights();
    img.pushMatrix();
    img.translate(this.x*scaleToFixBug, this.y*scaleToFixBug,this.z*scaleToFixBug);
    img.sphere(this.m*scaleToFixBug*0.5);
    img.popMatrix();
    //img.ellipse((ni.x+x)*scaleToFixBug, (ni.y+y)*scaleToFixBug, ni.m*scaleToFixBug, ni.m*scaleToFixBug);
    /*if(ni.f >= 0.5){
      img.fill(255);
    }else{
      img.fill(0);
    }
    img.textAlign(CENTER);
    img.textFont(font, 0.4*ni.m*scaleToFixBug);
    img.text(nf(ni.value,0,2),(ni.x+x)*scaleToFixBug,(ni.y+ni.m*lineY2+y)*scaleToFixBug);
    img.text(operationNames[ni.operation],(ni.x+x)*scaleToFixBug,(ni.y+ni.m*lineY1+y)*scaleToFixBug);*/
  }
  color colorLerp(color a, color b, float x){
    return color(red(a)+(red(b)-red(a))*x, green(a)+(green(b)-green(a))*x, blue(a)+(blue(b)-blue(a))*x);
  }
  
  public void saveToJson(JsonGenerator g){
    try{
      g.writeNumberField("x", this.x);
      g.writeNumberField("y", this.y);
      g.writeNumberField("z", this.z);
      g.writeNumberField("vx", this.vx);
      g.writeNumberField("vy", this.vy);
      g.writeNumberField("vz", this.vz);
      g.writeNumberField("m", this.m);
      g.writeNumberField("f", this.initf);
    } catch(Exception e){
        writeToErrorLog(e);
    }
  }
  
  public void loadFromJson(JsonParser p){
    try{
       while(p.nextToken() != JsonToken.END_OBJECT){
         String fieldName = p.getCurrentName();
         p.nextToken();
         if(fieldName.equals("x")){ this.x = p.getFloatValue(); }
         else if(fieldName.equals("y")){ this.y = p.getFloatValue(); }
         else if(fieldName.equals("z")){ this.z = p.getFloatValue(); }
         else if(fieldName.equals("vx")){ this.vx = p.getFloatValue(); }
         else if(fieldName.equals("vy")){ this.vy = p.getFloatValue(); }
         else if(fieldName.equals("vz")){ this.vz = p.getFloatValue(); }
         else if(fieldName.equals("m")){ this.m = p.getFloatValue(); }
         else if(fieldName.equals("f")){ 
           this.f = this.initf = p.getFloatValue();
           this.brainOutput = (2*this.initf)-1;
         }
         else if(fieldName.equals("pressure")){ this.pressure = p.getFloatValue(); }
       }
    } catch(Exception e){
      writeToErrorLog(e);
    }
  }

}