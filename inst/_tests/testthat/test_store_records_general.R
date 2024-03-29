context("store_records general tests")

tsl <- list(
  ts1 = ts(1:4, 2019, frequency = 12),
  ts2 = ts(1:5, 2019, frequency = 4)
)
class(tsl) <- c("tslist", "list")

if(is_test_db_reachable()) {
  con <- connect_to_test_db()
}

test_with_fresh_db(con, hard_reset = TRUE, "vintage id is a uuid", {
  db_ts_store(con,
                    tsl,
                    access = "tsdb_test_access_public",
                    valid_from = "2019-01-01",
                    schema = "tsdb_test")

  out <- dbGetQuery(con, "SELECT * FROM tsdb_test.timeseries_main")

  expect_match(out$id, "[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}")
})

test_with_fresh_db(con, hard_reset = TRUE, "it can deal with string valid_from", {
  expect_error(db_ts_store(con,
                                 tsl,
                                 access = "tsdb_test_access_public",
                                 valid_from = "2019-01-01",
                                 schema = "tsdb_test"),
               NA)
})

test_with_fresh_db(con, hard_reset = TRUE, "it can deal with string release_date", {
  expect_error(db_ts_store(con,
                                 tsl,
                                 access = "tsdb_test_access_public",
                                 release_date = "2019-01-01",
                                 schema = "tsdb_test"),
               NA)
})
