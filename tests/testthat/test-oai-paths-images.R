with_mock_dir("api/paths/images", {
  test_that("oai_create_image works with simple input", {
    image_pngs <- oai_create_image("Testing")
    image_path <- withr::local_tempfile(fileext = ".png")
    magick::image_write(image_pngs[[1]], image_path, format = "png")
    expect_snapshot_file(image_path, name = "oai_create_image_testing.png")
  })
})

test_that("oai_create_image fails gracefully with bad prompt", {
  expect_error(
    {
      bad_prompt <- stringr::str_dup("x", 1001)
      oai_create_image(bad_prompt)
    },
    class = "robodeck_error_image_prompt_length"
  )
})

test_that("oai_create_image validates inputs", {
  expect_error(
    {oai_create_image("Testing", model = "dall-e-3", quality = "high")},
    '"standard" or "hd"'
  )
  expect_error(
    {oai_create_image("Testing", model = "dall-e-3")},
    '"1024x1024", "1792x1024"'
  )
  expect_error(
    {
      oai_create_image(
        "Testing", model = "dall-e-3", size = "1024x1024",
        style = "cool"
      )
    },
    '"vivid" or "natural"'
  )
  expect_no_error({
    .validate_image_style("dall-e-3", "vivid")
  })
})

test_that(".extract_oai_image_content fails gracefully with bad data", {
  expect_error(
    {.extract_oai_image_content(list())},
    class = "robodeck_error_no_images"
  )
})
