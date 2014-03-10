(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: MotionErrorLogger
 * File: MotionErrorLogger.typ
 * Author: vancurar
 * Created: November 28, 2013
 ********************************************************************
 * Local data types of program MotionErrorLogger
 ********************************************************************)

TYPE
	SendEmailParameters_typ : 	STRUCT  (*Parameter structure*)
		host : STRING[80]; (*Host name*)
		sender : STRING[80]; (*Name of the sender*)
		receiver : STRING[80]; (*Name of the receiver*)
		user : STRING[80]; (*Username*)
		password : STRING[80]; (*Password*)
		subject : STRING[80]; (*Subject name*)
		text : STRING[200]; (*Text in email*)
		ethernetPort : STRING[80];
	END_STRUCT;
END_TYPE
