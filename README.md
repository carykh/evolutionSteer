# evolutionSteer
Evolution simulator of creatures learning how to steer towards food pellets better and better.

# INSTALL

1. **Dependencies** :
Please install Processing 2.2.1 by following the link on this website : https://processing.org/download/

2. **Download evolutionSteer** : 
You can either download zip file or typing the following command into your terminal: `git clone https://github.com/carykh/evolutionSteer.git`

3. **Launch evolutionSteer** :
You can then open evolutionSteer.pde and press the *RUN* button. That's it !

# Configuration

Most parameters are set at the beginning of the *evolutionSteer.pde* file. Noticeable parameters are:

* **windowSizeMultiplier** : set to 1 if window is too big 
* **nbCreatures** : define the number of creatures created at each generation. please verify that the value is even, and that the parameters *gridX* and *gridY* are set accordingly so that `gridX * gridY = nbCreatures`
* **thresholdName** : the name of the creature will be shown in the bottom graph if the number of creatures in this species is greater than this value
* **autoSave** : in ALAP mode, this option will automatically save your work. The number set in the *autoSave* variable will define the frequency of these saves
* **autoSaveTimecode** : if set to *true*, the periodical autosave will have a different name each time, with timecode included (data/autosave-2017-7-26_7-58-5.gz for example). If set to *false*, the autosave will have a fixed name (data/autosave.gz). As the files can be pretty large, please set this value to *false* if you don't have enough disk space.
* **autoPause** : because each man needs its pause, you can ask **evolutionSteer** to stop working after a given number of generations
* **simDuration** : the base duration (in seconds) of the simulation
* **jumperDuration** : if the first food blob is found too early (before this value, in seconds), the creature wil be defined as a jumper and thus destroyed
* **giftForChompSec** : gift (in simulation overtime) given to the creature when it found a food blob.
* **radioactiveNumber** : when Radioactive mode is enabled, this number of creatures will see its mutation rate increase by a given factor (**radioactiveMutator**)
* **freshBloodNumber** : when Radioactive mode is enabled, this number of creatures will be created from scratch each generation
* **THREAD_COUNT** : set accordingly to the number of cores in your computer. Multithreading will be activated if you set **activateMultiThreading** to *true*

# Features

First have a look to green commands in the upper right panel :

* Click **Do 1 step-by-step generation** button to launch the details of the generation process of new creatures. This will explain you how the creatures are generated and show you your creatures trying and failing to eat.
* Click **Do 1 quick generation** in order to follow the same steps but avoiding to see each of your creatures pathetically dying
* Click **Do 1 gen ASAP** in order to quickly generate *one* generation
* Click **Do gens ALAP** in order to continuously generate creatures. This will stop only when (your computer will crash or) you click anywhere else in the window.

You can press certain commands during execution

* Press **"r"** to activate *Radioactive mode*. This mode will increase the mutation rate of your creature and hopefully lead to new species
* Press **'"t"** to increase the variability of the food generation process. The food blob will be created relatively to the creature given a random angle which is contained between + and - the angle shown in the interface. You can reduce the variability by pressing **"g"**
* Press **"y"** to reduce the gift (in seconds of supplemental simulation) given to the creature each time it encounters a food blob. Press **"h"** to increase this gift.
* Press **left** and **right** arrow to select previous/next generation. Alternatively, you can use the slider in the interface.

At last you can save you creatures :

* If you press the **Save** button, everything contained in the window ill be saved, including past (sometimes *ancient*) creatures (3 per generation). However this can lead to very big files according to : the number of creatures simulated, the size of their brain and the number of generations.
* If you press the **Light save**, you will save only the two last generations. This has the advantage to create lighter files
* NB the files are gzipped files, and the format is a binary json file format named [Smile](https://en.wikipedia.org/wiki/Smile_(data_interchange_format)).