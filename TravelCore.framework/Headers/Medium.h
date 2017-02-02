//
//  Medium.h
//  Tripomatic
//
//  Created by Ondra Beneš on 9/11/12.
//  Copyright (c) 2012 Trinerdis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#define MEDIUM_SIZE_PLACEHOLDER_API     "{size}"   // ABI-EXPORTED
#define MEDIUM_SIZE_PLACEHOLDER_LOCAL   "__SIZE__" // ABI-EXPORTED

typedef NS_ENUM(NSUInteger, MediumType) { // ABI-EXPORTED
	MediumTypeUnknown      = 0,
	MediumTypeImage        = 1,
	MediumTypeVideo        = 2,
	MediumTypeImage360     = 3,
	MediumTypeVideo360     = 4,
};

typedef NS_ENUM(NSUInteger, ImageType) { // ABI-EXPORTED
	// Generic fast-cachable
	ImageTypeUnknown         = 0,
	ImageTypeSmall           = 1,
	ImageTypeMedium          = 2,
	ImageTypeLarge           = 3,
	// Generic non-cachable
	ImageTypeFullscreen      = 98,
	ImageTypeOriginal        = 99,
	// Specific
	ImageTypeGalleryPreview  = 1000,
	ImageTypeVideoPreview    = 1001,
};

typedef NS_ENUM(NSUInteger, VideoType) { // ABI-EXPORTED
	// Generic fast-cachable
	VideoTypeUnknown	= 0,
	VideoType720p		= 1,
	VideoType1080p		= 2,
	VideoType4K         = 3,
};

typedef NS_OPTIONS(NSUInteger, MediumSuitability) { // ABI-EXPORTED
	MediumSuitabilityNone           = 0,
	MediumSuitabilitySquare         = 1,
	MediumSuitabilityPortrait       = 2,
	MediumSuitabilityLandscape      = 4,
	MediumSuitabilityVideoPreview   = 8,
};


@interface Medium : NSObject

@property (nonatomic, copy) NSString *ID;
@property (atomic) MediumType type;
@property (nonatomic, copy) NSString *externalID;
@property (nonatomic, copy) NSString *title, *author, *provider, *license;
@property (nonatomic, strong) NSURL *URL, *previewURL;
@property (nonatomic, strong) NSURL *originURL, *authorURL;
@property (atomic) MediumSuitability suitability;
@property (atomic) CGFloat width, height;

// Static methods

+ (NSString *)sizeStringForImageType:(ImageType)type;
+ (CGSize)sizeForImageType:(ImageType)type;

+ (NSString *)sizeStringForVideoType:(VideoType)type;
+ (CGSize)sizeForVideoType:(VideoType)type;

// Instance methods

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;
- (instancetype)initFromJSON:(NSDictionary *)json;

@end
