#Evidence accumulation and change rate inference in dynamic environments

This repository contains the MATLAB scripts that were used in the article ["Evidence accumulation and change rate inference in dynamic environment"](https://arxiv.org/abs/1607.08318) by Adrian E. Radillo, Alan Veliz-Cuba, Kresimir Josic, Zachary P. Kilpatrick.

##A few words on the topic
For full information and bibliography, see the [article](https://arxiv.org/abs/1607.08318).

The problem that we study, in its simplest form, is the following: an environment Hn alternates between two values, say H+ and H-, where n is the discrete time variable and Hn is a homogeneous discrete time Markov chain. We say that the environment is *symmetric* when the transition probabilities H+ -> H- and H- -> H+ are the same. We call this probability epsilon. 
An *ideal observer* makes noisy observations of Hn at each time n. The noise distributions are known. The observer's main aim is to decide which state the environment is in at any present time. A subordinate aim is to learn the transition probability epsilon.  

Our article deals with complexifications of the case described above, where the 2 transition probabilities are distinct, where the environment can take on N values for N >= 2, and where time becomes continuous. The code present in this repository only deals with discrete time though, and with the exception of figure 4, with the 2-state symmetric case.

##Short scripts description
All scripts were written for MATLAB_R2015b release.

###Figure 1

###Figure 2
###Figure 3
###Figure 4

##Corresponding author for the scripts 
adrian@math.uh.edu
