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


@interface TKPlaceDetailIconicButton : UIButton
@end


@implementation TKPlaceDetailIconicButton

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.userInteractionEnabled = NO;
		self.adjustsImageWhenHighlighted = NO;
		self.imageView.contentMode = UIViewContentModeCenter;
		self.tintColor = [UIColor colorFromRGB:0x0099EB];
		self.backgroundColor = [UIColor colorWithWhite:.97 alpha:1];
		self.layer.masksToBounds = YES;
		self.layer.cornerRadius = self.height/2.0;
		self.layer.borderWidth = 1;
		self.layer.borderColor = [UIColor colorFromRGB:0xE2E2E2].CGColor;
	}

	return self;
}

- (void)setImage:(UIImage *)image
{
	[self setImage:image forState:UIControlStateNormal];
}

- (void)setHighlighted:(BOOL)highlighted
{
	self.tintColor = (highlighted) ?
		[UIColor colorFromRGB:0x0079DB] : [UIColor colorFromRGB:0x0099EB];
	self.backgroundColor = (highlighted) ?
		[UIColor colorWithWhite:.995 alpha:1] : [UIColor colorWithWhite:.97 alpha:1];
}

@end


@interface TKPlaceDetailProductControl ()

@property (nonatomic, strong) TKPlaceDetailIconicButton *button;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailTextLabel;

@end


@implementation TKPlaceDetailProductControl

- (instancetype)init
{
	return [self initWithFrame:CGRectMake(0, 0, 320, 44)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
		[self tk_initialise];

	return self;
}

- (void)tk_initialise
{
	self.backgroundColor = [UIColor whiteColor];

	_button = [[TKPlaceDetailIconicButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
	_button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	_button.userInteractionEnabled = NO;
	[self addCenteredSubview:_button];
	_button.fromRightEdge = kTKPlaceDetailCellsSidePadding;

	CGRect f = self.bounds;
	f.size.width -= 3*kTKPlaceDetailCellsSidePadding + _button.width;
	f.origin.x = kTKPlaceDetailCellsSidePadding;
	f.origin.y = kTKPlaceDetailCellsSidePadding/2;

	self.textLabel = [[UILabel alloc] initWithFrame:f];
	self.textLabel.numberOfLines = 0;
	self.textLabel.textColor = [UIColor blackColor];
	self.textLabel.font = [UIFont lightSystemFontOfSize:13];
	self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self addSubview:_textLabel];

	self.detailTextLabel = [[UILabel alloc] initWithFrame:f];
	self.detailTextLabel.numberOfLines = 0;
	self.detailTextLabel.textColor = [UIColor lightGrayColor];
	self.detailTextLabel.font = [UIFont lightSystemFontOfSize:15];
	self.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self addSubview:_detailTextLabel];
}

- (void)setProduct:(TKReference *)product
{
	_product = product;

	[self setLinkTitle:product.title];

	NSMutableArray<NSString *> *flags = [NSMutableArray arrayWithCapacity:product.flags.count];

	if (product.price.floatValue)
		[flags addObject:[NSString stringWithFormat:@"$%.0f", product.price.floatValue+0.3]];

	if ([product.flags containsObject:@"bestseller"])
		[flags addObject:NSLocalizedString(@"Bestseller", @"TravelKit UI - Reference flag")];
	if ([product.flags containsObject:@"instant_confirmation"])
		[flags addObject:NSLocalizedString(@"Instant confirmation", @"TravelKit UI - Reference flag")];
	if ([product.flags containsObject:@"mobile_voucher"])
		[flags addObject:NSLocalizedString(@"Mobile voucher", @"TravelKit UI - Reference flag")];
	if ([product.flags containsObject:@"Private"])
		[flags addObject:NSLocalizedString(@"Private", @"TravelKit UI - Reference flag")];
	if ([product.flags containsObject:@"skip_the_line"])
		[flags addObject:NSLocalizedString(@"Skip the line", @"TravelKit UI - Reference flag")];

	if (flags.count) {
		NSString *text = [[flags componentsJoinedByString:@" • "] uppercaseString] ?: @"";

		_detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{
			NSForegroundColorAttributeName: [UIColor colorFromRGB:0xF84B3D],
			NSFontAttributeName: [UIFont systemFontOfSize:11],
			NSKernAttributeName: @1,
		}];
	}

//	NSString *imageName = @"";

	[self layoutSubviews];
}

