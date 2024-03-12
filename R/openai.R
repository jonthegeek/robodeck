# nocov start

# I'll eventually either use one of the other OpenAI packages or beekeep my own.

#' Call an openapi API
#'
#' Generate a request to an openapi endpoint.
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams nectar::call_api
#' @param api_key An OpenAI API key.
#'
#' @return The response from the endpoint.
#' @keywords internal
call_oai <- function(path,
                     ...,
                     body = NULL,
                     api_key = Sys.getenv("OPENAI_API_KEY")) {
  rlang::check_dots_empty()

  req <- nectar::req_prepare(
    base_url = "https://api.openai.com/v1",
    path = path,
    body = body,
    method = "POST",
    user_agent = "robodeck (https://jonthegeek.github.io/robodeck/)"
  )
  req <- httr2::req_timeout(req, 30)
  req <- httr2::req_auth_bearer_token(req, token = api_key)
  resp <- httr2::req_perform(req)
  resp <- httr2::resp_body_json(resp)
  return(resp)
}

oai_create_chat_completion <- function(messages,
                                       ...,
                                       model = c(
                                         "gpt-3.5-turbo",
                                         "gpt-4-turbo-preview"
                                       ),
                                       frequency_penalty = 0,
                                       logit_bias = NULL,
                                       logprobs = FALSE,
                                       top_logprobs = NULL, # TODO: Only valid if logprobs = TRUE
                                       max_tokens = NULL,
                                       n = 1,
                                       presence_penalty = 0, # -2.0 to 2.0
                                       response_format = NULL,
                                       seed = NULL,
                                       temperature = 1,
                                       top_p = 1, # TODO: Set this OR temperature
                                       tools = NULL,
                                       tool_choice = "none",
                                       user = NULL) {
  # TODO: Implement all the things.
  #
  # TODO: Optionally warn about pricing (with confirmation pause if
  # interactive()).

  if (rlang::is_scalar_character(messages)) {
    messages <- list(list(role = "user", content = messages))
  }
  model <- rlang::arg_match(model)

  call_oai(
    path = "chat/completions",
    body = list(
      messages = messages,
      model = model,
      n = n,
      max_tokens = max_tokens
    )
  )
}

# nocov end
