//
//  TKPlaceDetailCells.m
//  SygicTravel-Demo
//
//  Created by Michal Zelinka on 15/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import "TKPlaceDetailCells.h"
#import "UIKit+TravelKit.h"

const CGFloat kTKPlaceDetailCellsSidePadding = 15.0;


@interface TKPlaceDetailGenericCell ()

+ (UITableViewCellStyle)tk_defaultStyle;
- (void)tk_initialise;

@end


@implementation TKPlaceDetailGenericCell

+ (UITableViewCellStyle)tk_defaultStyle
{
	return UITableViewCellStyleDefault;
}

- (instancetype)initWithFrame:(CGRect)frame
{
UITableViewCellStyle st = [[self class] tk_defaultStyle];

	if (self = [super initWithStyle:st reuseIdentifier:nil])
	{
		self.frame = frame;

		[self tk_initialise];
	}

	return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		[self tk_initialise];
	}

	return self;
}

- (void)tk_initialise
{}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
//	super.highlighted = highlighted;

	self.backgroundColor = (highlighted) ?
		[UIColor colorWithWhite:.97 alpha:1] : [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//	super.selected = selected;

	self.backgroundColor = (selected || self.isHighlighted) ?
		[UIColor colorWithWhite:.97 alpha:1] : [UIColor whiteColor];
}

- (void)addSeparatingLineToTop:(BOOL)toTop toBottom:(BOOL)toBottom
{
	CGRect f = self.bounds;
	f.size.height = 0.5;

	if (toTop) {
		UIView *s = [[UIView alloc] initWithFrame:f];
		s.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		s.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
		[self addSubview:s];
	}

	if (toBottom) {
		f.origin.y = CGRectGetHeight(self.frame) - f.size.height;
		UIView *s = [[UIView alloc] initWithFrame:f];
		s.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		s.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
		[self addSubview:s];
	}
}

@end




@implementation TKPlaceDetailEmptyCell

- (void)tk_initialise
{
	[self.textLabel removeFromSuperview];
	[self.detailTextLabel removeFromSuperview];
}

- (void)setFrame:(CGRect)frame
{
	super.frame = frame;
}

- (void)setBounds:(CGRect)bounds
{
	super.bounds = bounds;
}

@end




@implementation TKPlaceDetailSingleLabelCell

- (void)tk_initialise
{
	self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.textLabel.numberOfLines = 0;
	self.textLabel.textAlignment = NSTextAlignmentLeft;
	self.textLabel.font = [UIFont systemFontOfSize:16];
	self.textLabel.textColor = [UIColor colorWithWhite:0.66 alpha:1];
}

- (void)setDisplayedText:(NSString *)displayedText
{
	displayedText = displayedText.copy ?: @"";
	displayedText = [displayedText stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
	displayedText = [displayedText stringByReplacingOccurrencesOfString:@"\n " withString:@"\n"];
	displayedText = [displayedText stringByReplacingOccurrencesOfString:@"\n- " withString:@"\n  ◦ "];

	_displayedText = displayedText.copy;

	NSMutableAttributedString *str = [[NSMutableAttributedString alloc]
	initWithString:displayedText attributes:@{
		NSForegroundColorAttributeName: self.textLabel.textColor,
		NSFontAttributeName: self.textLabel.font,
	}];

	NSMutableParagraphStyle *para = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	para.lineHeightMultiple = 0.4;

	NSRegularExpression *regex = nil;

	regex = [NSRegularExpression
	  regularExpressionWithPattern:@"\n\n"
	  options:NSRegularExpressionCaseInsensitive
	  error:nil];
	[regex enumerateMatchesInString:displayedText options:0 range:NSMakeRange(0, displayedText.length)
	  usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
		[str addAttributes:@{
			NSParagraphStyleAttributeName: para,
			NSForegroundColorAttributeName: [UIColor colorWithRed:0 green:0.4 blue:0 alpha:1],
		} range:match.range];
	}];

	if (self.headingDetectionEnabled)
	{
		UIColor *headingColor = [UIColor colorWithWhite:.65 alpha:1];
		regex = [NSRegularExpression
		  // @"(^|\\n)(\\p{L}|\\p{N}|\\s){1,100}[^.\\n]\\n"
		  regularExpressionWithPattern:@"(^|\\n\\n)[^\\n.:-]{1,100}\\n"
		  options:NSRegularExpressionCaseInsensitive|NSRegularExpressionSearch
		  error:nil];
		[regex enumerateMatchesInString:displayedText options:0 range:NSMakeRange(0, displayedText.length)
		  usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
			  NSString *sub = [displayedText substringWithRange:match.range];
			if ([sub hasPrefix:@" "] || [sub hasPrefix:@" "]) return;
			sub = [sub stringByReplacingOccurrencesOfString:@"\n" withString:@""];
			if ([sub hasPrefix:@" "] || [sub hasPrefix:@" "]) return;
			[str addAttributes:@{
				NSForegroundColorAttributeName: headingColor,
				NSFontAttributeName: [UIFont boldSystemFontOfSize:self.textLabel.font.pointSize],
			} range:match.range];
		}];
	}

	para = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	para.lineHeightMultiple = 0.85;

	regex = [NSRegularExpression
	  regularExpressionWithPattern:@"^  ◦ [^.\\n]+$"
	  options:NSRegularExpressionCaseInsensitive
	  error:nil];
	[regex enumerateMatchesInString:displayedText options:0 range:NSMakeRange(0, displayedText.length)
	  usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
		[str addAttributes:@{
			NSParagraphStyleAttributeName: para,
		} range:match.range];
	}];

	self.textLabel.attributedText = str;

	[self layoutSubviews];
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	CGRect f = self.textLabel.frame;
	f.size.height = [self.textLabel expandedSizeOfText].height;
	f.origin.y = kTKPlaceDetailCellsSidePadding/2 + self.overridingTopPadding;
	self.textLabel.frame = f;

	f = self.frame;
	f.size.height = CGRectGetMaxY(self.textLabel.frame) + kTKPlaceDetailCellsSidePadding/2 + self.overridingBottomPadding;
	self.frame = f;
}

