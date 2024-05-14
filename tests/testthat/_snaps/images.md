# gen_image errors for bad size

    Code
      gen_image("prompt", image_size = "bad")
    Condition
      Error:
      ! `image_size` must be one of "small", "medium", or "large", not "bad".

