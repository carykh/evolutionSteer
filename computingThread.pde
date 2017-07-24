public class ComputingThread implements Runnable{
    private int beginIndex;
    private int endIndex;
    private int framePerChomp;
    private Creature myCreature;
    public ComputingThread(int bi, int ei, int fpc){
       this.beginIndex = bi; 
       this.endIndex = ei; 
       this.framePerChomp = fpc;
    }
    @Override
    public void run() {
      for(int k = this.beginIndex; k < this.endIndex; k++) {
        myCreature = c[k].copyCreature(-1,false,true);
        myCreature.calculateNextFoodLocation();
        int myMaxChomp = this.framePerChomp;
        boolean isJumper = false;
        for (int sim = 0; sim < myMaxChomp; sim++) {
          if(myCreature.simulate()){ // activated when chomped
            if(sim <= jumperFrames){ isJumper = true; break; } // we kill jumpers
            myMaxChomp += this.framePerChomp;
          }
        }
        if(isJumper){
          c[k].d = 0;
        } else {
          myCreature.setAverages();
          c[k].d = myCreature.getFitness();
        }
      }  
    }
}