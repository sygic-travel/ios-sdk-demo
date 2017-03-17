//
//  TKPlaceDetailCells.h
//  SygicTravel-Demo
//
//  Created by Michal Zelinka on 15/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TravelKit/TravelKit.h>

extern const CGFloat kTKPlaceDetailCellsSidePadding;


@interface TKPlaceDetailGenericCell : UITableViewCell

@property (atomic) CGFloat overridingTopPadding;
@property (atomic) CGFloat overridingBottomPadding;
@property (atomic) BOOL headingDetectionEnabled;

- (void)addSeparatingLineToTop:(BOOL)toTop toBottom:(BOOL)toBottom;

@end


@interface TKPlaceDetailEmptyCell : TKPlaceDetailGenericCell

@end


@interface TKPlaceDetailSingleLabelCell : TKPlaceDetailGenericCell

@property (nonatomic, copy) NSString *displayedText;

@end

@interface TKPlaceDetailSeparatorCell : TKPlaceDetailEmptyCell

@property (atomic) BOOL hasTopSeparator;
@property (atomic) BOOL hasBottomSeparator;

@end




@interface TKPlaceDetailHeaderCell : TKPlaceDetailEmptyCell

@property (nonatomic, copy) TKPlace *place;

@end


@interface TKPlaceDetailNameCell : TKPlaceDetailSingleLabelCell

@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *originalName;

@end


@interface TKPlaceDetailDescriptionCell : TKPlaceDetailSingleLabelCell

@property (nonatomic, copy) NSString *displayedDescription;

@end


@interface TKPlaceDetailTagsCell : TKPlaceDetailSingleLabelCell

@property (nonatomic, copy) NSArray<TKPlaceTag *> *tags;

@end
