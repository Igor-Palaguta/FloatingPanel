#import "UIView+FloatingPanel.h"

@implementation UIView (FloatingPanel)

-(void)fp_addSubviewAndScale:( UIView* )subview_
{
   [ self fp_addSubviewAndScale: subview_
               autoresizingMask: UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ];
}

-(void)fp_addSubviewAndScale:( UIView* )subview_
            autoresizingMask:( UIViewAutoresizing )mask_
{
   subview_.frame = self.bounds;
   subview_.autoresizingMask = mask_;
   [ self addSubview: subview_ ];
}

-(void)fp_applyAppearances
{
   UIView* superview_ = [ self superview ];

   UIWindow* fake_window_ = [ UIWindow new ];
   [ fake_window_ addSubview: self ];

   [ superview_ addSubview: self ];
}

-(void)fp_setTopBorderColor:( UIColor* )border_color_
                borderWidth:( CGFloat )border_width_
{
   UIView* line_view_ = [ UIView new ];
   line_view_.backgroundColor = border_color_;
   line_view_.frame = CGRectMake( 0.f, 0.f, self.bounds.size.width, border_width_ );
   line_view_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
   [ self addSubview: line_view_ ];
}

+(void)fp_animateWithCondition:( BOOL )condition_
                      duration:( NSTimeInterval )duration_
                  initialSetup:( FPAnimationTransitionBlock )transition_
                    animations:( FPAnimationTransitionBlock )animations_
                    completion:( FPAnimationCompletionBlock )completion_
{
   BOOL animation_enabled_ = [ UIView areAnimationsEnabled ];
   if ( !condition_ )
      [ UIView setAnimationsEnabled: NO ];
   
   if ( condition_ && transition_ )
      transition_();
   
   [ UIView animateWithDuration: duration_
                     animations: animations_
                     completion: completion_ ];
   
   if ( !condition_ )
      [ UIView setAnimationsEnabled: animation_enabled_ ];
}

+(void)fp_animateWithCondition:( BOOL )condition_
                      duration:( NSTimeInterval )duration_
                    animations:( FPAnimationTransitionBlock )animations_
                    completion:( FPAnimationCompletionBlock )completion_
{
   [ self fp_animateWithCondition: condition_
                         duration: duration_
                     initialSetup: nil
                       animations: animations_
                       completion: completion_ ];
}

+(void)fp_animateWithCondition:( BOOL )condition_
                      duration:( NSTimeInterval )duration_
                    animations:( FPAnimationTransitionBlock )animations_
{
   [ self fp_animateWithCondition: condition_
                         duration: duration_
                       animations: animations_
                       completion: nil ];
}

@end
