#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LayerMgr.h"

@interface PlayerNode : CCLayer {
@private
    int _tag;
    LayerMgr *_manager;
    
    CCSprite *_playerSprite;
    CCAction *_walkAction;
    CCAction *_moveAction;
    BOOL _moving;
    
}

-(id)initWithTag:(int) tag:(int) color:(LayerMgr*) layerMgr;
-(void)updateColor:(int)color;
-(int)tag;
-(void)moveTo:(CGPoint)p;
-(void)playerMoveEnded;

@property (readonly) CCSprite *player;
@property (nonatomic, assign, readonly) int color;
@property (nonatomic, retain) CCAction *walkAction;
@property (nonatomic, retain) CCAction *moveAction;

@end