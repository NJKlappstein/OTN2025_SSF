# install packages if you do not have them 
install.packages("terra")
install.packages("amt")
install.packages("mgcv")
install.packages("gratia")
install.packages("ggplot2")
install.packages("CircStats")
install.packages("cowplot")

# load packages
library(terra)
library(amt)
library(mgcv)
library(gratia)
library(ggplot2)
library(CircStats)
library(cowplot)
theme_set(theme_bw()) # set ggplot theme


## ----data-------------------------------------------------------------------------------------------------
# load processed locations
data <- read.csv("data/petrel.csv")
head(data)

# load bathymetry and convert to depth in km
depth <- rast("data/bathymetry_raster.tif")
depth <- - depth / 1000
names(depth) <- "depth"

# map of depth and petrel locations
plot(depth)
points(data$x, data$y)

# format times
data$time <- as.POSIXct(data$time)

# make amt track formatted as steps
data <- make_track(data, .x = x, .y = y, .t = time) |>
  steps()

# look at data
head(data)


## ---- get random_steps ---------------------------------------------------------------------
# simulate many random distances and turning angles
set.seed(25)
rmax <- max(data$sl_) 
sl_star <- sqrt(runif(n = 1e5, 0, rmax^2))
ta_star <- runif(n = 1e5, -pi, pi)

# add random locations to data
data <- random_steps(data, n_control = 100, 
                     rand_sl = sl_star,
                     rand_ta = ta_star)

# view data
print(data, n = 6, width = Inf)

# plot subset of data to visualise random steps
ggplot(subset(data, step_id_ %in% 4:6 & case_ == FALSE), 
       aes(x = x2_, y = y2_, color = factor(step_id_))) +
  geom_point() +
  geom_point(aes(x = x2_, y = y2_), 
             data = subset(data, step_id_ %in% 3:5 & case_ == TRUE), 
             col = 1, size = 2) +
  coord_equal()


# get bathymetry values at each point
data <- extract_covariates(x = data, covariates = depth, where = "end")

# convert step length into km
data$sl_ <- data$sl_ / 1000

# look at histogram to get a sense of covariate range at observed locs
obs <- subset(data, case_ == 1)
ggplot(obs, aes(x = depth)) + 
  geom_histogram(fill = "grey75", color = "grey25") + xlab("depth (km)")

# plot histograms
ggplot(obs, aes(x = sl_)) + 
  geom_histogram(fill = "grey75", color = "grey25")
ggplot(obs, aes(x = ta_)) + 
  geom_histogram(fill = "grey75", color = "grey25")



## ----fit model 1 (linear) ------------------------------------------------------------------------------------------
# format for mgcv
data$dummy_times <- 1

# fit model with all linear/parametric terms
fit_linear <- gam(cbind(dummy_times, step_id_) ~ 
                    sl_ + 
                    cos(ta_) + 
                    depth, 
                  data = data, 
                  family = cox.ph, 
                  weights = case_)

summary(fit_linear)

# angular concentration
kappa <- as.numeric(coefficients(fit_linear)["cos(ta_)"])
kappa

# step length parameters and distribution
beta_sl <- as.numeric(coefficients(fit_linear)["sl_"])
shape <- 2
scale <- - 1 / beta_sl

# derive mean and standard deviation of sl distribution
mean_step <- shape * scale
sd_step <- sqrt(shape) * scale
c(mean_step, sd_step)

# density plot for angles and step lengths
# step length
step_grid <- seq(0, 35, by= 0.1)
sl_df <- data.frame(sl_ = step_grid, density = dgamma(step_grid, shape = shape, scale = scale))
step_plot <- ggplot(sl_df, aes(x = sl_, y = density)) + geom_line()

# angle
angle_grid <- seq(-pi, pi, by = 0.01)
ang_df <- data.frame(ta_ = angle_grid, density = dvm(angle_grid, mu = 0, kappa = kappa))
ang_plot <- ggplot(ang_df, aes(x = ta_, y = density)) + geom_line()

# plot together
plot_grid(step_plot, ang_plot)

# RSS/effect of depth
exp(coefficients(fit_linear)["depth"])


## ----fit model with smooths ---------------------------------------------------------------------------------
fit_smooth <- gam(cbind(dummy_times, step_id_) ~ 
                    s(sl_) + 
                    s(ta_, bs = "cc") + 
                    s(depth), 
                  data = data, 
                  knots = list(ta_ = c(-pi, pi)), 
                  family = cox.ph, 
                  weights = case_)

summary(fit_smooth)

# smoothness parameters
fit_smooth$sp

# estimated non-linear relationships
gratia::draw(fit_smooth, rug = FALSE, fun = exp)

# calculate relative selection strength
pred <- predict(fit_smooth, 
                newdata = data.frame(sl_ = c(0, 0), 
                                     ta_ = c(0, 0), 
                                     depth = c(0, 1)))
rss <- exp(pred[2]) / exp(pred[1])
rss

# derive step length distribution
sm <- smooth_estimates(fit_smooth, select = c("s(sl_)"))
ggplot(sm, aes(x = sl_, y = exp(.estimate) * sl_)) + 
  geom_line() + ylab("distribution") 

## ----spatial smooth model --------------------------------------------------------------------------------
fit_ss <- gam(cbind(dummy_times, step_id_) ~ 
                s(sl_) + 
                s(ta_, bs = "cc") + 
                depth + 
                s(x2_, y2_), 
              data = data, 
              knots = list(ta_ = c(-pi, pi)),
              family = cox.ph, 
              weights = case_)

# look at spatial smooth with observed points 
gratia::draw(fit_ss, select = 3, rug = FALSE) + 
  geom_point(aes(x1_, y1_), data = subset(data, case_ == 1))

# calculate relative selection strength just based on space
pred <- predict(fit_ss, 
                newdata = data.frame(sl_ = c(0, 0), 
                                     ta_ = c(0, 0), 
                                     depth = c(0, 0), 
                                     x2_ = c(8e5, 8e5), 
                                     y2_ = c(-6.8e6, -6.7e6)))
rss <- exp(pred[2]) / exp(pred[1])
rss


## ----varying-coefficient model -------------------------------------------------------------------------------------------
data$time <- data$step_id_ / 2 # two locations per hour
fit_vc <- gam(cbind(dummy_times, step_id_) ~ 
                sl_ +
                cos(ta_) +
                s(time, by = depth, k = 12), 
              data = data, 
              family = cox.ph, 
              weights = case_)

summary(fit_vc)
gratia::draw(fit_vc, rug = FALSE) + 
  labs(x = "time (hours since start of series)", y = expression(beta[depth]))


## ----tensor product for movement kernel --------------------------------------------
fit_tensor <- gam(cbind(dummy_times, step_id_) ~ 
                    te(sl_, ta_, bs = c("tp", "cc") ) + 
                    depth, 
                  data = data, 
                  family = cox.ph, 
                  knots = list(ta_ = c(-pi, pi)), 
                  weights = case_)

gratia::draw(fit_tensor, rug = FALSE)

