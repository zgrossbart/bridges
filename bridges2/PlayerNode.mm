    //
//  RiverNode.m
//  Cocos2DSimpleGame
//
//  Created by Zack Grossbart on 8/19/12.
//
//

#import "PlayerNode.h"
#import "BridgeColors.h"

@interface PlayerNode()
@property (readwrite) CCSprite *player;
@property (nonatomic, assign, readwrite) int color;
@end

@implementation PlayerNode

@synthesize player = _player;
@synthesize moveAction = _moveAction;
@synthesize walkAction = _walkAction;

-(id)initWithTag:(int)tag :(int) color: (LayerMgr *)layerMgr {
    if( (self=[super init] )) {
        _manager = layerMgr;
        _tag = tag;
        self.color = color;
        if (color == RED) {
            [self setPlayerSprite:[CCSprite spriteWithSpriteFrameName:@"octopus1_red.png"]];
        } else if (color == BLUE) {
            [self setPlayerSprite:[CCSprite spriteWithSpriteFrameName:@"octopus1_blue.png"]];
        } else if (color == GREEN) {
            [self setPlayerSprite:[CCSprite spriteWithSpriteFrameName:@"octopus1_green.png"]];
        } else if (color == BLACK) {
            [self setPlayerSprite:[CCSprite spriteWithSpriteFrameName:@"octopus1.png"]];
        }
        
        NSMutableArray *walkAnimFrames = [NSMutableArray array];
        for(int i = 1; i <= 5; ++i) {
            [walkAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"octopus%d.png", i]]];
        }
        
        CCAnimation *walkAnim = [CCAnimation
                                 animationWithSpriteFrames:walkAnimFrames delay:0.1f];
        
        //        CGSize winSize = [CCDirector sharedDirector].winSize;
        //self.player = [CCSprite spriteWithSpriteFrameName:@"octopus1.png"];
//        _playerSprite.position = ccp(200, 100);
        self.walkAction = [CCRepeatForever actionWithAction:
                           [CCAnimate actionWithAnimation:walkAnim]];
        //
//        [_spriteSheet addChild:_playerSprite];
        
        _spriteBody = [_manager addChildToSheet:self.player];
    }
    
    return self;
}

-(void)playerMoveEnded {
    [_player stopAction:_walkAction];
    _moving = FALSE;
    
    /*
     * If this move caused us to collide with something (like crossing 
     * a bridge) then the bounding box for our sprite gets stuck against
     * the item we collided with until the next click.  We need to manually
     * update the position so the next click can move the player sprite
     * properly instead of just repositioning the box.
     */
    _spriteBody->SetTransform(b2Vec2(self.player.position.x,self.player.position.y), _spriteBody->GetAngle());
}

-(void)updateColor:(int)color {
    self.color = color;
    
    CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame* frame;
    
    if (color == RED) {
        frame = [cache spriteFrameByName:@"octopus1_red.png"];
    } else if (color == BLUE) {
        frame = [cache spriteFrameByName:@"octopus1_blue.png"];
    } else if (color == GREEN) {
        frame = [cache spriteFrameByName:@"octopus1_green.png"];
    } else if (color == BLACK) {
        frame = [cache spriteFrameByName:@"octopus1.png"];
    }
    
    [self.player setDisplayFrame:frame];
}

-(void)setPlayerSprite:(CCSprite*)player {
    self.player = player;
    self.contentSize = CGSizeMake(self.player.contentSize.width,
                                  self.player.contentSize.height);
    self.player.tag = [self tag];
}

-(void)moveTo:(CGPoint)p:(bool)force {
    if (force) {
        _moving = false;
    }
    
    [self moveTo:p];
}

-(void)moveTo:(CGPoint)p {
    if (_moving) {
        /*
         * If we're already moving then we just ignore 
         * new requests to move.
         */
        return;
    }
    
    [_player runAction:_walkAction];
    
    CGFloat distance = [LayerMgr distanceBetweenTwoPoints:_player.position: p];
    float velocity = 240/1; // 240pixels/1sec
    
    _moving = TRUE;
    self.moveAction = [CCSequence actions:
                       [CCMoveTo actionWithDuration:distance/velocity position:p],
                       [CCCallFunc actionWithTarget:self selector:@selector(playerMoveEnded)],
                       nil
                       ];
    
   // self.moveAction =
   //           [CCMoveTo actionWithDuration:distance/velocity position:ccp(p.x,p.y)];
    
    
    [_player runAction:self.moveAction];
}

-(void)position:(CGPoint)p {
    super.position = p;
    self.player.position = ccp(p.x, p.y);
}

-(int)tag {
    return _tag;
}

-(void)dealloc {
    
    [self.player dealloc];
    
    self.player = nil;
    self.walkAction = nil;
    
    [super dealloc];
}

@end
