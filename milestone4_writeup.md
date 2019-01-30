# Milestone 4 Write Up

For milestone 4, we implemented further formatting and design updates/upgrades, wrote in code comments to better our applications documentation, changed our scatter plot to a swarm plot and added a cost-efficiency frontier line to our scatter plot (described below). We believed these were the best changes to implement as we could do all of the changes efficiently and quickly, without getting too stuck in the details of making dramatic changes to our plot. The other changes we made, aside from better documentation, involved updating sidebar colours to match the overall theme of our app, updating axis lines, and getting rid of plot grid lines that took away from the whitespace needed for our app. All of this can be seen in the before and after shots shown below.

One of the changes we would have liked to implement is improving the application's performance in response to filter adjustments.  We tried simplifying our code to isolate the source of the performance issues but were unsuccessful, so given the amount of time we had, it didn't make sense to pursue this any further.

If we were to recreate our app again, the initial wrangling from the app would most likely be done much more efficiently and done first, instead of writing it as we go. This made us go back and forth with the many different formats of data frames, which wasted some time. Another thing we could do differently is to have a much stronger understanding of Plotly before creating an app containing only Plotly charts with hover options for each plot. Doing more research and practicing with Plotly in Rstudio would definitely have sped up our app creation and perfecting timelines. Other than those two, we are both very pleased with how our application turned out and would likely create the similar three plots again. 

The greatest challenge we faced for the final product was our cost-efficiency frontier line.  This line compares the benefit (rating) on the x-axis with its cost (price) on the y-axis.  The further above the frontier line a wine is, the less cost efficient it is.  Implementing this line was challenging because generating it required calculating a convex hull from the filtered data, and then subsetting the convex hull to retain only its underside.

The final changes made from Milestone 3 to Milestone 4 can be seen below:

#### Milestone 3 app:

![](https://github.com/UBC-MDS/wine_viz_mkpv/blob/master/img/milestone4-before.png)


#### Milestone 4 app:

![](https://github.com/UBC-MDS/wine_viz_mkpv/blob/master/img/milestone4_after.png)

