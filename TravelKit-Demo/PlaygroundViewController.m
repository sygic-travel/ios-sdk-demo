//
//  PlaygroundViewController.m
//  TravelKit-Demo
//
//  Created by Michal Zelinka on 09/01/2018.
//  Copyright © 2018 Tripomatic. All rights reserved.
//

#import "PlaygroundViewController.h"
#import "UIKit+TravelKit.h"

@interface PlaygroundViewController ()

@property (nonatomic, weak) TravelKit *travelKit;

@end

@implementation PlaygroundViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	_travelKit = [TravelKit sharedKit];

	self.view.backgroundColor = [UIColor whiteColor];

	UIButton *stuffButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[stuffButton setTitle:@"Do Stuff" forState:UIControlStateNormal];
	stuffButton.width = 150; stuffButton.height = 44;
	[stuffButton addTarget:self action:@selector(doStuff) forControlEvents:UIControlEventTouchUpInside];
	[self.view addCenteredSubview:stuffButton];
}

- (void)doStuff
{

	TKTrip *trip = [[TKTrip alloc] initWithName:@"Vylet do Londyna"];
	trip.destinationIDs = @[ @"city:1" ];

	TKTripDay *day = [TKTripDay new];
	[day insertItemWithID:@"poi:530" atIndex:0];
	[day insertItemWithID:@"poi:440" atIndex:1];

	trip.days = @[ day, day ];
	[_travelKit.trips saveTrip:trip];

}

@end
