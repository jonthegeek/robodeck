test_that("gen_deck_section_titles errors for chat minus choices", {
  local_mocked_bindings(
    oai_create_chat_completion = function(messages, ...) {
      return(list("Bad result"))
    }
  )
  expect_error(
    {gen_deck_section_titles("My Talk")},
    class = "robodeck_error_no_choices"
  )
})


test_that("messages are assembled correctly", {
  local_mocked_bindings(
    oai_create_chat_completion = function(messages, ...) {
      return(messages)
    },
    .parse_section_titles_result = function(result) {
      return(result)
    }
  )
  expect_snapshot(
    gen_deck_section_titles("My Talk")
  )
  expect_snapshot(
    gen_deck_section_titles("My Talk", description = "My description")
  )
  expect_snapshot(
    gen_deck_section_titles("My Talk", minutes = 20)
  )
  expect_snapshot(
    gen_deck_section_titles("My Talk", description = "My description", minutes = 20)
  )
})

test_that("gen_deck_section_titles returns a character vector of titles", {
  local_mocked_bindings(
    oai_create_chat_completion = function(messages, ...) {
      return(list(
        choices = list(list(message = list(content = "A, B, C, D, E")))
      ))
    }
  )
  expect_identical(
    gen_deck_section_titles("My Talk"),
    c("A", "B", "C", "D", "E")
  )
})

test_that("gen_deck_section_titles warns about n argument", {
  local_mocked_bindings(
    oai_create_chat_completion = function(messages, ...) {
      return(list(
        choices = list(list(message = list(content = "A, B, C, D, E")))
      ))
    }
  )
  expect_warning(
    {gen_deck_section_titles("My Talk", n = 2)},
    class = "robodeck_warning_n_not_supported"
  )
})
