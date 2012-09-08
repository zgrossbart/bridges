#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LayerMgr.h"

@interface PlayerNode : NSObject {
@private
    int _tag;
    LayerMgr *_manager;
    
    CCSprite *_playerSprite;
    b2Body *_spriteBody;
    CCAction *_walkAction;
    CCAction *_moveAction;
    BOOL _moving;
    
}

-(id)initWithTag:(int) tag:(int) color:(LayerMgr*) layerMgr;
-(void)updateColor:(int)color;
-(int)tag;
-(void)moveTo:(CGPoint)p;
-(void)moveTo:(CGPoint)p:(bool)force;
-(void)playerMoveEnded;

@property (readonly) CCSprite *player;
@property (nonatomic, assign, readonly) int color;
@property (nonatomic, retain) CCAction *walkAction;
@property (nonatomic, retain) CCAction *moveAction;
@property (nonatomic, assign, readwrite) int coins;

@end