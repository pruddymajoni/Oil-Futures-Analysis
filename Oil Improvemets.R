# Load Libraries
library(quantmod)   # For fetching financial data
library(tidyverse)  # For data manipulation and plotting
library(timetk)     # For converting xts to tidy tibbles
library(forecast)   # For ARIMA forecasting
library(zoo)        # For rolling calculations (volatility)

# ==============================================================================
# 2. Fetch Daily Crude Oil Futures Data (I'm fetching directly from yahoo)
# ==============================================================================
# "CL=F" is the Yahoo Finance symbol for WTI crude oil futures
# We fetch data from Jan 1, 2020 to today 
getSymbols("CL=F", src = "yahoo", from = "2020-01-01", to = Sys.Date())

#===============================================================================
# 3. I'm going to clean the data and rename some columns
#===============================================================================

# Remove missing values (safer for analysis)because some financial days may contain missing values due to:
#holiday closures, incomplete API data, weekend shifts, adjustments
CLF_clean <- na.omit(`CL=F`)

# Preview few rows cleaned data
head(CLF_clean)


oil_data <- CLF_clean %>%
  tk_tbl(rename_index = "Date") %>%
  rename(
    Open = CL.F.Open,
    High = CL.F.High,
    Low = CL.F.Low,
    Close = CL.F.Close,
    Volume = CL.F.Volume,
    Adjusted = CL.F.Adjusted
  ) %>%
  arrange(Date)

# Check first few rows 
head(oil_data) 
#===============================================================================
# 4. Simple line plot for closing price 
#===============================================================================
ggplot(oil_data, aes(x = Date, y = Close)) +
  
  # Closing price line
  geom_line(color = "steelblue", size = 1) +
  
  # Vertical event lines
  geom_vline(
    data = events,
    aes(xintercept = as.numeric(event_date), color = type),
    linetype = "dashed",
    size = 0.9
  ) +
  
  # Event labels
  geom_text(
    data = events,
    aes(
      x = event_date,
      y = max(oil_data$Close, na.rm = TRUE) * 0.95,
      label = event_name
    ),
    angle = 90,
    vjust = -0.4,
    hjust = 1,
    size = 3,
    inherit.aes = FALSE
  ) +
  
  labs(
    title = "WTI Crude Oil Futures Prices with Major Global Events",
    subtitle = "Major geopolitical and economic events affecting oil markets",
    x = "Date",
    y = "Closing Price (USD per Barrel)",
    color = "Event Type"
  ) +
  
  theme_minimal()

#===============================================================================
#Summary Stats
#===============================================================================
summary_stats <- oil_data %>%
  summarise(
    mean_price   = mean(Close, na.rm = TRUE),
    median_price = median(Close, na.rm = TRUE),
    min_price    = min(Close, na.rm = TRUE),
    max_price    = max(Close, na.rm = TRUE),
    sd_price     = sd(Close, na.rm = TRUE),
    n_obs        = n()
  )

summary_stats

#===============================================================================
#moving averages
#===============================================================================

library(dplyr)
library(zoo)

oil_ma <- oil_data %>%
  arrange(Date) %>%
  mutate(
    MA20  = rollmean(Close, k = 20, fill = NA, align = "right"),
    MA50  = rollmean(Close, k = 50, fill = NA, align = "right"),
    MA200 = rollmean(Close, k = 200, fill = NA, align = "right")
  )

library(ggplot2)

ggplot(oil_ma, aes(x = Date)) +
  geom_line(aes(y = Close), color = "steelblue", size = 1, alpha = 0.8) +
  geom_line(aes(y = MA20), color = "orange", size = 0.8) +
  geom_line(aes(y = MA50), color = "green", size = 0.8) +
  geom_line(aes(y = MA200), color = "purple", size = 0.8) +
  labs(
    title = "WTI Crude Oil Prices with Moving Averages",
    subtitle = "20-day (orange), 50-day (green), 200-day (purple)",
    x = "Date",
    y = "Price (USD per Barrel)"
  ) +
  theme_minimal()

