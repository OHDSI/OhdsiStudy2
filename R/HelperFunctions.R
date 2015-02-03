renderStudySpecificSql <- function(studyName, minCellCount, cdmSchema, resultsSchema, sourceName, dbms){
  if (studyName == "HTN12mo"){
    TxList <- '21600381,21601461,21601560,21601664,21601744,21601782'
    DxList <- '316866'
    ExcludeDxList <- '444094'
  } else if (studyName == "T2DM12mo"){
    TxList <- '21600712,21500148'
    DxList <- '201820'
    ExcludeDxList <- '444094,35506621'
  } else if (studyName == "Depression12mo"){
    TxList <- '21604686, 21500526'
    DxList <- '440383'
    ExcludeDxList <- '444094,432876,435783'
  }
  
  inputFile <- system.file(paste("sql/","sql_server",sep=""), 
  												 "TxPath_parameterized.sql", 
  												 package="OhdsiStudy2")   
#   inputFile <- "TxPath_parameterized.sql"
  
  outputFile <- paste("TxPath_autoTranslate ", dbms," ", studyName, ".sql",sep="")
  
  parameterizedSql <- readSql(inputFile)
  renderedSql <- renderSql(parameterizedSql, cdmSchema=cdmSchema, resultsSchema=resultsSchema, studyName = studyName, sourceName=sourceName, txlist=TxList, dxlist=DxList, excludedxlist=ExcludeDxList, smallcellcount = minCellCount)$sql
  translatedSql <- translateSql(renderedSql, sourceDialect = "sql server", targetDialect = dbms)$sql
  writeSql(translatedSql,outputFile)
  writeLines(paste("Created file '",outputFile,"'",sep=""))
  return(outputFile)
  }
  
  extractAndWriteToFile <- function(connection, tableName, resultsSchema, sourceName, studyName, dbms){
    parameterizedSql <- "SELECT * FROM @resultsSchema.dbo.@studyName_@sourceName_@tableName"
    renderedSql <- renderSql(parameterizedSql, cdmSchema=cdmSchema, resultsSchema=resultsSchema, studyName=studyName, sourceName=sourceName, tableName=tableName)$sql
    translatedSql <- translateSql(renderedSql, sourceDialect = "sql server", targetDialect = dbms)$sql
    data <- querySql(connection, translatedSql)
    outputFile <- paste(studyName,"_",sourceName,"_",tableName,".csv",sep='') 
    write.csv(data,file=outputFile)
    writeLines(paste("Created file '",outputFile,"'",sep=""))
  }
  
  
  