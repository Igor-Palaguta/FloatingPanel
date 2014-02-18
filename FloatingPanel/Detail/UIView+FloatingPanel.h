#import <UIKit/UIKit.h>

typedef void (^FPAnimationTransitionBlock)();
typedef void (^FPAnimationCompletionBlock)( BOOL finished_ );

@interface UIView (FloatingPanel)

-(void)fp_addSubviewAndScale:( UIView* )subview_;

-(void)fp_addSubviewAndScale:( UIView* )subview_
            autoresizingMask:( UIViewAutoresizing )mask_;

-(void)fp_applyAppearances;

-(void)fp_setTopBorderColor:( UIColor* )border_color_
                borderWidth:( CGFloat )border_width_;

+(void)fp_animateWithCondition:( BOOL )condition_
                      duration:( NSTimeInterval )duration_
                  initialSetup:( FPAnimationTransitionBlock )transition_
                    animations:( FPAnimationTransitionBlock )animations_
                    completion:( FPAnimationCompletionBlock )completion_;

+(void)fp_animateWithCondition:( BOOL )condition_
                      duration:( NSTimeInterval )duration_
                    animations:( FPAnimationTransitionBlock )animations_
                    completion:( FPAnimationCompletionBlock )completion_;

+(void)fp_animateWithCondition:( BOOL )condition_
                      duration:( NSTimeInterval )duration_
                    animations:( FPAnimationTransitionBlock )animations_;

@end
