# messages are assembled correctly

    Code
      .assemble_outline_messages("My Talk", description = NULL, minutes = NULL,
        section_titles = sections_no_time)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      Generate slide titles for a conference talk titled 'My Talk'. Major sections: 'A', 'B'. Return a json object with slide titles nested inside section titles.
      
      

---

    Code
      .assemble_outline_messages("My Talk", description = "My description", minutes = NULL,
        section_titles = sections_no_time)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      Generate slide titles for a conference talk titled 'My Talk'. My description Major sections: 'A', 'B'. Return a json object with slide titles nested inside section titles.
      
      

---

    Code
      .assemble_outline_messages("My Talk", description = NULL, minutes = 20,
        section_titles = sections_no_time)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      Generate slide titles for a conference talk titled 'My Talk'. The talk is 20 minutes long. Major sections: 'A', 'B'. Return a json object with slide titles nested inside section titles.
      
      

---

    Code
      .assemble_outline_messages("My Talk", description = "My description", minutes = 20,
        section_titles = sections_no_time)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      Generate slide titles for a conference talk titled 'My Talk'. My description The talk is 20 minutes long. Major sections: 'A', 'B'. Return a json object with slide titles nested inside section titles.
      
      

---

    Code
      .assemble_outline_messages("My Talk", description = "My description", minutes = 20,
        section_titles = sections_with_time)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      Generate slide titles for a conference talk titled 'My Talk'. My description The talk is 20 minutes long. Major sections: 'A' (8 minutes), 'B' (12 minutes). Return a json object with slide titles nested inside section titles.
      
      

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

