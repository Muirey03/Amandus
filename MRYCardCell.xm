#import "MRYCardCell.h"
#import "interfaces.h"
#import "globals.h"

@implementation MRYCardCell
-(instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		const CGFloat padding = 2.;
		_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, padding, frame.size.width, frame.size.height - (padding * 2))];
		_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self.contentView addSubview:_imageView];
	}
	return self;
}

-(void)configureForPass:(PKPass*)pass
{
	_pass = pass;
	_passView = [[%c(PKPassView) alloc] initWithPass:pass];
	_imageView.image = [[UIImage alloc] initWithCGImage:_pass.frontFaceImage.imageRef];
}
@end
