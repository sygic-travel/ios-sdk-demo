//
//  Reference.h
//  Tripomatic
//
//  Created by Michal Zelinka on 14/8/2014.
//  Refactored by Michal Zelinka on 18/8/2016.
//  Copyright (c) 2014 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Reference : NSObject <NSCopying>

@property (atomic) NSUInteger ID NS_SWIFT_NAME(ID);
@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *supplier;
@property (nonatomic, copy) NSNumber *price;
@property (nonatomic, copy) NSString *languageID;
@property (nonatomic, copy) NSURL *onlineURL;
@property (nonatomic, copy) NSString *offlineFile;
@property (nonatomic, copy) NSArray<NSString *> *flags;
@property (atomic) BOOL premiumContent;
@property (atomic) NSInteger priority;

- (instancetype)init OBJC_UNAVAILABLE("Use -initFromDictionary: variant instead.");
- (instancetype)initFromDictionary:(NSDictionary *)dictionary;
- (instancetype)initFromDictionary:(NSDictionary *)dictionary forItemWithID:(NSString *)itemID;

- (NSString *)iconName;
- (BOOL)canBeDisplayed;
- (NSURL *)urlToDisplay; // TODO: Remove ASAP
- (BOOL)offlineContentAvailable;

- (NSString *)temporaryPath;
- (NSString *)libraryPath;
- (NSString *)libraryPathZIP;

@end
