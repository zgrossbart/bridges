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
    
    glLineWidth(6.0f);
    ccDrawColor4B(255,0,255,255);
    ccDrawLine( ccp(0, 0), ccp(100, 0) );
    
    glLineWidth(3.0f);
    ccDrawColor4B(255,0,0,255);
    
    
    ccDrawRect( ccp(20, 20), ccp(40, 40) );
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    ccPointSize(32);
	ccDrawColor4B(0,0,255,128);
	ccDrawPoint( ccp(s.width / 2, s.height / 2) );
    
}

-(void)dealloc {
    
    delete _world;
    [super dealloc];
}

@end