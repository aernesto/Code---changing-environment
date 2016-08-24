#Evidence accumulation and change rate inference in dynamic environments

This repository contains the MATLAB scripts that were used in the article ["Evidence accumulation and change rate inference in dynamic environments"](https://arxiv.org/abs/1607.08318) by Adrian E. Radillo, Alan Veliz-Cuba, Kresimir Josic, Zachary P. Kilpatrick.

##A few words on the topic
For full information and bibliography, see our [article](https://arxiv.org/abs/1607.08318).

The problem that we study, in its simplest form, is the following: an environment Hn alternates between two values, say H+ and H-, where n is the discrete time variable and Hn is a homogeneous discrete time Markov chain. We say that the environment is **symmetric** when the transition probabilities H+ -> H- and H- -> H+ are the same. We call this probability epsilon. 
An **ideal observer** makes noisy observations of Hn at each time n. The noise distributions are known. The observer's main aim is to decide which state the environment is in at any present time. A subordinate aim is to learn the transition probability epsilon.  

Our article deals with complexifications of the case described above, where the 2 transition probabilities are distinct, where the environment can take on N values for N >= 2, and where time becomes continuous. The code present in this repository only deals with discrete time, and with the exception of figure 4, with the 2-state symmetric case.

##Short scripts description
All scripts were written for MATLAB_R2015b release.

###Figure 1
Scripts: *fig1B_data.m*, *fig1_FINAL_plotting.m*

No real computation is performed by those scripts which only had an illustrative aim.

Run the script *fig1B_data.m* to produce a *.mat* file. Run subsequently *fig1_FINAL_plotting.m* to produce figure 1 from our article.

###Figure 2
Scripts: *fig2CD_data.m*, *fig2_FINAL_plotting.m*

Panel A from figure 2 in the article was sketched manually with a drawing software. The data required to plot panels C and D is produced by the script *fig2CD_data.m*. Running it will produce 2 *.mat* files as output. These are in turn used by the final plotting script *fig2_FINAL_plotting.m*. Note that panel B from the figure also has a purely illustrative purpose and is therefore not simulated via the Markov chain Hn.  

###Figure 3
Scripts: *fig3AB_data.m*, *fig3Ck_data.m*, *fig3Cu_data.m*, *fig3_FINAL_plotting.m*

As before, all the scripts ending with *data.m* should be run before the *fig3_FINAL_plotting.m* script.
Each one of the *data.m* script will produce its own *.mat* file. Both *fig3Ck_data.m* and *fig3Cu_data.m* are required for producing the data relative to panel C.

###Figure 4
Scripts: *enfants.m*, *createNodes.m*, *fig4AC_data.m*, *fig4_FINAL_plotting.m*

The scripts *enfants.m* and *createNodes.m* are MATLAB functions used in *fig4AC_data.m*. The latter outputs a *.mat* file required
for the final plotting script *fig4_FINAL_plotting.m*. Panel B from figure 4 contains the list of node counts for the 3-state case hard-coded. These numbers were computed using a combination of Shell and MATLAB. For more information, contact the corresponding author for this repository.

##Corresponding author for the scripts 
adrian@math.uh.edu

##License
See the [LICENSE.txt](../master/LICENSE.txt) file in this repository.
