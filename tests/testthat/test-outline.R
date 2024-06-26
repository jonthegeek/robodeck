test_that("gen_deck_outline generates titles when none provided", {
  local_mocked_bindings(
    gen_deck_section_titles = function(...) {
      cli::cli_warn("Generating titles.", class = "gdst_call")
      return(list(list(title = "A", minutes = NULL)))
    },
    oai_create_chat_completion = function(...) {
      return(NULL)
    }
  )
  expect_warning(
    gen_deck_outline("My Talk"),
    class = "gdst_call"
  )
})

test_that("gen_deck_outline uses provided titles", {
  local_mocked_bindings(
    gen_deck_section_titles = function(...) {
      cli::cli_warn("Generating titles.", class = "gdst_call")
      return(list(list(title = "A", minutes = NULL)))
    },
    oai_create_chat_completion = function(...) {
      return(NULL)
    }
  )
  expect_no_warning(
    gen_deck_outline("My Talk", section_titles = c("A", "B", "C"))
  )
})

test_that("messages are assembled correctly", {
  sections_no_time <- .to_section_titles(c("A", "B"))
  sections_with_time <- update_section_title_minutes(sections_no_time, c(8, 12))
  expect_snapshot(
    .assemble_outline_messages(
      "My Talk",
      description = NULL,
      minutes = NULL,
      section_titles = sections_no_time
    )
  )
  expect_snapshot(
    .assemble_outline_messages(
      "My Talk",
      description = "My description",
      minutes = NULL,
      section_titles = sections_no_time
    )
  )
  expect_snapshot(
    .assemble_outline_messages(
      "My Talk",
      description = NULL,
      minutes = 20,
      section_titles = sections_no_time
    )
  )
  expect_snapshot(
    .assemble_outline_messages(
      "My Talk",
      description = "My description",
      minutes = 20,
      section_titles = sections_no_time
    )
  )
  expect_snapshot(
    .assemble_outline_messages(
      "My Talk",
      description = "My description",
      minutes = 20,
      section_titles = sections_with_time
    )
  )
})

test_that("gen_deck_outline returns a list of section titles with nested slide titles", {
  local_mocked_bindings(
    oai_create_chat_completion = function(...) {
      return('{"A":["A1","A2"],"B":["B1","B2"]}')
    }
  )
  test_result <- gen_deck_outline("My talk", section_titles = c("A", "B", "C"))
  expect_identical(
    unclass(test_result),
    list(A = c("A1", "A2"), B = c("B1", "B2"))
  )
  expect_s3_class(test_result, "robodeck_outline")
})

test_that(".to_outline fails informatively", {
  expect_error(
    .to_outline(1),
    class = "robodeck_error-invalid_outline"
  )
  expect_snapshot(
    .to_outline(1),
    error = TRUE
  )
})

test_that(".to_outline fails for weird lists", {
  expect_error(
    .to_outline(list(1, 2)),
    class = "robodeck_error-invalid_outline"
  )
  expect_snapshot(
    .to_outline(list(1, 2)),
    error = TRUE
  )
})

test_that(".to_outline triggers properly for outlines", {
  given <- list(A = c("A1", "A2"), B = c("B1", "B2"))
  test_result1 <- .to_outline(given)
  expected_result <- given
  class(expected_result) <- c("robodeck_outline", "list")
  expect_identical(test_result1, expected_result)
  expect_identical(test_result1, .to_outline(test_result1))
})
