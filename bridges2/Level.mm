//
//  Level.m
//  bridges2
//
//  Created by Zack Grossbart on 9/1/12.
//
//

#import "Level.h"
#import "BridgeColors.h"
#import "BridgeNode.h"
#import "Bridge4Node.h"
#import "HouseNode.h"
#import "JSONKit.h"

@interface Level()
@property (readwrite) NSMutableArray *rivers;
@property (readwrite) NSMutableArray *bridges;
@property (readwrite) NSMutableArray *bridge4s;
@property (readwrite) NSMutableArray *houses;
@property (readwrite) NSMutableArray *labels;
@property (readwrite) LayerMgr *layerMgr;
@property (readwrite, copy) NSDictionary *levelData;

@property (readwrite) NSString *name;
@property (readwrite) NSDate *date;
@property (readwrite) NSString *levelId;
@property (readwrite) CGPoint playerPos;
@end

@implementation Level

-(id) initWithJson:(NSString*) jsonString: (NSDate*) date;
{
    if( (self=[super init] )) {
        self.bridges = [[NSMutableArray alloc] init];
        self.bridge4s = [[NSMutableArray alloc] init];
        self.rivers = [[NSMutableArray alloc] init];
        self.houses = [[NSMutableArray alloc] init];
        self.labels = [[NSMutableArray alloc] init];
        self.date = date;
        
        [self parseLevel:jsonString];
    }
    
    return self;
    
}

-(void)parseLevel: (NSString*) jsonString {
    self.levelData = [[jsonString objectFromJSONString] objectForKey:@"level"];
    
    _levelId = [self.levelData objectForKey:@"id"];
    _name = [self.levelData objectForKey:@"name"];
}

