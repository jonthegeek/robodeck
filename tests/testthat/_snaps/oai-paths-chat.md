# oai_create_chat_completion works with character input

    Code
      oai_create_chat_completion("Testing", max_tokens = 1)
    Output
      [1] "Hello"

# oai_create_chat_completion works with fully formed input

    Code
      oai_create_chat_completion(list(list(role = "user", content = "Testing")),
      max_tokens = 1)
    Output
      [1] "Hello"

