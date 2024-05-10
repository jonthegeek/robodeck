# I'll eventually either use one of the other OpenAI packages or beekeep my own.

base_request <- httr2::req_user_agent(
  httr2::request("https://api.openai.com/v1"),
  "robodeck (https://jonthegeek.github.io/robodeck/)"
)

#' Load the default OpenAI API Key
#'
#' We encourage the use of the keyring package to securely store API keys. This
#' function attempts to load your OpenAI API key from keyring if it is
#' available, or from an environment variable otherwise.
#'
#' @param key_name The name of the keyring service or of the environment
#'   variable.
#'
#' @return A string with the value if available, or `""`.
#' @export
#' @examples
#' Sys.setenv(TEMP_OAI_API_KEY = "test_value")
#' test_result <- oai_get_default_key("TEMP_OAI_API_KEY")
#' test_result
#' Sys.unsetenv("TEMP_OAI_API_KEY")
oai_get_default_key <- function(key_name = "OPENAI_API_KEY") {
  key_value <- .keyring_try(key_name) %||% Sys.getenv(key_name)
  return(invisible(key_value))
}

.keyring_try <- function(key_name, keyring = NULL) {
  tryCatch(
    keyring::key_get(key_name, keyring = keyring),
    error = function(e) NULL
  )
}

#' Set an OpenAI API key
#'
#' Use the keyring package to store an API key.
#'
#' @param key_name The name of the key.
#' @param keyring The name of a specific keyring, passed on to
#'   `keyring::set_key` if available.
#'
#' @return The key, invisibly.
#' @export
oai_set_key <- function(key_name = "OPENAI_API_KEY", keyring = NULL) {
  rlang::check_installed("keyring", "to save the API key securely.") # nocov
  keyring::key_set(key_name, prompt = "OpenAI API Key", keyring = keyring) # nocov
  return(invisible(.keyring_try(key_name, keyring = keyring))) # nocov
}

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
                         api_key = oai_get_default_key()) {
  rlang::check_dots_empty()
  req <- nectar::req_modify(
    base_request,
    path = path,
    body = data,
    method = "POST"
  )
  req <- httr2::req_timeout(req, 30)
  req <- httr2::req_auth_bearer_token(req, token = api_key)
  resp <- httr2::req_perform(req)
  resp <- httr2::resp_body_json(resp)
  return(resp)
}
