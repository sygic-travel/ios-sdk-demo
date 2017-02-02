//
//  BatchActivityUpdateInfo.h
//  Tripomatic
//
//  Created by Michal Zelinka on 12/11/13.
//  Copyright (c) 2013 two bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TravelCore/Activity.h>

#define kBatchRecordLifeInDays 30


@interface BatchActivityUpdateInfo : NSObject

@property (nonatomic, copy) NSString *destinationID;
@property (atomic) NSTimeInterval updateFinished;
@property (atomic) NSUInteger lastIndex;
@property (atomic) ActivityType activityType;

- (id)initFromDatabase:(NSDictionary *)data;
- (id)initWithDestinationID:(NSString *)destinationID;
- (id)initWithDestinationID:(NSString *)destinationID activityType:(ActivityType)type;

- (BOOL)isUpToDate;

@end
