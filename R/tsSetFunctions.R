#' Store a New Set of Time Series
#' 
#' Store a new set of Time Series to the database. Users can select the time series keys
#' that should be grouped inside a set.
#' 
#' @param con PostgreSQL connection object
#' @param set_name character name of a set time series in the database.
#' @param set_keys list of keys contained in the set and their type of key. 
#' @param user_name character name of the user. Defaults to system user. 
#' @param description character description of the set to be stored in the db.
#' @param active logical should a set be active? Defaults to TRUE. If set to FALSE 
#' a set is not seen directly in the GUI directly after being stored and needs to be
#' activated first. 
#' @param tbl character name of set tqble. Defaults to timeseries\_sets.
#' @param schema character name of the database schema. Defaults to timeseries.
#' @author Ioan Gabriel Bucur, Matthias Bannert, Severin Thöni
#' @export
#' @importFrom DBI dbSendQuery
#' @rdname storeTsSet
storeTsSet <- function(con,
                       set_name,
                       set_keys,
                       user_name = Sys.info()['user'],
                       description = '',
                       active = TRUE,
                       tbl = "timeseries_sets",
                       schema = "timeseries") {
  UseMethod("storeTsSet", set_keys)
}

#' @importFrom DBI dbSendQuery
storeTsSet.list <- function(con, set_name, set_keys,
                       user_name = Sys.info()['user'],
                       description = '', active = TRUE,
                       tbl = 'timeseries_sets',
                       schema = 'timeseries') {
  vector_values <-c(set_name,
                    user_name, as.character(Sys.time()),
                    createHstore(set_keys, fct = FALSE), description, active)
  row_values <- paste(lapply(vector_values,
                             function(str) {
                               ifelse(grepl("hstore",str),
                                      sprintf("%s", str),
                                      sprintf("'%s'", str)
                                      )
                               }),
                      collapse = ",")
  
  sql_query <- sprintf(
    "INSERT INTO %s.%s VALUES (%s)",
    schema,tbl, row_values
  )
  class(sql_query) <- "SQL"
  dbSendQuery(con, sql_query)
}

#' @importFrom DBI dbSendQuery
storeTsSet.character <- function(con,
                                 set_name,
                                 set_keys,
                                 user_name = Sys.info()['user'],
                                 description = '',
                                 active = TRUE,
                                 tbl = "timeseries_sets",
                                 schema = "timeseries") {
  key_list <- as.list(rep("ts_key", length(set_keys)))
  names(key_list) <- set_keys
  storeTsSet.list(con, set_name, key_list, user_name, description, active, tbl, schema)
}

#' Join two Time Series sets together
#'
#' This will create a new set set_name_new with the keys from both 
#' set_name_1 and set_name_2 combined.
#' By default the description will be a combination of the descriptions
#' of the subsets and the new set will only be active it BOTH subsets
#' were active.
#'
#' @param con PostgreSQL connection
#' @param set_name_1 Name of the first set
#' @param set_name_2 Name of the second set
#' @param set_name_new Name of the set to be created
#' @param user_name1 User name of the first set's owner
#' @param user_name2 User name of the second set's owner
#' @param user_name_new User name of the new set's owner
#' @param description Description of the new set
#' @param active Should the new set be marked as active
#' @param tbl The time series set table
#' @param schema The time series db schema to use
#' @export
#' @author Severin Thöni
#' @importFrom DBI dbSendQuery
joinTsSets <- function(con,
                       set_name_1, set_name_2, set_name_new,
                       user_name1 = Sys.info()['user'],
                       user_name2 = user_name1,
                       user_name_new = user_name1,
                       description = NULL,
                       active = NULL,
                       tbl = "timeseries_sets",
                       schema = "timeseries") {
  contents1 <- loadTsSet(con, set_name_1, user_name1, tbl, schema)
  contents2 <- loadTsSet(con, set_name_2, user_name2, tbl, schema)
  
  if(is.null(contents1)) {
    message(sprintf("Could not find set %s belonging to %s.", set_name_1, user_name1))
  } else if(is.null(contents2)) {
    message(sprintf("Could not find set %s belonging to %s.", set_name_2, user_name2))
  } else {
    if(is.null(description)) {
      description <- paste(contents1$set_info$description, " combined with ", contents2$set_info$description)
    }
    
    if(is.null(active)) {
      active = contents1$set_info$active && contents2$set_info$active
    }
    
    storeTsSet(con, set_name_new, union(contents1$keys, contents2$keys), user_name_new, description, active, tbl, schema)
  }
}

