# README
# R script version of airbnb-san-diego.Rmd

# libraries
library(package = tidyverse)


# data-import
listings <- read.csv(url('http://data.insideairbnb.com/united-states/ca/san-diego/2019-11-21/visualisations/listings.csv'),
                     stringsAsFactors = FALSE)

# data-structure
str(listings)

# data-names
names(listings)

# histogram-price
hist(x = listings$price)

# histogram-log-price
hist(x = log1p(x = listings$price))

# histogram-log-price-ylim
hist(x = listings$price,
     ylim = c(0, 1000))

# filter-price
listings <- listings %>%
  filter(price <= 4000)

# filter-price-table
listings %>% # identify that we will use the listings object
  group_by(neighbourhood) %>% # group the data around the neighborhoods
  # for each neighborhood, calculate summary statistics
  summarise(
    count = n(), # the number of listings in each neighborhood (IEN)
    priceMean = mean(price), # the mean price of listings IEN
    priceSD = sd(price), # the standard deviation of the prices IEN
    priceSE = priceSD/sqrt(count) # the standard error of the price IEN
  ) %>% # use (or pass) the new object of summary values we have just created
  top_n(n = 5, wt = priceMean) %>%  # extract five records that have the highest mean price
  arrange(desc(priceMean)) # arrange data by price (desc = highest to lowest)

# filter-price-plot
listings %>% 
  group_by(neighbourhood) %>% 
  summarise(
    count = n(),
    priceMean = mean(price),
    priceSD = sd(price),
    priceSE = priceSD/sqrt(count)
  ) %>%
  top_n(n = 5, wt = priceMean) %>% 
  # mutate (change) neighbourhood to a factor so we can order it logically in our plot
  mutate(neighbourhood = fct_reorder(.f = neighbourhood, .x = priceMean, .desc = TRUE)) %>% 
  # call the ggplot function and create a blank canvas with neighbourhood and priceMean as the input data
  ggplot(aes(x = neighbourhood, y = priceMean)) +
  # add bars to reflect priceMean; stat = 'identity' tells geom_bar to make the bar heights correspond to the y variable (priceMean) that we called above
  geom_bar(stat = 'identity') +
  # add error bars based on the standard errors we calculated earlier
  geom_errorbar(aes(ymin = priceMean - priceSE, ymax = priceMean + priceSE), width = 0.5) +
  # add a descriptive title
  ggtitle(label = "Airbnb rentals in the San Diego, CA area (five most expensive neighbourhoods)") +
  # add a meaningful y-axis lable
  ylab("mean price per night")
