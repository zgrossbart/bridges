//
//  RiverNode.m
//  bridges2
//
//  Created by Zack Grossbart on 9/9/12.
//
//

#import "RiverNode.h"

@interface RiverNode()

@property (readwrite) CGRect frame;
@property (readwrite, copy) NSArray *rivers;

@end

@implementation RiverNode

-(id)initWithFrame: (CGRect) frame: (NSArray*) rivers {

    if ((self=[super init] )) {
        self.frame = frame;
        self.rivers = rivers;
    }
    
    return self;
}

-(bool)contains: (CCSprite*) river {
    return [self.rivers containsObject:river];
}

@end
