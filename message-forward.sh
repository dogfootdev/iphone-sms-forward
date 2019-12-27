#!/usr/bin/env bash

. config
LASTDATE=$(<lastdate.txt)
LASTMESSAGEDATA=${LASTDATE}
if [ -z "$LASTMESSAGEDATA" ]
then
	echo "not has last message date"
	sqlite3 ~/Library/Messages/chat.db "SELECT date FROM message m INNER JOIN handle h ON h.ROWID=m.handle_id WHERE h.id=\""${FROMPHONENUMBER}"\" ORDER BY date DESC LIMIT 1" | while read prkey; 
	do
		echo ${prkey} > lastdate.txt
	done
else
	sqlite3 ~/Library/Messages/chat.db "SELECT REPLACE(REPLACE(text, \"
\", \"\"), \"*\", \"\*\"), date FROM message m INNER JOIN handle h ON h.ROWID=m.handle_id WHERE h.id=\""${FROMPHONENUMBER}"\" AND m.date>"${LASTDATE} | while read prkey; 
	do
		LASTMESSAGEDATA=$(echo ${prkey} | awk -F'|' '{print $2}');
		echo ${LASTMESSAGEDATA} > lastdate.txt	
		MESSAGE=$(echo ${prkey} | awk -F'|' '{print $1}');
		echo ${LASTMESSAGEDATA}
		echo ${MESSAGE}
		osascript -e "tell application \"Messages\"
		    set targetBuddy to \"${TOPHONENUMBER}\"
		    set targetService to id of 1st service whose service type = iMessage
		    set textMessage to \"${MESSAGE}\"
		    set theBuddy to buddy targetBuddy of service id targetService
		    send textMessage to theBuddy
		end tell"
		sleep 1
	done
fi


