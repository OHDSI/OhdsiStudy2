Treatment Pathways Study Protocol 12 months
===============

This is a study of treatment pathways in hypertension, diabetes, and depression during the first 12 mo after diagnosis.  Detailed information and protocol is available on the [OHDSI Wiki](http://www.ohdsi.org/web/wiki/doku.php?id=research:treatment_pathways_in_chronic_disease_12_mos).

**R Version**

- Run R

```R
library(devtools)
install_github("OHDSI/OhdsiStudy2")
library(OhdsiStudy2)
?execute # To get extended help

execute(dbms = "postgresql",
        user = "joebruin",
        password = "supersecrete",
        server = "myserver",
        cdmSchema = "cdm_schema",
        resultsSchema = "results_schema")
```

- Email the resulting files to study coordinator.

If you would like to run the study directly from SQL without using R, contact the study administrator listed on the [Wiki page](http://www.ohdsi.org/web/wiki/doku.php?id=research:treatment_pathways_in_chronic_disease_12_mos). 
