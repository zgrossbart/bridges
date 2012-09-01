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
#import "HouseNode.h"
#import "JSONKit.h"

@interface Level()
@property (readwrite) NSMutableArray *rivers;
@property (readwrite) NSMutableArray *bridges;
@property (readwrite) NSMutableArray *houses;
@property (readwrite) LayerMgr *layerMgr;
@end

@implementation Level

-(id) initWithJson:(NSString*) jsonString: (LayerMgr*) layerMgr
{
    if( (self=[super init] )) {
        self.bridges = [[NSMutableArray alloc] init];
        self.rivers = [[NSMutableArray alloc] init];
        self.houses = [[NSMutableArray alloc] init];
        
        self.layerMgr = layerMgr;
        
        [self parseLevel:jsonString];
    }
    
    return self;
    
}

-(void)parseLevel: (NSString*) jsonString {
    NSLog(@"jsonString\n: %@", jsonString);
    NSDictionary *level = [[jsonString objectFromJSONString] objectForKey:@"level"];
    NSString *name = [level objectForKey:@"name"];
    NSLog(@"name: %@", name);
    
    NSArray *rivers = [level objectForKey:@"rivers"];
    NSLog(@"rivers.count: %i", rivers.count);
    
    /*
     * Add the rivers
     */
    for (NSDictionary *r in rivers) {
        NSString *x = [r objectForKey:@"x"];
        NSString *y = [r objectForKey:@"y"];
        NSString *dir = [r objectForKey:@"dir"];
        
        [self addRivers:x:y:[dir isEqualToString:@"v"]];
    }
    
    /*
     * Add the bridges
     */
    NSArray *bridges = [level objectForKey:@"bridges"];
    for (NSDictionary *b in bridges) {
        NSString *x = [b objectForKey:@"x"];
        NSString *y = [b objectForKey:@"y"];
        NSString *dir = [b objectForKey:@"dir"];
        NSString *color = [b objectForKey:@"color"];
        
        [self addBridge:[x integerValue]:[y integerValue]:
         [dir isEqualToString:@"v"]:[self getColor:color]];
    }
    
    /*
     * Add the houses
     */
    NSArray *houses = [level objectForKey:@"houses"];
    for (NSDictionary *h in houses) {
        NSString *x = [h objectForKey:@"x"];
        NSString *y = [h objectForKey:@"y"];
        NSString *color = [h objectForKey:@"color"];
        
        [self addHouse:[x integerValue]:[y integerValue]:[self getColor:color]];
    }
    
}

-(void)addSprites {
    for (CCSprite *r in self.rivers) {
        [self.layerMgr addChildToSheet:r];
    }
    
    for (BridgeNode *b in self.bridges) {
        [b addSprite];
    }
    
    for (HouseNode *h in self.houses) {
        [h addSprite];
    }
}

-(int)getColor:(NSString*) color {
    if ([color isEqualToString:@"red"]) {
        return RED;
    } else if ([color isEqualToString:@"green"]) {
        return GREEN;
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
    
    int xi1 = [self parseInt:x1];
    int yi1 = [self parseInt:y1];
    
    int xi2 = [self parseInt:x2];
    int yi2 = [self parseInt:y2];
    
    /*
     * Now we have two ranges specified by the
     * point x1, y1 and x2, y2.  The two points
     * might be the same if the coordinate was
     * simple, but we can still handle it like
     * a range.
     */
    for (int i = xi1; i <= xi2; i++) {
        for (int j = yi1; j <= yi2; j++) {
            [self addRiver:i:j:vert];
            
        }
    }
    
}

-(int)parseInt:(NSString*) s {
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
    } else {
        return [s integerValue];
    }
}

- (CCSprite*)addRiver:(int) x:(int) y:(BOOL) vert {
    
    CCSprite *river;
    if (vert) {
        river = [CCSprite spriteWithSpriteFrameName:@"river_h.png"];
    } else {
        river = [CCSprite spriteWithSpriteFrameName:@"river_v.png"];
    }
    
    [self resizeSprite:river:1];
    CGPoint startPos = [self tileToPoint:x:y];
    
//    printf("addingRiverTo (%f, %f)\n", startPos.x, startPos.y);
    
    river.position = startPos;
    river.tag = RIVER;
    
    [self.rivers addObject:river];
    
    return river;
    
}

- (BridgeNode*)addBridge:(int) x:(int) y:(bool) vertical:(int) color {
    
    //   CCSprite *bridge = [CCSprite spriteWithSpriteFrameName:@"bridge_v.png"];
    
    BridgeNode *bridgeNode = [[BridgeNode alloc] initWithDir:vertical:BRIDGE:color:self.layerMgr];
    CGPoint startPos = [self tileToPoint:x:y];
    
    [bridgeNode setBridgePosition:startPos];
    
    [self.bridges addObject:bridgeNode];
    
    return bridgeNode;
    
}

-(bool)hasWon {
    for (BridgeNode *n in _bridges) {
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

-(HouseNode*)addHouse:(int) x:(int) y:(int) color {
    
    //   CCSprite *bridge = [CCSprite spriteWithSpriteFrameName:@"bridge_v.png"];
    
    HouseNode *houseNode = [[HouseNode alloc] initWithColor:HOUSE:color:self.layerMgr];
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

-(void)resizeSprite:(CCSprite*) sprite: (int) tiles {
    sprite.scale = self.layerMgr.tileSize.width/sprite.contentSize.width;
    sprite.contentSize = self.layerMgr.tileSize;
    
}

-(CGSize)winSizeTiles {
    CGSize winSize = [self getWinSize];
    return CGSizeMake(winSize.width / self.layerMgr.tileSize.width,
                      winSize.height / self.layerMgr.tileSize.height);
}

-(CGPoint)tileToPoint:(int) x: (int)y {
//    printf("tileToPoint (%i, %i)\n", x, y);
//    printf("tileSize (%f, %f)\n", self.layerMgr.tileSize.width, self.layerMgr.tileSize.height);
    return CGPointMake(x * self.layerMgr.tileSize.width,
                       y * self.layerMgr.tileSize.height);
}

-(void)dealloc {
    
    [_rivers release];
    _rivers = nil;
    
    [_bridges release];
    _bridges = nil;
    
    [_houses release];
    _houses = nil;
    
    [super dealloc];
}

@end
