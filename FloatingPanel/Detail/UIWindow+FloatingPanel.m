#import "UIWindow+FloatingPanel.h"

static UIWindow* current_floating_window_ = nil;

@implementation UIWindow (FloatingPanel)

+(NSMutableArray*)fp_floatingWindowStack
{
   static NSMutableArray* stack_ = nil;
   if ( !stack_ )
   {
      stack_ = [ NSMutableArray new ];
   }
   return stack_;
}

+(UIWindow*)fp_currentFloatingWindow
{
   return [ [ self fp_floatingWindowStack ] lastObject ];
}

+(void)fp_pushFloatingWindow:( UIWindow* )window_
{
   NSAssert( ![ [ self fp_floatingWindowStack ] containsObject: window_ ], @"This window already pushed" );

   [ [ self fp_floatingWindowStack ] addObject: window_ ];
   [ window_ makeKeyAndVisible ];
}

+(void)fp_popFloatingWindow
{
   //NSAssert( [ [ self floatingWindowStack ] count ] > 0, @"Nothing to pop" );
   [ [ self fp_floatingWindowStack ] removeLastObject ];
}

@end
