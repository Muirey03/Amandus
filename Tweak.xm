#import "interfaces.h"
#import "globals.h"
#import "funcs.h"
#import "MRYBannerPassView.h"

/* Present new banner view and remove old view: */
%hook PKPassGroupsViewController
%property (nonatomic, strong) MRYBannerPassView* mryBannerView;
%property (nonatomic, strong) NSLayoutConstraint* bannerTopConstraint;
%property (nonatomic, strong) UITapGestureRecognizer* dismissTapGesture;

-(void)loadView
{
	%orig;

	self.view.backgroundColor = [UIColor colorWithWhite:0. alpha:darkeningAlpha];
	self.groupStackView.hidden = YES;

	MRYBannerPassView* bannerView = [[MRYBannerPassView alloc] initWithPasses:[self fetchPasses]];
	self.mryBannerView = bannerView;
	[self.view addSubview:bannerView];

	bannerView.translatesAutoresizingMaskIntoConstraints = NO;
	[bannerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:xPadding].active = YES;
	[bannerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:xPadding * -1].active = YES;
	[bannerView.heightAnchor constraintEqualToConstant:bannerHeight].active = YES;
	self.bannerTopConstraint = [bannerView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:bannerHeight * -1];
	self.bannerTopConstraint.active = YES;

	if (!self.dismissTapGesture)
	{
		self.dismissTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
		self.dismissTapGesture.delegate = (id<UIGestureRecognizerDelegate>)self;
		[self.view addGestureRecognizer:self.dismissTapGesture];
	}
}

%new
-(NSArray<PKPass*>*)fetchPasses
{
	PKGroupsController* groupsController = MSHookIvar<PKGroupsController*>(self, "_groupsController");
	NSMutableArray* passes = [NSMutableArray new];
	NSArray* groups = [groupsController groups];
	for (PKGroup* group in groups)
	{
		if (![group containsPasses] || [group passes].count == 0)
			continue;
		NSMutableArray* groupPasses = [[group passes] mutableCopy];
		rotateToIndex(groupPasses, [group frontmostPassIndex]);
		[passes addObjectsFromArray:groupPasses];
	}
	//rotate to default pass:
	PKPaymentService* paymentService = MSHookIvar<PKPaymentService*>(self, "_paymentService");
	NSString* defaultPassID = paymentService.defaultPaymentPassUniqueIdentifier;
	PKPass* defaultPass = [[%c(PKPassLibrary) sharedInstance] passWithUniqueID:defaultPassID];
	NSUInteger startingIndex = (defaultPass && [passes containsObject:defaultPass]) ? [passes indexOfObject:defaultPass] : 0;
	rotateToIndex(passes, startingIndex);
	return passes;
}

%new
-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    return ![touch.view isDescendantOfView:self.mryBannerView] || touch.view == self.view;
}

%new
-(void)handleTap:(UITapGestureRecognizer*)gesture
{
	[[NSNotificationCenter defaultCenter] postNotificationName:dismissNotificationName object:nil];
}

-(void)presentOffscreenAnimated:(BOOL)arg1 split:(BOOL)arg2 withCompletionHandler:(id)arg3
{
	NSInteger state = MSHookIvar<NSInteger>(self, "_presentationState");
	if (state == 1)
		[self beginPresentation];
	else
		[self beginDismissal];
	%orig;
}

%new
-(void)beginPresentation
{
	[UIView animateWithDuration:.3 animations:^{
        self.bannerTopConstraint.constant = self.view.safeAreaInsets.top + yPadding;
        [self.view layoutIfNeeded];
    }];
}

%new
-(void)beginDismissal
{
	[UIView animateWithDuration:.2 animations:^{
        self.bannerTopConstraint.constant = bannerHeight * -1;
        [self.view layoutIfNeeded];
    }];
}
%end

/* Fix layout and label in payment view: */
%hook PKPassPaymentPayStateView
-(void)setFrame:(CGRect)frame
{
	frame = CGRectMake(0., 0., self.superview.frame.size.width, self.superview.frame.size.height);
	%orig;
}

-(void)setNeedsLayout
{
	%orig;
	self.label.font = [UIFont systemFontOfSize:15.];
	self.label.adjustsFontSizeToFitWidth = YES;
	self.label.textColor = textColor();
	self.labelAlpha = 1.;
}
%end

%hook PKPassPaymentContainerView
-(UIButton*)_filledButtonWithTitle:(NSString*)title
{
	UIButton* btn = %orig;
	UIFont* font = [UIFont systemFontOfSize:15.];
	btn.titleLabel.numberOfLines = 0;
	btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	btn.titleLabel.font = font;

	CGRect boundingRect = [title boundingRectWithSize:CGSizeMake(paymentViewWidth - (passcodeBtnInsets * 2.), 0.) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:nil];
	btn.frame = CGRectMake(0., 0., paymentViewWidth - (passcodeBtnInsets * 2.), boundingRect.size.height + (passcodeBtnInsets * 2.));

	btn.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[btn.titleLabel.leadingAnchor constraintEqualToAnchor:btn.leadingAnchor].active = YES;
	[btn.titleLabel.trailingAnchor constraintEqualToAnchor:btn.trailingAnchor].active = YES;
	[btn.titleLabel.topAnchor constraintEqualToAnchor:btn.topAnchor].active = YES;
	[btn.titleLabel.bottomAnchor constraintEqualToAnchor:btn.bottomAnchor].active = YES;

	return btn;
}
%end

%hook PKPaymentRemoteAlertViewController
%property (nonatomic, strong) id mryObserver;

-(instancetype)init
{
	if ((self = %orig))
	{
		self.mryObserver = [[NSNotificationCenter defaultCenter] addObserverForName:dismissNotificationName object:nil queue:nil usingBlock:^(NSNotification* note){
			[self _dismissForSource:1 completion:nil];
		}];
	}
	return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self.mryObserver];
	%orig;
}
%end

//prevent old footer from aquiring the session
%hook PKPassFooterView
-(void)_startContactlessInterfaceSessionWithContext:(id)arg1 sessionAvailable:(/*^block*/id)arg2 sessionUnavailable:(/*^block*/id)arg3
{
	if (self.tag == mryFooterViewTag)
		%orig;
}
%end

//only one session is allowed at a time
//this means we need to invalidate the previous session before we can select a new card (which in turns creates a new session)
//this was such a pain-in-the-ass to figure out...
//(this shouldn't really be done with a hook, but I couldn't get it working any other way)
%hook PKContactlessInterfaceSession
PKContactlessInterfaceSession* currentSession = nil;
-(instancetype)initWithInternalSession:(id)arg1 targetQueue:(id)arg2
{
	if (currentSession)
		[currentSession invalidateSession];
	if ((self = %orig))
		currentSession = self;
	return self;
}
%end

//hide bottom bar
%hook _PKUIKVisibilityBackdropView
-(void)didMoveToWindow
{
	%orig;
	[(UIView*)self removeFromSuperview];
}
%end
