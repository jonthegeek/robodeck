% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/images.R
\name{gen_image}
\alias{gen_image}
\title{Generate an image for a talk}
\usage{
gen_image(
  prompt,
  ...,
  api_key = oai_get_default_key(),
  title = NULL,
  description = NULL,
  image_size = c("small", "medium", "large"),
  image_path = NULL,
  call = rlang::caller_env()
)
}
\arguments{
\item{prompt}{A description of the image. Must contain 1000 or fewer
characters.}

\item{...}{Additional parameters passed on to the image generation API. We
currently use the \code{"dall-e-2"} model.}

\item{api_key}{An OpenAI API key.}

\item{title}{The title of the talk.}

\item{description}{(optional) A description of the talk (or any other text you
would like to add to the prompt).}

\item{image_size}{Whether the image should be \code{"small"} (256×256 pixels),
\code{"medium"} (512×512 pixels) or \code{"large"} (1024×1024 pixels).}

\item{image_path}{An optional path where the image should be saved as a png.}

\item{call}{The execution environment of a currently
running function, e.g. \code{caller_env()}. The function will be
mentioned in error messages as the source of the error. See the
\code{call} argument of \code{\link[rlang:abort]{abort()}} for more information.}
}
\value{
A \code{\link[magick:editing]{magick::image_read()}} \code{magick-image} object.
}
\description{
Generate an image from a prompt and (optionally) information about the talk
in which the image will be used.
}
