.glue_special <- function(..., call = rlang::caller_env()) {
  glue::glue(..., .open = "{[{", .close = "}]}", .envir = call)
}
