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

#import "Bridge4Node.h"
#import "BridgeColors.h"

@interface Bridge4Node()
@property (readwrite, retain) CCSprite *bridge;
@property (nonatomic, assign, getter=isCrossed, readwrite) bool crossed;
@property (nonatomic, assign, readwrite) int color;
@property (readwrite, assign) LayerMgr *layerMgr;
@property (nonatomic, assign, readwrite) int tag;
@property (nonatomic, assign, readwrite) int coins;
@end

@implementation Bridge4Node

-(id) initWithTagAndColor:(int)color :(LayerMgr *)layerMgr {
    if( (self=[super init] )) {
        self.layerMgr = layerMgr;
        self.tag = BRIDGE4;
        self.color = color;
        
        [self setBridgeSprite:[CCSprite spriteWithSpriteFrameName:[self getSpriteName]]];
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
}

-(CGPoint)getBridgePosition {
    return self.bridge.position;
}

-(void) undo {
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

-(void)enterBridge:(int)dir {
    if (!self.isCrossed) {
        CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame* frame;
        
        if (dir == UP) {
            frame = [cache spriteFrameByName:@"bridge_4_up.png"];
        } else if (dir == DOWN) {
            frame = [cache spriteFrameByName:@"bridge_4_down.png"];
        } else if (dir == RIGHT) {
            frame = [cache spriteFrameByName:@"bridge_4_right.png"];
        } else {
            frame = [cache spriteFrameByName:@"bridge_4_left.png"];
        }
        
        [self.bridge setDisplayFrame:frame];
    }
}

-(NSArray*) controls {
    return [NSMutableArray arrayWithCapacity:1];
}

-(void)dealloc {
    
    [_bridge dealloc];
    [super dealloc];
}

@end
