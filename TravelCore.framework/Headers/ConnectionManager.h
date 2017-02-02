//
//  ConnectionManager.h
//  Tripomatic
//
//  Created by Ondra Beneš on 9/13/12.
//  Refactored by Michal Zelinka on 03/06/2015.
//  Copyright (c) 2015 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ConnectionManager : NSObject

+ (BOOL)isConnected;
+ (BOOL)isCellular;
+ (BOOL)isWifi;

// Check for active connection.
// Once in app's lifetime throws an alert with information.
+ (void)checkConnection;

- (instancetype)init OBJC_UNAVAILABLE("Use ConnectionManager class itself.");

@end
