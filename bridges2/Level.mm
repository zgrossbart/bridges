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

#import "Level.h"
#import "BridgeColors.h"
#import "BridgeNode.h"
#import "Bridge4Node.h"
#import "HouseNode.h"
#import "RiverNode.h"
#import "JSONKit.h"
#import "SubwayNode.h"

@interface Level()
@property (readwrite, retain) NSMutableArray *rivers;
@property (readwrite, retain) NSMutableArray *bridges;
@property (readwrite, retain) NSMutableArray *bridge4s;
@property (readwrite, retain) NSMutableArray *houses;
@property (readwrite, retain) NSMutableArray *labels;
@property (readwrite, retain) NSMutableArray *subways;
@property (readwrite, retain) LayerMgr *layerMgr;
@property (readwrite, copy) NSDictionary *levelData;

@property (readwrite, retain) NSString *name;
@property (readwrite) int coins;
@property (readwrite, retain) NSDate *date;
@property (readwrite, retain) NSString *levelId;
@property (readwrite) CGPoint playerPos;
@property (readwrite) int tileCount;
@end

@implementation Level

-(id) initWithJson:(NSString*) jsonString: (NSDate*) date;
{
    if( (self=[super init] )) {
        self.bridges = [NSMutableArray arrayWithCapacity:10];
        self.bridge4s = [NSMutableArray arrayWithCapacity:3];
        self.rivers = [NSMutableArray arrayWithCapacity:25];
        self.houses = [NSMutableArray arrayWithCapacity:10];
        self.subways = [NSMutableArray arrayWithCapacity:5];
        self.labels = [NSMutableArray arrayWithCapacity:5];
        self.date = date;
        
        self.tileCount = TILE_COUNT;
        
        [self parseLevel:jsonString];
    }
    
    return self;    
}

-(void)parseLevel: (NSString*) jsonString {
    self.levelData = [[jsonString objectFromJSONString] objectForKey:@"level"];
    
    if (self.levelData == nil) {
        [NSException raise:@"Invalid level definition" format:@"The level definition %@ is invalid JSON", jsonString];
    }
    
    _levelId = [self.levelData objectForKey:@"id"];
    _name = [self.levelData objectForKey:@"name"];
    if ([self.levelData objectForKey:@"coins"] != nil) {
        _coins = (int) [self parseInt:[self.levelData objectForKey:@"coins"]];
    } else {
        _coins = 0;
    }
}

