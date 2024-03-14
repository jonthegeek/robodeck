# messages are assembled correctly

    Code
      .assemble_outline_messages("My Talk", description = NULL, minutes = NULL,
        section_titles = sections_no_time)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Given a section titled 'A' with slides 'A1' and 'A2', and a section titled 'B' with slides 'B1' and 'B2', return a json object with slide titles nested inside section titles."
      
      
      [[2]]
      [[2]]$role
      [1] "assistant"
      
      [[2]]$content
      [1] "{\"A\":[\"A1\",\"A2\"],\"B\":[\"B1\",\"B2\"]}"
      
      
      [[3]]
      [[3]]$role
      [1] "user"
      
      [[3]]$content
      Great! Now generate slide titles for a conference talk titled 'My Talk'. Sections: 'A', 'B'. Generate at least one slide title for each section, about 1 title per minute. Return a json object with slide titles nested inside section titles.
      
      

---

    Code
      .assemble_outline_messages("My Talk", description = "My description", minutes = NULL,
        section_titles = sections_no_time)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Given a section titled 'A' with slides 'A1' and 'A2', and a section titled 'B' with slides 'B1' and 'B2', return a json object with slide titles nested inside section titles."
      
      
      [[2]]
      [[2]]$role
      [1] "assistant"
      
      [[2]]$content
      [1] "{\"A\":[\"A1\",\"A2\"],\"B\":[\"B1\",\"B2\"]}"
      
      
      [[3]]
      [[3]]$role
      [1] "user"
      
      [[3]]$content
      Great! Now generate slide titles for a conference talk titled 'My Talk'. My description Sections: 'A', 'B'. Generate at least one slide title for each section, about 1 title per minute. Return a json object with slide titles nested inside section titles.
      
      

---

    Code
      .assemble_outline_messages("My Talk", description = NULL, minutes = 20,
        section_titles = sections_no_time)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Given a section titled 'A' with slides 'A1' and 'A2', and a section titled 'B' with slides 'B1' and 'B2', return a json object with slide titles nested inside section titles."
      
      
      [[2]]
      [[2]]$role
      [1] "assistant"
      
      [[2]]$content
      [1] "{\"A\":[\"A1\",\"A2\"],\"B\":[\"B1\",\"B2\"]}"
      
      
      [[3]]
      [[3]]$role
      [1] "user"
      
      [[3]]$content
      Great! Now generate slide titles for a conference talk titled 'My Talk'. The talk is 20 minutes long. Sections: 'A', 'B'. Generate at least one slide title for each section, about 1 title per minute. Return a json object with slide titles nested inside section titles.
      
      

---

    Code
      .assemble_outline_messages("My Talk", description = "My description", minutes = 20,
        section_titles = sections_no_time)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Given a section titled 'A' with slides 'A1' and 'A2', and a section titled 'B' with slides 'B1' and 'B2', return a json object with slide titles nested inside section titles."
      
      
      [[2]]
      [[2]]$role
      [1] "assistant"
      
      [[2]]$content
      [1] "{\"A\":[\"A1\",\"A2\"],\"B\":[\"B1\",\"B2\"]}"
      
      
      [[3]]
      [[3]]$role
      [1] "user"
      
      [[3]]$content
      Great! Now generate slide titles for a conference talk titled 'My Talk'. The talk is 20 minutes long. My description Sections: 'A', 'B'. Generate at least one slide title for each section, about 1 title per minute. Return a json object with slide titles nested inside section titles.
      
      

---

    Code
      .assemble_outline_messages("My Talk", description = "My description", minutes = 20,
        section_titles = sections_with_time)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Given a section titled 'A' with slides 'A1' and 'A2', and a section titled 'B' with slides 'B1' and 'B2', return a json object with slide titles nested inside section titles."
      
      
      [[2]]
      [[2]]$role
      [1] "assistant"
      
      [[2]]$content
      [1] "{\"A\":[\"A1\",\"A2\"],\"B\":[\"B1\",\"B2\"]}"
      
      
      [[3]]
      [[3]]$role
      [1] "user"
      
      [[3]]$content
      Great! Now generate slide titles for a conference talk titled 'My Talk'. The talk is 20 minutes long. My description Sections: 'A' (8 minutes), 'B' (12 minutes). Generate at least one slide title for each section, about 1 title per minute. Return a json object with slide titles nested inside section titles.
      
      

# .to_outline fails informatively

    Code
      .to_outline(1)
    Condition
      Error:
      ! `content` must be a character vector, list, or NULL.

# .to_outline fails for weird lists

    Code
      .to_outline(list(1, 2))
    Condition
      Error:
      ! `content` must be a named list of character vectors.

