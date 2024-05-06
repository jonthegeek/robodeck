# nocov start

# I'll eventually either use one of the other OpenAI packages or beekeep my own.

base_request <- httr2::req_user_agent(
  httr2::request("https://api.openai.com/v1"),
  "robodeck (https://jonthegeek.github.io/robodeck/)"
)

#' Call an openapi API
#'
#' Generate a request to an openapi endpoint.
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams httr2::req_body_json
#' @param path The route to an API endpoint.
#' @param api_key An OpenAI API key.
#'
#' @return The response from the endpoint.
#' @keywords internal
oai_call_api <- function(path,
                         ...,
                         data = NULL,
                         api_key = Sys.getenv("OPENAI_API_KEY")) {
  rlang::check_dots_empty()

  req <- httr2::req_url_path_append(base_request, path)
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_body_json(req, data)
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

  result <- oai_call_api(
    path = "chat/completions",
    data = list(
      messages = messages,
      model = model,
      n = n,
      max_tokens = max_tokens
    )
  )
  return(.extract_oai_chat_completion_content(result))
}

.add_chat_completion_message <- function(content,
                                         ...,
                                         role = c("user", "assistant"),
                                         messages = list()) {
  rlang::check_dots_empty()
  role <- rlang::arg_match(role)
  return(
    c(messages, list(list(role = role, content = content)))
  )
}

.validate_create_chat_completion_dots <- function(...,
                                                  default_max_tokens = 100) {
  dots <- rlang::list2(...)
  if (length(dots$n)) {
    cli::cli_warn(
      "The {.arg n} argument is not supported and will be ignored.",
      class = "robodeck_warning_n_not_supported"
    )
  }
  dots$n <- 1
  dots$max_tokens <- dots$max_tokens %||% default_max_tokens
  return(dots)
}

.extract_oai_chat_completion_content <- function(result,
                                                 call = rlang::caller_env()) {
  if (length(result$choices)) {
    content <- purrr::map_chr(result$choices, c("message", "content"))
    if (rlang::is_scalar_character(content)) {
      return(content)
    }
    cli::cli_abort(
      "The result must include a single completion.",
      class = "robodeck_error_multiple_completions"
    )
  }
  msg <- "Object is empty."
  if (length(result)) {
    if (rlang::is_named(result)) {
      msg <- "Object has {length(result)} element{?s} named {names(result)}."
    } else {
      msg <- "Object has {length(result)} unnamed element{?s}."
    }
  }
  cli::cli_abort(
    c(
      "OpenAI Chat Completion result must include a 'choices' object.",
      "i" = msg
    ),
    class = "robodeck_error_no_choices"
  )
}

# nocov end
