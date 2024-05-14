#' Generate an image for a talk
#'
#' Generate an image from a prompt and (optionally) information about the talk
#' in which the image will be used.
#'
#' @inheritParams .shared-parameters
#' @inheritParams oai_call_api
#' @inheritParams rlang::args_error_context
#' @param prompt A description of the image. Must contain 1000 or fewer
#'   characters.
#' @param ... Additional parameters passed on to the image generation API. We
#'   currently use the `"dall-e-2"` model.
#' @param image_size Whether the image should be `"small"` (256×256 pixels),
#'   `"medium"` (512×512 pixels) or `"large"` (1024×1024 pixels).
#' @param image_path An optional path where the image should be saved as a png.
#'
#' @return A [magick::image_read()] `magick-image` object.
#' @export
gen_image <- function(prompt,
                      ...,
                      api_key = oai_get_default_key(),
                      title = NULL,
                      description = NULL,
                      image_size = c("small", "medium", "large"),
                      image_path = NULL,
                      call = rlang::caller_env()) {
  image <- .gen_image_raw(
    prompt,
    ...,
    api_key = api_key,
    title = title,
    description = description,
    image_size = image_size,
    call = call
  )
  return(.save_image(image, image_path))
}

.gen_image_raw <- function(prompt,
                           ...,
                           api_key = oai_get_default_key(),
                           title = NULL,
                           description = NULL,
                           image_size = c("small", "medium", "large"),
                           call = caller_env()) {
  prompt <- .assemble_image_prompt(prompt, title, description, call = call)
  image_size <- .translate_image_size(image_size, call)
  oai_create_image(
    prompt = prompt,
    api_key = api_key,
    size = image_size,
    call = call,
    ...
  )
}

.assemble_image_prompt <- function(prompt,
                                   title = NULL,
                                   description = NULL,
                                   call = caller_env()) {
  prompt <- .add_period(prompt)
  title <- .add_period(title)
  description <- .add_period(description)

  title <- .glue_special("For a talk titled {[{title}]}")
  description <- .glue_special("Talk description: {[{description}]}")

  .combine_prompt_pieces(c(prompt, title, description), max_char = 1000, call)
}

.add_period <- function(x) {
  x <- stringr::str_squish(x)
  if (!length(x) || (length(x) == 1 && x == "")) {
    return(NULL)
  }
  to_update <- nchar(x) > 0 & !stringr::str_ends(x, "\\p{Punct}")
  x[to_update] <- paste0(x[to_update], ".")
  return(x)
}

.combine_prompt_pieces <- function(prompt_pieces,
                                   max_char = 1000,
                                   call = caller_env()) {
  prompt_pieces <- prompt_pieces[nchar(prompt_pieces) > 0]
  prompt <- .validate_prompt_length(prompt_pieces[[1]], max_char, call)
  for (i in seq_along(prompt_pieces[-1]) + 1) {
    next_piece <- prompt_pieces[[i]]
    if (nchar(prompt) + nchar(next_piece) + 1 > max_char) {
      .warn_unused_prompt_piece(i, max_char)
      break
    }
    prompt <- paste(prompt, next_piece)
  }
  prompt
}

.warn_unused_prompt_piece <- function(i, max_char) {
  used <- seq_len(i - 1)
  n <- length(used)
  cli::cli_warn(
    c(
      "Prompt must contain {max_char} or fewer characters.",
      "!" = "Piece {i} would make the prompt too long.",
      "i" = "Only {qty(n)} piece{?s} {used} {qty(n)} {?was/were} included."
    ),
    class = "robodeck_warning-unused_prompt_pieces"
  )
}

.translate_image_size <- function(image_size = c("small", "medium", "large"),
                                  call = caller_env()) {
  image_size <- rlang::arg_match(image_size, error_call = call)
  switch(
    image_size,
    small = "256x256",
    medium = "512x512",
    large = "1024x1024"
  )
}

.save_image <- function(image, image_path = NULL) {
  if (length(image_path)) {
    image_path <- stbl::stabilize_chr(unclass(image_path))
    if (length(image_path) == length(image)) {
      purrr::walk2(image, image_path, .write_png)
    }

  }
  return(image)
}

.write_png <- function(image, image_path) {
  magick::image_write(image, image_path, format = "png") # nocov
}
