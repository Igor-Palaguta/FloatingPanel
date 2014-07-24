#import <UIKit/UIKit.h>

@interface FPFloatingOverlayView : UIView

@property ( nonatomic, strong ) UIColor* overlayColor UI_APPEARANCE_SELECTOR;
@property ( nonatomic, assign ) CGFloat headerHeight UI_APPEARANCE_SELECTOR;
@property ( nonatomic, strong ) UIImage* headerImage UI_APPEARANCE_SELECTOR;
@property ( nonatomic, strong ) UIColor* borderColor UI_APPEARANCE_SELECTOR;
@property ( nonatomic, assign ) CGFloat borderWidth UI_APPEARANCE_SELECTOR;

+(void)setDefaultBackgroundViewClass:( Class )class_;

@end


typedef void (^FPFloatingViewControllerCompletionBlock)();

@interface UIViewController (FPFloatingViewController)

-(void)presentFloatingViewControllerAnimated:( BOOL )animated_;

-(void)presentFloatingViewControllerAnimated:( BOOL )animated_
                                  completion:( FPFloatingViewControllerCompletionBlock )completion_;

-(void)presentFloatingViewControllerAnimated:( BOOL )animated_
                                 windowLevel:( UIWindowLevel )level_
                                  completion:( FPFloatingViewControllerCompletionBlock )completion_;

-(void)dismissFloatingViewControllerAnimated:( BOOL )animated_
                                  completion:( FPFloatingViewControllerCompletionBlock )completion_;

-(void)dismissFloatingViewControllerAnimated:( BOOL )animated_;

+(BOOL)isFloatingViewControllerVisible;
+(void)dismissVisibleFloatingViewControllerAnimated:( BOOL )animated_;

@end


@interface UIViewController (FPFloatingViewController_Customize)

-(CGFloat)fp_bottomMarginInFloatingViewController;
-(CGFloat)fp_contentHeightInFloatingViewController;

-(BOOL)fp_shouldShowFloatingHeader;
-(BOOL)fp_shouldAddContentBackground;

@end
