## ---- eval=FALSE--------------------------------------------------------------
#  library(PheCAP)

## ---- eval=FALSE--------------------------------------------------------------
#  data(ehr_data)
#  data <- PhecapData(ehr_data, "healthcare_utilization", "label", 0.4)
#  data

## ---- eval=FALSE--------------------------------------------------------------
#  surrogates <- list(
#    PhecapSurrogate(
#      variable_names = "main_ICD",
#      lower_cutoff = 1, upper_cutoff = 10),
#    PhecapSurrogate(
#      variable_names = "main_NLP",
#      lower_cutoff = 1, upper_cutoff = 10),
#    PhecapSurrogate(
#      variable_names = c("main_ICD", "main_NLP"),
#      lower_cutoff = 1, upper_cutoff = 10))

## ---- eval=FALSE--------------------------------------------------------------
#  feature_selected <- phecap_run_feature_extraction(data, surrogates)
#  feature_selected

## ---- eval=FALSE--------------------------------------------------------------
#  model <- phecap_train_phenotyping_model(data, surrogates, feature_selected)
#  model

## ---- eval=FALSE--------------------------------------------------------------
#  validation <- phecap_validate_phenotyping_model(data, model)
#  validation
#  phecap_plot_roc_curves(validation)

## ---- eval=FALSE--------------------------------------------------------------
#  phenotype <- phecap_predict_phenotype(data, model)

