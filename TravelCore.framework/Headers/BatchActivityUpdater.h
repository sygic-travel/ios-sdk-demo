//
//  BatchActivityUpdater.h
//  Tripomatic
//
//  Created by Michal Zelinka on 12/11/13.
//  Copyright (c) 2013 two bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TravelCore/BatchActivityUpdateOperation.h>

@interface BatchActivityUpdater : NSObject <BatchActivityUpdateOperationDelegate>

+ (BatchActivityUpdater *)defaultUpdater;
- (instancetype)init;

- (void)updateActivitiesInDestinationID:(NSString *)destinationID hasPriority:(BOOL)hasPriority;
- (void)updateActivitiesInDestinationArray:(NSArray *)destinationArray hasPriority:(BOOL)hasPriority;
- (void)cancelUpdating;

- (BOOL)queueContainsDestinationID:(NSString *)destinationID activityType:(ActivityType)activityType;

@end
