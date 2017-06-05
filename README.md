### PRCT (Data Operations) Automation

#### Summary

Create an automated build process for the PRCT realm similar to those that already exist within the FCRA nonFCRA, and Boolean realm.

#### Outline

What set the automated build process for the PRCT realm apart from those that already exist in FCRA nonFCRA, and Boolean realm is that it has to be robust enough to tackle all the similarities and difference of all the datasets that encompass the PRCT realm.
At high level the automated process to be to do the following for all the PRCT builds.
1. Get the file or files that are dropped in the landing zone for each individual dataset.
2. If necessary do integrity verification on the file or files depending on what is outlined for each dataset.
3. Run the corresponding ECL build attributes to spray and build the data.
4. If we have not received data within a set period of time run the build process utilizing the data previously sprayed.
