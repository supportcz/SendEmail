(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: MotionErrorLogger
 * File: MotionErrorLogger.st
 * Author: vancurar
 * Created: November 28, 2013
 ********************************************************************
 * Implementation of program MotionErrorLogger
 ********************************************************************)

PROGRAM _INIT
	
	params.host := '217.198.120.44';
	params.sender := 'error@czechmachines.cz';
	params.receiver := 'icm@czechmachines.cz';
	params.user := 'icm@czechmachines.cz';
	params.password := 'Karroh13';
	params.text := '';
	params.ethernetPort := 'IF5';
	
END_PROGRAM


PROGRAM _CYCLIC

	CASE step OF
		0:	(* check if there is a motion error *)
			MC_BR_AxisErrorCollector_0.Axis := mcALL_AXES;
			MC_BR_AxisErrorCollector_0.Enable := 1;
			
			IF MC_BR_AxisErrorCollector_0.FunctionBlockError OR MC_BR_AxisErrorCollector_0.AxisError OR 
				MC_BR_AxisErrorCollector_0.AxisWarning THEN
				step := step + 1;
			END_IF
		
		1:	(* wait some time *)
			TON_0.IN := 1;
			TON_0.PT := T#5s;
		
			IF TON_0.Q THEN
				TON_0.IN := 0;
				step := step + 1;
			END_IF

		2: //Get the station Hostname
			CfgGetHostName_0.enable := 1;
			CfgGetHostName_0.pHostName := ADR(hostName); 
			CfgGetHostName_0.Len := SIZEOF(hostName);
			CfgGetHostName_0();
			
			IF CfgGetHostName_0.status = 0 THEN
				step := step + 1;
			END_IF
			
		3: //Get the station IP address
			CfgGetIPAddr_0.enable := 1;
			CfgGetIPAddr_0.pDevice := ADR(params.ethernetPort);
			CfgGetIPAddr_0.Len := SIZEOF(ip_address);
			CfgGetIPAddr_0.pIPAddr := ADR(ip_address);
			CfgGetIPAddr_0();
			
			IF CfgGetIPAddr_0.status = 0 THEN
				step := step + 1;
			END_IF
	
		4: //build subject text
			brsstrcpy(ADR(params.subject), ADR('Chyba pohonu na stroji "'));
			brsstrcat(ADR(params.subject), ADR(hostName));
			brsstrcat(ADR(params.subject), ADR('" ('));
			brsstrcat(ADR(params.subject), ADR(ip_address));		
			brsstrcat(ADR(params.subject), ADR(')'));		
			step := step + 1;;
		
		5:	(* send email *)	
			SmtpSend_0.enable := 1;
			SmtpSend_0.pHost := ADR(params.host);  (*IP adress of the SMTP server*)	
			SmtpSend_0.pUser := 0;  (*User name, optional. If 0 is specified, authentication does not take place.*)
			SmtpSend_0.pPassword := 0;  (*Password,  optional. If 0 is specified, authentication does not take place.*)
			SmtpSend_0.pSender := ADR(params.sender);  (*Sender name*)
			SmtpSend_0.pReceiver := ADR(params.receiver);  (*Receiver string, can also contain several recipients that are separated by ',' or a space.*)
			SmtpSend_0.pSubject := ADR(params.subject);  (*Subject string*)							
			SmtpSend_0.pText := ADR(params.text);  (*Text string*)
			SmtpSend_0.pUser := ADR(params.user);
			SmtpSend_0.pPassword := ADR(params.password);
			SmtpSend_0.pDomain := 0;  (*Sender domain name, optional, If 0 is specified, "[127.0.0.1]" is entered as the sender domain name.*)
			SmtpSend_0.pAttachment := 0;  (*Pointer to attachment structure.*)  
			SmtpSend_0.attcnt := 0;  (*Number of attachments.*)
			SmtpSend_0.timeout := 0;  (*Server response timeout, optional. If 0 is specified, the default timeout of 120s is used.*)
			SmtpSend_0.port := 0;  (*Server port number, optional. If 0 is specified, the default port is used (SMTP: 25).*)
			SmtpSend_0();  
			
			IF SmtpSend_0.status = 0 THEN
				step := step + 1;
			END_IF
		
		6:	(* wait till error disappears *)
			IF NOT (MC_BR_AxisErrorCollector_0.FunctionBlockError OR MC_BR_AxisErrorCollector_0.AxisError OR 
				MC_BR_AxisErrorCollector_0.AxisWarning) THEN
				step := step + 1;
			END_IF
			
		7:	(* go to the beginning *)
			step := 0;
	END_CASE;

	MC_BR_AxisErrorCollector_0();
	TON_0();
	
END_PROGRAM