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

@interface TeleportNode()

@property (nonatomic, assign, readwrite) BridgeColor color;
@property (readwrite, assign) LayerMgr *layerMgr;
@property (nonatomic, assign, readwrite) int tag;
@property (nonatomic, assign, readwrite) int coins;

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
    }
    
    return self;
}

-(void)jumpIn {
    /*
     * When the player jumps into a teleporter we change to a 
     * highlight sprite to show which teleporter the player is 
     * inside.
     */
    CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame* frame;
    frame = [cache spriteFrameByName:[self getHighlightSpriteName]];
    [self.teleporter setDisplayFrame:frame];
}

-(void)jumpOut {
    /*
     * When the player jumps out of the teleporter we set back to 
     * the previous sprite without the highlight.
     */
    CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame* frame;
    frame = [cache spriteFrameByName:[self getSpriteName]];
    [self.teleporter setDisplayFrame:frame];
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
    return [NSMutableArray arrayWithCapacity:0];
}

-(void) undo {
    /*
     * Nothing to do here
     */
}

-(void)dealloc {
    [self.teleporter release];
    [super dealloc];
}


@end
