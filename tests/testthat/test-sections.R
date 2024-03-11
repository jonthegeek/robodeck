test_that("gen_section_titles errors for chat minus choices", {
  local_mocked_bindings(
    oai_create_chat_completion = function(messages, ...) {
      return(list("Bad result"))
    }
  )
  expect_error(
    {gen_section_titles("My Talk")},
    class = "robodeck_error_no_choices"
  )
})

test_that("gen_section_titles returns a character vector of titles", {
  local_mocked_bindings(
    oai_create_chat_completion = function(messages, ...) {
      return(list(
        choices = list(list(message = list(content = "A, B, C, D, E")))
      ))
    }
  )
  expect_identical(
    gen_section_titles("My Talk"),
    c("A", "B", "C", "D", "E")
  )
})

test_that("gen_section_titles warns about n argument", {
  local_mocked_bindings(
    oai_create_chat_completion = function(messages, ...) {
      return(list(
        choices = list(list(message = list(content = "A, B, C, D, E")))
      ))
    }
  )
  expect_warning(
    {gen_section_titles("My Talk", n = 2)},
    class = "robodeck_warning_n_not_supported"
  )
})
