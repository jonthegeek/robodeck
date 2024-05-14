oai_create_image <- function(prompt,
                             ...,
                             api_key = oai_get_default_key(),
                             model = c("dall-e-2", "dall-e-3"),
                             n = 1L,
                             quality = c("standard", "hd"),
                             size = c(
                               "256x256",
                               "512x512",
                               "1024x1024",
                               "1792x1024",
                               "1024x1792"
                             ),
                             style = c("vivid", "natural"),
                             user = NULL,
                             call = rlang::caller_env()) {
  model <- rlang::arg_match(model)
  prompt <- .validate_image_prompt(model, prompt, call)
  quality <- rlang::arg_match(quality, error_call = call)
  quality <- .validate_image_quality(model, quality, call)
  size <- rlang::arg_match(size, error_call = call)
  size <- .validate_image_size(model, size, call)
  style <- rlang::arg_match(style, error_call = call)
  style <- .validate_image_style(model, style, call)
  result <- oai_call_api(
    path = "images/generations",
    api_key = api_key,
    data = list(
      prompt = prompt,
      model = model,
      n = n,
      quality = quality,
      response_format = "b64_json",
      size = size,
      style = style,
      user = user
    )
  )
  return(.extract_oai_image_content(result))
}

.validate_image_prompt <- function(model, prompt, call = caller_env()) {
  max_char <- switch(model, "dall-e-2" = 1000L, "dall-e-3" = 4000L)
  prompt <- stbl::to_chr_scalar(
    prompt,
    allow_null = FALSE,
    allow_zero_length = FALSE,
    call = call
  )
  prompt <- stringr::str_squish(prompt)
  prompt <- .validate_prompt_length(prompt, max_char, call)
  return(prompt)
}

.validate_prompt_length <- function(prompt, max_char, call = caller_env()) {
  prompt_chars <- nchar(prompt)
  if (prompt_chars > max_char) {
    cli::cli_abort(
      c(
        "Prompt must contain {max_char} or fewer characters.",
        "x" = "{.arg prompt} has {prompt_chars} characters."
      ),
      class = "robodeck_error-prompt_length",
      call = call
    )
  }
  prompt
}

.validate_image_quality <- function(model, quality, call = caller_env()) {
  switch(model,
    "dall-e-2" = NULL,
    "dall-e-3" = rlang::arg_match0(
      quality,
      values = c("standard", "hd"),
      error_call = call
    )
  )
}

.validate_image_style <- function(model, style, call = caller_env()) {
  switch(model,
    "dall-e-2" = NULL,
    "dall-e-3" = style
  )
}

.validate_image_size <- function(model, size, call = caller_env()) {
  size <- stringr::str_replace(size, "x", "x")
  switch(model,
    "dall-e-2" = rlang::arg_match0(
      size,
      values = c("256x256", "512x512", "1024x1024"),
      error_call = call
    ),
    "dall-e-3" = rlang::arg_match0(
      size,
      values = c("1024x1024", "1792x1024", "1024x1792"),
      error_call = call
    )
  )
}

.extract_oai_image_content <- function(result, call = caller_env()) {
  if (length(result$data)) {
    images <- purrr::map(result$data, \(this_data) {
      .raw_to_magick(jsonlite::base64_dec(this_data$b64_json))
    })
    return(images)
  }
  cli::cli_abort("No images returned.", class = "robodeck_error-no_images")
}

.raw_to_magick <- function(raw_image) {
  magick::image_read(raw_image) # nocov
}