#' List All Time Series Sets for a Particular User
#' 
#' Show the names of all sets that are available to a particular user. 
#' 
#' @param con PostgreSQL connection object
#' @param user_name character name of the user. Defaults to system user. 
#' @param tbl character name of set tqble. Defaults to timeseries\_sets.
#' @param schema character name of the database schema. Defaults to timeseries.
#' @author Matthias Bannert, Gabriel Bucur
#' @export
#' @importFrom DBI dbGetQuery
#' @rdname listTsSets
listTsSets <- function(con,user_name = Sys.info()['user'],tbl = "timeseries_sets", schema = "timeseries"){
  sql_query <- sprintf("SELECT setname FROM %s.%s 
                       WHERE username = '%s' 
                       AND active = TRUE",
                       schema,tbl,user_name)
  class(sql_query) <- "SQL"
  dbGetQuery(con,sql_query)$setname
}


#' Load a Time Series Set
#' 
#' Loads a Time Series Set.
#' 
#' @param con PostgreSQL connection object
#' @param user_name character name of the user. Defaults to system user. 
#' @param set_name character name of the set to be loaded.
#' @param tbl character name of set tqble. Defaults to timeseries\_sets.
#' @param schema character name of the database schema. Defaults to timeseries.
#' @author Matthias Bannert, Ioan Gabriel Bucur
#' @export
#' @importFrom DBI dbGetQuery
#' @importFrom jsonlite fromJSON
#' @rdname loadTsSet
loadTsSet <- function(con, set_name, user_name = Sys.info()['user'],
                       tbl = 'timeseries_sets', schema = 'timeseries') {
  
  sql_query <- sprintf("SELECT setname,username,tstamp,
                       set_description,active,
                       key_set::json::text FROM %s.%s WHERE username = '%s'
                       AND setname = '%s'",
                       schema, tbl, user_name,set_name)
  class(sql_query) <- "SQL"
  set <- dbGetQuery(con, sql_query)
  if(nrow(set) == 0){
    message("No set with this set_name / user_name combination available.")
    return(NULL)
  }
  
  
  result <- list()
  result$set_info <- set[,c("setname","username","tstamp","set_description","active")]
  json_conversion <- fromJSON(set$key_set)
  result$keys <- names(json_conversion)
  result$key_type <- unique(json_conversion)
  if(length(result$key_type) != 1) stop("Multiple key type are not allowed in the same set yet.")
  result
}


#' Deactivate a Set of Time Series
#' 
#' This deactivates a set of time series to get out of the user's sight, 
#' but it's not the deleted because users may not delete sets.
#'
#' @param con PostgreSQL connection object
#' @param set_name character name of the set to be deactivated.
#' @param user_name character name of the user. Defaults to system user. 
#' @param tbl character name of set tqble. Defaults to timeseries\_sets.
#' @param schema character name of the database schema. Defaults to timeseries.
#' @author Matthias Bannert, Ioan Gabriel Bucur
#' @export
#' @importFrom DBI dbGetQuery
#' @rdname deactivateTsSet
deactivateTsSet <- function(con,set_name,
                            user_name = Sys.info()['user'],
                            tbl = "timeseries_sets",
                            schema = "timeseries"){
  sql_query <- sprintf("UPDATE %s.%s SET active = FALSE
                       WHERE username = '%s' AND setname = '%s'",
                       schema,tbl,user_name,set_name)
  class(sql_query) <- "SQL"
  dbGetQuery(con,sql_query)
}



#' Activate a Set of Time Series
#' 
#' Activate a set of time series to get in the user's sight. 
#' Deactivated sets are not deleted though.
#'
#' @param con PostgreSQL connection object
#' @param user_name character name of the user. Defaults to system user. 
#' @param set_name character name of the set to be activated.
#' @param tbl character name of set tqble. Defaults to timeseries\_sets.
#' @param schema character name of the database schema. Defaults to timeseries.
#' @author Matthias Bannert, Ioan Gabriel Bucur
#' @export
#' @importFrom DBI dbGetQuery
#' @rdname activateTsSet
activateTsSet <- function(con,set_name,
                            user_name = Sys.info()['user'],
                            tbl = "timeseries_sets",
                            schema = "timeseries"){
  sql_query <- sprintf("UPDATE %s.%s SET active = TRUE
                       WHERE username = '%s' AND setname = '%s'",
                       schema,tbl,user_name,set_name)
  class(sql_query) <- "SQL"
  dbGetQuery(con,sql_query)
}

