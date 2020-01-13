@class PKPass;
@class PKPassView;

@interface MRYCardCell : UICollectionViewCell
{
	UIImageView* _imageView;
}
@property (nonatomic, readonly, strong) PKPass* pass;
@property (nonatomic, readonly, strong) PKPassView* passView;
-(void)configureForPass:(PKPass*)pass;
@end