-(void)loadSprites {
    
    
    if ([self.levelData objectForKey:@"player"] != nil) {
        self.playerPos = [self tileToPoint:[self parseInt:[[self.levelData objectForKey:@"player"] objectForKey:@"x"]]:
                             [self parseInt:[[self.levelData objectForKey:@"player"] objectForKey:@"y"]]];
    } else {
        self.playerPos = ccp(-1, -1);
    }
    
    if ([_levelData objectForKey:@"tiles"] != nil) {
        self.tileCount = [[_levelData objectForKey:@"tiles"] intValue];
    }
    
    NSArray *rivers = [_levelData objectForKey:@"rivers"];
//    NSLog(@"rivers.count: %i", rivers.count);
    
    /*
     * Add the rivers
     */
    for (NSDictionary *r in rivers) {
        NSString *x = [r objectForKey:@"x"];
        NSString *y = [r objectForKey:@"y"];
        NSString *dir = [r objectForKey:@"orient"];
        NSString *side = [r objectForKey:@"side"];
        
        [self addRivers:x:y:[dir isEqualToString:@"v"]:[self getSide:side]];
    }
    
    /*
     * Add the bridges
     */
    NSArray *bridges = [_levelData objectForKey:@"bridges"];
    for (NSDictionary *b in bridges) {
        NSString *x = [b objectForKey:@"x"];
        NSString *y = [b objectForKey:@"y"];
        NSString *orient = [b objectForKey:@"orient"];
        NSString *dir = [b objectForKey:@"dir"];
        NSString *color = [b objectForKey:@"color"];
        NSString *coins = [b objectForKey:@"coins"];
        
        [self addBridge:[self parseInt:x]:[self parseInt:y]:
         [orient isEqualToString:@"v"]:[self getDir:dir]:[self getColor:color]:coins];
    }
    
    /*
     * Add the 4-way bridges
     */
    NSArray *bridge4s = [_levelData objectForKey:@"bridge4s"];
    for (NSDictionary *b in bridge4s) {
        NSString *x = [b objectForKey:@"x"];
        NSString *y = [b objectForKey:@"y"];
        NSString *color = [b objectForKey:@"color"];
        
        [self addBridge4:[self parseInt:x]:[self parseInt:y]:[self getColor:color]];
    }
    
    /*
     * Add the houses
     */
    if ([_levelData objectForKey:@"houses"] != nil) {
        NSArray *houses = [_levelData objectForKey:@"houses"];
        for (NSDictionary *h in houses) {
            NSString *x = [h objectForKey:@"x"];
            NSString *y = [h objectForKey:@"y"];
            NSString *color = [h objectForKey:@"color"];
            NSString *coins = [h objectForKey:@"coins"];
            
            [self addHouse:[self parseInt:x]:[self parseInt:y]:[self getColor:color]:coins];
        }
    }
    
    /*
     * Add the subways
     */
    if ([_levelData objectForKey:@"subways"] != nil) {
        NSArray *subways = [_levelData objectForKey:@"subways"];
        for (NSDictionary *h in subways) {
            NSString *x1 = [h objectForKey:@"x1"];
            NSString *y1 = [h objectForKey:@"y1"];
            NSString *x2 = [h objectForKey:@"x2"];
            NSString *y2 = [h objectForKey:@"y2"];
            NSString *color = [h objectForKey:@"color"];
            
            [self addSubway:[self parseInt:x1]:[self parseInt:y1]:[self parseInt:x2]:[self parseInt:y2]:[self getColor:color]];
        }
    }
    
    /*
     * Add the labels
     */
    if ([_levelData objectForKey:@"labels"] != nil) {
        NSArray *labels = [_levelData objectForKey:@"labels"];
        for (NSDictionary *l in labels) {
            NSString *x = [l objectForKey:@"x"];
            NSString *y = [l objectForKey:@"y"];
            NSString *w = [l objectForKey:@"w"];
            NSString *h = [l objectForKey:@"h"];
            NSString *text = [l objectForKey:@"text"];
            
            [self addLabel:[self parseInt:x]:[self parseInt:y]:[self parseInt:w]:[self parseInt:h]:text];
        }
    }
}

-(BridgeDir)getSide:(NSString*) side {
    if ([@"left" isEqualToString:side]) {
        return dLeft;
    } else if ([@"right" isEqualToString:side]) {
        return dRight;
    } else {
        return dNone;
    }
}

-(BridgeDir)getDir:(NSString*) dir {
    if ([@"left" isEqualToString:dir]) {
        return dLeft;
    } else if ([@"right" isEqualToString:dir]) {
        return dRight;
    } else if ([@"up" isEqualToString:dir]) {
        return dUp;
    } else if ([@"down" isEqualToString:dir]) {
        return dDown;
    } else {
        return dNone;
    }
}

-(void)removeSprites:(LayerMgr*) layerMgr: (UIView*) view {
    self.layerMgr = layerMgr;
    
    if (self.rivers.count == 0) {
        /* 
         * If we haven't loaded yet then there's nothing to do
         */
        return;
    }
    
    if (view) {
        for (UIControl *c in [self controls]) {
            [c removeFromSuperview];
        }
        
        [self.labels removeAllObjects];
    }
    
    [self.rivers removeAllObjects];
    [self.bridges removeAllObjects];
    [self.bridge4s removeAllObjects];
    [self.houses removeAllObjects];
    [self.subways removeAllObjects];
    
    
}

-(void)addSprites: (LayerMgr*) layerMgr: (UIView*) view {
    
    self.layerMgr = layerMgr;
    
    if (self.rivers.count > 0) {
        [self removeSprites:self.layerMgr: view];
    }
    
    [self loadSprites];
    
    if (view != nil) {
        for (UIButton *l in self.labels) {
            [view addSubview:l];
        }
    }
    
    for (RiverNode *r in self.rivers) {
        for (CCSprite *s in r.rivers) {
            [self.layerMgr addChildToSheet:s];
        }
    }
    
    for (BridgeNode *b in self.bridges) {
        for (UIControl *c in [b controls]) {
            [view addSubview:c];
        }
        [self.layerMgr addChildToSheet:b.bridge];
    }
    
    for (Bridge4Node *b in self.bridge4s) {
        for (UIControl *c in [b controls]) {
            [view addSubview:c];
        }
        [self.layerMgr addChildToSheet:b.bridge];
    }
    
    for (HouseNode *h in self.houses) {
        for (UIControl *c in [h controls]) {
            [view addSubview:c];
        }
        [h addSprite];
    }
    
    for (SubwayNode *s in self.subways) {
        for (UIControl *c in [s controls]) {
            [view addSubview:c];
        }
        [s addSprite];
    }
    
}

