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

  return(
    .parse_section_titles_result(result)
  )
}

.gen_section_titles_raw <- function(title,
                                    ...,
                                    description,
                                    minutes) {
  dots <- .validate_section_titles_dots(...)
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

.validate_section_titles_dots <- function(...) {
  dots <- rlang::list2(...)
  if (length(dots$n)) {
    cli::cli_warn(
      "The {.arg n} argument is not supported and will be ignored.",
      class = "robodeck_warning_n_not_supported"
    )
  }
  dots$n <- 1
  dots$max_tokens <- dots$max_tokens %||% 100
  return(dots)
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
  time_msg <- glue::glue("The talk is {minutes} minutes long.")
  return(
    glue::glue_collapse(
      c(title_msg, description, time_msg),
      sep = " "
    )
  )
}

.parse_section_titles_result <- function(result) {
  if (length(result$choices)) {
    return(
      stringr::str_split_1(
        purrr::map_chr(result$choices, c("message", "content")),
        ", "
      )
    )
  }
  cli::cli_abort(
    c(
      "OpenAI Chat Completion result must include a 'choices' object.",
      "i" = "Object has elements {names(result)}."
    ),
    class = "robodeck_error_no_choices"
  )
}
