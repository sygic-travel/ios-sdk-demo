//
//  BatchActivityUpdateOperation.h
//  Tripomatic
//
//  Created by Michal Zelinka on 24/05/2014.
//  Copyright (c) 2014 two bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TravelCore/BatchActivityUpdateInfo.h>
#import <TravelCore/ActivityManager.h>


@class BatchActivityUpdateOperation;


@protocol BatchActivityUpdateOperationDelegate <NSObject>

- (void)batchActivityUpdateOperationDidFinishUpdate:(BatchActivityUpdateOperation *)operation;
- (void)batchActivityUpdateOperationDidFail:(BatchActivityUpdateOperation *)operation;
- (void)batchActivityUpdateOperationDidCancel:(BatchActivityUpdateOperation *)operation;

@end


@interface BatchActivityUpdateOperation : NSOperation

@property (nonatomic, weak) id<BatchActivityUpdateOperationDelegate> delegate;
@property (nonatomic, copy, readonly) NSString *destinationID;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (atomic, readonly) ActivityType activityType;

- (id)initWithDestinationID:(NSString *)destinationID;
- (id)initWithDestinationID:(NSString *)destinationID activityType:(ActivityType)type;

@end
