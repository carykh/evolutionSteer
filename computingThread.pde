public class ComputingThread implements Runnable{
    private int beginIndex;
    private int endIndex;
    private int framePerChomp;
    private Creature myCreature;
    public ComputingThread(int bi, int ei){
       this.beginIndex = bi; 
       this.endIndex = ei; 
    }
    @Override
    public void run() {
      for(int k = this.beginIndex; k < this.endIndex; k++) {
        myCreature = c[k].copyCreature(-1,false,true);
        myCreature.calculateNextFoodLocation();
        int myMaxFrames = maxFrames;
        int currentChomp = 0;
        boolean isJumper = false;
        for (int sim = 0; sim < myMaxFrames; sim++) {
          if(myCreature.simulate()){ // activated when chomped
            if(simDuration > jumperTruncate){
              if(sim <= jumperFrames){ isJumper = true; break; } // we kill jumpers
            }
            myMaxFrames += giftForChompFrames;
            currentChomp++;
            if(currentChomp >= maxChomp){ break; }
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