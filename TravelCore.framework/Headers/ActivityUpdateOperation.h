//
//  ActivityUpdateOperation.h
//  Tripomatic
//
//  Created by Michal Zelinka in 2014.
//  Copyright (c) 2014 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TravelCore/Activity.h>

@class ActivityUpdateOperation;


@protocol ActivityUpdateOperationDelegate <NSObject>
@optional
- (void) activityUpdateOperation:(ActivityUpdateOperation *)operation didFinishWithActivity:(Activity *)activity;
- (void) activityUpdateOperation:(ActivityUpdateOperation *)operation didFinishWithPhotosForActivity:(Activity *)activity;
- (void) activityUpdateOperation:(ActivityUpdateOperation *)operation didHaltWithActivity:(Activity *)activity;
- (void) activityUpdateOperationDidFail:(ActivityUpdateOperation *)downloader;
@end

@interface ActivityUpdateOperation : NSOperation

@property (nonatomic, weak) id<ActivityUpdateOperationDelegate> delegate;
@property (nonatomic, readonly) Activity *activity;

- (instancetype)initWithActivity:(Activity *)activity;

@end