-(void)loadSprites {
    
    if ([self.levelData objectForKey:@"player"] != nil) {
        self.playerPos = [self tileToPoint:[self parseInt:[[self.levelData objectForKey:@"player"] objectForKey:@"x"]]:
                             [self parseInt:[[self.levelData objectForKey:@"player"] objectForKey:@"y"]]];
    } else {
        self.playerPos = ccp(-1, -1);
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
        
        [self addRivers:x:y:[dir isEqualToString:@"v"]];
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

-(int)getDir:(NSString*) dir {
    if ([@"left" isEqualToString:dir]) {
        return LEFT;
    } else if ([@"right" isEqualToString:dir]) {
        return RIGHT;
    } else if ([@"up" isEqualToString:dir]) {
        return UP;
    } else if ([@"down" isEqualToString:dir]) {
        return DOWN;
    } else {
        return NONE;
    }
}

-(void)removeSprites:(LayerMgr*) layerMgr {
    self.layerMgr = layerMgr;
    
    if (self.rivers.count == 0) {
        /* 
         * If we haven't loaded yet then there's nothing to do
         */
        return;
    }
    
    
    [self.rivers removeAllObjects];
    [self.bridges removeAllObjects];
    [self.bridge4s removeAllObjects];
    [self.houses removeAllObjects];
}

-(void)addSprites: (LayerMgr*) layerMgr: (UIView*) view {
    
    self.layerMgr = layerMgr;
    
    if (self.rivers.count > 0) {
        [self removeSprites:self.layerMgr];
    } 
    
    [self loadSprites];
    
    if (view != nil) {
        for (UIButton *l in self.labels) {
            [view addSubview:l];
        }
    }
    
    for (CCSprite *r in self.rivers) {
        [self.layerMgr addChildToSheet:r];
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
    
}

-(int)getColor:(NSString*) color {
    if ([color isEqualToString:@"red"]) {
        return RED;
    } else if ([color isEqualToString:@"green"]) {
        return GREEN;
    } else if ([color isEqualToString:@"orange"]) {
        return ORANGE;
    } else if ([color isEqualToString:@"blue"]) {
        return BLUE;
    } else if ([color isEqualToString:@"black"]) {
        return BLACK;
    } else {
        return NONE;
    }
}

-(void)addRivers:(NSString*) xSpec:(NSString*) ySpec:(BOOL) vert {
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
    
    float xi1 = [self parseInt:x1];
    float yi1 = [self parseInt:y1];
    
    float xi2 = [self parseInt:x2];
    float yi2 = [self parseInt:y2];
    
    /*
     * Now we have two ranges specified by the
     * point x1, y1 and x2, y2.  The two points
     * might be the same if the coordinate was
     * simple, but we can still handle it like
     * a range.
     */
    for (float i = xi1; i <= xi2; i++) {
        for (float j = yi1; j <= yi2; j++) {
            [self addRiver:i:j:vert];
            
        }
    }
    
}

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

- (CCSprite*)addRiver:(float) x:(float) y:(BOOL) vert {
    
    CCSprite *river;
    if (vert) {
        river = [CCSprite spriteWithSpriteFrameName:@"river_v.png"];
    } else {
        river = [CCSprite spriteWithSpriteFrameName:@"river_h.png"];
    }
    
    [self resizeSprite:river:1:vert];
    CGPoint startPos = [self tileToPoint:x:y];
    
//    printf("addingRiverTo (%f, %f)\n", startPos.x, startPos.y);
    
    river.position = startPos;
    river.tag = RIVER;
    
    [self.rivers addObject:river];
    
    return river;
    
}

- (Bridge4Node*)addBridge4:(float) x:(float) y:(float) color {
    
    //   CCSprite *bridge = [CCSprite spriteWithSpriteFrameName:@"bridge_v.png"];
    
    Bridge4Node *bridgeNode = [[Bridge4Node alloc] initWithTagAndColor:BRIDGE4:color:self.layerMgr];
    CGPoint startPos = [self tileToPoint:x:y];
    
    [bridgeNode setBridgePosition:startPos];
    
    [self.bridge4s addObject:bridgeNode];
    
    return bridgeNode;
    
}

- (BridgeNode*)addBridge:(float) x:(float) y:(bool) vertical:(float) dir: (float) color: (NSString*) coins {
    
    //   CCSprite *bridge = [CCSprite spriteWithSpriteFrameName:@"bridge_v.png"];
    
    BridgeNode *bridgeNode = [[BridgeNode alloc] initWithOrientAndDirAndCoins:vertical:dir:BRIDGE:color:self.layerMgr: [self coins:coins]];
    CGPoint startPos = [self tileToPoint:x:y];
    
    [bridgeNode setBridgePosition:startPos];
    
    [self.bridges addObject:bridgeNode];
    
    return bridgeNode;
    
}

-(UIButton*)addLabel:(float) x:(float) y:(float) w:(float) h:(NSString*) text {

    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGPoint s = [self tileToPoint:x:y];
    button.frame = CGRectMake(s.x, s.y, w * _layerMgr.tileSize.width, h * _layerMgr.tileSize.height);
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.layer setCornerRadius:8.0f];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor:[[UIColor clearColor] CGColor]];
    button.backgroundColor = [UIColor colorWithRed:(1.0 * 224) / 255 green:(1.0 * 203) / 255 blue:(1.0 * 97) / 255 alpha:0.7];
    button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    button.titleLabel.font = [UIFont fontWithName:@"Lucida Grande" size: 14.0];
    button.titleEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
//    button.titleLabel.textAlignment = UITextAlignmentCenter;
    
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

-(HouseNode*)addHouse:(float) x:(float) y:(float) color:(NSString*) coins {
    
    //   CCSprite *bridge = [CCSprite spriteWithSpriteFrameName:@"bridge_v.png"];
    
    HouseNode *houseNode = [[HouseNode alloc] initWithColorAndCoins:HOUSE:color:self.layerMgr:[self coins:coins]];
    CGPoint startPos = [self tileToPoint:x:y];
    
    [houseNode setHousePosition:startPos];
    
    [self.houses addObject:houseNode];
    
    return houseNode;
    
}

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

-(CGSize)winSizeTiles {
    CGSize winSize = [self getWinSize];
    return CGSizeMake(winSize.width / self.layerMgr.tileSize.width,
                      winSize.height / self.layerMgr.tileSize.height);
}

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
