//
//  NSDate+Tripomatic.h
//  Tripomatic
//
//  Created by Ondra Beneš on 8/29/12.
//  Copyright (c) 2012 Trinerdis. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSLocale (Tripomatic)

+ (NSLocale *)sharedPOSIXLocale;

@end


@interface NSCalendar (Tripomatic)

+ (NSCalendar *)sharedCalendar;

@end


@interface NSDateFormatter (Tripomatic)

+ (NSDateFormatter *)sharedDateTimeFormatter;
+ (NSDateFormatter *)sharedDateFormatter;
+ (NSDateFormatter *)sharedTimeFormatter;
+ (NSDateFormatter *)sharedMediumStyleDateFormatter;
+ (NSDateFormatter *)sharedDatePickerStyleDateTimeFormatter;
+ (NSDateFormatter *)sharedDEFormatDateFormatter;
+ (NSDateFormatter *)sharedEFormatDateFormatter;
+ (NSDateFormatter *)sharedLLLLYYYYFormatDateFormatter;
+ (NSDateFormatter *)sharedLLLLDFormatDateFormatter;
+ (NSDateFormatter *)shared8601DateTimeFormatter;

@end


@interface NSDate (Tripomatic)

- (NSDate *)dateByAddingNumberOfDays:(NSInteger)days;

+ (NSDate *)dateFromDateTimeString:(NSString *)dateString;
+ (NSDate *)dateFromGMTDateTimeString:(NSString *)dateString;
+ (NSDate *)dateFromDateString:(NSString *)dateString;
+ (NSDate *)dateFromGMTDateString:(NSString *)dateString;

+ (NSDate *)now;
- (NSDate *)midnight;

+ (NSDate *)beginDate;
+ (NSDate *)endDate;

- (NSString *)dateString;
- (NSString *)dateTimeString;
- (NSString *)GMTDateTimeString;

- (NSDate *)nearestHalfHourDate;

/**
 * Compares if date is within same date as today
 *
 * @return if date is today
 */
- (BOOL)isToday;

- (BOOL)isYesterday;
- (BOOL)isTomorrow;

/**
 * Compares if date is the same day as given one
 *
 * @param date date to compare with
 * @return if given day is in same day or no
 */
- (BOOL)isSameDayAsDate:(NSDate *)date;

@end
