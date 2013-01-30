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

#import "HouseNode.h"
#import "BridgeColors.h"
#import "StyleUtil.h"
#import "SimpleAudioEngine.h"

@interface HouseNode()
@property (readwrite, retain) CCSprite *house;
@property (nonatomic, assign, getter=isVisited, readwrite) bool visited;
@property (nonatomic, assign, readwrite) BridgeColor color;
@property (readwrite, assign) LayerMgr *layerMgr;
@property (readwrite, retain) UILabel *label;
@property (nonatomic, assign, readwrite) int tag;
@property (nonatomic, assign, readwrite) int coins;
@end

@implementation HouseNode

-(id)initWithColor:(BridgeColor) color layerMgr:(LayerMgr*) layerMgr {
    self = [super init];
    return [self initWithColorAndCoins :color layerMgr:layerMgr coins:0];
}
    
-(id)initWithColorAndCoins:(BridgeColor) color layerMgr:(LayerMgr*) layerMgr coins:(int) coins {
    
    if( (self=[super init] )) {
        self.layerMgr = layerMgr;
        self.tag = HOUSE;
        self.visited = false;
        self.color = color;
        [self setHouseSprite:[CCSprite spriteWithSpriteFrameName:[self getSpriteName]]];
        self.coins = coins;
        
        if (self.coins > 0) {
            _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
            _label.text = [NSString stringWithFormat:@"%i", self.coins];
            [StyleUtil styleNodeLabel:_label];
        }
    }
    
    return self;
}

-(NSString*)getSpriteName {
    if (self.color == cRed) {
        return @"house_red.png";
    } else if (self.color == cBlue) {
        return @"house_blue.png";
    } else if (self.color == cGreen) {
        return @"house_green.png";
    } else if (self.color == cOrange) {
        return @"house_orange.png";
    } else {
        return @"house.png";
    }
}

-(void)undo {
    if (_label != nil) {
        self.coins++;
        _label.text = [NSString stringWithFormat:@"%i", self.coins];
    }
    
    if (self.isVisited) {
        CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame* frame;
        frame = [cache spriteFrameByName:[self getSpriteName]];
        [self.house setDisplayFrame:frame];
        self.visited = false;
    }
}

-(void) addSprite {
    [self.layerMgr addChildToSheet:self.house];
}

-(void)setHouseSprite:(CCSprite*)house {
    self.house = house;
    self.house.tag = [self tag];
}

-(void)visitEnded {
    CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame* frame;
    frame = [cache spriteFrameByName:@"house_gray.png"];
    [self.house setDisplayFrame:frame];
}

-(void)visit {
    if (self.coins > 0) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"HouseVisitPartial.m4a"];
        self.coins--;
        _label.text = [NSString stringWithFormat:@"%i", self.coins];
    } else {
        [[SimpleAudioEngine sharedEngine] playEffect:@"HouseVisitComplete.m4a"];
    }
    
    if (self.coins == 0 && !self.visited) {
        self.visited = true;
        
        float scale = 1.0;
        
        /*
         * If this is the last visit to a house then we want to show
         * a small animation to call your attention to it.  This 
         * animation rotates it horizontally while it changes the sprite.
         */
        CCEaseExponentialIn* flipHalf = [CCEaseExponentialIn actionWithAction:[CCActionTween actionWithDuration:0.25 key:@"scaleX" from:-scale to:0.0]];
        CCEaseExponentialOut* flipRemainingHalf = [CCEaseExponentialOut actionWithAction:[CCActionTween actionWithDuration:0.25 key:@"scaleX" from:0.0 to:scale]];
        
        CCSequence* seq = [CCSequence actions:flipHalf,
                           [CCCallFunc actionWithTarget:self selector:@selector(visitEnded)],
                           flipRemainingHalf, nil];
        [self.house runAction:seq];
    }     
}

-(void)setHousePosition:(CGPoint)p {
    self.house.position = ccp(p.x, p.y);
    if (_label != nil) {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0) &&
            UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            /*
             * The iPad retina uses very large icons and we need a little more space
             * between the sprite and the label.
             */
            _label.frame = CGRectMake(p.x + (self.house.scale * 3) + 5, ([LayerMgr normalizeYForControl:p.y] - _label.frame.size.height) - (self.house.scale * 3) - 7, _label.frame.size.width, _label.frame.size.height);
        } else {
            _label.frame = CGRectMake(p.x + (self.house.scale * 3), ([LayerMgr normalizeYForControl:p.y] - _label.frame.size.height) - (self.house.scale * 3), _label.frame.size.width, _label.frame.size.height);
        }
    }
}

-(CGPoint)getHousePosition {
    return self.house.position;
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
    
    [_house release];
    [super dealloc];
}

@end
