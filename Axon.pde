class Axon {
  final double MUTABILITY_MUTABILITY = 0.7;
  final int mutatePower = 9;
  final double MUTATE_MULTI;
  
  double weight;
  double mutability;
  public Axon(double w, double m){
    weight = w;
    mutability = m;
    MUTATE_MULTI = Math.pow(0.5,mutatePower);
  }
  
  public Axon mutateAxon(){
    double mutabilityMutate = Math.pow(0.5,pmRan()*MUTABILITY_MUTABILITY);
    return new Axon(weight+r()*mutability/MUTATE_MULTI,mutability*mutabilityMutate);
  }
  public double r(){
    return Math.pow(pmRan(),mutatePower);
  }
  public double pmRan(){
    return (Math.random()*2-1);
  }
  
  public void saveToJson(JsonGenerator g){
    try {
      g.writeNumberField("weight", weight);
      g.writeNumberField("mutability", mutability);
    } catch(Exception e){
        writeToErrorLog(e);
    }
  }
  
  public void loadFromJson(JsonParser p){
    try{
       while(p.nextToken() != JsonToken.END_OBJECT){
         String fieldName = p.getCurrentName();
         p.nextToken();
         if(fieldName.equals("weight")){ this.weight = p.getDoubleValue(); }
         else if(fieldName.equals("mutability")){ this.mutability = p.getDoubleValue(); }
      }
    } catch(Exception e){
      writeToErrorLog(e);
    }
  }
}