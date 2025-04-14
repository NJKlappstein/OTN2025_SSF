# Ocean Tracking Network ECR workshop (SSFs)

This repository contains all the relevant code and data for the OTN ECR workshop on step selection functions (SSFs) with non-linear and random effects (Klappstein et al. 2024). We acknowledge the use of the publicly available GPS data from Antarctic Petrels, obtained from MoveBank Data Repository (Descamps et al. 2016; https://doi.org/10.5441/001/1.q4gn4q56). 

## Basic repository structure
The `code` folder contains the analysis code in both a script (petrel_ssf.R) and an RMarkdown (petrel_ssf.Rmd) format. There is also a knitted PDF file of the RMarkdown. The `data` folder contains the petrel GPS locations (stored as a csv file) and a bathymetry raster obtained from the GEBCO project (https://www.gebco.net/). 

## Basic tutorial structure
In this tutorial, we will focus on building the complexity of a simple SSF via the inclusion of non-linear model terms. We will use the mgcv package to fit 4 models: 

1. A simple SSF with a parametric movement kernel and log-linear selection for depth.
2. An analagous SSF with all smooth terms (i.e., a non-parametric movement kernel and non-linear selection for depth). 
3. An SSF with time-varying selection for depth via a varying-coefficient model. 
4. An SSF with spatial random effects to capture unexplained spatial pattern.

## References

Descamps S, A Tarroux, Y Cherel, K Delord, OR Godø, A Kato, et al. 2016 At-Sea Distribution and Prey Selection of Antarctic Petrels and Commercial Krill Fisheries. PLoS ONE 11(8): e0156968. 

Klappstein NJ, T Michelot, J Fieberg, EJ Pedersen, and J Mills Flemming. 2024. Step selection analysis with non-linear and random effects. Methods in Ecology and Evolution 15(8): 1332-1346.