#import "FPFloatingViewController.h"

#import "UIWindow+FloatingPanel.h"
#import "UIView+FloatingPanel.h"

#import <KeyboardHandler/NSObject+KeyboardHandler.h>

static CGFloat FPDefaultAnimationTime = 0.3f;
static Class FPDefaultBackgroundViewClass = nil;

@implementation FPFloatingOverlayView

@synthesize overlayColor;
@synthesize headerHeight;
@synthesize headerImage;
@synthesize borderColor;
@synthesize borderWidth;

+(void)load
{
   @autoreleasepool
   {
      FPFloatingOverlayView* appearance_ = [ FPFloatingOverlayView appearance ];
      [ appearance_ setHeaderHeight: 50.f ];
      [ appearance_ setOverlayColor: [ UIColor colorWithWhite: 0.f alpha: 0.2f ] ];
      FPDefaultBackgroundViewClass = [ UIView class ];
   }
}

+(void)setDefaultBackgroundViewClass:( Class )class_
{
   FPDefaultBackgroundViewClass = class_;
}

+(Class)defaultBackgroundViewClass
{
   return FPDefaultBackgroundViewClass;
}

@end

@interface FPFloatingViewController : UIViewController< UIGestureRecognizerDelegate >

@property ( nonatomic, strong ) UIViewController* contentViewController;

@end

@interface FPFloatingViewController ()

@property ( nonatomic, strong ) FPFloatingOverlayView* overlayView;
@property ( nonatomic, weak ) UIView* floatingView;
@property ( nonatomic, weak ) UIView* headerView;
@property ( nonatomic, weak ) UIScrollView* contentView;

@end

@implementation FPFloatingViewController

@synthesize overlayView = _overlayView;
@synthesize floatingView;
@synthesize headerView;
@synthesize contentView;
@synthesize contentViewController = _contentViewController;

-(UIColor*)overlayColorWithVisiblePart:( CGFloat )visible_part_
{
   CGFloat alpha_ = CGColorGetAlpha( self.overlayView.overlayColor.CGColor );
   return [ self.overlayView.overlayColor colorWithAlphaComponent: alpha_ * visible_part_ ];
}

-(void)moveToYOrigin:( CGFloat )origin_
            animated:( BOOL )animated_
                hide:( BOOL )hide_
          completion:( FPFloatingViewControllerCompletionBlock )completion_
{
   CGFloat offset_ = fabsf( origin_ - self.floatingView.bounds.origin.y );
   [ UIView fp_animateWithCondition: animated_
                           duration: FPDefaultAnimationTime * ( offset_ / self.floatingView.bounds.size.height )
                         animations: ^()
    {
       CGRect floating_rect_ = self.floatingView.frame;
       floating_rect_.origin.y = origin_;
       self.floatingView.frame = floating_rect_;
       CGFloat visible_height_ = CGRectGetMaxY( self.view.bounds ) - CGRectGetMinY( floating_rect_ );
       
       CGFloat visible_part_ = visible_height_ == 0.f ? 0.f : visible_height_ / CGRectGetMaxY( self.floatingView.bounds );
       
       [ UIWindow fp_currentFloatingWindow ].backgroundColor = [ self overlayColorWithVisiblePart: visible_part_ ];
    }
                      completion: ^( BOOL result_ )
    {
       if ( hide_ )
       {
          [ UIWindow fp_popFloatingWindow ];
       }

       if ( completion_ )
       {
          completion_();
       }
    }];
}

-(void)dismissFloatingViewController:( UIViewController* )controller_
                            animated:( BOOL )animated_
                          completion:( FPFloatingViewControllerCompletionBlock )completion_
{
   if ( self.contentViewController != controller_ )
      return;

   [ self moveToYOrigin: CGRectGetMaxY( self.view.bounds )
               animated: animated_
                   hide: YES
             completion: completion_ ];
}

-(void)didPanHeader:( UIPanGestureRecognizer* )pan_recognizer_
{
   CGFloat y_origin_ = 0.f;

   BOOL hide_controller_ = NO;
   if ( pan_recognizer_.state == UIGestureRecognizerStateEnded )
   {
      CGPoint velocity_ = [ pan_recognizer_ velocityInView: self.headerView ];
      hide_controller_ = velocity_.y > 0.f;
      y_origin_ = hide_controller_
         ? CGRectGetMaxY( self.view.bounds )
         : self.view.bounds.size.height - self.floatingView.bounds.size.height;
   }
   else if ( [ pan_recognizer_ locationInView: self.view ].y >= self.view.bounds.size.height - self.floatingView.bounds.size.height )
   {
      y_origin_ = [ pan_recognizer_ locationInView: self.view ].y;
   }
   else
   {
      return;
   }

   [ self moveToYOrigin: y_origin_ animated: YES hide: hide_controller_ completion: nil ];
}

-(void)dismissWithGesture:( UITapGestureRecognizer* )tap_recognizer_
{
   [ self dismissFloatingViewController: self.contentViewController animated: YES completion: nil ];
}

