# Ocean Tracking Network ECR workshop (SSFs)

This repository contains all the relevant code and data for the OTN ECR workshop on step selection functions (SSFs) with non-linear and random effects (Klappstein et al. 2024). We acknowledge the use of the publicly available GPS data from Antarctic Petrels, obtained from MoveBank Data Repository (https://doi.org/10.5441/001/1.q4gn4q56) and originally published in Descamps et al. (2016).  

### Workshop description
The workshop will start by covering the neccessary statistical background, followed by a hands-on R tutorial. The learning objectives of the workshop are to:

1. Understand the statistical background of SSFs, including model formulation, implementation, and interpretation.
2. Formulate SSFs as GAM-like models to include smooth (i.e., non-linear and random) effects. 
3. Learn how to fit and interpret SSFs with non-linear effects in R. 

#### R tutorial structure
In the R tutorial, we will cover how to prepare data for SSFs in the amt package, and fit models in mgcv. We will focus on building complexity through 4 model formulations:

1. A simple SSF with a parametric movement kernel and log-linear selection for depth.
2. An analagous SSF with all smooth terms (i.e., a non-parametric movement kernel and non-linear selection for depth). 
3. An SSF with spatial random effects to capture unexplained spatial pattern.
4. An SSF with time-varying selection for depth via a varying-coefficient model.

We will use the gratia package for visualisation and interpretation. 

### Repository structure and set-up instructions
You can clone the repository, or you can download the data and code as a zip folder by using the '<> Code' dropdown menu at the top right. You can open the R project file, which should avoid any problems with the working directory. The repository has the following folders/files:

1. The *code* folder contains the analysis code in both a script (petrel_ssf.R) and an RMarkdown (petrel_ssf.Rmd) format. There is also a knitted PDF file of the RMarkdown. 
2. The *data* folder contains a csv of the petrel GPS locations and a bathymetry raster obtained from the GEBCO project (https://www.gebco.net/). 

### References

Descamps S, A Tarroux, Y Cherel, K Delord, OR Godø, A Kato, et al. 2016 At-Sea Distribution and Prey Selection of Antarctic Petrels and Commercial Krill Fisheries. PLoS ONE 11(8): e0156968. 

Klappstein NJ, T Michelot, J Fieberg, EJ Pedersen, and J Mills Flemming. 2024. Step selection analysis with non-linear and random effects. Methods in Ecology and Evolution 15(8): 1332-1346.