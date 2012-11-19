/*******************************************************************************
 *
 * Copyright 2012 Zack Grossbart
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************/

#import "BridgeNode.h"
#import "BridgeColors.h"
#import "StyleUtil.h"
#import "SimpleAudioEngine.h"

@interface BridgeNode()
@property (readwrite) bool vertical;
@property (readwrite, retain) CCSprite *bridge;
@property (nonatomic, assign, getter=isCrossed, readwrite) bool crossed;
@property (nonatomic, assign, readwrite) BridgeColor color;
@property (assign, readwrite) LayerMgr *layerMgr;
@property (readwrite, retain) UILabel *label;
@property (nonatomic, assign, readwrite) int tag;
@property (nonatomic, assign, readwrite) int coins;
@property (readwrite) int direction;
@end

@implementation BridgeNode

-(id) initWithOrient:(bool) vertical:(BridgeColor) color:(LayerMgr*) layerMgr {
    self=[super init];
    return [self initWithOrientAndDir:vertical:dNone:color:layerMgr];
}

-(id)initWithOrientAndDir: (bool)vertical:(BridgeDir)dir: (BridgeColor) color:(LayerMgr*) layerMgr {
    self=[super init];
    return [self initWithOrientAndDirAndCoins:vertical:dNone:color:layerMgr:0];
}

-(id)initWithOrientAndDirAndCoins: (bool)vertical:(BridgeDir)dir:(BridgeColor) color:(LayerMgr*) layerMgr:(int)coins {
    if( (self=[super init] )) {
        self.layerMgr = layerMgr;
        self.tag = BRIDGE;
        self.color = color;
        self.vertical = vertical;
        self.direction = dir;
        
        [self setBridgeSprite:[CCSprite spriteWithSpriteFrameName:[self getSpriteName]]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.bridge.scale = IPAD_SCALE_FACTOR;
        }
        
        self.coins = coins;
        
        if (self.coins > 0) {
            _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
            _label.text = [NSString stringWithFormat:@"%i", self.coins];
            
            [StyleUtil styleNodeLabel:_label];
        }
    }
    
    return self;
}

-(void) addSprite {
    [self.layerMgr addChildToSheet:self.bridge];
}

-(void)setBridgeSprite:(CCSprite*)bridge {
    self.bridge = bridge;
    self.bridge.tag = [self tag];
}

-(void)setBridgePosition:(CGPoint)p {
    self.bridge.position = ccp(p.x, p.y);
    if (_label != nil) {
        _label.frame = CGRectMake((p.x + ((self.bridge.contentSize.width * self.bridge.scale) / 2)) -(_label.frame.size.width / 2) + 5, [LayerMgr normalizeYForControl:p.y] -(((self.bridge.contentSize.height * self.bridge.scale) / 2) + (_label.frame.size.height / 2)) - 3, _label.frame.size.width, _label.frame.size.height);
    }
}

-(CGPoint)getBridgePosition {
    return self.bridge.position;
}

-(void) undo {
    if (_label != nil) {
        self.coins++;
        _label.text = [NSString stringWithFormat:@"%i", self.coins];
    }
    
    if (self.crossed) {
        CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame* frame = [cache spriteFrameByName:[self getSpriteName]];
        [self.bridge setDisplayFrame:frame];
        
        self.crossed = false;
    }
    
}

-(NSString*)getSpriteName {
    if (self.vertical) {
        if (self.color == cRed) {
            if (self.direction == dUp) {
                return @"bridge_red_up.png";
            } else if (self.direction == dDown) {
                return @"bridge_red_down.png";
            } else {
                return @"bridge_v_red.png";
            }
        } else if (self.color == cBlue) {
            if (self.direction == dUp) {
                return @"bridge_blue_up.png";
            } else if (self.direction == dDown) {
                return @"bridge_blue_down.png";
            } else {
                return @"bridge_v_blue.png";
            }
        } else if (self.color == cGreen) {
            if (self.direction == dUp) {
                return @"bridge_green_up.png";
            } else if (self.direction == dDown) {
                return @"bridge_green_down.png";
            } else {
                return @"bridge_v_green.png";
            }
        } else if (self.color == cOrange) {
            if (self.direction == dUp) {
                return @"bridge_orange_up.png";
            } else if (self.direction == dDown) {
                return @"bridge_orange_down.png";
            } else {
                return @"bridge_v_orange.png";
            }
        } else {
            if (self.direction == dUp) {
                return @"bridge_up.png";
            } else if (self.direction == dDown) {
                return @"bridge_down.png";
            } else {
                return @"bridge_v.png";
            }
        }
    } else {
        if (self.color == cRed) {
            if (self.direction == dLeft) {
                return @"bridge_red_left.png";
            } else if (self.direction == dRight) {
                return @"bridge_red_right.png";
            } else {
                return @"bridge_h_red.png";
            }
        } else if (self.color == cBlue) {
            if (self.direction == dLeft) {
                return @"bridge_blue_left.png";
            } else if (self.direction == dRight) {
                return @"bridge_blue_right.png";
            } else {
                return @"bridge_h_blue.png";
            }
        } else if (self.color == cGreen) {
            if (self.direction == dLeft) {
                return @"bridge_green_left.png";
            } else if (self.direction == dRight) {
                return @"bridge_green_right.png";
            } else {
                return @"bridge_h_green.png";
            }
        } else if (self.color == cOrange) {
            if (self.direction == dLeft) {
                return @"bridge_orange_left.png";
            } else if (self.direction == dRight) {
                return @"bridge_orange_right.png";
            } else {
                return @"bridge_h_orange.png";
            }
        } else {
            if (self.direction == dLeft) {
                return @"bridge_left.png";
            } else if (self.direction == dRight) {
                return @"bridge_right.png";
            } else {
                return @"bridge_h.png";
            }
        }
    }
}

-(void)cross {
    
    if (self.coins > 0) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"BridgeCrossPartial.m4a"];
        self.coins--;
        _label.text = [NSString stringWithFormat:@"%i", self.coins];
    } else {
        [[SimpleAudioEngine sharedEngine] playEffect:@"BridgeComplete.m4a"];
    }
    
    if (self.coins == 0 && !self.crossed) {
        CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame* frame;
        if (self.vertical) {
            frame = [cache spriteFrameByName:@"bridge_v_x.png"];
        } else {
            frame = [cache spriteFrameByName:@"bridge_h_x.png"];
        }
        [self.bridge setDisplayFrame:frame];
        self.crossed = true;
    }    
}

-(NSArray*) controls {
    NSMutableArray *controls = [NSMutableArray arrayWithCapacity:1];
    if (_label != nil) {
        [controls addObject:_label];
    }
    return controls;
}

-(void)dealloc {
    
    if (_label != nil) {
        [_label release];
    }
    
    [_bridge release];
    [super dealloc];
}

@end
