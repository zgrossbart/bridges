#import "HelloWorldLayer.h"

//#define PTM_RATIO 32.0

@implementation HelloWorldLayer

+ (id)scene {
    
    CCScene *scene = [CCScene node];
    HelloWorldLayer *layer = [HelloWorldLayer node];
    [scene addChild:layer];
    return scene;
    
}

- (id)init {
    
    if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
        
    }
    return self;
    
}

-(void)draw {
    
    [super draw];
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    ccDrawColor4B(255,255,255,255);
    ccDrawSolidRect( ccp(0, 0), ccp(s.width, s.height), ccc4f(255, 255, 255, 255) );
    
    glLineWidth(6.0f);
    ccDrawColor4B(255,0,255,255);
    ccDrawLine( ccp(150, 250), ccp(250, 250) );
    
    glLineWidth(3.0f);
    ccDrawColor4B(255,0,0,255);
    
    
    ccDrawRect( ccp(100, 100), ccp(40, 40) );
    
    
    
    ccPointSize(32);
	ccDrawColor4B(0,0,255,128);
	ccDrawPoint( ccp(s.width / 2, s.height / 2) );
    
}

-(void)dealloc {
    
    delete _world;
    [super dealloc];
}

@end