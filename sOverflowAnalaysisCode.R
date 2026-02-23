# Required libraries
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, caret, C50, ggplot2, corrplot)

# Reproducibility settings
SEED_VAL <- 123
SPLIT_RATIO <- 0.7

# Columns removed to avoid leakage and noise
COLS_TO_DROP <- c(
  "title", "body", "tags", "categories",
  "comment_count", "favorite_count", "owner_badge_count",
  "first_response_time_seconds", "first_response_time_hours",
  "question_id", "last_activity_date", "creation_date",
  "quality_score",
  "is_answered",
  "accepted_answer_score"
)

# Load data and basic cleaning
load_and_clean_data <- function(file_path = NULL) {
  
  path <- if (is.null(file_path)) file.choose() else file_path
  df <- fread(path, encoding = "UTF-8", fill = TRUE)
  df <- as.data.frame(df)
  
  # Drop unused columns
  df <- df[, !names(df) %in% COLS_TO_DROP]
  
  # Convert character columns to factors
  char_cols <- names(df)[sapply(df, is.character)]
  for (col in char_cols) {
    df[[col]] <- as.factor(df[[col]])
  }
  
  return(df)
}

# Train / test split
split_data <- function(df, ratio = 0.7, seed = 123) {
  set.seed(seed)
  idx <- sample(seq_len(nrow(df)), size = ratio * nrow(df))
  list(train = df[idx, ], test = df[-idx, ])
}

# Feature scaling and target preparation
preprocess_features <- function(train_data, test_data) {
  
  # Standardize numeric features
  numeric_cols <- names(train_data)[sapply(train_data, is.numeric)]
  
  if (length(numeric_cols) > 0) {
    train_means <- sapply(train_data[, numeric_cols], mean, na.rm = TRUE)
    train_sds   <- sapply(train_data[, numeric_cols], sd, na.rm = TRUE)
    
    for (col in numeric_cols) {
      if (train_sds[col] != 0) {
        train_data[[col]] <- (train_data[[col]] - train_means[col]) / train_sds[col]
        test_data[[col]]  <- (test_data[[col]]  - train_means[col]) / train_sds[col]
      }
    }
  }
  
  # Positive class explicitly defined (TRUE = accepted answer exists)
  target_col <- "has_accepted_answer"
  train_data[[target_col]] <- factor(train_data[[target_col]], levels = c("TRUE", "FALSE"))
  test_data[[target_col]]  <- factor(test_data[[target_col]],  levels = c("TRUE", "FALSE"))
  
  # Convert logical features to factors
  log_cols <- names(train_data)[sapply(train_data, is.logical)]
  for (col in log_cols) {
    train_data[[col]] <- as.factor(train_data[[col]])
    test_data[[col]]  <- as.factor(test_data[[col]])
  }
  
  return(list(train = train_data, test = test_data))
}

# Train C5.0 model and evaluate
train_and_evaluate <- function(train_data, test_data) {
  
  # Increased trials and rule-based model to reduce overfitting
  model <- C5.0(
    has_accepted_answer ~ .,
    data = train_data,
    trials = 20,
    rules = TRUE
  )
  
  predictions <- predict(model, test_data)
  cm <- confusionMatrix(predictions, test_data$has_accepted_answer)
  
  return(list(model = model, confusion_matrix = cm))
}

# Load and clean dataset
raw_df <- load_and_clean_data()
cat("Raw rows:", nrow(raw_df), "\n")

# Logical filtering
raw_df <- raw_df[raw_df$body_word_count > 0, ]
raw_df <- raw_df[raw_df$owner_reputation > 0, ]
cat("After logical filter:", nrow(raw_df), "\n")

# Remove missing values
raw_df <- na.omit(raw_df)
cat("Final clean rows:", nrow(raw_df), "\n")

# Check class distribution
cat("\nClass distribution:\n")
print(prop.table(table(raw_df$has_accepted_answer)))

# Split and preprocess
splits <- split_data(raw_df, ratio = SPLIT_RATIO, seed = SEED_VAL)
processed_data <- preprocess_features(splits$train, splits$test)

# Train C5.0
results <- train_and_evaluate(processed_data$train, processed_data$test)

cat("\nC5.0 Confusion Matrix:\n")
print(results$confusion_matrix)

cat("\nBalanced Accuracy:",
    results$confusion_matrix$byClass["Balanced Accuracy"], "\n")

# Feature importance normalized
imp <- C5imp(results$model)
imp_norm <- round((imp / sum(imp)) * 100, 2)
cat("\nNormalized Feature Importance (%):\n")
print(imp_norm)

# Logistic regression as baseline model
model_glm <- glm(
  has_accepted_answer ~ .,
  data = processed_data$train,
  family = "binomial"
)

# Custom threshold instead of default 0.5
probs_glm <- predict(model_glm, processed_data$test, type = "response")
threshold <- 0.4

preds_glm <- ifelse(probs_glm > threshold, "TRUE", "FALSE")
preds_glm <- factor(preds_glm, levels = levels(processed_data$test$has_accepted_answer))

cm_glm <- confusionMatrix(preds_glm, processed_data$test$has_accepted_answer)
cat("\nLogistic Regression Confusion Matrix:\n")
print(cm_glm)

# Model comparison table
comparison_table <- data.frame(
  Metric = c("Accuracy", "Kappa", "Sensitivity", "Specificity", "Balanced Accuracy"),
  C5.0 = c(
    results$confusion_matrix$overall["Accuracy"],
    results$confusion_matrix$overall["Kappa"],
    results$confusion_matrix$byClass["Sensitivity"],
    results$confusion_matrix$byClass["Specificity"],
    results$confusion_matrix$byClass["Balanced Accuracy"]
  ),
  Logistic_Regression = c(
    cm_glm$overall["Accuracy"],
    cm_glm$overall["Kappa"],
    cm_glm$byClass["Sensitivity"],
    cm_glm$byClass["Specificity"],
    cm_glm$byClass["Balanced Accuracy"]
  )
)

comparison_table[, 2:3] <- round(comparison_table[, 2:3], 4)
cat("\nModel comparison:\n")
print(comparison_table)