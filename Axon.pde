class Axon{
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
}
