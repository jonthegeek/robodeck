# Actual image generation is tested in test-oai-paths-images.R. Focus on the
# wrapper.

test_that(".add_period() adds periods", {
  expect_null(.add_period(NULL))
  expect_null(.add_period(character()))
  expect_identical(.add_period("This!"), "This!")
  expect_identical(.add_period("This"), "This.")
})

test_that(".assemble_image_prompt() stitches together a clean prompt.", {
  expect_identical(
    .assemble_image_prompt("a", title = "b", description = "c"),
    "a. For a talk titled b. Talk description: c."
  )
})

test_that(".assemble_image_prompt() warns for long piece", {
  expect_warning(
    {
      expect_identical(
        .assemble_image_prompt(
          "a",
          title = "b",
          description = stringr::str_dup("c", 1000)
        ),
        "a. For a talk titled b."
      )
    },
    class = "robodeck_warning-unused_prompt_pieces"
  )
})

test_that("gen_image errors for bad size", {
  expect_snapshot(
    {gen_image("prompt", image_size = "bad")},
    error = TRUE
  )
})

test_that(".translate_image_size works for valid sizes", {
  expect_identical(
    .translate_image_size("small"),
    "256x256"
  )
  expect_identical(
    .translate_image_size("medium"),
    "512x512"
  )
  expect_identical(
    .translate_image_size("large"),
    "1024x1024"
  )
})

test_that("gen_image generates an image with valid inputs", {
  local_mocked_bindings(
    oai_create_image = function(prompt, ...) {
      return(prompt)
    }
  )
  expect_identical(
    gen_image("prompt"),
    "prompt."
  )
  expect_identical(
    gen_image("prompt", title = "title"),
    "prompt. For a talk titled title."
  )
  expect_identical(
    gen_image("prompt", title = "title", description = "description"),
    "prompt. For a talk titled title. Talk description: description."
  )
  expect_identical(
    gen_image("prompt", description = "description"),
    "prompt. Talk description: description."
  )
})

test_that(".save_image errors with length mismatch", {
  expect_error(
    .save_image(letters, "a"),
    class = "robodeck_error-length_mismatch"
  )
})

test_that("gen_image saves when path provided", {
  local_mocked_bindings(
    oai_create_image = function(prompt, ...) {
      return(prompt)
    },
    .write_png = function(image, image_path) {
      cli::cli_warn("Saving {image} to {image_path}")
    }
  )
  expect_warning(
    expect_identical(
      gen_image("prompt", image_path = "path"),
      "prompt."
    ),
    "Saving prompt. to path"
  )
})
