###########################################################
# R script for creating SQL files (and sending the SQL    # 
# commands to the server) for the treatment pattern       #
# studies for these diseases:                             #
# - Hypertension (HTN)                                    #
# - Type 2 Diabetes (T2DM)                                #
# - Depression                                            #
#                                                         #
# Requires: R and Java 1.6 or higher                      #
###########################################################

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
#' @param cdmSchema  The name of the CDM schema to connect to
#' @param resultsSchema  The name of the existant results schema to connect to
#' @param minCellCount  The smallest allowable cell count, 1 means all counts are allowed
#' @param sourceName WHAT IS THIS? TODO
#' @param folder   The name of the local folder to place results
#' 
#' @importFrom DBI dbDisconnect
#' @export
execute <- function(dbms, user, password, server, port,
										cdmSchema, resultsSchema, 
										minCellCount = 1,
										sourceName = "source_name",
										folder = getwd()) {
										
# 	folder = getwd(), # Folder containing the R and SQL files, use forward slashes
# 										minCellCount  = 1,   # the smallest allowable cell count, 1 means all counts are allowed
# 										cdmSchema     = "cdm_schema",
# 										resultsSchema = "results_schema",
# 										sourceName    = "source_name",
# 										dbms          = "sql server",  	  # Should be "sql server", "oracle", "postgresql" or "redshift"
# 										user,
# 										password,
# 										server,
# 										port = NULL) {
	
	# If you want to use R to run the SQL and extract the results tables, please create a connectionDetails 
	# object. See ?createConnectionDetails for details on how to configure for your DBMS.
	
	
	
	# user <- NULL
	# pw <- NULL
	# server <- "server_name"
	# port <- NULL
	
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
	
	# source("HelperFunctions.R")
	
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