- (void)setLinkTitle:(NSString *)title
{
	title = title ?: @"";
	title = [title uppercaseString];

	self.textLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{
		NSFontAttributeName: self.textLabel.font,
		NSForegroundColorAttributeName: self.textLabel.textColor,
		NSKernAttributeName: @1,
	}];
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	_textLabel.height = [_textLabel expandedSizeOfText].height;
	_detailTextLabel.height = [_detailTextLabel expandedSizeOfText].height;

	_detailTextLabel.top = _textLabel.bottom + 4;

	self.height = MAX(54, _detailTextLabel.bottom + kTKPlaceDetailCellsSidePadding/2);
}

- (void)setHighlighted:(BOOL)highlighted
{
	self.backgroundColor = (highlighted) ?
		[UIColor colorWithWhite:.97 alpha:1] : [UIColor whiteColor];
	_button.highlighted = highlighted;
}

@end


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
	self.textLabel.font = [UIFont lightSystemFontOfSize:16];
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
				NSFontAttributeName: [UIFont systemFontOfSize:self.textLabel.font.pointSize],
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
	self.layer.masksToBounds = NO;

	_pictureView = [[UIImageView alloc] initWithFrame:self.bounds];
	_pictureView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_pictureView.contentMode = UIViewContentModeScaleAspectFill;
	_pictureView.layer.masksToBounds = YES;
	[self addSubview:_pictureView];
}

- (void)setPlace:(TKPlace *)place
{
	_place = place;

	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		_pictureView.backgroundColor = [UIColor colorFromRGB:place.displayableHexColor];
	}];

	[[TravelKit sharedKit] mediaForPlaceWithID:place.ID completion:^(NSArray<TKMedium *> *media, NSError *error) {

		if (!media.count) return;

		[[NSOperationQueue new] addOperationWithBlock:^{

			__weak typeof(_pictureView) wpv = _pictureView;

			[wpv setImageWithMediumImage:media.firstObject size:CGSizeMake(640, 640) completion:^(UIImage *i) {

				CATransition *transition = [CATransition animation];
				transition.duration = .35f;
				transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
				transition.type = kCATransitionFade;
				transition.removedOnCompletion = YES;

				if (wpv.layer.animationKeys.count == 0)
					[wpv.layer addAnimation:transition forKey:nil];
			}];

		}];
	}];
}