#' Overwrite a Time Series set with a new one
#'
#' Completely replaces the set set_name of user_name with the new values
#' (keys, description, active) of the new one.
#' If the set does not yet exist for the given user it will be created.
#'
#' @param con PostgreSQL connection
#' @param set_name The name of the set to be overwritten
#' @param ts_keys The keys in the new set
#' @param user_name The owner of the set to be overwritten
#' @param description The description of the new set
#' @param active Should the new set be active?
#' @param tbl Name of the time series sets table
#' @param schema Schema of the time series database to use
#' @export
#' @author Severin Thöni
#' @importFrom DBI dbSendQuery
overwriteTsSet <- function(con,
                           set_name,
                           ts_keys,
                           user_name = Sys.info()['user'],
                           description = "",
                           active = TRUE,
                           tbl = "timeseries_sets",
                           schema = "timeseries") {
    deleted <- deleteTsSet(con, set_name, user_name, tbl, schema)
    
    if(dbGetException(deleted)$errorNum == 0) {
      storeTsSet(con, set_name, ts_keys, user_name, description, active, tbl, schema)
    }
}

#' Add keys to an existing Time Series set
#'
#' @param con PostgreSQL connection
#' @param set_name The name of the set
#' @param ts_keys A character vector of keys to be added
#' @param user_name The user name of the set's owner
#' @param tbl Name of the time series sets table
#' @param schema Schema of the time series database to use
#' @export
#' @author Severin Thöni
#' @importFrom DBI dbSendQuery
addKeysToTsSet <- function(con,
                           set_name,
                           ts_keys,
                           user_name = Sys.info()['user'],
                           tbl = "timeseries_sets",
                           schema = "timeseries") {
  set <- loadTsSet(con, set_name, user_name, tbl, schema)
  
  if(!is.null(set)) {
    hstore <- paste(sprintf("%s => ts_key", unique(c(ts_keys, set$keys))), collapse = ", ")
    sql_query <- sprintf("UPDATE %s.%s set key_set = '%s' WHERE username = '%s' and setname = '%s'",
                         schema, tbl, hstore, user_name, set_name)
    dbSendQuery(con, sql_query)
  } else {
    message("Set-User combination not found!")
  }
}

#' Remove keys from a Time Series set (if present)
#'
#' @param con PostgreSQL connection
#' @param set_name character name of a time series set.
#' @param ts_keys A character vector of keys to be removed.
#' @param user_name The user name of the set's owner.
#' @param tbl Name of the time series sets table.
#' @param schema Schema of the time series database to use.
#' @export
#' @author Severin Thöni
#' @importFrom DBI dbSendQuery
removeKeysFromTsSet <- function(con,
                                set_name,
                                ts_keys,
                                user_name = Sys.info()['user'],
                                tbl = "timeseries_sets",
                                schema = "timeseries") {
  set <- loadTsSet(con, set_name, user_name, tbl, schema)
  
  if(!is.null(set)) {
    hstore <- paste(sprintf("%s => ts_key", setdiff(set$keys, ts_keys)), collapse = ", ")
    sql_query <- sprintf("UPDATE %s.%s set key_set = '%s' WHERE username = '%s' and setname = '%s'",
                         schema, tbl, hstore, user_name, set_name)
    dbSendQuery(con, sql_query)
  } else {
    message("Set-User combination not found!")
  }
}

#' Change the owner of a Time Series set
#'
#' @param con PostgreSQL connection
#' @param set_name Name of the set to be updates
#' @param old_owner User name of the set's current owner
#' @param new_owner User name of the set's new owner
#' @param tbl Name of the time series sets table
#' @param schema Schema of the time series database to use
#' @export
#' @author Severin Thöni
#' @importFrom DBI dbSendQuery
changeTsSetOwner <- function(con,
                             set_name,
                             old_owner = Sys.info()['user'],
                             new_owner,
                             tbl = "timeseries_sets",
                             schema = "timeseries") {
  sql_query <- sprintf("UPDATE %s.%s SET username = '%s' WHERE setname = '%s' AND username = '%s'",
                       schema, tbl, new_owner, set_name, old_owner);
  dbSendQuery(con, sql_query)
}

#' Permanently delete a Set of Time Series Keys
#'
#' @param con PostgreSQL connection object
#' @param set_name The name of the set to be deleted
#' @param user_name Username to which the set belongs
#' @param tbl Name of set table
#' @param schema Name of timeseries schema
#' @author Severin Thöni
#' @export
#' @importFrom DBI dbSendQuery
deleteTsSet <- function(con,
                        set_name,
                        user_name = Sys.info()['user'],
                        tbl = "timeseries_sets",
                        schema = "timeseries") {
  sql_query <- sprintf("DELETE FROM %s.%s WHERE username = '%s' AND setname = '%s'",
                       schema, tbl, user_name, set_name)
  dbSendQuery(con, sql_query)
}
