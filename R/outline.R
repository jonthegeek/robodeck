#' Generate an outline of talk slides
#'
#' Generate a list of slide titles nested inside the major sections of a
#' conference talk.
#'
#' @inheritParams .shared-parameters
#' @inheritParams oai_call_api
#' @param ... Additional parameters passed on to the OpenAI Chat Completion API.
#'
#' @return A list of character vectors. The name of each vector is the title of
#'   a major section of the talk, and the vector contains the titles of the
#'   slides within that section.
#' @export
gen_deck_outline <- function(title,
                             ...,
                             api_key = oai_get_default_key(),
                             description = NULL,
                             minutes = NULL,
                             section_titles = NULL) {
  result <- .gen_outline_raw(
    title,
    ...,
    api_key = api_key,
    description = description,
    minutes = minutes,
    section_titles = section_titles
  )

  return(.to_outline(result))
}

.gen_outline_raw <- function(title,
                             ...,
                             api_key = oai_get_default_key(),
                             description,
                             minutes,
                             section_titles) {
  dots <- .validate_create_chat_completion_dots(..., default_max_tokens = 300)
  section_titles <- .maybe_gen_section_titles(
    title = title,
    description = description,
    minutes = minutes,
    section_titles = section_titles,
    ...
  )
  return(
    oai_create_chat_completion(
      messages = .assemble_outline_messages(
        title = title,
        description = description,
        minutes = minutes,
        section_titles = section_titles
      ),
      api_key = api_key,
      !!!dots
    )
  )
}

.assemble_outline_messages <- function(title,
                                       description,
                                       minutes,
                                       section_titles) {
  msg <- .add_chat_completion_message(
    paste(
      "Given a section titled 'A' with slides 'A1' and 'A2',",
      "and a section titled 'B' with slides 'B1' and 'B2',",
      "return a json object with slide titles nested inside section titles."
    )
  )
  msg <- .add_chat_completion_message(
    '{"A":["A1","A2"],"B":["B1","B2"]}',
    role = "assistant",
    messages = msg
  )
  return(
    .add_chat_completion_message(
      .assemble_outline_msg(
        title,
        description,
        minutes,
        section_titles
      ),
      messages = msg
    )
  )
}

.assemble_outline_msg <- function(title,
                                  description,
                                  minutes,
                                  section_titles) {
  title_msg <- .glue_special(
    "Great! Now generate slide titles for a conference talk titled '{[{title}]}'."
  )
  title_msg <- glue::glue_collapse(
    c(
      title_msg,
      .glue_special("The talk is {[{minutes}]} minutes long.")
    ),
    sep = " "
  )
  talk_basics_msg <- .assemble_talk_basics_msg(
    title_msg,
    description
  )
  section_titles_prompt <- .assemble_section_titles_prompt(section_titles)
  return(
    .glue_special(
      talk_basics_msg,
      section_titles_prompt,
      "Generate at least one slide title for each section, about 1 title per minute.",
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
  return(.glue_special("Sections: {[{section_descriptions}]}."))
}

.assemble_section_title_prompt <- function(section_title) {
  return(
    glue::glue_collapse(
      c(
        .glue_special("'{[{section_title$title}]}'"),
        .glue_special("({[{section_title$minutes}]} minutes)")
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
    "{.arg content} must be a character vector, list, or NULL.",
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
  content <- jsonlite::fromJSON(content)
  return(.to_outline(content))
}

#' @export
.to_outline.list <- function(content, ..., call = rlang::caller_env()) {
  if (rlang::is_named(content) && purrr::every(content, is.character)) {
    return(
      structure(
        content,
        class = c("robodeck_outline", "list")
      )
    )
  }
  cli::cli_abort(
    "{.arg content} must be a named list of character vectors.",
    class = "robodeck_error_invalid_outline",
    call = call
  )
}

#' @export
.to_outline.robodeck_outline <- function(content, ...) {
  return(content)
}

.maybe_gen_section_titles <- function(section_titles,
                                      title,
                                      description,
                                      minutes,
                                      ...) {
  if (is.null(section_titles)) {
    section_titles <- gen_deck_section_titles(
      title,
      ...,
      description = description,
      minutes = minutes
    )
    return(section_titles)
  }
  return(.to_section_titles(section_titles))
}
