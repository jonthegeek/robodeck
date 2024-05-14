with_mock_dir("api/paths/chat", {
  test_that("oai_create_chat_completion works with character input", {
    expect_snapshot({
      oai_create_chat_completion(
        "Testing",
        max_tokens = 1
      )
    })
  })

  test_that("oai_create_chat_completion works with fully formed input", {
    expect_snapshot({
      oai_create_chat_completion(
        list(list(role = "user", content = "Testing")),
        max_tokens = 1
      )
    })
  })
})

test_that("Chat completion parsing fails gracefully with multiple resutls", {
  expect_error(
    {
      .extract_oai_chat_completion_content(
        list(
          choices = list(
            list(message = list(content = "a")),
            list(message = list(content = "b"))
          )
        )
      )
    },
    class = "robodeck_error-multiple_completions"
  )
})

test_that("Chat completion parsing fails gracefully with multiple resutls", {
  expect_error(
    {
      .extract_oai_chat_completion_content(list(x = 1))
    },
    regexp = " named ",
    class = "robodeck_error-no_choices"
  )
})

test_that("Chat completion parsing fails gracefully with multiple resutls", {
  expect_error(
    {
      .extract_oai_chat_completion_content(list(1))
    },
    regexp = "unnamed",
    class = "robodeck_error-no_choices"
  )
})

test_that("Chat completion parsing fails gracefully with multiple resutls", {
  expect_error(
    {
      .extract_oai_chat_completion_content(list())
    },
    regexp = "empty",
    class = "robodeck_error-no_choices"
  )
})
