//
//  RiverNode.h
//  bridges2
//
//  Created by Zack Grossbart on 9/9/12.
//
//

#import <Foundation/Foundation.h>
#import "Cocos2d.h"

@interface RiverNode : NSObject

-(id)initWithFrame: (CGRect) frame: (NSArray*) rivers;

-(bool)contains: (CCSprite*) river;

@property (readonly) CGRect frame;
@property (readonly, copy) NSArray *rivers;


@end
