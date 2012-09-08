//
//  RiverNode.m
//  Cocos2DSimpleGame
//
//  Created by Zack Grossbart on 8/19/12.
//
//

#import "HouseNode.h"
#import "BridgeColors.h"

@interface HouseNode()
@property (readwrite, retain) CCSprite *house;
@property (nonatomic, assign, getter=isVisited, readwrite) bool visited;
@property (nonatomic, assign, readwrite) int color;
@property (readwrite) LayerMgr *layerMgr;
@property (nonatomic, assign, readwrite) int tag;
@property (nonatomic, assign, readwrite) int coins;
@end

@implementation HouseNode

-(id)initWithColor:(int) tag:(int) color:(LayerMgr*) layerMgr {
    self = [super init];
    return [self initWithColorAndCoins:tag :color :layerMgr :0];
}
    
-(id)initWithColorAndCoins:(int) tag:(int) color:(LayerMgr*) layerMgr: (int) coins {
    
    if( (self=[super init] )) {
        self.layerMgr = layerMgr;
        self.tag = tag;
        self.visited = false;
        self.color = color;
        [self setHouseSprite:[CCSprite spriteWithSpriteFrameName:[self getSpriteName]]];
        
        self.coins = coins;
        
        if (self.coins > 0) {
            _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
            _label.text = [NSString stringWithFormat:@"%i", self.coins];
            _label.textColor = [UIColor blackColor];
            _label.backgroundColor = [UIColor lightGrayColor];
            _label.layer.cornerRadius = 6;
            _label.font = [UIFont fontWithName:@"Verdana" size: 11.0];
            _label.textAlignment = UITextAlignmentCenter;
            [_label sizeToFit];
            
            _label.frame = CGRectMake(0, 0, _label.frame.size.width + 6, _label.frame.size.height + 3);
        }
    }
    
    return self;
}

-(NSString*)getSpriteName {
    if (self.color == RED) {
        return @"house_red.png";
    } else if (self.color == BLUE) {
        return @"house_blue.png";
    } else if (self.color == GREEN) {
        return @"house_green.png";
    } else if (self.color == ORANGE) {
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

- (void) addSprite {
    [self.layerMgr addChildToSheet:self.house];
}

-(void)setHouseSprite:(CCSprite*)house {
    self.house = house;
    self.house.tag = [self tag];
}

-(void)visit {
    if (self.coins > 0) {
        self.coins--;
        _label.text = [NSString stringWithFormat:@"%i", self.coins];
    }
    
    if (self.coins == 0 && !self.visited) {
        CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame* frame;
        frame = [cache spriteFrameByName:@"house_gray.png"];
        [self.house setDisplayFrame:frame];
        self.visited = true;
    }
    
}

-(void)setHousePosition:(CGPoint)p {
    self.house.position = ccp(p.x, p.y);
    if (_label != nil) {
        _label.frame = CGRectMake(p.x, [LayerMgr normalizeYForControl:p.y] - _label.frame.size.height, _label.frame.size.width, _label.frame.size.height);
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
        [_label dealloc];
    }
    
    [self.house dealloc];
    [super dealloc];
}

@end
