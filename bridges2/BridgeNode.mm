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
@property (readwrite, retain) CCSprite *bridge;
@property (nonatomic, assign, getter=isCrossed, readwrite) bool crossed;
@property (nonatomic, assign, readwrite) int color;
@property (readwrite) LayerMgr *layerMgr;
@property (nonatomic, assign, readwrite) int tag;
@property (readwrite) int direction;
@end

@implementation BridgeNode

-(id) initWithOrient:(bool) vertical:(int) tag: (int) color:(LayerMgr*) layerMgr {
    self=[super init];
    return [self initWithOrientAndDir:vertical:NONE:tag:color:layerMgr];
}

-(id)initWithOrientAndDir: (bool)vertical:(int)dir: (int) tag:(int) color:(LayerMgr*) layerMgr {
    if( (self=[super init] )) {
        self.layerMgr = layerMgr;
        self.tag = tag;
        self.color = color;
        self.vertical = vertical;
        self.direction = dir;
        
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
    if (self.vertical) {
        if (self.color == RED) {
            if (self.direction == UP) {
                return @"bridge_red_up.png";
            } else if (self.direction == DOWN) {
                return @"bridge_red_down.png";
            } else {
                return @"bridge_v_red.png";
            }
        } else if (self.color == BLUE) {
            if (self.direction == UP) {
                return @"bridge_blue_up.png";
            } else if (self.direction == DOWN) {
                return @"bridge_blue_down.png";
            } else {
                return @"bridge_v_blue.png";
            }
        } else if (self.color == GREEN) {
            if (self.direction == UP) {
                return @"bridge_green_up.png";
            } else if (self.direction == DOWN) {
                return @"bridge_green_down.png";
            } else {
                return @"bridge_v_green.png";
            }
        } else if (self.color == ORANGE) {
            if (self.direction == UP) {
                return @"bridge_orange_up.png";
            } else if (self.direction == DOWN) {
                return @"bridge_orange_down.png";
            } else {
                return @"bridge_v_orange.png";
            }
        } else {
            if (self.direction == UP) {
                return @"bridge_up.png";
            } else if (self.direction == DOWN) {
                return @"bridge_down.png";
            } else {
                return @"bridge_v.png";
            }
        }
    } else {
        if (self.color == RED) {
            if (self.direction == LEFT) {
                return @"bridge_red_left.png";
            } else if (self.direction == RIGHT) {
                return @"bridge_red_right.png";
            } else {
                return @"bridge_h_red.png";
            }
        } else if (self.color == BLUE) {
            if (self.direction == LEFT) {
                return @"bridge_blue_left.png";
            } else if (self.direction == RIGHT) {
                return @"bridge_blue_right.png";
            } else {
                return @"bridge_h_blue.png";
            }
        } else if (self.color == GREEN) {
            if (self.direction == LEFT) {
                return @"bridge_green_left.png";
            } else if (self.direction == RIGHT) {
                return @"bridge_green_right.png";
            } else {
                return @"bridge_h_green.png";
            }
        } else if (self.color == ORANGE) {
            if (self.direction == LEFT) {
                return @"bridge_orange_left.png";
            } else if (self.direction == RIGHT) {
                return @"bridge_orange_right.png";
            } else {
                return @"bridge_h_orange.png";
            }
        } else {
            if (self.direction == LEFT) {
                return @"bridge_left.png";
            } else if (self.direction == RIGHT) {
                return @"bridge_right.png";
            } else {
                return @"bridge_h.png";
            }
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

-(NSArray*) controls {
    return [NSMutableArray arrayWithCapacity:1];
}

-(void)dealloc {
    
    [self.bridge dealloc];
    [super dealloc];
}

@end
