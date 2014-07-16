/*

FUNCTION GetTime() : Returns the system time;

FUNCTION GetDateTime() : Returns the system date + time;

*/
IMPORT STD.Date;

EXPORT DateTimeLibrary := MODULE
// Function to get time in HHMMSS format
// Courtesy : Nigel/Gavin
	EXPORT GetTime() := FUNCTION
	//function to get time
			string6 getTime() := BEGINC++
			// Declarations
			struct tm localt; // localtime in "tm" structure
			time_t timeinsecs; // variable to store time in secs

			// Get time in sec since Epoch
			time(&timeinsecs); 
			// Convert to local time
			localtime_r(&timeinsecs,&localt);
			// Format the local time value
			strftime(__result, 8, "%H%M%S", &localt); // Formats the localtime to HHMMSS

			ENDC++;

			return getTime();
	END;
// Return the data and time
	EXPORT GetDateTime() := FUNCTION
		Return Date.Today() + getTime();
	END;
END;