-(FPFloatingOverlayView*)overlayView
{
   if ( !_overlayView )
   {
      _overlayView = [ FPFloatingOverlayView new ];
      [ _overlayView fp_applyAppearances ];
   }
   return _overlayView;
}

-(void)loadView
{
   self.overlayView.frame = [ UIScreen mainScreen ].bounds;
   
   UITapGestureRecognizer* tap_recognizer_ = [ [ UITapGestureRecognizer alloc ] initWithTarget: self
                                                                                        action: @selector(dismissWithGesture:) ];

   tap_recognizer_.delegate = self;

   [ self.overlayView addGestureRecognizer: tap_recognizer_ ];

   self.view = self.overlayView;
   self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

   UIView* floating_view_ = [ [ UIView alloc ] initWithFrame: self.view.bounds ];
   if ( [ self.contentViewController fp_shouldAddContentBackground ] )
   {
      [ floating_view_ fp_addSubviewAndScale: [ [ FPFloatingOverlayView defaultBackgroundViewClass ] new ] ];
      [ floating_view_ fp_setTopBorderColor: self.overlayView.borderColor
                                borderWidth: self.overlayView.borderWidth ];
   }

   [ self.view fp_addSubviewAndScale: floating_view_ ];
   self.floatingView = floating_view_;

   CGRect header_rect_ = CGRectZero;
   CGRect content_rect_ = CGRectZero;
   CGRectDivide( floating_view_.bounds, &header_rect_, &content_rect_, self.overlayView.headerHeight, CGRectMinYEdge );

   UIView* header_view_ = [ [ UIView alloc ] initWithFrame: header_rect_ ];

   header_view_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
   header_view_.backgroundColor = [ UIColor clearColor ];
   
   UIPanGestureRecognizer* pan_recognizer_ = [ [ UIPanGestureRecognizer alloc ] initWithTarget: self
                                                                                        action: @selector(didPanHeader:) ];

   UITapGestureRecognizer* header_tap_recognizer_ = [ [ UITapGestureRecognizer alloc ] initWithTarget: self
                                                                                               action: @selector(dismissWithGesture:) ];

   header_view_.gestureRecognizers = @[pan_recognizer_, header_tap_recognizer_];

   [ self.floatingView addSubview: header_view_ ];
   self.headerView = header_view_;

   if ( self.overlayView.headerImage )
   {
      UIImageView* floating_image_view_ = [ [ UIImageView alloc ] initWithImage: self.overlayView.headerImage ];
      floating_image_view_.contentMode = UIViewContentModeCenter;
      [ self.headerView fp_addSubviewAndScale: floating_image_view_ ];
   }

   UIScrollView* content_view_ = [ [ UIScrollView alloc ] initWithFrame: content_rect_ ];
   content_view_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
   content_view_.backgroundColor = [ UIColor clearColor ];
   [ content_view_ fp_addSubviewAndScale: self.contentViewController.view autoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ];
   [ self.floatingView addSubview: content_view_ ];
   self.contentView = content_view_;
}

-(void)moveUp
{
   CGRect floating_rect_ = self.view.bounds;
   CGFloat content_height_ = [ self.contentViewController fp_contentHeightInFloatingViewController ];
   if ( content_height_ == 0.f )
   {
      self.floatingView.frame = floating_rect_;
   }
   else
   {
      floating_rect_.size.height = content_height_ + self.overlayView.headerHeight;
      floating_rect_.origin.y = self.view.bounds.size.height - floating_rect_.size.height;
      self.floatingView.frame = floating_rect_;
   }
}

-(void)moveDown
{
   CGRect floating_rect_ = self.floatingView.frame;
   floating_rect_.origin.y = self.view.bounds.size.height;
   self.floatingView.frame = floating_rect_;
}

-(void)relayoutFloatingView
{
   [ self moveUp ];

   if ( ![ self.contentViewController fp_shouldShowFloatingHeader ] )
   {
      self.contentView.frame = self.floatingView.bounds;
      self.headerView.hidden = YES;
   }

   CGFloat content_height_ = [ self.contentViewController fp_contentHeightInFloatingViewController ];
   self.floatingView.autoresizingMask = content_height_ == 0.f
      ? UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      : UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
   self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

   self.contentView.contentSize = CGSizeMake( self.contentView.frame.size.width, content_height_ );
}

-(void)setContentViewController:( UIViewController* )content_view_controller_
{
   [ _contentViewController removeFromParentViewController ];
   [ _contentViewController.view removeFromSuperview ];

   if ( content_view_controller_ )
   {
      [ self addChildViewController: content_view_controller_ ];
      [ self.contentView fp_addSubviewAndScale: content_view_controller_.view autoresizingMask: UIViewAutoresizingFlexibleWidth ];
   }

   _contentViewController = content_view_controller_;

   [ self relayoutFloatingView ];
}

