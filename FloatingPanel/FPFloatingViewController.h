#import <UIKit/UIKit.h>

typedef void (^FPFloatingViewControllerCompletionBlock)();

@interface FPFloatingOverlayView : UIView

@property ( nonatomic, strong ) UIColor* overlayColor UI_APPEARANCE_SELECTOR;
@property ( nonatomic, assign ) CGFloat headerHeight UI_APPEARANCE_SELECTOR;
@property ( nonatomic, strong ) UIImage* headerImage UI_APPEARANCE_SELECTOR;
@property ( nonatomic, strong ) UIColor* borderColor UI_APPEARANCE_SELECTOR;
@property ( nonatomic, assign ) CGFloat borderWidth UI_APPEARANCE_SELECTOR;
@property ( nonatomic, strong ) Class backgroundViewClass UI_APPEARANCE_SELECTOR;

@end

@interface UIViewController (FPFloatingViewController)

-(void)presentFloatingViewControllerAnimated:( BOOL )animated_
                                  completion:( FPFloatingViewControllerCompletionBlock )completion_;

-(void)dismissFloatingViewControllerAnimated:( BOOL )animated_
                                  completion:( FPFloatingViewControllerCompletionBlock )completion_;

-(void)presentFloatingViewControllerAnimated:( BOOL )animated_;

-(void)dismissFloatingViewControllerAnimated:( BOOL )animated_;

@end