-(BridgeColor)getColor:(NSString*) color {
    if ([color isEqualToString:@"red"]) {
        return cRed;
    } else if ([color isEqualToString:@"green"]) {
        return cGreen;
    } else if ([color isEqualToString:@"orange"]) {
        return cOrange;
    } else if ([color isEqualToString:@"blue"]) {
        return cBlue;
    } else if ([color isEqualToString:@"black"]) {
        return cBlack;
    } else {
        return cNone;
    }
}

-(void)addRivers:(NSString*) xSpec:(NSString*) ySpec:(BOOL) vert: (int) side {
    /*
     * There are a few ways to define a tile coordinate.
     * You can define a simple number like 5 or 12, you 
     * can define an edge of the screen like l for left
     * or t for top, or you can define a range with a dash.
     * For example, if you wanted a river to go from the left
     * side of the screen to the right then you could 
     * define it as l-r.
     *
     * We'll start by parsing out the x and then we'll handle
     * the y.
     */
    unsigned int len = [xSpec length];
    const char *str = [xSpec UTF8String];
    NSMutableString *x1 = [NSMutableString stringWithCapacity:2];
    NSMutableString *x2 = [NSMutableString stringWithCapacity:2];
    bool inSecond = false;
    
    for(int i = 0; i < len; i++) {
        char c = str[i];
        if (c == '-') {
            inSecond = true;
        } else if (inSecond) {
            [x2 appendString: [NSString stringWithFormat:@"%c" , c]];
        } else {
            [x1 appendString: [NSString stringWithFormat:@"%c" , c]];
        }
    }
    
    if ([x2 length] == 0) {
        [x2 appendString:x1];
    }
    
    len = [ySpec length];
    str = [ySpec UTF8String];
    
    NSMutableString *y1 = [NSMutableString stringWithCapacity:2];
    NSMutableString *y2 = [NSMutableString stringWithCapacity:2];
    inSecond = false;
    
    for(int i = 0; i < len; i++) {
        char c = str[i];
        if (c == '-') {
            inSecond = true;
        } else if (inSecond) {
            [y2 appendString: [NSString stringWithFormat:@"%c" , c]];
        } else {
            [y1 appendString: [NSString stringWithFormat:@"%c" , c]];
        }
    }
    
    if ([y2 length] == 0) {
        [y2 appendString:y1];
    }
    
    /*
     * At this point we have a rectangle defined by the points (x1, y1)
     * and (x2, y2).  We want to fill that rectangle using rivers.  
     * However, the coordintes of this rectangle are defined in
     * tiles and we want to show them in points.  We also need to handle
     * the fact that tile sizes are variable based on the device and if 
     * they are specified in the level, but river sizes are fixed.  
     * That means we'll need a variable number of rivers based on the 
     * size of the tiles.
     */
    
    float xi1 = [self parseInt:x1] * self.layerMgr.tileSize.width;
    float yi1 = [self parseInt:y1] * self.layerMgr.tileSize.height;
    
    float xi2 = [self parseInt:x2] * self.layerMgr.tileSize.width;
    float yi2 = [self parseInt:y2] * self.layerMgr.tileSize.height;
    
    NSMutableArray *rivers = [NSMutableArray arrayWithCapacity:10];
    
    CCSprite *rSprite;
    if (vert) {
        rSprite = [CCSprite spriteWithSpriteFrameName:@"river_v.png"];
    } else {
        rSprite = [CCSprite spriteWithSpriteFrameName:@"river_h.png"];
    }
    
    /*
     * Now we have two ranges specified by the
     * point x1, y1 and x2, y2.  The two points
     * might be the same if the coordinate was
     * simple, but we can still handle it like
     * a range.
     */
    if (vert) {
        for (float j = yi1; j <= yi2;) {
            int range = [self getRiverRange:j:yi2];
            if (range * (rSprite.contentSize.height) > yi2) {
                range = 1;
            }
            
            [rivers addObject:[self addRiver:xi1:j:vert:range]];
            
            j += range * (rSprite.contentSize.height);
            
        }
    } else {
        for (float i = xi1; i <= xi2;) {
            int range = [self getRiverRange:i:xi2];
            
            if (range * (rSprite.contentSize.width) > xi2) {
                range = 1;
            }
            
            [rivers addObject:[self addRiver:i:yi1:vert:range]];
            
            i += range * (rSprite.contentSize.width);
        }
    }
    
    /* 
     * At this point we've drawn the river, but we want to support
     * a special sprite for the end of the river so that we can give 
     * it a rounded corner.  For that we look to see if the river
     * specified a side and substitute the right sprites for the top
     * most and bottom most sections of the river.
     */
    if (vert && side != dNone) {
        if (yi1 != 0) {
            CCSprite *riverEnd;
            if (side == dRight) {
                riverEnd = [CCSprite spriteWithSpriteFrameName:@"river_v_br.png"];
            } else {
                riverEnd =  [CCSprite spriteWithSpriteFrameName:@"river_v_bl.png"];
            }
            riverEnd.position = ccp(xi1, yi1);
            riverEnd.tag = RIVER;
            [rivers removeObjectAtIndex:0];
            [rivers insertObject:riverEnd atIndex:0];
        }
        
        if (yi2 < [self getWinSize].height - _layerMgr.tileSize.height) {
            CCSprite *riverEnd2;
            if (side == dRight) {
                riverEnd2 = [CCSprite spriteWithSpriteFrameName:@"river_v_ur.png"];
            } else {
                riverEnd2 = [CCSprite spriteWithSpriteFrameName:@"river_v_tl.png"];
            }
            riverEnd2.position = ccp(xi2, yi2);
            riverEnd2.tag = RIVER;
            //[rivers removeLastObject];
            [rivers addObject:riverEnd2];
        }
    }
    
    if (vert && yi2 == [self getWinSize].height) {
        CCSprite *river = [CCSprite spriteWithSpriteFrameName:@"river_v.png"];
        river.position = ccp(xi2, yi2);
        river.tag = RIVER;
        [rivers addObject:river];
    }
    
    if (!vert && xi1 > 0) {
        [rivers removeObjectAtIndex:0];
    }
    
//    [rSprite release];
    CGPoint start = [self tileToPoint:xi1 :yi1];
    CGPoint end = [self tileToPoint:xi2 :yi2];
    
    RiverNode *node = [[RiverNode alloc] initWithFrame:CGRectMake(start.x, start.y, end.x - start.x, end.y - start.y): rivers];
    
    [self.rivers addObject:node];
    
}

