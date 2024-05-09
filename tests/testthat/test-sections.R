test_that("messages are assembled correctly", {
  # m1 <- "Create a comma-separated list of titles for the major sections of a 20-minute conference talk."
  # m2 <- "Introduction, Methods, Results, Discussion, Conclusion"
  # m3 <- "Perfect! Now create a comma-separated list of titles for the major sections of a conference talk titled 'My Talk'."

  expect_snapshot(
    .assemble_section_titles_messages(
      "My Talk",
      description = NULL,
      minutes = NULL
    )
  )
  expect_snapshot(
    .assemble_section_titles_messages(
      "My Talk",
      description = "My description",
      minutes = NULL
    )
  )
  expect_snapshot(
    .assemble_section_titles_messages(
      "My Talk",
      description = NULL,
      minutes = 20
    )
  )
  expect_snapshot(
    .assemble_section_titles_messages(
      "My Talk",
      description = "My description",
      minutes = 20
    )
  )
})

test_that("gen_deck_section_titles returns titles object", {
  local_mocked_bindings(
    oai_create_chat_completion = function(messages, ...) {
      return("A, B, C, D, E")
    }
  )
  test_result <- gen_deck_section_titles("My Talk")
  expected_result <- list(
    list(title = "A", minutes = NULL),
    list(title = "B", minutes = NULL),
    list(title = "C", minutes = NULL),
    list(title = "D", minutes = NULL),
    list(title = "E", minutes = NULL)
  )
  expect_identical(unclass(test_result), expected_result)
  expect_s3_class(test_result, c("robodeck_section_titles", "list"))
})

test_that("gen_deck_section_titles warns about n argument", {
  local_mocked_bindings(
    oai_create_chat_completion = function(messages, ...) {
      return("A, B, C, D, E")
    }
  )
  expect_warning(
    {
      gen_deck_section_titles("My Talk", n = 2)
    },
    class = "robodeck_warning_n_not_supported"
  )
})

test_that(".to_section_titles errors for weird cases", {
  expect_error(
    {
      .to_section_titles(1)
    },
    class = "robodeck_error_invalid_section_titles"
  )
  expect_snapshot(
    {
      .to_section_titles(1)
    },
    error = TRUE
  )

  expect_error(
    {
      .to_section_titles(list(list("nonames")))
    },
    class = "robodeck_error_invalid_section_title"
  )
  expect_snapshot(
    {
      .to_section_titles(list(list("nonames")))
    },
    error = TRUE
  )

  expect_error(
    {
      .to_section_titles(list(1))
    },
    class = "robodeck_error_invalid_section_title"
  )
  expect_snapshot(
    {
      .to_section_titles(list(1))
    },
    error = TRUE
  )
})

test_that(".to_section_titles cleans up acceptable cases", {
  given1 <- list(list(title = "A"))
  expected1 <- list(list(title = "A", minutes = NULL))
  test_result <- .to_section_titles(given1)
  expect_identical(
    unclass(test_result),
    expected1
  )
  expect_s3_class(test_result, c("robodeck_section_titles", "list"))
  given2 <- list(list(title = "A", minutes = 10))
  expected2 <- list(list(title = "A", minutes = 10))
  expect_identical(
    unclass(.to_section_titles(given2)),
    expected2
  )
  given3 <- c(given1, list(list(title = "B")))
  expected3 <- c(expected1, list(list(title = "B", minutes = NULL)))
  expect_identical(
    unclass(.to_section_titles(given3)),
    expected3
  )
  given4 <- c(given1, list(list(title = "B", minutes = 10)))
  expected4 <- c(expected1, list(list(title = "B", minutes = 10)))
  expect_identical(
    unclass(.to_section_titles(given4)),
    expected4
  )
  given5 <- structure(given1, class = c("robodeck_section_titles", "list"))
  expect_identical(.to_section_titles(given5), given5)
  expect_null(.to_section_titles(NULL))
})

test_that("Can update section_titles minutes", {
  section_titles <- .to_section_titles(c("A", "B", "C"))
  expect_snapshot(update_section_title_minutes(section_titles, c(1, 2, 3)))
  expect_snapshot(
    update_section_title_minutes(section_titles, 1),
    error = TRUE
  )
})

test_that("Can extract section titles", {
  section_titles <- .to_section_titles(c("A", "B", "C"))
  expect_identical(
    extract_section_titles(section_titles),
    c("A", "B", "C")
  )

  section_titles <- list(
    list(title = "C", minutes = NULL),
    list(title = "B", minutes = NULL),
    list(title = "A", minutes = NULL)
  )
  expect_identical(
    extract_section_titles(section_titles),
    c("C", "B", "A")
  )
})
