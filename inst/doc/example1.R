## -----------------------------------------------------------------------------
library(PheCAP)

## -----------------------------------------------------------------------------
set.seed(123)

## -----------------------------------------------------------------------------
latent <- rgamma(8000, 0.3)
latent2 <- rgamma(8000, 0.3)
ehr_data <- data.frame(
  patient_id = 1:8000,
  ICD1 = rpois(8000, 7 * (rgamma(8000, 0.2) + latent) / 0.5),
  ICD2 = rpois(8000, 6 * (rgamma(8000, 0.8) + latent) / 1.1),
  ICD3 = rpois(8000, 1 * rgamma(8000, 0.5 + latent2) / 0.5),
  ICD4 = rpois(8000, 2 * rgamma(8000, 0.5) / 0.5),
  NLP1 = rpois(8000, 8 * (rgamma(8000, 0.2) + latent) / 0.6),
  NLP2 = rpois(8000, 2 * (rgamma(8000, 1.1) + latent) / 1.5),
  NLP3 = rpois(8000, 5 * (rgamma(8000, 0.1) + latent) / 0.5),
  NLP4 = rpois(8000, 11 * rgamma(8000, 1.9 + latent) / 1.9),
  NLP5 = rpois(8000, 3 * rgamma(8000, 0.5 + latent2) / 0.5),
  NLP6 = rpois(8000, 2 * rgamma(8000, 0.5) / 0.5),
  NLP7 = rpois(8000, 1 * rgamma(8000, 0.5) / 0.5),
  HU = rpois(8000, 30 * rgamma(8000, 0.1) / 0.1),
  label = NA)
ii <- sample.int(8000, 400)
ehr_data[ii, "label"] <- with(
  ehr_data[ii, ], rbinom(400, 1, plogis(
    -5 + 1.5 * log1p(ICD1) + log1p(NLP1) +
      0.8 * log1p(NLP3) - 0.5 * log1p(HU))))
head(ehr_data)
tail(ehr_data)

## -----------------------------------------------------------------------------
data <- PhecapData(ehr_data, "HU", "label", 0.4, patient_id = "patient_id")
data

## -----------------------------------------------------------------------------
surrogates <- list(
  PhecapSurrogate(
    variable_names = "ICD1",
    lower_cutoff = 1, upper_cutoff = 10),
  PhecapSurrogate(
    variable_names = "NLP1",
    lower_cutoff = 1, upper_cutoff = 10))

## -----------------------------------------------------------------------------
system.time(feature_selected <- phecap_run_feature_extraction(data, surrogates))
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

