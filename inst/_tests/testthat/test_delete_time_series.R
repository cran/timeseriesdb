context("deleting ts")

if(is_test_db_reachable()) {
  con_admin <- connect_to_test_db()
  con_writer <- connect_to_test_db("dev_writer")
}

test_that("it aborts if the user does not type yes", {
  fake_readline <- mock("nope")
  with_mock(
    readline = fake_readline,
    expect_error(db_ts_delete("con", "vts2", "tsdb_test"), "nope")
  )
})

test_with_fresh_db(con_admin, "writer may not delete whole ts", {
  fake_readline <- mock("yes")
  with_mock(
    readline = fake_readline,
    {
      expect_error(
        db_ts_delete(con_writer, "vts1", schema = "tsdb_test"),
        "sufficient privileges"
      )
    }
  )
})

test_with_fresh_db(con_admin, "db_ts_delete returns a status", {
  fake_readline <- mock("yes")

  with_mock(
    readline = fake_readline,
    {
      out <- db_ts_delete(con_admin, "vts1", schema = "tsdb_test")
      expect_equal(out, list(status = "ok"))
    }
  )
})

test_with_fresh_db(con_admin, "deleting ts cleans house", {
  fake_readline <- mock("yes")
  with_mock(
    readline = fake_readline,
    {
      db_ts_delete(con_admin, c("vts1", "vts2"), schema = "tsdb_test")

      vintages <- dbGetQuery(con_admin, "SELECT * FROM tsdb_test.timeseries_main WHERE ts_key = ANY('{vts1, vts2}'::TEXT[])")
      expect_equal(nrow(vintages), 0)

      mdl <- dbGetQuery(con_admin, "SELECT * FROM tsdb_test.metadata_localized WHERE ts_key = ANY('{vts1, vts2}')")
      expect_equal(nrow(mdl), 0)

      mdul <- dbGetQuery(con_admin, "SELECT * FROM tsdb_test.metadata WHERE ts_key = ANY('{vts1, vts2}')")
      expect_equal(nrow(mdul), 0)

      catalog <- dbGetQuery(con_admin, "SELECT * FROM tsdb_test.catalog where ts_key = ANY('{vts1, vts2}')")
      expect_equal(nrow(catalog), 0)

      collects <- dbGetQuery(con_admin, "SELECT * FROM tsdb_test.collect_catalog WHERE ts_key = ANY('{vts1, vts2}')")
      expect_equal(nrow(collects), 0)
    }
  )
})


# deleting the edge -------------------------------------------------------


context("deleting ts - edge")

test_with_fresh_db(con_admin, "writer may not delete edge", {
  expect_error(
    db_ts_delete_latest_version(con_writer, c("vts1", "vts2"), schema = "tsdb_test"),
    "sufficient privileges"
  )
})

test_with_fresh_db(con_admin, "db_ts_delete_latest_version returns a status", {
  out <- db_ts_delete_latest_version(con_admin, "vts1", schema = "tsdb_test")

  expect_equal(out, list(status = "ok"))
})

test_with_fresh_db(con_admin, "db_delete_latest_vinage", {
  db_ts_delete_latest_version(con_admin, c("vts1", "vts2"), schema = "tsdb_test")

  main <- dbGetQuery(con_admin, "SELECT * FROM tsdb_test.timeseries_main")

  ids_deleted <- c(
    "f6aa6c70-41ae-11ea-b77f-2e728ce88125",
    "f6aa6ee6-41ae-11ea-b77f-2e728ce88125"
  )

  expect_false(any(ids_deleted %in% main$id))

  ids_kept <- c(
    "f6aa69c8-41ae-11ea-b77f-2e728ce88125",
    "f6aa6dba-41ae-11ea-b77f-2e728ce88125"
  )

  expect_true(all(ids_kept %in% main$id))
})



# deleting old vintages ---------------------------------------------------

context("deleting ts - trimming old vintages")

test_with_fresh_db(con_admin, "writer may not delete old vintages", {
  expect_error(
    db_ts_trim_history(con_writer, "vts1", as.Date("2020-01-10"), "tsdb_test"),
    "sufficient privileges"
  )
})

test_with_fresh_db(con_admin, "db_ts_trim_history returns status", {
  out <- db_ts_trim_history(con_admin, "vts1", as.Date("2020-01-10"), "tsdb_test")

  expect_equal(out, list(status = "ok"))
})

test_with_fresh_db(con_admin, "db_ts_trim_history", {
  db_ts_trim_history(con_admin, c("vts1", "vts2"), as.Date("2020-01-10"), "tsdb_test")

  main <- dbGetQuery(con_admin, "SELECT * FROM tsdb_test.timeseries_main")

  ids_deleted <- c(
    "f6aa69c8-41ae-11ea-b77f-2e728ce88125",
    "f6aa6dba-41ae-11ea-b77f-2e728ce88125"
  )

  expect_false(any(ids_deleted %in% main$id))

  ids_kept <- c(
    "f6aa6c70-41ae-11ea-b77f-2e728ce88125",
    "f6aa6ee6-41ae-11ea-b77f-2e728ce88125"
  )
  expect_true(all(ids_kept %in% main$id))
})

test_with_fresh_db(con_admin, "db_ts_trim_history on exact validity should keep that vintage", {
  db_ts_trim_history(con_admin, c("vts1", "vts2"), as.Date("2020-02-01"), "tsdb_test")

  main <- dbGetQuery(con_admin, "SELECT * FROM tsdb_test.timeseries_main")

  ids_deleted <- c(
    "f6aa69c8-41ae-11ea-b77f-2e728ce88125",
    "f6aa6dba-41ae-11ea-b77f-2e728ce88125"
  )

  expect_false(any(ids_deleted %in% main$id))

  ids_kept <- c(
    "f6aa6c70-41ae-11ea-b77f-2e728ce88125",
    "f6aa6ee6-41ae-11ea-b77f-2e728ce88125"
  )
  expect_true(all(ids_kept %in% main$id))
})


test_with_fresh_db(con_admin, "db_ts_trim_history with character date", {
  out <- db_ts_trim_history(con_admin, "vts1", "2020-01-12", "tsdb_test")

  expect_equal(out, list(status = "ok"))
})

test_with_fresh_db(con_admin, "db_ts_trim_history with garbage date", {
  expect_error(
    db_ts_trim_history(con_admin, "vts1", "bananas", "tsdb_test"),
    "of the form"
  )
})
