//
//  RiverNode.m
//  Cocos2DSimpleGame
//
//  Created by Zack Grossbart on 8/19/12.
//
//

#import "BridgeNode.h"
#import "BridgeColors.h"

@interface BridgeNode()
@property (readwrite) bool vertical;
@property (readwrite) CCSprite *bridge;
@property (nonatomic, assign, getter=isCrossed, readwrite) bool crossed;
@property (nonatomic, assign, readwrite) int color;
@property (readwrite) LayerMgr *layerMgr;
@property (nonatomic, assign, readwrite) int tag;
@end

@implementation BridgeNode

-(id) initWithDir:(bool) vertical:(int) tag: (int) color:(LayerMgr*) layerMgr {
    if( (self=[super init] )) {
        self.layerMgr = layerMgr;
        self.tag = tag;
        self.color = color;
        if (vertical) {
            if (color == RED) {
                [self setBridgeSprite:[CCSprite spriteWithSpriteFrameName:@"bridge_v_red.png"]];
            } else if (color == BLUE) {
                [self setBridgeSprite:[CCSprite spriteWithSpriteFrameName:@"bridge_v_blue.png"]];
            } else if (color == GREEN) {
                [self setBridgeSprite:[CCSprite spriteWithSpriteFrameName:@"bridge_v_green.png"]];
            } else if (color == BLACK || color == NONE) {
                [self setBridgeSprite:[CCSprite spriteWithSpriteFrameName:@"bridge_v.png"]];
            }
        } else {
            if (color == RED) {
                [self setBridgeSprite:[CCSprite spriteWithSpriteFrameName:@"bridge_h_red.png"]];
            } else if (color == BLUE) {
                [self setBridgeSprite:[CCSprite spriteWithSpriteFrameName:@"bridge_h_blue.png"]];
            } else if (color == GREEN) {
                [self setBridgeSprite:[CCSprite spriteWithSpriteFrameName:@"bridge_h_green.png"]];
            } else if (color == BLACK || color == NONE) {
                [self setBridgeSprite:[CCSprite spriteWithSpriteFrameName:@"bridge_h.png"]];
            }
        }
        
        
        self.vertical = vertical;
    }
    
    return self;
}

- (void) addSprite {
    [self.layerMgr addChildToSheet:self.bridge];
}

-(void)setBridgeSprite:(CCSprite*)bridge {
    self.bridge = bridge;
    self.contentSize = CGSizeMake(self.bridge.contentSize.width,
                                  self.bridge.contentSize.height);
    self.bridge.tag = [self tag];
}

-(void)setBridgePosition:(CGPoint)p {
    self.bridge.position = ccp(p.x, p.y);
}

-(CGPoint)getBridgePosition {
    return self.bridge.position;
}

-(void)cross {
    if (!self.crossed) {
        CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame* frame;
        if (self.vertical) {
            frame = [cache spriteFrameByName:@"bridge_v_x.png"];
        } else {
            frame = [cache spriteFrameByName:@"bridge_h_x.png"];
        }
        [self.bridge setDisplayFrame:frame];
    }
    self.crossed = true;
}

-(void)dealloc {
    
    [self.bridge dealloc];
    [super dealloc];
}

@end
