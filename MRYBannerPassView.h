@class PKPassFooterView;
@class PKPassPresentationContext;
@class PKPassLibrary;
@class PKPass;

@interface MRYBannerPassView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>
{
	NSMutableArray<UIImageView*>* _chevronViews;
	UICollectionView* _collectionView;
	PKPassFooterView* _paymentView;
	PKPassPresentationContext* _context;
	NSArray<PKPass*>* _passes;
	UIVisualEffectView* _blurView;
}
-(instancetype)initWithPasses:(NSArray<PKPass*>*)passes;
-(void)setupBlurView;
-(void)setupChevronViews;
-(void)setupCollectionView;
-(void)setupPaymentView;
-(void)pageDidChange:(NSUInteger)pageNo;
@end