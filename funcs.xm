#import "funcs.h"
#import "interfaces.h"
#import "globals.h"
#import <Cephei/HBPreferences.h>

/* DEBUG: */
// (This was useful for dumping the view heirarchy of PassbookUIService
// so I thought I'd leave it in the source ¯\_(ツ)_/¯)
void printViewHeirarchy(UIView* view, NSUInteger indentation)
{
    NSString* const path = @"/var/mobile/Documents/heirarchy.txt";
	NSString* str = [@"" stringByPaddingToLength:indentation withString:@" " startingAtIndex:0];
	str = [str stringByAppendingFormat:@"%@\n", [view class]];
    NSMutableString* contents = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    contents = contents ?: [NSMutableString new];
    [contents appendString:str];
    NSError* err;
    [contents writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&err];
	for (UIView* v in view.subviews)
		printViewHeirarchy(v, indentation + 2);
}
/* END DEBUG */

UIImage* UIKitImage(NSString* imgName)
{
    NSString* artworkPath = @"/System/Library/PrivateFrameworks/UIKitCore.framework/Artwork.bundle";
    NSBundle* artworkBundle = [NSBundle bundleWithPath:artworkPath];
    if (!artworkBundle)
    {
        artworkPath = @"/System/Library/Frameworks/UIKit.framework/Artwork.bundle";
        artworkBundle = [NSBundle bundleWithPath:artworkPath];
    }
    UIImage* img = [UIImage imageNamed:imgName inBundle:artworkBundle];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

BOOL PreferencesBool(NSString* key, BOOL fallback, NSString* domain)
{
	static HBPreferences* prefs = nil;
	static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        prefs = [[HBPreferences alloc] initWithIdentifier:domain];
    });
    id value = [prefs objectForKey:key];
    return value ? [value boolValue] : fallback;
}

UIColor* backgroundColor()
{
	CGFloat alpha = PreferencesBool(@"isTranslucent", YES) ? translucencyAlpha : 1.;
	return PreferencesBool(@"darkMode", NO) ? [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:alpha] : [UIColor colorWithWhite:1. alpha:alpha];
}

UIColor* textColor()
{
	return PreferencesBool(@"darkMode", NO) ? [UIColor colorWithRed:0.922 green:0.922 blue:0.961 alpha:1.] : [UIColor darkGrayColor];
}

void rotateToIndex(NSMutableArray* arr, NSUInteger index)
{
    if (index < arr.count)
    {
        NSRange range = NSMakeRange(0, index);
        [arr addObjectsFromArray:[arr subarrayWithRange:range]];
        [arr removeObjectsInRange:range];
    }
}
