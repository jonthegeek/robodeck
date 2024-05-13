#' Generate titles for talk sections
#'
#' Generate a list of titles for the major sections of a conference talk.
#'
#' @inheritParams .shared-parameters
#' @inheritParams oai_call_api
#' @param ... Additional parameters passed on to the OpenAI Chat Completion API.
#'
#' @return A list of lists, each of which contains a title for a major sections
#'   of the talk, and an empty `minutes` object.
#' @export
gen_deck_section_titles <- function(title,
                                    ...,
                                    api_key = oai_get_default_key(),
                                    description = NULL,
                                    minutes = NULL) {
  result <- .gen_section_titles_raw(
    title,
    ...,
    api_key = api_key,
    description = description,
    minutes = minutes
  )

  return(.parse_section_titles_result(result))
}

.gen_section_titles_raw <- function(title,
                                    ...,
                                    api_key = oai_get_default_key(),
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
      api_key = api_key,
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
  title_msg <- .glue_special(
    "Perfect! Now create a comma-separated list of titles for the major ",
    "sections of a conference talk titled '{[{title}]}'."
  )
  title_msg <- glue::glue_collapse(
    c(title_msg, .assemble_section_time_msg(minutes)),
    sep = " "
  )
  return(unclass(.assemble_talk_basics_msg(title_msg, description)))
}

.assemble_talk_basics_msg <- function(title_msg, description) {
  return(glue::glue_collapse(c(title_msg, description), sep = " "))
}

.assemble_section_time_msg <- function(minutes) {
  if (is.null(minutes) || minutes <= 0) {
    return(character(0))
  }
  n_sections_low <- ceiling(minutes/5)
  n_sections_high <- ceiling(minutes/2)
  return(
    .glue_special(
      "The talk is {[{minutes}]} minutes long. ",
      "It should have between {[{n_sections_low}]} and {[{n_sections_high}]} sections."
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

#' Update minutes component of section_titles
#'
#' Update the minutes component of a list of section titles, to assign
#' approximate times to those sections.
#'
#' @inheritParams .shared-parameters
#' @param section_minutes A numeric vector of minutes for each section. This
#'   vector must be the same length as `section_titles`.
#'
#' @return An updated list of section titles and their length in minutes.
#' @export
update_section_title_minutes <- function(section_titles, section_minutes) {
  section_titles <- .to_section_titles(section_titles)
  if (length(section_titles) != length(section_minutes)) {
    cli::cli_abort(
      "The length of {.arg section_minutes} must match the length of {.arg section_titles}.",
      class = "robodeck_error_invalid_section_title_minutes"
    )
  }
  for (i in seq_along(section_titles)) {
    section_titles[[i]]$minutes <- section_minutes[[i]]
  }
  return(section_titles)
}

#' Extract section titles
#'
#' Convert a `robodeck_section_titles` object to a character vector of section
#' titles (removing the "minutes" component).
#'
#' @param section_titles A `robodeck_section_titles` object.
#'
#' @return A character vector of section titles.
#' @export
#'
#' @examples
#' # gen_deck_section_titles() returns an object that contains both the section
#' # titles and their anticipated length.
#'
#' section_titles_object <- list(
#'   list(title = "Slide 1", minutes = NULL),
#'   list(title = "Slide 2", minutes = NULL),
#'   list(title = "Slide 3", minutes = NULL)
#' )
#' extract_section_titles(section_titles_object)
extract_section_titles <- function(section_titles) {
  section_titles <- .to_section_titles(section_titles)
  return(purrr::map_chr(section_titles, "title"))
}
