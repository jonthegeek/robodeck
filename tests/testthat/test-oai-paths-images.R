with_mock_dir("api/paths/images", {
  test_that("oai_create_image works with simple input", {
    local_mocked_bindings(
      .raw_to_magick = function(raw_image) raw_image
    )
    images <- oai_create_image("Testing")
    # Comparing pngs had subtle differences between operating systems. Instead
    # let's re-encode the data and compare it raw.
    expect_snapshot({
      jsonlite::base64_enc(images[[1]])
    })
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
