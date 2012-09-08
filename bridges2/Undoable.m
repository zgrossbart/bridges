//
//  Undoable.m
//  bridges2
//
//  Created by Zack Grossbart on 9/2/12.
//
//

#import "Undoable.h"

@interface Undoable()
@property (readwrite) CGPoint pos;
@property (readwrite) int color;
@property (readwrite, assign) id<GameNode> node;
@property (nonatomic, assign, readwrite) int coins;
@end

@implementation Undoable

-(id) initWithPosAndNode:(CGPoint) pos:(id<GameNode>) node: (int) color: (int) coins {
    if( (self=[super init] )) {
        self.pos = pos;
        self.node = node;
        self.color = color;
        self.coins = coins;
    }
    
    return self;
}

@end
