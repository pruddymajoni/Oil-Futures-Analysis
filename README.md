---
# This project serves to analyze the impact of war vs non-war events on the oil futures market. 

## Hypothesis 

Null hypothesis (H₀):

There is no difference in the impact on oil futures prices across event types (wars vs non-war crises).

Alternative hypothesis (H₁):

War-related events have a significantly greater impact on oil futures prices than non-war global crises.

### Closing Plot
/Users/prudencemajoni/Documents/Project/Final/Closing Price.png

### Summary Stats

summary_stats

  mean_price median_price min_price max_price sd_price n_obs
       <dbl>        <dbl>     <dbl>     <dbl>    <dbl> <int>
       70.4         71.7     -37.6      124.     18.7  1592

### Moving Averages 

Key points:
* MA20 (orange) → short-term trend (reacts quickly to shocks)
* MA50 (green) → medium-term trend
* MA200 (purple) → long-term market direction

The 20-day moving average reacts sharply during crisis periods such as the COVID-19 crash, reflecting rapid changes in short-term market sentiment. In contrast, the 200-day moving average remains smoother, indicating the long-term equilibrium trend of oil prices. Divergences between short-term and long-term averages highlight periods of market instability and transition.

### Rolling volatility

The 20-day rolling volatility plot shows that oil futures experienced their highest level of short-term instability during the early stages of the COVID-19 pandemic in 2020. Volatility rose sharply as global demand collapsed and uncertainty surrounding energy markets intensified. After this period, volatility declined substantially and remained relatively stable, with only moderate increases during later geopolitical events such as the Ukraine war. This suggests that while both war-related and non-war events affect oil prices, the magnitude of market uncertainty depends more on the economic severity of the shock than on the category of the event itself.


### Defining Events

Group 1: War / geopolitical conflict
* Ukraine war (2022–present)
* Iran–Israel tensions / Middle East conflict spikes
* Iraq war (2003) (optional older anchor)

Group 2: Non-war global shocks
* COVID-19 (2020)
* Major economic shock events (e.g., 2008 crisis if you include it)
* Natural disaster shocks affecting supply chains (optional)

Result 

  event_name                        event_date type    price_impact
  <chr>                             <date>     <chr>          <dbl>
1 COVID Crash                       2020-03-11 Non-War      -30.2  
2 COVID Recovery                    2020-11-09 Non-War        8.36 
3 Ukraine War                       2022-02-24 War           10.9  
4 Oil Price War (Saudi-Russia 2020) 2020-03-08 War          -29.0  
5 Middle East Tension               2023-10-07 War           -0.218

War Average : -10.9%
Non-War Average : -6.1%

The data does NOT clearly support this
Instead:Both types create large but inconsistent shocks

The results suggest: Oil price reactions depend more on the type of shock (supply vs demand) rather than simply whether the event is a war or not.

COVID crash (-30%) and Oil Price War (-29%) are similar in magnitude
But come from completely different causes
This shows Oil markets are sensitive to both demand destruction and supply disruptions

### ANOVA RESULTS

           Df Sum Sq Mean Sq F value Pr(>F)
type         1   27.4    27.4   0.052  0.835
Residuals    3 1591.8   530.6        

p-value 0.835 > 0.05 
There is no statistically significant difference between war and non-war events in terms of oil price impact. However, both categories produce large and volatile price movements, suggesting that oil markets respond strongly to global shocks regardless of classification. (Also n=5 is very small)

### INSIGHT

Large price drops (COVID: -30%, Oil Price War: -29%)
Large price increases (Ukraine: +10.9%)
Mixed effects within the same category (war)

Therefore, Oil price movements are highly sensitive to global events, but the direction and magnitude of the impact vary depending on the nature of the shock rather than the classification of the event as war or non-war.
