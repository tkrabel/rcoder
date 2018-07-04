##
##                        CREATE TRAINING DATA
##

rm(list = ls())

# Libs
library(stringr)
library(purrr)
library(readr)
library(glue)
library(magrittr)

# CONST
TIMESTEPS <- 30
MAX_TEXT_LEN <- 200000
FILE <- "data/r_scripts_text.txt"

# Save info for training
saveRDS(MAX_TEXT_LEN, "data/max_text_len.rds")
saveRDS(TIMESTEPS, "data/timesteps.rds")

# Load data
text_raw <- read_file(FILE, 
                      locale = locale(encoding = "ascii"))
text_total <- text_raw %>%
  strsplit(., "") %>%
  unlist() 

vocab <- text_total %>%
  unique() %>%
  sort()

vocab_size <- vocab %>% length()
total_text_size <- text_total %>% length()

# Store vocab size
saveRDS(vocab_size, "data/vocab_size.rds")
saveRDS(vocab, "data/vocab.rds")

n_steps <- total_text_size %/% MAX_TEXT_LEN

# Save training data in chunks on drive
for (j in seq_len(n_steps)) {
  cat("Prepare chunk", j, "-----------\n")
  start_idx <- MAX_TEXT_LEN * (j - 1) + 1
  stop_idx <- if (j == n_steps) total_text_size else start_idx + MAX_TEXT_LEN - 1
  
  text <- text_total[start_idx:stop_idx]
  text_size  <- text %>% length()
  
  sentence <- vapply(
    seq_len(text_size - TIMESTEPS + 1),
    function(.i) {
      text[.i:(.i + TIMESTEPS - 1)]
    },
    vector("character", TIMESTEPS)
  ) %>% t()
  
  next_char <- vapply(
    seq_len(text_size - TIMESTEPS + 1),
    function(.i) {
      text[.i + TIMESTEPS]
    },
    vector("character", 1)
  ) %>% as.vector()
  
  # Vectorization
  cat("... create arrays\n")
  x <- array(0, dim = c(length(next_char) - 1, TIMESTEPS, vocab_size))
  y <- array(0, dim = c(length(next_char) - 1, vocab_size))
  
  for (i in seq_len(length(next_char) - 1)) {
    
    x[i,,] <- sapply(vocab, function(x){
      as.integer(x == sentence[[i]])
    })
    
    y[i,] <- as.integer(vocab == next_char[i])
    
  }
  cat("... write to drive\n")
  saveRDS(text, glue("data/data_for_callback/text{j}.rds"))
  saveRDS(x, glue("data/training_data/x{j}.rds"))
  saveRDS(y, glue("data/training_data/y{j}.rds"))
}
