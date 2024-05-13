# gen_deck messages are assembled correctly

    Code
      .assemble_deck_messages("My Talk", description = NULL, minutes = NULL,
        section_titles = section_titles, outline = outline, additional_information = "Default info")
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Generate Quarto markdown to produce revealjs slides for a conference talk titled 'My Talk'.\n\nSections: 'A'.\n\nInclude an image tag or a code block on every slide, separate from any bulleted list. Image placeholders should describe the image, such as `![A photograph of an elephant](elephant.png)`\n Code blocks should describe the intended code with a comment, such as\n ```{r}\n# description of this code\n```\n\nDefault info\n\nInclude a bulleted list on every slide. Every bulleted list should contain at least 2 bullets.\n\nIn this outline, # indicates a section, and ## indicates a slide within a section.\n\nUse these slide titles:\n\n# A\n\n## Slide 1\n\n## Slide 2"
      
      

---

    Code
      .assemble_deck_messages("My Talk", description = "My description", minutes = NULL,
        section_titles = section_titles, outline = outline, additional_information = "Default info")
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Generate Quarto markdown to produce revealjs slides for a conference talk titled 'My Talk'. My description\n\nSections: 'A'.\n\nInclude an image tag or a code block on every slide, separate from any bulleted list. Image placeholders should describe the image, such as `![A photograph of an elephant](elephant.png)`\n Code blocks should describe the intended code with a comment, such as\n ```{r}\n# description of this code\n```\n\nDefault info\n\nInclude a bulleted list on every slide. Every bulleted list should contain at least 2 bullets.\n\nIn this outline, # indicates a section, and ## indicates a slide within a section.\n\nUse these slide titles:\n\n# A\n\n## Slide 1\n\n## Slide 2"
      
      

---

    Code
      .assemble_deck_messages("My Talk", description = NULL, minutes = 20,
        section_titles = section_titles, outline = outline, additional_information = "Default info")
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Generate Quarto markdown to produce revealjs slides for a conference talk titled 'My Talk'. The talk should take 20 minutes to deliver.\n\nSections: 'A'.\n\nInclude an image tag or a code block on every slide, separate from any bulleted list. Image placeholders should describe the image, such as `![A photograph of an elephant](elephant.png)`\n Code blocks should describe the intended code with a comment, such as\n ```{r}\n# description of this code\n```\n\nDefault info\n\nInclude a bulleted list on every slide. Every bulleted list should contain at least 2 bullets.\n\nIn this outline, # indicates a section, and ## indicates a slide within a section.\n\nUse these slide titles:\n\n# A\n\n## Slide 1\n\n## Slide 2"
      
      

---

    Code
      .assemble_deck_messages("My Talk", description = "My description", minutes = 20,
        section_titles = section_titles, outline = outline, additional_information = "Default info")
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Generate Quarto markdown to produce revealjs slides for a conference talk titled 'My Talk'. The talk should take 20 minutes to deliver. My description\n\nSections: 'A'.\n\nInclude an image tag or a code block on every slide, separate from any bulleted list. Image placeholders should describe the image, such as `![A photograph of an elephant](elephant.png)`\n Code blocks should describe the intended code with a comment, such as\n ```{r}\n# description of this code\n```\n\nDefault info\n\nInclude a bulleted list on every slide. Every bulleted list should contain at least 2 bullets.\n\nIn this outline, # indicates a section, and ## indicates a slide within a section.\n\nUse these slide titles:\n\n# A\n\n## Slide 1\n\n## Slide 2"
      
      

# .to_deck fails informatively

    Code
      .to_deck(1)
    Condition
      Error:
      ! `content` must be a character vector or NULL.

# robodeck_slide_style() returns expected text

    Code
      robodeck_slide_style()
    Output
      [1] "The tone of the talk should be fun and upbeat. Use an emoji at the start of every bullet in bulleted lists."

