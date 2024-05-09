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
                             error_call = rlang::caller_env()) {
  model <- rlang::arg_match(model)
  prompt <- .validate_image_prompt(model, prompt, error_call)
  quality <- rlang::arg_match(quality, error_call = error_call)
  quality <- .validate_image_quality(model, quality, error_call)
  size <- rlang::arg_match(size, error_call = error_call)
  size <- .validate_image_size(model, size, error_call)
  style <- rlang::arg_match(style, error_call = error_call)
  style <- .validate_image_style(model, style, error_call)
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

.validate_image_prompt <- function(model,
                                   prompt,
                                   error_call = rlang::caller_env()) {
  max_char <- switch(model, "dall-e-2" = 1000L, "dall-e-3" = 4000L)
  prompt <- stbl::to_chr_scalar(
    prompt,
    allow_null = FALSE,
    allow_zero_length = FALSE,
    call = error_call
  )
  prompt <- stringr::str_squish(prompt)
  if (nchar(prompt) > max_char) {
    cli::cli_abort(
      c(
        "{.arg prompt} must have {max_char} or fewer characters.",
        x = "{.arg prompt} has {nchar(prompt)} characters."
      ),
      class = "robodeck_error_image_prompt_length")
  }
  return(prompt)
}

.validate_image_quality <- function(model,
                                    quality,
                                    error_call = rlang::caller_env()) {
  switch(model,
    "dall-e-2" = NULL,
    "dall-e-3" = rlang::arg_match0(
      quality,
      values = c("standard", "hd"),
      error_call = error_call
    )
  )
}

.validate_image_style <- function(model,
                                  style,
                                  error_call = rlang::caller_env()) {
  switch(model,
    "dall-e-2" = NULL,
    "dall-e-3" = style
  )
}

.validate_image_size <- function(model,
                                 size,
                                 error_call = rlang::caller_env()) {
  size <- stringr::str_replace(size, "x", "x")
  switch(model,
    "dall-e-2" = rlang::arg_match0(
      size,
      values = c("256x256", "512x512", "1024x1024"),
      error_call = error_call
    ),
    "dall-e-3" = rlang::arg_match0(
      size,
      values = c("1024x1024", "1792x1024", "1024x1792"),
      error_call = error_call
    )
  )
}

.extract_oai_image_content <- function(result,
                                       call = rlang::caller_env()) {
  if (length(result$data)) {
    images <- purrr::map(result$data, \(this_data) {
      magick::image_read(jsonlite::base64_dec(this_data$b64_json))
    })
    return(images)
  }
  cli::cli_abort("No images returned.", class = "robodeck_error_no_images")
}
