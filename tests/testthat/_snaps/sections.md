# messages are assembled correctly

    Code
      .assemble_section_titles_messages("My Talk", description = NULL, minutes = NULL)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Create a comma-separated list of titles for the major sections of a 20-minute conference talk."
      
      
      [[2]]
      [[2]]$role
      [1] "assistant"
      
      [[2]]$content
      [1] "Introduction, Methods, Results, Discussion, Conclusion"
      
      
      [[3]]
      [[3]]$role
      [1] "user"
      
      [[3]]$content
      [1] "Perfect! Now create a comma-separated list of titles for the major sections of a conference talk titled 'My Talk'."
      
      

---

    Code
      .assemble_section_titles_messages("My Talk", description = "My description",
        minutes = NULL)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Create a comma-separated list of titles for the major sections of a 20-minute conference talk."
      
      
      [[2]]
      [[2]]$role
      [1] "assistant"
      
      [[2]]$content
      [1] "Introduction, Methods, Results, Discussion, Conclusion"
      
      
      [[3]]
      [[3]]$role
      [1] "user"
      
      [[3]]$content
      [1] "Perfect! Now create a comma-separated list of titles for the major sections of a conference talk titled 'My Talk'. My description"
      
      

---

    Code
      .assemble_section_titles_messages("My Talk", description = NULL, minutes = 20)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Create a comma-separated list of titles for the major sections of a 20-minute conference talk."
      
      
      [[2]]
      [[2]]$role
      [1] "assistant"
      
      [[2]]$content
      [1] "Introduction, Methods, Results, Discussion, Conclusion"
      
      
      [[3]]
      [[3]]$role
      [1] "user"
      
      [[3]]$content
      [1] "Perfect! Now create a comma-separated list of titles for the major sections of a conference talk titled 'My Talk'. The talk is 20 minutes long. It should have between 4 and 10 sections."
      
      

---

    Code
      .assemble_section_titles_messages("My Talk", description = "My description",
        minutes = 20)
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      [1] "Create a comma-separated list of titles for the major sections of a 20-minute conference talk."
      
      
      [[2]]
      [[2]]$role
      [1] "assistant"
      
      [[2]]$content
      [1] "Introduction, Methods, Results, Discussion, Conclusion"
      
      
      [[3]]
      [[3]]$role
      [1] "user"
      
      [[3]]$content
      [1] "Perfect! Now create a comma-separated list of titles for the major sections of a conference talk titled 'My Talk'. The talk is 20 minutes long. It should have between 4 and 10 sections. My description"
      
      

# .to_section_titles errors for weird cases

    Code
      .to_section_titles(1)
    Condition
      Error:
      ! `section_titles` must be a character vector or a list.

---

    Code
      .to_section_titles(list(list("nonames")))
    Condition
      Error in `purrr::map()`:
      i In index: 1.
      Caused by error:
      ! `section_title` list elements must have `title` elements.

---

    Code
      .to_section_titles(list(1))
    Condition
      Error in `purrr::map()`:
      i In index: 1.
      Caused by error:
      ! `section_title` elements must be character vectors or lists.

# Can update section_titles minutes

    Code
      update_section_title_minutes(section_titles, c(1, 2, 3))
    Output
      [[1]]
      [[1]]$title
      [1] "A"
      
      [[1]]$minutes
      [1] 1
      
      
      [[2]]
      [[2]]$title
      [1] "B"
      
      [[2]]$minutes
      [1] 2
      
      
      [[3]]
      [[3]]$title
      [1] "C"
      
      [[3]]$minutes
      [1] 3
      
      
      attr(,"class")
      [1] "robodeck_section_titles" "list"                   

---

    Code
      update_section_title_minutes(section_titles, 1)
    Condition
      Error in `update_section_title_minutes()`:
      ! The length of `section_minutes` must match the length of `section_titles`.

