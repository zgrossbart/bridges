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

#import "TeleportNode.h"
#import "StyleUtil.h"
#import "SimpleAudioEngine.h"

@interface TeleportNode()

@property (nonatomic, assign, readwrite) BridgeColor color;
@property (readwrite, assign) LayerMgr *layerMgr;
@property (nonatomic, assign, readwrite) int tag;
@property (nonatomic, assign, readwrite) int coins;
@property (readwrite, retain) UILabel *label;

@property (readwrite, retain) CCSprite *teleporter;
@end

@implementation TeleportNode

-(id)initWithColor: (BridgeColor) color :(LayerMgr*) layerMgr {
    
    if( (self=[super init] )) {
        self.layerMgr = layerMgr;
        self.tag = TELEPORT;
        self.color = color;
        [self setTeleportSprite:[CCSprite spriteWithSpriteFrameName:[self getSpriteName]]];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.teleporter.scale = IPAD_SCALE_FACTOR;
        }
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 16)];
        _label.text = [NSString stringWithFormat:@"Jump out"];
        [StyleUtil styleNodeLabel:_label];
        _label.hidden = YES;
    }
    
    return self;
}

-(void)jumpIn {
    [[SimpleAudioEngine sharedEngine] playEffect:@"TeleporterEnter.m4a"];
    /*
     * When the player jumps into a teleporter we change to a 
     * highlight sprite to show which teleporter the player is 
     * inside.
     */
    CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame* frame;
    frame = [cache spriteFrameByName:[self getHighlightSpriteName]];
    [self.teleporter setDisplayFrame:frame];
    
    int y = [LayerMgr normalizeYForControl:self.teleporter.position.y] + (_label.frame.size.height / 2) + 2;
    if (self.teleporter.position.y < [self.teleporter boundingBox].size.height) {
        /*
         * If this teleporter is close to the bottom of the screen
         * then we'll move the level to the top of the sprite.
         */
        y = [LayerMgr normalizeYForControl:self.teleporter.position.y] - [self.teleporter boundingBox].size.height +(_label.frame.size.height / 2) - 8;
    }
    
    int x = self.teleporter.position.x - (_label.frame.size.width / 2);
    if (self.teleporter.position.x < [self.teleporter boundingBox].size.width) {
        x = 2;
        y += 2;
    }
    
    _label.frame = CGRectMake(x, y, _label.frame.size.width, _label.frame.size.height);
    
    _label.hidden = NO;
    
}

-(void)jumpOut {
    [[SimpleAudioEngine sharedEngine] playEffect:@"TeleporterExit.m4a"];
    /*
     * When the player jumps out of the teleporter we set back to 
     * the previous sprite without the highlight.
     */
    CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame* frame;
    frame = [cache spriteFrameByName:[self getSpriteName]];
    [self.teleporter setDisplayFrame:frame];
    _label.hidden = YES;
}

-(void)setTeleportSprite:(CCSprite*)teleporter {
    self.teleporter = teleporter;
    self.teleporter.tag = [self tag];
}

-(NSString*)getSpriteName {
    if (self.color == cRed) {
        return @"teleport_red.png";
    } else if (self.color == cBlue) {
        return @"teleport_blue.png";
    } else if (self.color == cGreen) {
        return @"teleport_green.png";
    } else if (self.color == cOrange) {
        return @"teleport_orange.png";
    } else {
        return @"teleport.png";
    }
}

-(NSString*)getHighlightSpriteName {
    if (self.color == cRed) {
        return @"teleport_red_highlight.png";
    } else if (self.color == cBlue) {
        return @"teleport_blue_highlight.png";
    } else if (self.color == cGreen) {
        return @"teleport_green_highlight.png";
    } else if (self.color == cOrange) {
        return @"teleport_orange_highlight.png";
    } else {
        return @"teleport_highlight.png";
    }
}


-(void) addSprite {
    [self.layerMgr addChildToSheet:self.teleporter];
}

-(NSArray*) controls {
    NSMutableArray *controls = [NSMutableArray arrayWithCapacity:1];
    [controls addObject:self.label];
    return controls;
}

-(void) undo {
    /*
     * Nothing to do here
     */
}

-(void)dealloc {
    [self.label release];
    [self.teleporter release];
    [super dealloc];
}


@end