-(BOOL)shouldAutorotate
{
   return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
   return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

#pragma mark Keyboard relayout

-(void)viewWillAppear:( BOOL )animated_
{
   [ super viewWillAppear: animated_ ];
   
   [ self kh_subscribeKeyboardNotifications ];
}

-(void)viewWillDisappear:( BOOL )animated_
{
   [ super viewWillDisappear: animated_ ];
   [ self.floatingView endEditing: YES ];
   [ self kh_unsubscribeKeyboardNotifications ];
}

-(void)kh_willShowKeyboardWithHeight:( CGFloat )height_
                              inRect:( CGRect )rect_
                            duration:( NSTimeInterval )duration_
                             options:( UIViewAnimationOptions )options_
{
   if ( self.kh_isKeyboardVisible )
      return;

   [ UIView animateWithDuration: duration_
                          delay: 0.0
                        options: options_
                     animations:
    ^{
       CGRect floating_rect_ = CGRectOffset( self.floatingView.frame, 0.f, -height_ );
       if ( floating_rect_.origin.y < 0 )
       {
          floating_rect_.size.height += floating_rect_.origin.y;
          floating_rect_.origin.y = 0;
       }
       self.floatingView.frame = floating_rect_;
    }
                     completion: nil ];
}

-(void)kh_willHideKeyboardWithDuration:( NSTimeInterval )duration_
                               options:( UIViewAnimationOptions )options_
{
   [ UIView animateWithDuration: duration_
                          delay: 0.0
                        options: options_
                     animations:
    ^{
       [ self moveUp ];
    }
                     completion: nil ];
}

#pragma mark UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:( UIGestureRecognizer* )gesture_recognizer_
      shouldReceiveTouch:( UITouch* )touch_
{
   if ( [ touch_.view isDescendantOfView: self.floatingView ] )
      return NO;

   return YES;
}

@end

@implementation UIViewController (FPFloatingViewController)

-(void)presentFloatingViewControllerAnimated:( BOOL )animated_
                                  completion:( FPFloatingViewControllerCompletionBlock )completion_
{
   [ [ UIApplication sharedApplication ].keyWindow endEditing: YES ];

   UIWindow* floating_window_ = [ [ UIWindow alloc ] initWithFrame: [ UIScreen mainScreen ].bounds ];
   floating_window_.windowLevel = UIWindowLevelStatusBar;

   FPFloatingViewController* floating_controller_ = [ FPFloatingViewController new ];
   floating_controller_.contentViewController = self;
   floating_window_.rootViewController = floating_controller_;

   [ UIView fp_animateWithCondition: animated_
                           duration: FPDefaultAnimationTime
    
                       initialSetup:
    ^{
       floating_window_.backgroundColor = [ floating_controller_ overlayColorWithVisiblePart: 0.f ];
       [ floating_controller_ moveDown ];
    }
                         animations:
    ^{
       floating_window_.backgroundColor = [ floating_controller_ overlayColorWithVisiblePart: 1.f ];
       [ floating_controller_ moveUp ];
    }
                         completion: ^( BOOL finished_ )
    {
       if ( completion_ ) completion_();
    } ];

   [ UIWindow fp_pushFloatingWindow: floating_window_ ];
}

-(void)dismissFloatingViewController:( UIViewController* )controller_
                            animated:( BOOL )animated_
                          completion:( FPFloatingViewControllerCompletionBlock )completion_
{
   //Do nothing for usual controller
}

-(void)dismissFloatingViewControllerAnimated:( BOOL )animated_
                                  completion:( FPFloatingViewControllerCompletionBlock )completion_
{
   UIViewController* root_controller_ = [ [ UIWindow fp_currentFloatingWindow ] rootViewController ];
   if ( ![ root_controller_ isMemberOfClass: [ FPFloatingViewController class ] ] )
   {
      return;
   }

   FPFloatingViewController* floating_controller_ = ( FPFloatingViewController* )root_controller_;

   if ( floating_controller_.contentViewController != self )
   {
      return;
   }
   else if ( floating_controller_.presentedViewController )
   {
      [ floating_controller_ dismissViewControllerAnimated: animated_
                                                completion:
       ^{
          [ floating_controller_ dismissFloatingViewController: self animated: animated_ completion: completion_ ];
       } ];
   }
   else
   {
      [ floating_controller_ dismissFloatingViewController: self animated: animated_ completion: completion_ ];
   }
}

-(void)presentFloatingViewControllerAnimated:( BOOL )animated_
{
   [ self presentFloatingViewControllerAnimated: animated_ completion: nil ];
}

-(void)dismissFloatingViewControllerAnimated:( BOOL )animated_
{
   [ self dismissFloatingViewControllerAnimated: animated_ completion: nil ];
}

+(BOOL)isFloatingViewControllerVisible
{
   return [ UIWindow fp_currentFloatingWindow ] != nil;
}

@end

@implementation UIViewController (FPFloatingViewController_Customize)

-(CGFloat)fp_bottomMarginInFloatingViewController
{
   return 20.f;
}

-(CGFloat)fp_contentHeightInFloatingViewController
{
   CGFloat height_ = self.contentSizeForViewInPopover.height;
   return height_ == 0.f ? 0.f : height_ + [ self fp_bottomMarginInFloatingViewController ];
}

-(BOOL)fp_shouldShowFloatingHeader
{
   return YES;
}

-(BOOL)fp_shouldAddContentBackground
{
   return YES;
}

@end
