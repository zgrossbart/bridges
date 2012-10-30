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
    // TODO
}

-(void)jumpOut {
    // TODO
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
