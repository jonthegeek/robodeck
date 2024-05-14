#' Generate markdown for a revealjs presentation
#'
#' Generate markdown to produce slides for a conference talk. We strongly
#' recommend that you use these slides as a starting point, not as the final
#' slide deck.
#'
#' @inheritParams .shared-parameters
#' @inheritParams oai_call_api
#' @param ... Additional parameters passed on to the OpenAI Chat Completion API.
#' @param outline A list of character vectors as returned by
#'   [gen_deck_outline()]. The name of each vector is the title of a major
#'   section of the talk, and the vector contains the titles of the slides
#'   within that section.
#' @param additional_information (optional) A single string with additional
#'   information about the tone of the talk, specific requirements, etc.
#'
#' @return A single string with markdown to produce slides for a revealjs
#'   presentation.
#' @export
gen_deck <- function(title,
                     ...,
                     api_key = oai_get_default_key(),
                     description = NULL,
                     minutes = NULL,
                     section_titles = NULL,
                     outline = NULL,
                     additional_information = robodeck_slide_style()) {
  result <- .gen_deck_raw(
    title,
    ...,
    api_key = api_key,
    description = description,
    minutes = minutes,
    section_titles = section_titles,
    outline = outline,
    additional_information = additional_information
  )

  return(.to_deck(result))
}

#' Description of the overall feel of the slides
#'
#' This is a placeholder for an upcoming, more complex function.
#'
#' @return A string describing the style of the slides.
#' @export
#'
#' @examples
#' robodeck_slide_style()
robodeck_slide_style <- function() {
  paste(
    "The tone of the talk should be fun and upbeat.",
    "Use an emoji at the start of every bullet in bulleted lists."
  )
}

.gen_deck_raw <- function(title,
                          ...,
                          api_key = oai_get_default_key(),
                          description,
                          minutes,
                          section_titles,
                          outline,
                          additional_information) {
  section_titles <- .maybe_gen_section_titles(
    title = title,
    description = description,
    minutes = minutes,
    section_titles = section_titles,
    ...
  )
  outline <- .maybe_gen_outline(
    title = title,
    description = description,
    minutes = minutes,
    section_titles = section_titles,
    outline = outline,
    ...
  )
  total_slides <- length(outline) + sum(lengths(outline))
  dots <- .validate_create_chat_completion_dots(
    ...,
    default_max_tokens = 100 * total_slides
  )
  deck <- oai_create_chat_completion(
    messages = .assemble_deck_messages(
      title = title,
      description = description,
      minutes = minutes,
      section_titles = section_titles,
      outline = outline,
      additional_information
    ),
    api_key = api_key,
    !!!dots
  )
  return(.trim_deck(deck, outline))
}

.assemble_deck_messages <- function(title,
                                    description,
                                    minutes,
                                    section_titles,
                                    outline,
                                    additional_information) {
  return(
    .add_chat_completion_message(
      .assemble_deck_msg(
        title,
        description,
        minutes,
        section_titles,
        outline,
        additional_information
      )
    )
  )
}

.assemble_deck_msg <- function(title,
                               description,
                               minutes,
                               section_titles,
                               outline,
                               additional_information) {
  title_msg <- glue::glue_collapse(
    c(
      .glue_special(
        "Generate Quarto markdown to produce revealjs slides for a conference talk titled '{[{title}]}'."
      ),
      .glue_special("The talk should take {[{minutes}]} minutes to deliver.")
    ),
    sep = " "
  )
  talk_basics_msg <- .assemble_talk_basics_msg(
    title_msg,
    description
  )
  section_titles_prompt <- .assemble_section_titles_prompt(section_titles)
  placeholder_prompt <- paste(
    "Include an image tag or a code block on every slide, separate from any bulleted list.",
    "Image placeholders should describe the image, such as",
    "`![A photograph of an elephant](elephant.png)`\n",
    "Code blocks should describe the intended code with a comment, such as\n",
    "```{r}\n# description of this code\n```"
  )
  bullets_prompt <- paste(
    "Include a bulleted list on every slide.",
    "Every bulleted list should contain at least 2 bullets."
  )
  outline_prompt <- .assemble_outline_prompt(outline)
  return(
    paste(
      talk_basics_msg,
      section_titles_prompt,
      placeholder_prompt,
      additional_information,
      bullets_prompt,
      outline_prompt,
      sep = "\n\n"
    )
  )
}

.assemble_outline_prompt <- function(outline) {
  outline_descriptions <- glue::glue_collapse(
    purrr::imap_chr(
      outline,
      .assemble_outline_section_prompt
    ),
    sep = "\n\n"
  )
  return(
    .glue_special(
      "In this outline, # indicates a section, and ## indicates a slide within a section.",
      "Use these slide titles:",
      "{[{outline_descriptions}]}",
      .sep = "\n\n"
    )
  )
}

.assemble_outline_section_prompt <- function(slide_titles, section_title) {
  slide_headers <- glue::glue_collapse(
    paste("##", slide_titles),
    sep = "\n\n"
  )

  return(
    .glue_special(
      "# {[{section_title}]}",
      slide_headers,
      .sep = "\n\n"
    )
  )
}

.trim_deck <- function(deck, outline) {
  if (isTRUE(nzchar(deck)) && !is.na(deck)) {
    trimmed <- .remove_deck_beginning_noise(deck, outline)
    if (nzchar(trimmed)) {
      trimmed <- .remove_deck_end_noise(trimmed)
    }
    if (nzchar(trimmed)) {
      return(.remove_deck_middle_noise(trimmed))
    }
  }
  return(deck)
}

.remove_deck_beginning_noise <- function(deck, outline) {
  title_1 <- stringr::str_escape(names(outline)[[1]])
  pattern <- .glue_special("^((.|\\n)*)(# {[{title_1}]}(.|\\n)*$)")
  return(stringr::str_extract(deck, pattern, group = 3))
}

.remove_deck_end_noise <- function(deck) {
  return(stringr::str_remove(deck, "(\\s*```\\s*)+$"))
}

.remove_deck_middle_noise <- function(deck) {
  return(stringr::str_replace_all(deck, "---\\s+#", "#"))
}

.to_deck <- function(content, ..., call = rlang::caller_env()) {
  UseMethod(".to_deck")
}

#' @export
.to_deck.default <- function(content,
                             ...,
                             call = rlang::caller_env()) {
  cli::cli_abort(
    "{.arg content} must be a character vector or NULL.",
    class = "robodeck_error-invalid_deck",
    call = call
  )
}

#' @export
.to_deck.NULL <- function(content, ...) {
  return(NULL)
}

#' @export
.to_deck.character <- function(content, ...) {
  return(structure(content, class = c("robodeck_deck", "character")))
}

#' @export
.to_deck.robodeck_deck <- function(content, ...) {
  return(content)
}

.maybe_gen_outline <- function(outline,
                               title,
                               description,
                               minutes,
                               section_titles,
                               ...) {
  if (is.null(outline)) {
    return(
      gen_deck_outline(
        title,
        ...,
        description = description,
        minutes = minutes,
        section_titles = section_titles
      )
    )
  }
  return(.to_outline(outline))
}
