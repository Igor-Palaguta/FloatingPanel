#import <UIKit/UIKit.h>

@interface UIWindow (FloatingPanel)

+(UIWindow*)fp_currentFloatingWindow;

+(void)fp_pushFloatingWindow:( UIWindow* )window_;
+(void)fp_popFloatingWindow;

@end
