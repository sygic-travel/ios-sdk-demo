//
//  NSObject+Parsing.h
//  Tripomatic
//
//  Created by Michal Zelinka on 03/09/15.
//  Copyright (c) 2015 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Parsing)

@property (nonatomic, readonly) NSArray *parsedArray;
@property (nonatomic, readonly) NSDictionary *parsedDictionary;
@property (nonatomic, readonly) NSString *parsedString;
@property (nonatomic, readonly) NSNumber *parsedNumber;

- (id)objectAtIndex:(NSUInteger)index;
- (id)objectForKeyedSubscript:(id)key;
- (id)objectForKey:(id)key;

@end


// Object macros
NS_INLINE id objectOrNil(id obj)   { return ![[NSNull null] isEqual:obj] ? obj : nil; }
NS_INLINE id objectOrNull(id obj)  { return obj ?: [NSNull null]; }

// String macros
#define stringOrValue(str, value)        ([str parsedString] ?: value)
#define nonEmptyString(str)               [str parsedString]

// Number macros
#define numberOrValue(number, value)     ([number parsedNumber] ?: value)
#define numberOrNil(number)               [number parsedNumber]

// Dictionary macros
#define dictionaryOrValue(dict, value)   ([dict parsedDictionary] ?: value)
#define dictionaryOrNil(dict)             [dict parsedDictionary]

// Array macros
#define arrayOrValue(array, value)       ([array parsedArray] ?: value)
#define arrayOrNil(array)                 [array parsedArray]
