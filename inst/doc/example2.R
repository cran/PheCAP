## -----------------------------------------------------------------------------
library(PheCAP)

## -----------------------------------------------------------------------------
data(ehr_data)
data <- PhecapData(ehr_data, "healthcare_utilization", "label", 0.4, patient_id = "patient_id")
data

## -----------------------------------------------------------------------------
surrogates <- list(
  PhecapSurrogate(
    variable_names = "main_ICD",
    lower_cutoff = 1, upper_cutoff = 10),
  PhecapSurrogate(
    variable_names = "main_NLP",
    lower_cutoff = 1, upper_cutoff = 10),
  PhecapSurrogate(
    variable_names = c("main_ICD", "main_NLP"),
    lower_cutoff = 1, upper_cutoff = 10))

## -----------------------------------------------------------------------------
system.time(feature_selected <- phecap_run_feature_extraction(data, surrogates))

## -----------------------------------------------------------------------------
feature_selected

## -----------------------------------------------------------------------------
suppressWarnings(model <- phecap_train_phenotyping_model(data, surrogates, feature_selected))
model

## -----------------------------------------------------------------------------
validation <- phecap_validate_phenotyping_model(data, model)
validation
round(validation$valid_roc[validation$valid_roc[, "FPR"] <= 0.2, ], 3)

## -----------------------------------------------------------------------------
phecap_plot_roc_curves(validation)

## -----------------------------------------------------------------------------
phenotype <- phecap_predict_phenotype(data, model)
idx <- which.min(abs(validation$valid_roc[, "FPR"] - 0.05))
cut.fpr95 <- validation$valid_roc[idx, "cutoff"]
case_status <- ifelse(phenotype$prediction >= cut.fpr95, 1, 0)
predict.table <- cbind(phenotype, case_status)
predict.table[1:10, ]

