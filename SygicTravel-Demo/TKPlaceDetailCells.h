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


#pragma mark -
#pragma mark Objects
#pragma mark -


typedef NS_ENUM(NSUInteger, TKPlaceDetailLinkType) {
	TKPlaceDetailLinkTypeUnknown = 0,
	TKPlaceDetailLinkTypeURL,       // NSURL
	TKPlaceDetailLinkTypePhone,     // NSString
	TKPlaceDetailLinkTypeEmail,     // NSString
	TKPlaceDetailLinkTypeReference, // TKReference
};


@interface TKPlaceDetailLink : NSObject

@property (atomic) TKPlaceDetailLinkType type;
@property (nonatomic, strong) id value;

+ (instancetype)linkWithType:(TKPlaceDetailLinkType)type value:(id)value;

@end


#pragma mark -
#pragma mark Components
#pragma mark -



#pragma mark -
#pragma mark Cells
#pragma mark -


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

@end


@interface TKPlaceDetailTagsCell : TKPlaceDetailSingleLabelCell

@property (nonatomic, copy) NSArray<NSString *> *categories;
@property (nonatomic, copy) NSArray<TKPlaceTag *> *tags;

@end


@interface TKPlaceDetailLinkCell : TKPlaceDetailGenericCell

@property (nonatomic, copy) TKPlaceDetailLink *link;

@end


@interface TKPlaceDetailProductsCell : TKPlaceDetailEmptyCell

@property (nonatomic, copy) NSArray<TKReference *> *products;
@property (nonatomic, copy) void (^productTappingBlock)(TKReference *product);
@property (nonatomic, copy) void (^productsListTappingBlock)();

@end
