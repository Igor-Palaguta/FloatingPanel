#import "UIWindow+FloatingPanel.h"

static UIWindow* current_floating_window_ = nil;

@implementation UIWindow (FloatingPanel)

+(NSMutableArray*)floatingWindowStack
{
   static NSMutableArray* stack_ = nil;
   if ( !stack_ )
   {
      stack_ = [ NSMutableArray new ];
   }
   return stack_;
}

+(UIWindow*)currentFloatingWindow
{
   return [ [ self floatingWindowStack ] lastObject ];
}

+(void)pushFloatingWindow:( UIWindow* )window_
{
   NSAssert( ![ [ self floatingWindowStack ] containsObject: window_ ], @"This window already pushed" );

   [ [ self floatingWindowStack ] addObject: window_ ];
   [ window_ makeKeyAndVisible ];
}

+(void)popFloatingWindow
{
   //NSAssert( [ [ self floatingWindowStack ] count ] > 0, @"Nothing to pop" );
   [ [ self floatingWindowStack ] removeLastObject ];
}

@end
