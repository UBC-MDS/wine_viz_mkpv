## Wine Rating Application Write-Up


    Your writeup should include the rationale for your design choices, focusing on the interaction aspects and connecting these choices to a data abstraction (including a characterization of the raw data types and their scale/cardinality, and of any derived data that you decide compute) and the task abstraction (including a more detailed breakdown of tasks that arise from the goal stated above). You should also concisely describe your visual encoding choices.

    Talk about how your vision has changed since your proposal
    How have your visualization goals changed?
    Does your app enable the tasks you set out to facilitate?


Our exploratory wine rating application has come together by closely replicating our initial sketch's layout and specific colour palette choices. On the left hand side, the eye is first drawn to the sliders and conditional drop down menus of the price, rating, nation, region, and vintage of the wines the user wants to explore. These toggles should be able to filter each other in a hierarchical way so the user is not overwhelmed by a very large list of regions when only the country of `France` is chosen. This way they only get wine regions _in_ France. The vintage selection was done by extracting the vintage year from the `title` column in the original dataset and making it a new factor field from which we can filter our application.

On the right hand side, we first have a world map showing the average rating for wines in that region in a choropleth plot. The darkest regions shows the highest rated wine nations by average. The goal was to have this choropleth heat map be selectable and be a filter itself, however as this is only a draft we will move that functionality goal to milestone 3. We also have the goal for the choropleth heatmap to show the top regions within that country in the hover-tooltip for milestone 3. The colour palette we chose for the heatmap was shades from red to purple to go with our wine theme and single gradient colour heat maps tend to be the better choice instead of a converging colour scheme when comparing scores.

Below our choropleth map, we have two plots. One is the Top 10 Varieties with their average ratings. We chose to give every variety of grape it's own colour, within the same red-purple colour palette. The aim was to have the horizontal bar plot be sorted in a descending order with the highest rated grape variety on top, however `plotly` sorts do not work well with `dplyr` sorts and filters, we aim to solve that issue for milestone 3. The scatter plot next to it looks at each bottle and plots it with its price and the rating. This plot contains much more information in it's tooltip with the wine's name, price, vintage, and nation.

Our vision has stayed roughly the same since our initial sketch, except for a couple details. Our original sketch was made in Tableau and Shiny has a few limitations that makes the smaller details of the application more difficult to implement. The original goal of our application was to make an exploratory wine application and I believe that is still our goal. Our application has the functionality of an exploratory app due to the many filters and specifications one could either dig deep into or just choose to have a broader look for world wine ratings. Our app does what we set out to facilitate with a few limitations on details about each plot, which we originally intended to deliver through the tooltips. We aim to include this functionality for our next milestone.


## Screenshots

This is the initial view below of our app with all of the features selected to be "Select All":

![](https://github.com/mkeyim/wine_viz_mkpv/blob/master/img/milestone2-full.png)



This screenshot below is a filtered view of our app to only include wines from the Niagara region in Canada:

![](https://github.com/mkeyim/wine_viz_mkpv/blob/master/img/milestone2-filtered.png)



This screenshot below  shows our conditional filtering within our dropdown menus. When "Canada" is select as the country, only regions within Canada are shown. 

![](https://github.com/mkeyim/wine_viz_mkpv/blob/master/img/milestone2-filtered.png)



This screenshot below shows what is included within our tooltips in our Plotly graphs. 

![](https://github.com/mkeyim/wine_viz_mkpv/blob/master/img/milestone2-tooltip.png)

