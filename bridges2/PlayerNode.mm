//
//  RiverNode.m
//  Cocos2DSimpleGame
//
//  Created by Zack Grossbart on 8/19/12.
//
//

#import "PlayerNode.h"
#import "BridgeColors.h"

@interface PlayerNode()
@property (readwrite) CCSprite *player;
@property (nonatomic, assign, readwrite) int color;
@end

@implementation PlayerNode

-(id)initWithTag:(int)tag :(int) color: (LayerMgr *)layerMgr {
    if( (self=[super init] )) {
        _manager = layerMgr;
        _tag = tag;
        self.color = color;
        if (color == RED) {
            [self setPlayerSprite:[CCSprite spriteWithSpriteFrameName:@"octopus1_red.png"]];
        } else if (color == BLUE) {
            [self setPlayerSprite:[CCSprite spriteWithSpriteFrameName:@"octopus1_blue.png"]];
        } else if (color == GREEN) {
            [self setPlayerSprite:[CCSprite spriteWithSpriteFrameName:@"octopus1_green.png"]];
        } else if (color == BLACK) {
            [self setPlayerSprite:[CCSprite spriteWithSpriteFrameName:@"octopus1.png"]];
        }
        
        [_manager addChildToSheet:self.player];
    }
    
    return self;
}

-(void)updateColor:(int)color {
    self.color = color;
    
    CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame* frame;
    
    if (color == RED) {
        frame = [cache spriteFrameByName:@"octopus1_red.png"];
    } else if (color == BLUE) {
        frame = [cache spriteFrameByName:@"octopus1_blue.png"];
    } else if (color == GREEN) {
        frame = [cache spriteFrameByName:@"octopus1_green.png"];
    } else if (color == BLACK) {
        frame = [cache spriteFrameByName:@"octopus1.png"];
    }
    
    [self.player setDisplayFrame:frame];
}

-(void)setPlayerSprite:(CCSprite*)player {
    self.player = player;
    self.contentSize = CGSizeMake(self.player.contentSize.width,
                                  self.player.contentSize.height);
    self.player.tag = [self tag];
}

-(void)position:(CGPoint)p {
    super.position = p;
    self.player.position = ccp(p.x, p.y);
}

-(int)tag {
    return _tag;
}

-(void)dealloc {
    
    [self.player dealloc];
    [super dealloc];
}

@end