@end





@implementation TKPlaceDetailSeparatorCell

- (void)tk_initialise
{
	self.userInteractionEnabled = NO;
	self.contentView.backgroundColor = [UIColor colorWithWhite:.94 alpha:1];

	_hasTopSeparator = _hasBottomSeparator = YES;
}

- (void)layoutSubviews
{
	[self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

	[self addSeparatingLineToTop:_hasTopSeparator toBottom:_hasBottomSeparator];
}

@end






@interface TKPlaceDetailHeaderCell ()

@property (nonatomic, strong) UIImageView *pictureView;

@end


@implementation TKPlaceDetailHeaderCell

- (void)tk_initialise
{
	_pictureView = [[UIImageView alloc] initWithFrame:self.bounds];
	_pictureView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self addSubview:_pictureView];
}

- (void)setPlace:(TKPlace *)place
{
	_place = place;


	[[TravelKit sharedKit] mediaForPlaceWithID:place.ID completion:^(NSArray<TKMedium *> *media, NSError *error) {

		if (!media.count) return;

		[[NSOperationQueue new] addOperationWithBlock:^{

			[_pictureView setImageWithMediumImage:media.firstObject size:CGSizeMake(640, 640) completion:nil];

		}];
	}];
}

@end








@implementation TKPlaceDetailNameCell

- (void)tk_initialise
{
	[super tk_initialise];

	self.overridingBottomPadding = -5;
	self.textLabel.font = [UIFont boldSystemFontOfSize:22];
	self.textLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
}

- (void)setDisplayName:(NSString *)displayName
{
	_displayName = displayName;

	self.textLabel.text = displayName;

	[self layoutSubviews];
}

@end


@implementation TKPlaceDetailDescriptionCell

- (void)tk_initialise
{
	[super tk_initialise];

	self.overridingTopPadding = -3;
}

@end


@implementation TKPlaceDetailTagsCell

- (void)tk_initialise
{
	[super tk_initialise];

	self.overridingBottomPadding = 3;
	self.textLabel.font = [UIFont systemFontOfSize:13];
	self.textLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1];
}

- (void)setTags:(NSArray<TKPlaceTag *> *)tags
{
	_tags = tags.copy;

	NSMutableArray<NSString *> *outTags = [NSMutableArray arrayWithCapacity:_tags.count];

	for (TKPlaceTag *t in _tags)
		[outTags addObject:t.name ?: t.key];

	NSString *output = NSLocalizedString(@"Tags: %@", @"TravelKit Place Detail – Tags label");
	output = [NSString stringWithFormat:output, [outTags componentsJoinedByString:@" • "]];
	output = [output uppercaseString];

	self.textLabel.text = output;

	[self layoutSubviews];
}

@end
