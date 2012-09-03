//
//  ScreenShotLayer.m
//  bridges2
//
//  Created by Zack Grossbart on 9/3/12.
//
//

#import "ScreenShotLayer.h"

@implementation ScreenShotLayer

- (id)init {
    
    if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
    }
    
    return self;
}

-(void)draw {
    
    [super draw];
    
    ccDrawSolidRect( ccp(0, 0), ccp(self.bounds.size.width, self.bounds.size.height), ccc4f(255, 255, 255, 255) );
}
@end
