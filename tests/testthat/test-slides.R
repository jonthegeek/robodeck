test_that("gen_deck generates titles when needed", {
  local_mocked_bindings(
    gen_deck_section_titles = function(...) {
      cli::cli_abort("Generating titles.", class = "gdst_call")
    },
    oai_create_chat_completion = function(...) {
      return(NULL)
    }
  )
  expect_error(
    gen_deck("My Talk"),
    class = "gdst_call"
  )
  expect_no_error(
    gen_deck("My Talk", section_titles = c("A", "B", "C"))
  )
})

test_that("gen_deck generates outline when needed", {
  local_mocked_bindings(
    gen_deck_section_titles = function(...) {
      return(list(list(title = "A", minutes = NULL)))
    },
    gen_deck_outline = function(...) {
      cli::cli_abort("Generating outline.", class = "gdo_call")
    },
    oai_create_chat_completion = function(...) {
      return(NULL)
    }
  )
  expect_error(
    gen_deck("My Talk"),
    class = "gdo_call"
  )
  expect_no_error(
    gen_deck(
      "My Talk",
      section_titles = "A",
      outline = list(A = c("Slide 1", "Slide 2"))
    )
  )
})

test_that("gen_deck messages are assembled correctly", {
  section_titles <- .to_section_titles("A")
  outline <- list(A = c("Slide 1", "Slide 2"))
  expect_snapshot(
    .assemble_deck_messages(
      "My Talk",
      description = NULL,
      minutes = NULL,
      section_titles = section_titles,
      outline = outline,
      additional_information = "Default info"
    )
  )
  expect_snapshot(
    .assemble_deck_messages(
      "My Talk",
      description = "My description",
      minutes = NULL,
      section_titles = section_titles,
      outline = outline,
      additional_information = "Default info"
    )
  )
  expect_snapshot(
    .assemble_deck_messages(
      "My Talk",
      description = NULL,
      minutes = 20,
      section_titles = section_titles,
      outline = outline,
      additional_information = "Default info"
    )
  )
  expect_snapshot(
    .assemble_deck_messages(
      "My Talk",
      description = "My description",
      minutes = 20,
      section_titles = section_titles,
      outline = outline,
      additional_information = "Default info"
    )
  )
})

test_that("gen_deck returns a robodeck_deck with the markdown", {
  local_mocked_bindings(
    oai_create_chat_completion = function(...) {
      # The initial return has some noise, replicate that.
      return(
        paste(
          "```markdown\n# Noise yada yada",
          "# First title",
          "\n\n```\n",
          sep = "\n\n"
        )
      )
    }
  )
  section_titles <- c("First title", "Second", "Third") |>
    .to_section_titles() |>
    update_section_title_minutes(c(5, 5, 5))
  outline <- list(
    `First title` = c("A", "B"),
    `Second` = c("A", "B"),
    `Third` = c("A", "B")
  ) |>
    .to_outline()

  test_result <- gen_deck(
    title = "My talk",
    description = "My description",
    minutes = 15,
    section_titles = section_titles,
    outline = outline
  )
  expect_identical(unclass(test_result), "# First title")
  expect_s3_class(test_result, "robodeck_deck")
})

test_that(".to_deck fails informatively", {
  expect_error(
    .to_deck(1),
    class = "robodeck_error_invalid_deck"
  )
  expect_snapshot(
    .to_deck(1),
    error = TRUE
  )
})

test_that(".to_deck passes through a robodeck_deck", {
  deck <- structure("a", class = c("robodeck_deck", "character"))
  expect_identical(.to_deck(deck), deck)
})

test_that("robodeck_slide_style() returns expected text", {
  expect_snapshot(robodeck_slide_style())
})
