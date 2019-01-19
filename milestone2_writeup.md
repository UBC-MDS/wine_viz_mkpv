# Wine Rating Application Write-Up


## Rational:

Our exploratory wine rating application has come together by closely replicating our initial sketch's layout and specific colour palette choices. On the left hand side, the eye is first drawn to the sliders and conditional drop down menus of the price, rating, nation, region, and vintage of the wines the user wants to explore. These toggles should be able to filter each other in a hierarchical way so the user is not overwhelmed by a very large list of regions when only the country of `France` is chosen. This way they only get wine regions _in_ France. The vintage selection was done by extracting the vintage year from the `title` column in the original dataset and making it a new factor field from which we can filter our application. All of our plots were made using plotly to make sure we have a hover feature to show additional information in tooltips.

## Tasks
1.  Build a choropleth world map with a hover tooltip:
> Create a choropleth heatmap of the world with the average wine ratings for each country to be shown as a heat map. This will give a good overall worldview of wine averages and may point to specific countries the user wants to filter down to. Data wrangling will be needed to get `iso3c` country codes and wine rating averages for each country.  <BR>
The colour palette we chose for the heatmap was shades from red to purple to go with our wine theme and single gradient colour heat maps tend to be the better choice instead of a converging colour scheme when comparing scores.

2. Build a horizontal bar chart with the top 10 varieties of wines, shown by average score.
> We chose to give every variety of grape it's own colour, within the same red-purple colour palette. Using R's `dplyr` library, we are able to wrangle the data to be nicely arranged and have only the top 10 varieties be shown.

3. Build a scatterplot with price vs. rating:
> The scatter plot next to it looks at each bottle and plots it with its price and the rating. This plot contains much more information in it's hover tooltip with the wine's name, price, vintage, and nation. This will mainly be added in as `paste()` in a text option.

4. Configure the layout to show the map up top and the other 2 plots below, side by side.
> Configure the `ui` code to have `fluidRow()` to have two plots side by side.


## Vision and next steps:

The goal of the choropleth heat map be selectable and be a filter itself, however as this is only a draft we will move that functionality goal to milestone 3. We also have the goal for the choropleth heatmap to show the top regions within that country in the hover-tooltip for milestone 3. This may include further text wrangling. Our vision has stayed roughly the same since our initial sketch. The original goal of our application was to make an exploratory wine application and I believe that is still our goal. Our application has the functionality of an exploratory app due to the many filters and specifications one could either dig deep into or just choose to have a broader look for world wine ratings. Our app does what we set out to facilitate with a few limitations on details about each plot, which we originally intended to deliver through the tooltips. We aim to include this functionality for our next milestone.

## Bugs:

- The horizontal bar plot cannot be in a descending order with the highest rated grape variety on top. `plotly` sorts do not work well with `dplyr` sorts and filters, we aim to solve that issue for milestone 3. Perhaps we can make it into a `ggplotly` object instead.
- The tooltips in the map and horizontal bar chart are very particular and are difficult to change. Further investigation into documentation might be needed to have completely re-written tooltips to include good qualitative information.
- The tooltips are not left-aligned. This is a plotly issue that has not yet been closed.



## Screenshots

This is the initial view below of our app with all of the features selected to be "Select All":

![](https://github.com/mkeyim/wine_viz_mkpv/blob/master/img/milestone2-full.png)



This screenshot below is a filtered view of our app to only include wines from the Niagara region in Canada:

![](https://github.com/mkeyim/wine_viz_mkpv/blob/master/img/milestone2-filtered.png)



This screenshot below  shows our conditional filtering within our dropdown menus. When "Canada" is select as the country, only regions within Canada are shown. 

![](https://github.com/mkeyim/wine_viz_mkpv/blob/master/img/milestone2-filtered.png)



This screenshot below shows what is included within our tooltips in our Plotly graphs. 

![](https://github.com/mkeyim/wine_viz_mkpv/blob/master/img/milestone2-tooltip.png)

