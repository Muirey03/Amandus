#import "MRYBannerPassView.h"
#import "globals.h"
#import "interfaces.h"
#import "funcs.h"
#import "MRYCardCell.h"

@implementation MRYBannerPassView
-(instancetype)init
{
	if ((self = [super init]))
	{
		_context = [%c(PKPassPresentationContext) contextWithAnimation:NO];
		_library = [%c(PKPassLibrary) sharedInstance];
		_passes = [_library passesOfType:1]; //type 1 is payment pass

		self.backgroundColor = backgroundColor();
		self.clipsToBounds = YES;
		self.layer.cornerRadius = bannerCornerRadius;

		if (PreferencesBool(@"isTranslucent", YES))
			[self setupBlurView];

		//create chevron views:
		if (_passes.count > 1)
			[self setupChevronViews];

		//create collection view:
		[self setupCollectionView];

		//create payment view:
		[self setupPaymentView];
		[self pageDidChange:0];
	}
	return self;
}

-(void)setupBlurView
{
	UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:PreferencesBool(@"darkMode", NO) ? UIBlurEffectStyleDark : UIBlurEffectStyleLight];
	_blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	[self addSubview:_blurView];

	_blurView.translatesAutoresizingMaskIntoConstraints = NO;
	[_blurView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
	[_blurView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
	[_blurView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
	[_blurView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
}

-(void)setupChevronViews
{
	_chevronViews = [[NSMutableArray alloc] initWithCapacity:2];
	for (unsigned i = 0; i < 2; i++)
	{
		UIImageView* chevronView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[_chevronViews addObject:chevronView];
		chevronView.contentMode = UIViewContentModeScaleAspectFit;
		chevronView.tintColor = textColor();
		[self addSubview:chevronView];
		chevronView.translatesAutoresizingMaskIntoConstraints = NO;
		[chevronView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:cardInsets].active = YES;
		[chevronView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:paymentViewWidth * -1].active = YES;
	}
	[_chevronViews[0].topAnchor constraintEqualToAnchor:self.topAnchor constant:chevronPadding].active = YES;
	[_chevronViews[0].bottomAnchor constraintEqualToAnchor:self.topAnchor constant:cardInsets].active = YES;
	[_chevronViews[1].bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:chevronPadding * -1].active = YES;
	[_chevronViews[1].topAnchor constraintEqualToAnchor:self.bottomAnchor constant:cardInsets * -1].active = YES;

	_chevronViews[0].image = UIKitImage(@"UIButtonBarArrowUp");
	_chevronViews[1].image = UIKitImage(@"UIButtonBarArrowDown");
}

-(void)setupCollectionView
{
	UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
	_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
	_collectionView.dataSource = self;
	_collectionView.delegate = self;
	_collectionView.pagingEnabled = YES;
	[_collectionView registerClass:[MRYCardCell class] forCellWithReuseIdentifier:@"MRYCardCell"];
	_collectionView.backgroundColor = UIColor.clearColor;
	[self addSubview:_collectionView];

	_collectionView.translatesAutoresizingMaskIntoConstraints = NO;
	[_collectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:cardInsets].active = YES;
	[_collectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:paymentViewWidth * -1].active = YES;
	[_collectionView.topAnchor constraintEqualToAnchor:self.topAnchor constant:cardInsets + chevronPadding].active = YES;
	[_collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:(cardInsets + chevronPadding) * -1].active = YES;
}

-(void)setupPaymentView
{
	_paymentView = [[%c(PKPassFooterView) alloc] initWithPassView:nil state:1 context:_context];
	_paymentView.tag = mryFooterViewTag;
	_paymentView.clipsToBounds = YES;
	[self addSubview:_paymentView];

	_paymentView.translatesAutoresizingMaskIntoConstraints = NO;
	[_paymentView.leadingAnchor constraintEqualToAnchor:self.trailingAnchor constant:paymentViewWidth * -1].active = YES;
	[_paymentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
	[_paymentView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
	[_paymentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;

	[_paymentView didBecomeVisibleAnimated:NO];
}

-(void)pageDidChange:(NSUInteger)pageNo
{
	dispatch_async(dispatch_get_main_queue(), ^{
		MRYCardCell* cell = (MRYCardCell*)[self collectionView:_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:pageNo inSection:0]];
		[_paymentView configureForState:1 context:_context passView:cell.passView];
	});
}

#pragma mark UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
	return _passes.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
	MRYCardCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MRYCardCell" forIndexPath:indexPath];
	[cell configureForPass:_passes[indexPath.row]];
	return cell;
}

-(CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}

-(CGFloat)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	return 0.;
}

#pragma mark UICollectionViewDelegate

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	static NSUInteger oldPageNo = 0;
	CGFloat pageF = scrollView.contentOffset.y / scrollView.frame.size.height;
	NSUInteger pageNo = round(pageF);
	const CGFloat scrollThreshold = 0.01;
	if (fabs(pageF - pageNo) < scrollThreshold && pageNo != oldPageNo)
	{
		oldPageNo = pageNo;
		[self pageDidChange:pageNo];
	}
}
@end
