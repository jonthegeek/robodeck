gen_deck_outline <- function(title,
                             ...,
                             description = NULL,
                             minutes = NULL,
                             section_titles = NULL) {
  result <- .gen_outline_raw(
    title,
    ...,
    description = description,
    minutes = minutes,
    section_titles = section_titles
  )

  return(.to_outline(result))
}

.gen_outline_raw <- function(title,
                             ...,
                             description,
                             minutes,
                             section_titles) {
  dots <- .validate_create_chat_completion_dots(..., default_max_tokens = 300)
  if (is.null(section_titles)) {
    section_titles <- gen_deck_section_titles(
      title,
      ...,
      description = description,
      minutes = minutes
    )
  } else {
    section_titles <- .to_section_titles(section_titles)
  }
  return(
    oai_create_chat_completion(
      messages = .assemble_outline_messages(
        title = title,
        description = description,
        minutes = minutes,
        section_titles = section_titles
      ),
      !!!dots
    )
  )
}

.assemble_outline_messages <- function(title,
                                       description,
                                       minutes,
                                       section_titles) {
  return(
    .add_chat_completion_message(
      .assemble_outline_msg(
        title,
        description,
        minutes,
        section_titles
      )
    )
  )
}

.assemble_outline_msg <- function(title,
                                  description,
                                  minutes,
                                  section_titles) {
  talk_basics_msg <- .assemble_talk_basics_msg(
    glue::glue("Generate slide titles for a conference talk titled '{title}'."),
    description,
    minutes
  )
  section_titles_prompt <- .assemble_section_titles_prompt(section_titles)
  return(
    glue::glue(
      talk_basics_msg,
      section_titles_prompt,
      "Return a json object with slide titles nested inside section titles.",
      .sep = " "
    )
  )
}

.assemble_section_titles_prompt <- function(section_titles) {
  section_descriptions <- glue::glue_collapse(
    purrr::map_chr(
      section_titles,
      .assemble_section_title_prompt
    ),
    sep = ", "
  )
  return(glue::glue("Major sections: {section_descriptions}."))
}

.assemble_section_title_prompt <- function(section_title) {
  return(
    glue::glue_collapse(
      c(
        glue::glue("'{section_title$title}'"),
        glue::glue("({section_title$minutes} minutes)")
      ),
      sep = " "
    )
  )
}

.to_outline <- function(content, ..., call = rlang::caller_env()) {
  UseMethod(".to_outline")
}

#' @export
.to_outline.default <- function(content,
                                ...,
                                call = rlang::caller_env()) {
  cli::cli_abort(
    "{.arg content} must be a character vector or NULL.",
    class = "robodeck_error_invalid_outline",
    call = call
  )
}

#' @export
.to_outline.NULL <- function(content, ...) {
  return(NULL)
}

#' @export
.to_outline.character <- function(content, ...) {
  return(jsonlite::fromJSON(content))
}
