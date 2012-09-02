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
        self.vertical = vertical;
        
        [self setBridgeSprite:[CCSprite spriteWithSpriteFrameName:[self getSpriteName]]];
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

- (void) undo {
    if (self.crossed) {
        CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame* frame = [cache spriteFrameByName:[self getSpriteName]];
        [self.bridge setDisplayFrame:frame];
        
        self.crossed = false;
    }
    
}

-(NSString*)getSpriteName {
    if (self.vertical) {
        if (self.color == RED) {
            return @"bridge_v_red.png";
        } else if (self.color == BLUE) {
            return @"bridge_v_blue.png";
        } else if (self.color == GREEN) {
            return @"bridge_v_green.png";
        } else {
            return @"bridge_v.png";
        }
    } else {
        if (self.color == RED) {
            return @"bridge_h_red.png";
        } else if (self.color == BLUE) {
            return @"bridge_h_blue.png";
        } else if (self.color == GREEN) {
            return @"bridge_h_green.png";
        } else {
            return @"bridge_h.png";
        }
    }
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
