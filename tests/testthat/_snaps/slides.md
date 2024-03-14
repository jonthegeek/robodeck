# gen_deck messages are assembled correctly

    Code
      .assemble_deck_messages("My Talk", description = NULL, minutes = NULL,
        section_titles = section_titles, outline = outline, additional_information = "Default info")
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Generate Quarto markdown to produce revealjs slides for a conference talk titled 'My Talk'.\n\nMajor sections: 'A'.\n\nInclude a placeholder on every slide, for either an image such as `![A photograph of an elephant](elephant.png)` or a code block such as \n```{r}\n# description of this code\n```\n\nDefault info\n\nIn this outline, # indicates a section, and ## indicates a slide within a section.\n\nUse these slide titles:\n\n# A\n\n## Slide 1\n\n## Slide 2"
      
      

---

    Code
      .assemble_deck_messages("My Talk", description = "My description", minutes = NULL,
        section_titles = section_titles, outline = outline, additional_information = "Default info")
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Generate Quarto markdown to produce revealjs slides for a conference talk titled 'My Talk'. My description\n\nMajor sections: 'A'.\n\nInclude a placeholder on every slide, for either an image such as `![A photograph of an elephant](elephant.png)` or a code block such as \n```{r}\n# description of this code\n```\n\nDefault info\n\nIn this outline, # indicates a section, and ## indicates a slide within a section.\n\nUse these slide titles:\n\n# A\n\n## Slide 1\n\n## Slide 2"
      
      

---

    Code
      .assemble_deck_messages("My Talk", description = NULL, minutes = 20,
        section_titles = section_titles, outline = outline, additional_information = "Default info")
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Generate Quarto markdown to produce revealjs slides for a conference talk titled 'My Talk'. The talk is 20 minutes long.\n\nMajor sections: 'A'.\n\nInclude a placeholder on every slide, for either an image such as `![A photograph of an elephant](elephant.png)` or a code block such as \n```{r}\n# description of this code\n```\n\nDefault info\n\nIn this outline, # indicates a section, and ## indicates a slide within a section.\n\nUse these slide titles:\n\n# A\n\n## Slide 1\n\n## Slide 2"
      
      

---

    Code
      .assemble_deck_messages("My Talk", description = "My description", minutes = 20,
        section_titles = section_titles, outline = outline, additional_information = "Default info")
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Generate Quarto markdown to produce revealjs slides for a conference talk titled 'My Talk'. My description The talk is 20 minutes long.\n\nMajor sections: 'A'.\n\nInclude a placeholder on every slide, for either an image such as `![A photograph of an elephant](elephant.png)` or a code block such as \n```{r}\n# description of this code\n```\n\nDefault info\n\nIn this outline, # indicates a section, and ## indicates a slide within a section.\n\nUse these slide titles:\n\n# A\n\n## Slide 1\n\n## Slide 2"
      
      

# .to_deck fails informatively

    Code
      .to_deck(1)
    Condition
      Error:
      ! `content` must be a character vector or NULL.

