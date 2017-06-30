//
//  TKGradientView.m
//  Tripomatic
//
//  Created by Michal Zelinka on 16/10/2014.
//  Copyright (c) 2014 Tripomatic. All rights reserved.
//

#import "TKGradientView.h"

@implementation TKGradientView

- (void)refreshAppearance
{
	CAGradientLayer *maskLayer = [CAGradientLayer layer];
	maskLayer.anchorPoint = CGPointZero;
	maskLayer.startPoint = CGPointMake(0.0f, .0f);
	maskLayer.endPoint = CGPointMake(0.0f, 1.f);

	if (_type == TKGradientViewTypeTopClearBottomFull)
	{
		UIColor *fullColor = [UIColor whiteColor];
		UIColor *clearColor = [UIColor clearColor];
		maskLayer.colors = @[ (id)clearColor.CGColor, (id)fullColor.CGColor ];
		maskLayer.locations = @[ @0, @1 ];
	}
	else if (_type == TKGradientViewTypeTopFullBottomClear)
	{
		UIColor *fullColor = [UIColor whiteColor];
		UIColor *clearColor = [UIColor clearColor];
		maskLayer.colors = @[ (id)fullColor.CGColor, (id)clearColor.CGColor ];
		maskLayer.locations = @[ @0, @1 ];
	}

	maskLayer.bounds = self.bounds;
	self.layer.mask = maskLayer;
	self.layer.shouldRasterize = YES;
	self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	self.layer.mask.bounds = self.bounds;
	[self refreshAppearance];
}

- (void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	self.layer.mask.bounds = bounds;
	[self refreshAppearance];
}

- (void)setType:(TKGradientViewType)type
{
	_type = type;
	[self refreshAppearance];
}

@end