/**
 * Parse the specified string as an int.  This string contains 
 * individual characters for preset coordinates.
 *
 * l - The left side of the screen
 * b - The bottom of the screen
 * r - The right side of the screen
 * t - The top of the screen
 * m - The vertical middle of the screen
 * c - The horizontal center of the screen
 */
-(float)parseInt:(NSString*) s {
    if ([s characterAtIndex:0] == 'l') {
        // The left side of the screen
        return 0;
    } else if ([s characterAtIndex:0] == 'b') {
        // The bottom side of the screen
        return 0;
    } else if ([s characterAtIndex:0] == 'r') {
        // The right side of the screen
        return [self winSizeTiles].width;
    } else if ([s characterAtIndex:0] == 't') {
        // The top side of the screen
        return [self winSizeTiles].height;
    } else if ([s characterAtIndex:0] == 'm') {
        // The vertical middle of the screen
        return [self winSizeTiles].height / 2;
    } else if ([s characterAtIndex:0] == 'c') {
        // The horizontal center of the screen
        return [self winSizeTiles].width / 2;
    } else {
        return [s floatValue];
    }
}

-(int) rand_lim: (int) limit {
    int divisor = RAND_MAX/(limit+1);
    int retval;
    
    do {
        retval = rand() / divisor;
    } while (retval > limit);
    
    return retval;
}

-(float)getRiverRange: (float) index: (float) size {
    
    int r = [self rand_lim:4];
    
    if (r == 1) {
        return 3;
    } else if (r == 2) {
        return 5;
    } else if (r == 3) {
        return 11;
    } else {
        return 1;
    }    
}

