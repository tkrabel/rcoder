##
##                        LSTM ON R CODE
##

rm(list = ls())

# Libs
library(stringr)
library(keras)
library(purrr)
library(readr)
library(magrittr)
library(glue)

# CONST
BATCH_SIZE <- 256
EPOCHS_PER_DATA_CHUNK <- 3
FITTING_RUNS <- 3
SEP_HEADING <- "##############################################"
SEP_HALF    <- substr(SEP_HEADING, 1, floor(nchar(SEP_HEADING)/2))

# Constants that where determined by create_training_data.R
timesteps    <- readRDS("data/timesteps.rds")
max_text_len <- readRDS("data/max_text_len.rds")
vocab_size   <- readRDS("data/vocab_size.rds")
vocab        <- readRDS("data/vocab.rds")

# Funs
print_header <- function(run) {
  cat(SEP_HEADING, "\n")
  cat("RUN", run, "\n")
  cat(SEP_HEADING, "\n\n")
}

## Initiate model ----
model <- keras_model_sequential() %>%
  layer_lstm(input_shape = list(timesteps, vocab_size),
             units = 128,
             activation = "tanh",
             dropout = 0.5,
             return_sequences = TRUE) %>%
  layer_lstm(units = 128, dropout = 0.5) %>%
  layer_dense(units = vocab_size,
              activation = "softmax")

## Compile ----
model %>% compile(
  optimizer = optimizer_adadelta(),
  loss = "categorical_crossentropy",
  metrics = "accuracy"
)

# Callback
sample_char <- function(preds, variance = 1) {

  preds     <- log(preds) / variance # Adjust link values (narrow / widen prior)
  exp_preds <- exp(preds)
  probs     <- exp_preds / sum(exp_preds)
  
  rmultinom(1, 1, probs) %>% as.integer() %>% which.max()
}
print_sample <- function(epoch, logs) {
  
  cat(glue("epoch: {epoch} =====================\n"))
  
  for (variance in c(0.5, 1, 2)) {
    
    cat(glue("Variance: {variance} ---------------\n"))
    
    start_idx <- sample(seq_len(text_size - timesteps), size = 1)
    stop_idx  <- start_idx + timesteps - 1
    sentence  <- text[start_idx:stop_idx]
    output    <- ""
    
    for (i in 1:400) {
      
      x <- sapply(vocab, function(x){
        as.integer(x == sentence)
      })
      x <- array_reshape(x, c(1, dim(x)))
      
      preds     <- predict(model, x)
      next_char <- vocab[sample_char(preds, variance)]
      
      output    <- str_c(output, next_char, collapse = "")
      sentence  <- c(sentence[-1], next_char)
      
    }
    
    cat(output)
    cat("\n\n")
  }
}
print_callback <- callback_lambda(on_epoch_end = print_sample)

## Fit ----
# Get the number of steps from the number of data chunks on drive
n_steps <- list.files("data/training_data/") %>% 
  grep(x = ., pat = "x") %>%
  length()

# Iterate over all chunks
for (run in seq_len(FITTING_RUNS)) {
  print_header(run)
  
  for (i in seq_len(n_steps)) {
    cat("Use Chunk", i, "=============================\n\n")
    text <- readRDS(glue("data/data_for_callback/text{i}.rds"))
    text_size <- text %>% length()
    x <- readRDS(glue("data/training_data/x{i}.rds"))
    y <- readRDS(glue("data/training_data/y{i}.rds"))
    
    cat("... Fit model \n")
    model %>% fit(
      x, y,
      batch_size = BATCH_SIZE,
      epochs = EPOCHS_PER_DATA_CHUNK,
      callbacks = print_callback
    )  
    
    # Create Checkpoint
    cat("... Save model \n")
    now <- format(Sys.time(), format = "%Y-%m-%d_%H%M%S")
    save_model_hdf5(model, glue("data/model/model_{now}.h5"))
  }
}



