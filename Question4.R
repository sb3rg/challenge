library(ggfortify)
# ##################
# ### QUESTION 4 ###
# ##################
### RESPONSE NOTES ############################
### This is a digital signal processing method.
### 
### The high-level overview of what's happening with the code chunk is
### that we're simulating time series data by amplifying certain frequencies
### in the frequency domain so that when we transform the signal back to the
### time domain (inverse DFT), the signal has the desired periodicities.
### The code does this while preserving the original statistical parameters 
### of the sampling distribution.
### 
### The reason why we have to mirror the signal is to account for aliasing about the
### nyquist frequency and preserving information about the original signal when 
### performing the inverse transform.
###############################################


# set size of sample
N <- 512  

# create two indices 8 and 16
inds <- c(8, 16)

# scaling factor for signal amplitude in frequency domain
b <- 30

# set the number of samples per unit time--sampling frequency
a <- 128

# sample 512 values from the normal distribution
s <- rnorm(N)

# perform the fast discrete fourier transform of the sample data
# return a vector of complex numbers.  This transforms time domain
# values into the frequency domain
x <- fft(s)

# repeat false (N/2-1) times.
logind <- rep(F, N/2-1)

# replace two falses with true at index 8 and 16 in the vector
logind[inds] <- T

# concatenate logind vector with leading and trailing FALSe values with
# the added concatenation of the reverse of the original vector
logind <- c(F, logind, F, rev(logind))

# replace four complex numbers after scaling by 'b'
# the indices are now c(9,17,497, 505)
x[logind] <- b*x[logind]

# take the inverse discrete fourier transform of the scaled response
# divide the values by half and return only the real component of
# complex number.
y <- Re(fft(x, inverse=T)/length(x))

# generate a time series object scaled to a range that's in the
# standard normal distribution
result <- ts(y/sd(y), frequency=a)





## BEGIN ANALYSIS AND GRAPHS
result %>% autoplot()+
  ## TITLES & AXES
  labs( # draw labels
    y = "Result",
    x = "Time"
  )+
  theme_classic()

ggsave(path="./", filename="q4_result_ts.png", height = 4.78, width = 8.75, units = "in", device = "png" )
## END ANALYSIS AND GRAPHS