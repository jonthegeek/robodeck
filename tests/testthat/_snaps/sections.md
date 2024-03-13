# messages are assembled correctly

    Code
      gen_deck_section_titles("My Talk")
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
      Perfect! Now create a comma-separated list of titles for the major sections of a conference talk titled 'My Talk'.
      
      

---

    Code
      gen_deck_section_titles("My Talk", description = "My description")
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
      Perfect! Now create a comma-separated list of titles for the major sections of a conference talk titled 'My Talk'. My description
      
      

---

    Code
      gen_deck_section_titles("My Talk", minutes = 20)
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
      Perfect! Now create a comma-separated list of titles for the major sections of a conference talk titled 'My Talk'. The talk is 20 minutes long.
      
      

---

    Code
      gen_deck_section_titles("My Talk", description = "My description", minutes = 20)
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
      Perfect! Now create a comma-separated list of titles for the major sections of a conference talk titled 'My Talk'. My description The talk is 20 minutes long.
      
      

