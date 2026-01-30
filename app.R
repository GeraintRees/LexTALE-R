library(shiny)
library(digest)  # used for participant ID

ui <- fluidPage(
  titlePanel("LexTALE"),
  uiOutput("survey_ui")
)

server <- function(input, output, session) {
  
  ## -------------------------------
  ## Load data
  ## -------------------------------
  words <- read.csv("words.csv", stringsAsFactors = FALSE) # To use test languages other than English (e.g., English, Dutch, German), change the words.csv file. 
  
  instructions_text <- paste(
    readLines("instructions_for_test_takers.txt", warn = FALSE), # this file contains the test instructions with some HTML markup, change to the language of your choice.
    collapse = "\n"
  )
  
  ## -------------------------------
  ## Reactive values
  ## -------------------------------
  values <- reactiveValues(
    page = 0,  # 0 = instructions
    participant_id = substr(digest(session$token), 1, 10), # generates a random 10 character string as a participant ID
    start_time = NULL,
    end_time = NULL,
    duration_seconds = NULL,
    
    responses = data.frame(
      participant_id = character(),
      word = character(),
      response = character(),
      correct = logical(),
      scored = logical(),
      timestamp = as.POSIXct(character())
    ),
    
    final_score = NULL
  )
  
  ## -------------------------------
  ## UI rendering
  ## -------------------------------
  output$survey_ui <- renderUI({
    
    ## Instructions page
    if (values$page == 0) {
      return(
        tagList(
          div(
            HTML(instructions_text),
            style = "max-width: 700px; margin: auto;"
          ),
          br(),
          div(
            actionButton(
              "start", "Start",
              class = "btn btn-primary btn-lg"
            ),
            style = "text-align: center;"
          )
        )
      )
    }
    
    ## Thank-you page
    if (values$page > nrow(words)) {
      return(
        tagList(
          h2("Thank you!", style = "color: green; text-align: center;"),
          br(),
          h3(
            paste0(
              "Your LexTALE score: ",
              values$final_score$lextale_score, "%"
            ),
            style = "text-align: center; color: blue;"
          ),
          p(
            paste0(
              "Words correct: ",
              values$final_score$words_correct, " / 40"
            ),
            style = "text-align: center;"
          ),
          p(
            paste0(
              "Nonwords correct: ",
              values$final_score$nonwords_correct, " / 20"
            ),
            style = "text-align: center;"
          ),
          br(),
          p(
            paste0(
              "Time to complete test: ",
              round(values$duration_seconds, 1), " seconds"
            ),
            style = "text-align: center; color: gray;"
          ),
          p(
            paste0("Participant ID: ", values$participant_id),
            style = "text-align: center; font-size: 12px; color: gray;"
          )
        )
      )
    }
    
    ## -------------------------------
    ## Survey page
    ## -------------------------------
    progress <- values$page / nrow(words) * 100
    
    tagList(
      h2(
        words$WORD[values$page],
        style = "text-align: center; margin-top: 40px; margin-bottom: 40px;"
      ),
      
      div(
        actionButton(
          "yes", "Yes",
          class = "btn btn-success btn-lg",
          style = "margin-right: 40px;"
        ),
        actionButton(
          "no", "No",
          class = "btn btn-danger btn-lg"
        ),
        style = "text-align: center;"
      ),
      
      div(
        div(
          class = "progress",
          div(
            class = "progress-bar",
            role = "progressbar",
            style = paste0("width: ", round(progress), "%;"),
            paste0(round(progress), "%")
          )
        ),
        style = "max-width: 500px; margin: 50px auto 0 auto;"
      )
    )
  })
  
  ## -------------------------------
  ## Start test
  ## -------------------------------
  observeEvent(input$start, {
    values$start_time <- Sys.time()
    values$page <- 1
  })
  
  ## -------------------------------
  ## Save response + advance
  ## -------------------------------
  save_answer <- function(resp) {
    
    i <- values$page
    status <- words$STATUS[i]
    index  <- words$INDEX[i]
    
    scored <- index != 0
    correct <- if (scored) {
      (resp == "Yes" && status == 1) ||
        (resp == "No"  && status == 0)
    } else {
      NA
    }
    
    values$responses <- rbind(
      values$responses,
      data.frame(
        participant_id = values$participant_id,
        word = words$WORD[i],
        response = resp,
        correct = correct,
        scored = scored,
        timestamp = Sys.time()
      )
    )
    
    values$page <- values$page + 1
    
    ## Finalize when last word answered
    if (values$page > nrow(words)) {
      
      values$end_time <- Sys.time()
      values$duration_seconds <- as.numeric(
        difftime(
          values$end_time,
          values$start_time,
          units = "secs"
        )
      )
      
      scored_items <- subset(values$responses, scored)
      
      word_items <- subset(
        scored_items,
        words$STATUS[match(scored_items$word, words$WORD)] == 1
      )
      nonword_items <- subset(
        scored_items,
        words$STATUS[match(scored_items$word, words$WORD)] == 0
      )
      
      n_words_correct <- sum(word_items$correct)
      n_nonwords_correct <- sum(nonword_items$correct)
      
      lextale_score <- (
        (n_words_correct / 40 * 100) +
          (n_nonwords_correct / 20 * 100)
      ) / 2
      
      values$final_score <- list(
        lextale_score    = round(lextale_score, 1),
        words_correct    = n_words_correct,
        nonwords_correct = n_nonwords_correct
      )
      
      ## Save a record of responses for each word (not strictly necessary, but nice to have)
      write.table(
        values$responses,
        "responses.csv", 
        sep = ",",
        row.names = FALSE,
        col.names = !file.exists("responses.csv"),
        append = file.exists("responses.csv")
      )
      
      ## Save participant-level summary (Score, number of words correctly identified, number of non-words correctly identified, time taken)
      summary_row <- data.frame(
        participant_id = values$participant_id,
        lextale_score = values$final_score$lextale_score,
        words_correct = n_words_correct,
        nonwords_correct = n_nonwords_correct,
        duration_seconds = round(values$duration_seconds, 2),
        timestamp = Sys.time()
      )
      
      write.table(
        summary_row,
        "participant_summary.csv",
        sep = ",",
        row.names = FALSE,
        col.names = !file.exists("participant_summary.csv"),
        append = file.exists("participant_summary.csv")
      )
    }
  }
  
  observeEvent(input$yes, { save_answer("Yes") })
  observeEvent(input$no,  { save_answer("No")  })
}

shinyApp(ui, server)
