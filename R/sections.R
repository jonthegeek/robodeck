#' Generate titles for talk sections
#'
#' Generate a comma-separated list of titles for the major sections of a
#' conference talk.
#'
#' @param title The title of the talk.
#' @param ... Additional parameters passed on to the OpenAI Chat Completion API.
#' @param description (optional) A description of the talk (or any other text you
#'   would like to add to the prompt).
#' @param minutes (optional) The length of the talk in minutes.
#'
#' @return A character vector of titles for the major sections of the talk.
#' @export
gen_deck_section_titles <- function(title,
                                    ...,
                                    description = NULL,
                                    minutes = NULL) {
  result <- .gen_section_titles_raw(
    title,
    ...,
    description = description,
    minutes = minutes
  )

  return(.parse_section_titles_result(result))
}

.gen_section_titles_raw <- function(title,
                                    ...,
                                    description,
                                    minutes) {
  dots <- .validate_create_chat_completion_dots(...)
  return(
    oai_create_chat_completion(
      messages = .assemble_section_titles_messages(
        title = title,
        description = description,
        minutes = minutes
      ),
      !!!dots
    )
  )
}

.assemble_section_titles_messages <- function(title, description, minutes) {
  msg <- .add_chat_completion_message(
    "Create a comma-separated list of titles for the major sections of a 20-minute conference talk."
  )
  msg <- .add_chat_completion_message(
    "Introduction, Methods, Results, Discussion, Conclusion",
    role = "assistant",
    messages = msg
  )
  return(
    .add_chat_completion_message(
      .assemble_section_titles_msg(title, description, minutes),
      messages = msg
    )
  )
}

.assemble_section_titles_msg <- function(title, description, minutes) {
  title_msg <- glue::glue(
    "Perfect! Now create a comma-separated list of titles for the major ",
    "sections of a conference talk titled '{title}'."
  )
  return(
    .assemble_talk_basics_msg(title_msg, description, minutes)
  )
}

.assemble_talk_basics_msg <- function(title_msg, description, minutes) {
  time_msg <- glue::glue("The talk is {minutes} minutes long.")
  return(
    glue::glue_collapse(
      c(title_msg, description, time_msg),
      sep = " "
    )
  )
}

.parse_section_titles_result <- function(result) {
  return(
    .to_section_titles(
      stringr::str_split_1(result, ", ")
    )
  )
}

.to_section_titles <- function(section_titles,
                               call = rlang::caller_env()) {
  UseMethod(".to_section_titles")
}

#' @export
.to_section_titles.default <- function(section_titles,
                                       call = rlang::caller_env()) {
  cli::cli_abort(
    "{.arg section_titles} must be a character vector or a list.",
    class = "robodeck_error_invalid_section_titles",
    call = call
  )
}

#' @export
.to_section_titles.character <- function(section_titles,
                                         call = rlang::caller_env()) {
  return(
    .to_section_titles(as.list(section_titles))
  )
}

#' @export
.to_section_titles.list <- function(section_titles,
                                    call = rlang::caller_env()) {
  section_titles <- purrr::map(
    section_titles,
    \(section_title) {
      .validate_section_title_element(section_title, call = call)
    }
  )
  return(
    structure(section_titles, class = c("robodeck_section_titles", "list"))
  )
}

#' @export
.to_section_titles.robodeck_section_titles <- function(section_titles,
                                                       call = rlang::caller_env()) {
  return(section_titles)
}

#' @export
.to_section_titles.NULL <- function(section_titles,
                                    call = rlang::caller_env()) {
  return(NULL)
}

.validate_section_title_element <- function(section_title,
                                            call = rlang::caller_env()) {
  UseMethod(".validate_section_title_element")
}

#' @export
.validate_section_title_element.default <- function(section_title,
                                                    call = rlang::caller_env()) {
  cli::cli_abort(
    "{.arg section_title} elements must be character vectors or lists.",
    class = "robodeck_error_invalid_section_title",
    call = call
  )
}

#' @export
.validate_section_title_element.character <- function(section_title,
                                                      ...) {
  return(
    list(title = section_title, minutes = NULL)
  )
}

#' @export
.validate_section_title_element.list <- function(section_title,
                                                 call = rlang::caller_env()) {
  if (rlang::has_name(section_title, "title")) {
    if (rlang::has_name(section_title, "minutes")) {
      return(
        section_title
      )
    } else {
      return(list(title = section_title$title, minutes = NULL))
    }
  } else {
    cli::cli_abort(
      "{.arg section_title} list elements must have {.arg title} elements.",
      class = "robodeck_error_invalid_section_title",
      call = call
    )
  }
}

update_section_title_minutes <- function(section_titles, minutes) {
  section_titles <- .to_section_titles(section_titles)
  if (length(section_titles) != length(minutes)) {
    cli::cli_abort(
      "The length of {.arg minutes} must match the length of {.arg section_titles}.",
      class = "robodeck_error_invalid_section_title_minutes"
    )
  }
  for (i in seq_along(section_titles)) {
    section_titles[[i]]$minutes <- minutes[[i]]
  }
  return(section_titles)
}
