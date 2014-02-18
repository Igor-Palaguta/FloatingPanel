#import <UIKit/UIKit.h>

@interface UIWindow (FloatingPanel)

+(UIWindow*)currentFloatingWindow;

+(void)pushFloatingWindow:( UIWindow* )window_;
+(void)popFloatingWindow;

@end
