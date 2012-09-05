//
//  RiverNode.m
//  Cocos2DSimpleGame
//
//  Created by Zack Grossbart on 8/19/12.
//
//

#import "Bridge4Node.h"
#import "BridgeColors.h"

@interface Bridge4Node()
@property (readwrite, retain) CCSprite *bridge;
@property (nonatomic, assign, getter=isCrossed, readwrite) bool crossed;
@property (nonatomic, assign, readwrite) int color;
@property (readwrite) LayerMgr *layerMgr;
@property (nonatomic, assign, readwrite) int tag;
@end

@implementation Bridge4Node

-(id) initWithTagAndColor:(int)tag :(int)color :(LayerMgr *)layerMgr {
    if( (self=[super init] )) {
        self.layerMgr = layerMgr;
        self.tag = tag;
        self.color = color;
        
        [self setBridgeSprite:[CCSprite spriteWithSpriteFrameName:[self getSpriteName]]];
    }
    
    return self;
}

- (void) addSprite {
    [self.layerMgr addChildToSheet:self.bridge];
}

-(void)setBridgeSprite:(CCSprite*)bridge {
    self.bridge = bridge;
    self.bridge.tag = [self tag];
}

-(void)setBridgePosition:(CGPoint)p {
    self.bridge.position = ccp(p.x, p.y);
}

-(CGPoint)getBridgePosition {
    return self.bridge.position;
}

- (void) undo {
    if (self.crossed) {
        CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame* frame = [cache spriteFrameByName:[self getSpriteName]];
        [self.bridge setDisplayFrame:frame];
        
        self.crossed = false;
    }
    
}

-(NSString*)getSpriteName {
    if (self.color == RED) {
        return @"bridge_4_red.png";
    } else if (self.color == BLUE) {
        return @"bridge_4_blue.png";
    } else if (self.color == GREEN) {
        return @"bridge_4_green.png";
    } else if (self.color == ORANGE) {
        return @"bridge_4_orange.png";
    } else {
        return @"bridge_4.png";
    }
}

-(void)cross {
    if (!self.crossed) {
        CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame* frame = [cache spriteFrameByName:@"bridge_4_x.png"];
        [self.bridge setDisplayFrame:frame];
    }
    self.crossed = true;
}

-(void)dealloc {
    
    [self.bridge dealloc];
    [super dealloc];
}

@end