- (void)updateWithVerticalOffset:(CGFloat)verticalOffset inset:(CGFloat)verticalInset
{
	CGRect f = self.bounds;
	f.origin.y = verticalOffset;
	f.size.height -= verticalOffset;
	_pictureView.frame = f;
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

	self.textLabel.font = [UIFont systemFontOfSize:16];
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

- (void)refreshContent
{
	NSMutableArray<NSString *> *outTags = [NSMutableArray arrayWithCapacity:_categories.count+_tags.count];

	for (NSString *c in _categories)
		[outTags addObject:c];

	for (TKPlaceTag *t in _tags)
		[outTags addObject:t.name ?: t.key];

	NSString *output = NSLocalizedString(@"Tags: %@", @"TravelKit Place Detail – Tags label");
	output = [NSString stringWithFormat:output, [outTags componentsJoinedByString:@" • "]];
	output = [output uppercaseString];

	self.textLabel.text = output;

	[self layoutSubviews];
}

- (void)setCategories:(NSArray<NSString *> *)categories
{
	_categories = categories.copy;
	[self refreshContent];
}

- (void)setTags:(NSArray<TKPlaceTag *> *)tags
{
	_tags = tags.copy;
	[self refreshContent];
}

@end


@implementation TKPlaceDetailLink

+ (instancetype)linkWithType:(TKPlaceDetailLinkType)type value:(id)value
{
	TKPlaceDetailLink *link = [TKPlaceDetailLink new];
	link.type = type;
	link.value = value;
	return link;
}

@end


@interface TKPlaceDetailLinkCell ()

@property (nonatomic, strong) TKPlaceDetailIconicButton *button;

@end


@implementation TKPlaceDetailLinkCell

+ (UITableViewCellStyle)tk_defaultStyle
{
	return UITableViewCellStyleSubtitle;
}

- (void)tk_initialise
{
	_button = [[TKPlaceDetailIconicButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
	_button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	_button.userInteractionEnabled = NO;
	[self addCenteredSubview:_button];
	_button.fromRightEdge = kTKPlaceDetailCellsSidePadding;

//	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//	self.accessoryView = [UIImageView imageViewWithImageNamed:@"disclosure-gray"];
	self.textLabel.textColor = [UIColor blackColor];
	self.textLabel.font = [UIFont lightSystemFontOfSize:13];
	self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
	self.detailTextLabel.textColor = [UIColor lightGrayColor];
	self.detailTextLabel.font = [UIFont lightSystemFontOfSize:15];
	self.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
}

- (void)setLink:(TKPlaceDetailLink *)link
{
	_link = link;

	NSString *title = @"Link";
	NSString *subtitle = nil;
//	NSString *imageName = @"";

	if (link.type == TKPlaceDetailLinkTypePhone) {
		title = NSLocalizedString(@"Phone number", @"TravelKit UI Detail label");
		subtitle = link.value;
	}
	else if (link.type == TKPlaceDetailLinkTypeEmail) {
		title = NSLocalizedString(@"Email address", @"TravelKit UI Detail label");
		subtitle = link.value;
	}
	else if (link.type == TKPlaceDetailLinkTypeReference) {
		TKReference *ref = link.value;
		title = ref.title;
		subtitle = ref.onlineURL.absoluteString;
		subtitle = [subtitle stringByReplacingOccurrencesOfString:@"http://" withString:@""];
		subtitle = [subtitle stringByReplacingOccurrencesOfString:@"https://" withString:@""];
	}

	[self setLinkTitle:title];
	self.detailTextLabel.text = subtitle;
}

- (void)setLinkTitle:(NSString *)title
{
	title = title ?: @"";
	title = [title uppercaseString];

	self.textLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{
		NSFontAttributeName: self.textLabel.font,
		NSForegroundColorAttributeName: self.textLabel.textColor,
		NSKernAttributeName: @1,
	}];
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	if (self.detailTextLabel.text.length) {
		self.textLabel.top -= 2;
		self.detailTextLabel.top += 2;
	}
//	else self.textLabel.top += 2;

	if (self.textLabel.right > _button.left)
		self.textLabel.width -= _button.width;
	if (self.detailTextLabel.right > _button.left)
		self.detailTextLabel.width -= _button.width;
}

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	_button.highlighted = highlighted;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:animated];
	_button.highlighted = highlighted;
}

@end


@implementation TKPlaceDetailProductsCell

- (void)setProducts:(NSArray<TKReference *> *)products
{
	_products = products.copy;

	[self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

	CGFloat maxY = 0;

	for (TKReference *prod in products)
	{
		if ([products indexOfObject:prod] > 2) break;

		TKPlaceDetailProductControl *pc = [[TKPlaceDetailProductControl alloc]
										   initWithFrame:self.contentView.bounds];
		pc.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		pc.product = prod;
		pc.top = maxY;
		maxY = pc.bottom;
		[self.contentView addSubview:pc];
		[pc addTarget:self action:@selector(productControlTapped:)
			forControlEvents:UIControlEventTouchUpInside];

		if (pc.top > 0) {
			UIView *sep = [[UIView alloc] initWithFrame:pc.bounds];
			sep.height = 0.5;
			sep.backgroundColor = [UIColor colorWithWhite:.74 alpha:1];
			sep.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			[pc addSubview:sep];
		}
	}

	if (products.count > 3) {

		UILabel *moreLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
		moreLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		moreLabel.height = 54;
		moreLabel.textAlignment = NSTextAlignmentCenter;
		moreLabel.textColor = [UIColor blackColor];
		moreLabel.font = [UIFont systemFontOfSize:15];
		moreLabel.text = [@"More" uppercaseString];
		moreLabel.top = maxY;
		[self.contentView addSubview:moreLabel];
		maxY = moreLabel.bottom;

		UIView *moreSep = [[UIView alloc] initWithFrame:moreLabel.bounds];
		moreSep.height = 0.5;
		moreSep.backgroundColor = [UIColor colorFromRGB:0xD9D9D9];
		moreSep.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[moreLabel addSubview:moreSep];

		[moreLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreTapped)]];
		moreLabel.userInteractionEnabled = YES;
	}

	self.height = maxY;
}

- (IBAction)productControlTapped:(TKPlaceDetailProductControl *)sender
{
	TKReference *product = sender.product;

	if (product)
		if (_productTappingBlock)
			_productTappingBlock(product);
}

- (IBAction)moreTapped
{
	if (_productsListTappingBlock)
		_productsListTappingBlock();
}

@end