#===============================================================================
#rolling volatility
#===============================================================================
ggplot(oil_vol, aes(x = Date, y = rolling_vol_20)) +
  geom_line(color = "purple", size = 1) +
  geom_vline(
    data = events,
    aes(xintercept = as.numeric(event_date), color = type),
    linetype = "dashed",
    size = 0.8
  ) +
  geom_text(
    data = events,
    aes(
      x = event_date,
      y = max(oil_vol$rolling_vol_20, na.rm = TRUE),
      label = event_name
    ),
    angle = 90,
    vjust = -0.4,
    size = 3,
    inherit.aes = FALSE
  ) +
  labs(
    title = "20-Day Rolling Volatility of WTI Crude Oil Returns",
    x = "Date",
    y = "Volatility"
  ) +
  theme_minimal()

#===============================================================================
#define events
#===============================================================================
events <- tibble(
  event_name = c(
    "COVID Crash",
    "COVID Recovery",
    "Ukraine War",
    "Oil Price War (Saudi-Russia 2020)",
    "Middle East Tension"
  ),
  event_date = as.Date(c(
    "2020-03-11",
    "2020-11-09",   # vaccine announcement (recovery)
    "2022-02-24",
    "2020-03-08",   # oil price war
    "2023-10-07"
  )),
  type = c(
    "Non-War",
    "Non-War",
    "War",
    "War",
    "War"
  )
)

ggplot(oil_data, aes(x = Date, y = Close)) +
  geom_line(color = "steelblue") +
  geom_vline(
    data = events,
    aes(xintercept = as.numeric(event_date), color = type),
    linetype = "dashed",
    size = 1
  ) +
  labs(
    title = "Oil Prices with Major Events",
    x = "Date",
    y = "Price"
  ) +
  theme_minimal()

ggplot(event_results, aes(x = event_name, y = price_impact, fill = type)) +
  geom_bar(stat = "identity") +
  labs(title = "Oil Price Impact by Event",
       x = "Event",
       y = "% Price Change") +
  theme_minimal()

#===============================================================================
#Calculate pct impact
#===============================================================================
calculate_event_impact <- function(event_date, data, window = 7) {
  
  before <- data %>%
    filter(Date >= (event_date - window) & Date < event_date)
  
  after <- data %>%
    filter(Date > event_date & Date <= (event_date + window))
  
  # Safety check (prevents errors if missing data)
  if(nrow(before) == 0 | nrow(after) == 0) return(NA)
  
  before_avg <- mean(before$Close)
  after_avg  <- mean(after$Close)
  
  pct_change <- (after_avg - before_avg) / before_avg * 100
  
  return(pct_change)
}

event_results <- events %>%
  rowwise() %>%
  mutate(
    price_impact = calculate_event_impact(event_date, oil_data)
  ) %>%
  ungroup()

event_results

#===============================================================================
ANOVA
#===============================================================================
anova_model <- aov(price_impact ~ type, data = event_results)
summary(anova_model)

#===============================================================================
SQL 
#===============================================================================

install.packages("sqldf")
library(sqldf)

event_volume <- events %>%
  rowwise() %>%
  mutate(
    avg_volume = mean(
      oil_data$Volume[
        oil_data$Date >= (event_date - 7) &
          oil_data$Date <= (event_date + 7)
      ],
      na.rm = TRUE
    )
  ) %>%
  ungroup()

event_volume

#===============================================================================
#Volume Chart
#===============================================================================

ggplot(event_volume, aes(x = event_name, y = avg_volume, fill = type)) +
  geom_bar(stat = "identity") +
  geom_text(
    aes(label = round(avg_volume, 0)),
    vjust = -0.3,
    size = 3
  ) +
  labs(
    title = "Average Trading Volume Around Major Events",
    x = "Event",
    y = "Average Volume"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )


