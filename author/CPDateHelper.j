@implementation CPDateHelper : CPDate {

}

/**
 * Formats a date string for a given time
 *
 * Uses the same string formatting parameters as with PHP's date() function
 * See http://www.php.net/date
 *
 * @param CPString timestamp	A JavaScript Date()-compatible datetime string
 * @param CPString withFormat	The format of the outputted date string
 * @return CPString A date string following a given date and date format rule
 *
 */
+ (CPString)date:(CPString)timestamp withFormat:(CPString)format {
	var date = new Date(timestamp),
		strLen = [format length],
		out = [[CPString alloc] initWithString:@""],
		day = date.getDay(),
		dayOfMonth = date.getDate(),
		month = date.getMonth(),
		year = date.getFullYear();
		
	for (i = 0; i < strLen; i++) {
		var char = [format characterAtIndex:i],
			charCode = char.charCodeAt(0);
		switch (charCode) {
			case 68: //D : 3-letter day of week
				out += [self textualRepresentationOfDay:day short:YES];
				break;
			
			case 106: //j : day of month without leading zeros (1-31)
				out += [self dayOfMonth:dayOfMonth withLeadingZeros:NO];
				break;
			
			case 100: //d : day of month with leading zeros (01-31)
				out += [self dayOfMonth:dayOfMonth withLeadingZeros:YES];
				break;
			
			case 108: //l : full name of day (Monday - Sunday)
				out += [self textualRepresentationOfDay:day short:NO];
				break;
			
			case 78: //N : day of week as integer (1-7)
				out += day;
				break;
			
			case 83: //S : ordinal suffix of day of month (1st, 12th, etc.)
				out += [self ordinalSuffix:dayOfMonth];
				break;
			
			case 70: //F : full name of month (January - December)
				out += [self textualRepresentationOfMonth:month short:NO];
				break;
				
			case 109: //m : month as integer with leading zeros (01-12)
				out += (month+1 < 10) ? ("0" + (month + 1)) : (month+1);
				break;
				
			case 77: //M : abbreviation of month's name (Jan - Dec)
				out += [self textualRepresentationOfMonth:month short:YES];
				break;
			
			case 110: //n : month as integer without leading zeros (1-12)
				out += (month + 1);
				break;
			
			case 116: //t : number of days in the given month
				var _month = (month + 1);
				out += [self numberOfDaysInMonth:_month ofYear:year];
				break;
			
			case 76: //L : true / false if year is leap year
				var isLeapYear = [self isLeapYear:year];
				out += (isLeapYear == YES ? 1 : 0);
				break;
			
			case 89: //Y : full year representation
				out += year;
				break;
				
			case 121: //y : 2-digit representation of year
				var _year = [CPString stringWithString:year];
				out += [_year substringFromIndex:2];
				break;
			
			case 97: //a : am or pm
				var hour = date.getHours();
				out += [self meridian:hour];
				break;
			
			case 65: //A : AM or PM
				var hour = date.getHours();
				out += [[self meridian:hour] uppercaseString];
				break;
			
			case 103: //g : 12-hour format without leading zeros (1-12)
				var hour = date.getHours();
				out += [self formatHour:hour military:NO leadingZeros:NO];
				break;
			
			case 71: //G : 24-hour format without leading zeros (0-23)
				var hour = date.getHours();
				out += [self formatHour:hour military:YES leadingZeros:NO];
				break;
			
			case 104: //h : 12-hour format with leading zeros (01-12)
				var hour = date.getHours();
				out += [self formatHour:hour military:NO leadingZeros:YES];
				break;
			
			case 72: //H : 24-hour format with leading zeros (00-23)
				var hour = date.getHours();
				out += [self formatHour:hour military:YES leadingZeros:YES];
				break;
			
			case 105: //i : minutes with leading zeros (00-59)
				var mins = date.getMinutes();
				if (mins < 10) {
					mins = @"0" + mins;
				}
				out += mins;
				break;
			
			case 115: //s : seconds with leading zeros (00-59)
				out += date.getSeconds();
				break;
			
			case 32:
				out += @" ";
				break;
				
			default:
				out += char;
				break;
		}
	}
	return out;
}

/**
 * Returns a formatted hour for a given hour
 *
 * @param int hour	An hour to format
 * @param BOOL military	Whether to return in military (24-hour) format
 * @param BOOL leadingZeros	Whether to return with leading zeros
 * @return CPString A formatted hour
 *
 */
+ (CPString)formatHour:(int)hour military:(BOOL)isMilitary leadingZeros:(BOOL)hasLeadingZeros {
	if (isMilitary == NO) {
		if (hour == 0) {
			hour = 12;
		}
		if (hour > 12) {
			hour = hour - 12;
		}
	}
	if (hasLeadingZeros == YES && hour < 10) {
		return @"0" + Math.floor(hour);
	} else {
		return hour;
	}
}

/**
 * Returns a formatted meridan (am or pm) for a given hour
 *
 * @param int hour	The hour
 * @return CPString am or pm
 *
 */
+ (CPString)meridian:(int)hour {
	if (hour < 12) {
		return @"am";
	} else {
		return @"pm";
	}
}

/**
 * Calculates the number of days in a given month for a given year
 *
 * (Year is necessary for determining the leap year)
 *
 * @param int aMonth	A given month
 * @param int ofYear	Corresponding year
 * @return CPString	Numbers of days in that month
 *
 */
+ (CPString)numberOfDaysInMonth:(int)aMonth ofYear:(int)aYear {
	var thirtyOne = [1, 3, 5, 7, 8, 10, 12],
		thirty = [4, 6, 9, 11],
		isThirtyOne = NO,
		isThirty = NO,
		isLeap = [self isLeapYear:aYear];
	for (var i in thirtyOne) {
		if (aMonth == thirtyOne[i]) {
			isThirtyOne = YES;
			break;
		}
	}
	if (isThirtyOne == YES) {
		return @"31";
	} else {
		for (var i in thirty) {
			if (aMonth == thirty[i]) {
				isThirty = YES;
				break;
			}
		}
		if (isThirty == YES) {
			return @"30";
		} else {
			return isLeap == YES ? @"29" : @"28";
		}
	}
}

/**
 * Whether or not a given year is a leap year (following Gregorian calendar rules)
 *
 * (incidentally, centennial years that aren't evenly divisble by 400 are not leap years)
 *
 * @param int aYear	A given year
 * @return BOOL	Whether or not the year is a leap year
 *
 */
+ (BOOL)isLeapYear:(int)aYear {
	if ((aYear % 4) == 0) {
		if ((aYear % 100) == 0 && (aYear % 400) != 0) {
			return NO;
		} else {
			return YES;
		}
	} else {
		return NO;
	}
}

/**
 * Returns a textual representation of a given month
 *
 * @param int monthOfYear	A given month of the year (1-12)
 * @param BOOL short	Whether to return as 3-digit abbreviation or as the full name of the month
 * @return CPString	Textual representation of the month
 *
 */
+ (CPString)textualRepresentationOfMonth:(int)monthOfYear short:(BOOL)isShort {
	var months = ["January","February","March","April","May","June","July","August","September","October","November","December"],
		monthsShort = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
	if (isShort == YES) {
		return monthsShort[monthOfYear];
	} else {
		return months[monthOfYear];
	}
}

/**
 * Returns the ordinal suffix for a given day of the month
 *
 * @param int day	The day of the month
 * @return CPString	Ordinal suffix (st for 1st, nd for 2nd, etc.)
 *
 */
+ (CPString)ordinalSuffix:(int)day {
	var suffixes = ["th","st","nd","rd"],
		val = day % 100;
	return (suffixes[(val - 20) % 10] || suffixes[val] || suffixes[0]);
}

/**
 * Returns the day of the month with or without leading zeros
 *
 * @param int day	Day of the month (1-31)
 * @param BOOL withLeadingZeros	Whether to format with leading zeros
 * @return CPString	Formatted day of the month
 *
 */
+ (CPString)dayOfMonth:(int)day withLeadingZeros:(BOOL)isLeadingZeros {
	var out = Math.floor(day);
	if (isLeadingZeros == YES && out < 10) {
		return "0" + out;
	} else {
		return out;
	}
}

/**
 * Returns a textual representation of the day of the week
 *
 * @param int dayOfWeek	Day of the weeks as integer (1-7); Monday = 1, etc.
 * @param BOOL short	Whether to abbreviate or render the full name
 * @return CPString	Day of the week
 *
 */
+ (CPString)textualRepresentationOfDay:(int)dayOfWeek short:(BOOL)isShort {
	var daysOfWeek = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"],
		daysOfWeekShort = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"],
		day = dayOfWeek - 1;
	if (isShort == YES) {
		return daysOfWeekShort[day];
	} else {
		return daysOfWeek[day];
	}
}

@end