//
//  TKGradientView.h
//  Tripomatic
//
//  Created by Michal Zelinka on 16/10/2014.
//  Copyright (c) 2014 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TKGradientViewType) {
	TKGradientViewTypeTopClearBottomFull = 0,
	TKGradientViewTypeTopFullBottomClear,
};


@interface TKGradientView : UIView

@property (nonatomic) TKGradientViewType type;

@end
