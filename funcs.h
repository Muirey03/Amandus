@class PKContactlessInterfaceSession;
#define PREFS_DOMAIN @"com.muirey03.amandus"

void printViewHeirarchy(UIView* view, NSUInteger indentation); //DEBUG
UIImage* UIKitImage(NSString* imgName);
BOOL PreferencesBool(NSString* key, BOOL fallback, NSString* domain = PREFS_DOMAIN);
UIColor* backgroundColor(void);
UIColor* textColor(void);
