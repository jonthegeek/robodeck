gen_image <- function(prompt,
                      ...,
                      api_key = oai_get_default_key(),
                      talk_title = NULL,
                      talk_description = NULL,
                      image_size = c("small", "medium", "large"),
                      image_path = NULL) {
  image <- .gen_image_raw(
    prompt,
    ...,
    api_key = api_key,
    talk_title = talk_title,
    talk_description = talk_description,
    image_size = image_size
  )
  return(.save_image(image, image_path))
}

.gen_image_raw <- function(prompt,
                           ...,
                           api_key = oai_get_default_key(),
                           talk_title = NULL,
                           talk_description = NULL,
                           image_size = c("small", "medium", "large"),
                           error_call = rlang::caller_env()) {
  prompt <- .assemble_image_prompt(prompt, talk_title, talk_description)
  image_size <- .translate_image_size(image_size)
  oai_create_image(
    prompt = prompt,
    api_key = api_key,
    size = image_size,
    error_call = error_call
  )
}

.assemble_image_prompt <- function(prompt,
                                   talk_title = NULL,
                                   talk_description = NULL) {
  prompt <- .add_period(prompt)
  talk_title <- .add_period(talk_title)
  talk_description <- .add_period(talk_description)

  talk_title <- .glue_special("For a talk titled {[{talk_title}]}.")
  talk_description <- .glue_special("Talk description: {[{talk_description}]}")

  prompt_pieces <- c(prompt, talk_title, talk_description)
  glue::glue_collapse(prompt_pieces, sep = " ")
}

.add_period <- function(x) {
  x <- stringr::str_squish(x)
  if (!length(x) || x == "") {
    return(NULL)
  }
  if (stringr::str_ends(x, "\\p{Punct}")) {
    return(x)
  }
  return(paste0(x, "."))
}

.translate_image_size <- function(image_size = c("small", "medium", "large")) {
  image_size <- rlang::arg_match(image_size)
  switch(
    image_size,
    small = "256x256",
    medium = "512x512",
    large = "1024x1024"
  )
}

.save_image <- function(image, image_path = NULL) {
  if (length(image_path)) {
    image_path <- stbl::stabilize_chr_scalar(unclass(image_path))
    magick::image_write(image, image_path)
  }
  return(image)
}