-(CCSprite*)addRiver:(float) x:(float) y:(BOOL) vert: (int) range {
    
    CCSprite *river;
    if (vert) {
        if (range == 3) {
            river = [CCSprite spriteWithSpriteFrameName:@"river_v_3.png"];
        } else if (range == 5) {
            river = [CCSprite spriteWithSpriteFrameName:@"river_v_5.png"];
        } else if (range == 11) {
            river = [CCSprite spriteWithSpriteFrameName:@"river_v_11.png"];
        } else {
            river = [CCSprite spriteWithSpriteFrameName:@"river_v.png"];
        }
        
        y += river.contentSize.height / 2;
        
        
    } else {
        if (range == 3) {
            river = [CCSprite spriteWithSpriteFrameName:@"river_h_3.png"];
        } else if (range == 5) {
            river = [CCSprite spriteWithSpriteFrameName:@"river_h_5.png"];
        } else if (range == 11) {
            river = [CCSprite spriteWithSpriteFrameName:@"river_h_11.png"];
        } else {
            river = [CCSprite spriteWithSpriteFrameName:@"river_h.png"];
        }
        
        x += river.contentSize.width / 2;
    }

    CGPoint startPos = ccp(x, y); //[self tileToPoint:x:y];
    
//    printf("addingRiverTo (%f, %f)\n", startPos.x, startPos.y);
    
    river.position = startPos;
    river.tag = RIVER;
    
    
    return river;
    
}

-(Bridge4Node*)addBridge4:(float) x:(float) y:(BridgeColor) color {
    
    //   CCSprite *bridge = [CCSprite spriteWithSpriteFrameName:@"bridge_v.png"];
    
    Bridge4Node *bridgeNode = [[Bridge4Node alloc] initWithTagAndColor:color:self.layerMgr];
    CGPoint startPos = [self tileToPoint:x:y];
    
    [bridgeNode setBridgePosition:startPos];
    
    [self.bridge4s addObject:bridgeNode];
    
    return bridgeNode;
    
}

-(BridgeNode*)addBridge:(float) x:(float) y:(bool) vertical:(BridgeDir) dir: (BridgeColor) color: (NSString*) coins {
    
    //   CCSprite *bridge = [CCSprite spriteWithSpriteFrameName:@"bridge_v.png"];
    
    BridgeNode *bridgeNode = [[BridgeNode alloc] initWithOrientAndDirAndCoins:vertical:dir:color:self.layerMgr: [self coins:coins]];
    CGPoint startPos = [self tileToPoint:x:y];
    
    [bridgeNode setBridgePosition:startPos];
    
    [self.bridges addObject:bridgeNode];
    
    return bridgeNode;
    
}

-(UIButton*)addLabel:(float) x:(float) y:(float) w:(float) h:(NSString*) text {

    /*
     * We make all labels buttons so the button consumes taps and the player
     * doesn't get lost under the labels.
     */
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGPoint s = [self tileToPoint:x:y];
    
    s = ccp(s.x, [LayerMgr normalizeYForControl:s.y]);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        w = w / 2;
        h = h / 2;
    }
    
    button.frame = CGRectMake(s.x, s.y, w * _layerMgr.tileSize.width, h * _layerMgr.tileSize.height);
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.layer setCornerRadius:8.0f];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    button.backgroundColor = [UIColor colorWithRed:(1.0 * 255) / 255 green:(1.0 * 255) / 255 blue:(1.0 * 153) / 255 alpha:0.7];
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.font = [UIFont fontWithName:@"Verdana" size: 14.0];
    button.titleEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    
    [button sizeThatFits:CGSizeMake(w, 0)];
    
    button.frame = CGRectMake(s.x, s.y, button.frame.size.width + 6, button.frame.size.height + 3);

    
    [self.labels addObject:button];
    
    
    return button;
    
}

-(bool)hasWon {
    for (BridgeNode *n in _bridges) {
        if (!n.isCrossed) {
            return false;
        }
    }
    
    for (Bridge4Node *n in _bridge4s) {
        if (!n.isCrossed) {
            return false;
        }
    }
    
    for (HouseNode *n in _houses) {
        if (!n.isVisited) {
            return false;
        }
    }
    
    return true;
    
}

-(int)coins:(NSString*)coins {
    if (coins) {
        return [coins integerValue];
    } else {
        return 0;
    }
}

