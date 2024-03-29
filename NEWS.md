## timeseriesdb v1.0.0

Substantial improvements and new functionality. 

- R Postgres interface switched from RPostgreSQL to the DBI compliant RPostgres
- time series represented as JSON instead of hstore for better performance and consistency (ensuring order).
- store version of every time series to track revisions 
- true release date feature
- meta data on vintage (time series version) level 


## timeseriesdb v0.3.5.3 (Release date: 2017-10-20)

- getting ready for next CRAN release
- bulk wise operations using copy



## timeseriesdb v0.21 (Release date: 2015-04-01)

- updated readme
- fixed bug in the shiny based GUI that prevented starting it up properly
- moved sql code to a single setup file


## timeseriesdb v0.2 (Release date: 2015-03-25)

- ~ quarterly release cycle planned
- added convenience function to plot a list of time series (plot.tslist)
- major speed up of write process by avoiding multiple selects (~2 times)
- major speed up of read process by avoiding multiple selects (~ 3.5 times)
- added a table to store sets of time series similar to shopping carts in web stores (basic)
- basic export to .csv format to support wide and long format .csv
- dependency to RJSONIO added as it used for speed up
- added a shiny based data explorer GUI (use function exploredb(con))
- changed upsert behavior to not affect unlocalized meta information on insert of new series
- improved NULL handling
- added SQL transaction utils
- quiet execution of Meta Information Storage
- fixed issues with quotes
- added hstore lookup function
- changed from deprecated hstore operator to new hstore function (see PostgreSQL release notes)
- function to concatenate overlapping series
- function to set attributes to each element of a list
- improved read process for bulk reading to use single query instead of looping
- improve store process
- exported print method
- added function to check whether db connection is valid
- added quickHandle operator and a closure to create further quick Handle operators



## timeseriesdb v0.1 (Release date: 2014-11-26)

- initial realease 
