
#' @title Execute OHDSI Study 2
#'
#' @details
#' This function executes OHDSI Study 2 -- Treatment Pathways Study 
#' Protocol 12 months.  This is a study of treatment pathways in hypertension,
#' diabetes and depression during the first 12 months after diagnosis.
#' Detailed information and protocol are available on the OHDSI Wiki.
#' 
#' @return
#' Study results are placed in CSV format files in specified local folder.

#' @param dbms              The type of DBMS running on the server. Valid values are
#' \itemize{
#'   \item{"mysql" for MySQL}
#'   \item{"oracle" for Oracle}
#'   \item{"postgresql" for PostgreSQL}
#'   \item{"redshift" for Amazon Redshift}   
#'   \item{"sql server" for Microsoft SQL Server}
#' } 
#' @param user				The user name used to access the server.
#' @param password		The password for that user
#' @param server			The name of the server
#' @param port				(optional) The port on the server to connect to
#' @param cdmSchema  Schema name where your patient-level data in OMOP CDM format resides
#' @param resultsSchema  Schema where you'd like the results tables to be created (requires user to have create/write access)
#' @param minCellCount  The smallest allowable cell count, 1 means all counts are allowed
#' @param sourceName Short name that will be appeneded to results table name
#' @param folder   The name of the local folder to place results;  make sure to use forward slashes (/)
#' 
#' @importFrom DBI dbDisconnect
#' @export
execute <- function(dbms, user, password, server, 
										port = NULL,
										cdmSchema, resultsSchema, 
										minCellCount = 1,
										sourceName = "source_name",
										folder = getwd()) {

	connectionDetails <- DatabaseConnector::createConnectionDetails(dbms=dbms, 
																																	server=server, 
																																	user=user, 
																																	password=password, 
																																	schema=cdmSchema,
																																	port=port)
	
	
	###########################################################
	# End of parameters. Make no changes after this           #
	###########################################################
	
	setwd(folder)
		
	# Create the parameterized SQL files:
	htnSqlFile <- renderStudySpecificSql("HTN12mo",minCellCount,cdmSchema,resultsSchema,sourceName,dbms)
	t2dmSqlFile <- renderStudySpecificSql("T2DM12mo",minCellCount,cdmSchema,resultsSchema,sourceName,dbms)
	depSqlFile <- renderStudySpecificSql("Depression12mo",minCellCount,cdmSchema,resultsSchema,sourceName,dbms)
	
	# Execute the SQL:
	conn <- DatabaseConnector::connect(connectionDetails)
	DatabaseConnector::executeSql(conn,SqlRender::readSql(htnSqlFile))
	DatabaseConnector::executeSql(conn,SqlRender::readSql(t2dmSqlFile))
	DatabaseConnector::executeSql(conn,SqlRender::readSql(depSqlFile))
	
	# Extract tables to CSV files:
	extractAndWriteToFile(conn, "summary", cdmSchema, resultsSchema, sourceName, "HTN12mo", dbms)
	extractAndWriteToFile(conn, "person_cnt", cdmSchema, resultsSchema, sourceName, "HTN12mo", dbms)
	extractAndWriteToFile(conn, "seq_cnt", cdmSchema, resultsSchema, sourceName, "HTN12mo", dbms)
	
	extractAndWriteToFile(conn, "summary", cdmSchema, resultsSchema, sourceName, "T2DM12mo", dbms)
	extractAndWriteToFile(conn, "person_cnt", cdmSchema, resultsSchema, sourceName, "T2DM12mo", dbms)
	extractAndWriteToFile(conn, "seq_cnt", cdmSchema, resultsSchema, sourceName, "T2DM12mo", dbms)
	
	extractAndWriteToFile(conn, "summary", cdmSchema, resultsSchema, sourceName, "Depression12mo", dbms)
	extractAndWriteToFile(conn, "person_cnt", cdmSchema, resultsSchema, sourceName, "Depression12mo", dbms)
	extractAndWriteToFile(conn, "seq_cnt", cdmSchema, resultsSchema, sourceName, "Depression12mo", dbms)
	
	DBI::dbDisconnect(conn)
	
}