-(HouseNode*)addHouse:(float) x:(float) y:(BridgeColor) color:(NSString*) coins {
    
    //   CCSprite *bridge = [CCSprite spriteWithSpriteFrameName:@"bridge_v.png"];
    
    HouseNode *houseNode = [[HouseNode alloc] initWithColorAndCoins:color:self.layerMgr:[self coins:coins]];
    CGPoint startPos = [self tileToPoint:x:y];
    
    [houseNode setHousePosition:startPos];
    
    [self.houses addObject:houseNode];
    
    return houseNode;
    
}

-(SubwayNode*)addSubway:(float) x1:(float) y1:(float) x2:(float) y2:(BridgeColor) color {
    
    //   CCSprite *bridge = [CCSprite spriteWithSpriteFrameName:@"bridge_v.png"];
    
    SubwayNode *subwayNode = [[SubwayNode alloc] initWithColor:color:self.layerMgr];
    
    subwayNode.subway1.position = [self tileToPoint:x1:y1];
    subwayNode.subway2.position = [self tileToPoint:x2:y2];
    
    [self.subways addObject:subwayNode];
    
    return subwayNode;
    
}

/**
 * Gets the dimensions of the current screen
 */
-(CGSize)getWinSize {
    //CGRect r = [[UIScreen mainScreen] bounds];
    //return r.size;
    return [[CCDirector sharedDirector] winSize];
}

-(void)resizeSprite:(CCSprite*) sprite: (float) tiles: (bool) vert {
    if (vert) {
        sprite.scaleY = self.layerMgr.tileSize.width/sprite.contentSize.width;
        sprite.contentSize = CGSizeMake(sprite.contentSize.width, self.layerMgr.tileSize.height);
    } else {
        sprite.scaleX = self.layerMgr.tileSize.width/sprite.contentSize.width;
        sprite.contentSize = CGSizeMake(self.layerMgr.tileSize.width, sprite.contentSize.height);
    }
    
}

/**
 * Gets the size of each tile in points on the screen.  All tiles are
 * squares.
 */
-(CGSize)winSizeTiles {
    CGSize winSize = [self getWinSize];
    return CGSizeMake(winSize.width / self.layerMgr.tileSize.width,
                      winSize.height / self.layerMgr.tileSize.height);
}

/**
 * Convert a position in tiles to a point on the screen
 */
-(CGPoint)tileToPoint:(float) x: (float)y {
//    printf("tileToPoint (%i, %i)\n", x, y);
//    printf("tileSize (%f, %f)\n", self.layerMgr.tileSize.width, self.layerMgr.tileSize.height);
    return CGPointMake(x * self.layerMgr.tileSize.width,
                       y * self.layerMgr.tileSize.height);
}

-(NSArray*) controls {
    NSMutableArray *controls = [NSMutableArray arrayWithCapacity:10];
    
    for (UIButton *l in self.labels) {
        [controls addObject:l];
    }
    
    for (BridgeNode *b in self.bridges) {
        for (UIControl *c in [b controls]) {
            [controls addObject:c];
        }
    }
    
    for (Bridge4Node *b in self.bridge4s) {
        for (UIControl *c in [b controls]) {
            [controls addObject:c];
        }
    }
    
    for (HouseNode *h in self.houses) {
        for (UIControl *c in [h controls]) {
            [controls addObject:c];
        }
    }
    
    return controls;
}

-(bool)hasCoins {
    for (BridgeNode *b in self.bridges) {
        if (b.coins > 0) {
            return true;
        }
    }
    
    for (Bridge4Node *b in self.bridge4s) {
        if (b.coins > 0) {
            return true;
        }
    }
    
    for (HouseNode *h in self.houses) {
        if (h.coins > 0) {
            return true;
        }
    }
    
    return false;
}

-(void)dealloc {
    
    [_rivers release];
    _rivers = nil;
    
    [_bridges release];
    _bridges = nil;
    
    [_bridge4s release];
    _bridge4s = nil;
    
    [_houses release];
    _houses = nil;
    
    [_subways release];
    _subways = nil;
    
    [_labels release];
    _labels = nil;
    
    [_name release];
    _name = nil;
    
    [_levelId release];
    _levelId = nil;
    
    [_levelData release];
    _levelData = nil;
    
    [super dealloc];
}

@end
