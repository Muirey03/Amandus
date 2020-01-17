@class MRYBannerPassView;
@class PKPass;
@class PKGroup;

@interface PKPassGroupsViewController : UIViewController
@property (nonatomic,retain,readonly) UIView* groupStackView;
@property (nonatomic, strong) MRYBannerPassView* mryBannerView;
@property (nonatomic, strong) NSLayoutConstraint* bannerTopConstraint;
@property (nonatomic, strong) UITapGestureRecognizer* dismissTapGesture;
//%new
-(NSArray<PKPass*>*)fetchPasses;
-(void)beginPresentation;
-(void)beginDismissal;
@end

@interface PKPassPresentationContext : NSObject
@property (assign,getter=wantsPersistentCardEmulation,nonatomic) BOOL persistentCardEmulation;
+(instancetype)contextWithAnimation:(BOOL)animated;
@end

@interface PKPassLibrary : NSObject
+(instancetype)sharedInstance;
-(NSArray<PKPass*>*)passesOfType:(NSUInteger)type;
-(PKPass*)passWithUniqueID:(NSString*)passID;
@end

@interface PKImage : NSObject
@property (nonatomic,readonly) CGImageRef imageRef;
@end

@interface PKPass : NSObject
@property (nonatomic,readonly) PKImage* frontFaceImage;
@end

@interface PKPassView : UIView
-(instancetype)initWithPass:(PKPass*)pass;
@end

@interface PKPassFooterView : UIView
@property (nonatomic,retain) PKPassView* passView;
-(instancetype)initWithPassView:(PKPassView*)passView state:(NSInteger)state context:(PKPassPresentationContext*)context;
-(void)configureForState:(NSUInteger)state context:(PKPassPresentationContext*)context passView:(PKPassView*)passView;
-(void)didBecomeVisibleAnimated:(BOOL)animated;
-(void)_acquireContactlessInterfaceSessionWithSessionToken:(unsigned long long)arg1 handler:(/*^block*/id)arg2;
@end

@interface PKPassPaymentContainerView : UIView
@end

@interface PKPassPaymentPayStateView : UIView
@property (nonatomic,readonly) UILabel* label;
@property (assign,nonatomic) CGFloat labelAlpha;
@end

@interface UIImage (Private)
+(instancetype)imageNamed:(NSString*)name inBundle:(NSBundle*)bundle;
@end

@interface PKPaymentRemoteAlertViewController : UIViewController
@property (nonatomic, strong) id mryObserver;
-(void)_dismissForSource:(NSUInteger)source completion:(/*^block*/id)completion;
@end

@interface PKPaymentSession : NSObject
-(void)invalidateSession;
@end

@interface PKContactlessInterfaceSession : PKPaymentSession
+(instancetype)currentSession;
@end

@interface PKPaymentSessionHandle : NSObject
-(void)invalidateSession;
-(BOOL)isFirstInQueue;
@end

@interface PKGroupsController : NSObject
-(NSArray<PKGroup*>*)groups;
@end

@interface PKGroup : NSObject
-(BOOL)containsPasses;
-(NSArray<PKPass*>*)passes;
-(NSUInteger)frontmostPassIndex;
@end

@interface PKPaymentService : NSObject
@property (nonatomic,retain) NSString* defaultPaymentPassUniqueIdentifier;
@end
