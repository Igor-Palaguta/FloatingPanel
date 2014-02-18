#import "FPFloatingSegue.h"

#import "FPFloatingViewController.h"

@implementation FPFloatingSegue

-(void)perform
{
   [ self.destinationViewController presentFloatingViewControllerAnimated: YES ];
}

@end
