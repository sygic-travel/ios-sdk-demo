//
//  TKNavigationController.m
//  TravelKit-Demo
//
//  Created by Michal Zelinka on 12/04/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import "TKNavigationController.h"

@implementation TKNavigationController

- (BOOL)modalPresentationCapturesStatusBarAppearance
{
	return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	if (self.modalPresentationStyle != UIModalPresentationFullScreen)
		return UIStatusBarStyleLightContent;

	return [super preferredStatusBarStyle];
}

@end
