//
//  LevelMgr.m
//  bridges2
//
//  Created by Zack Grossbart on 9/1/12.
//
//

#import "LevelMgr.h"
#import "JSONKit.h"
#import "Level.h"

@interface LevelMgr()
@property (readwrite) NSMutableDictionary *levels;
@end

@implementation LevelMgr

+ (LevelMgr*)getLevelMgr {
    static LevelMgr *levelMgr;
    
    @synchronized(self)
    {
        if (!levelMgr) {
            levelMgr = [[LevelMgr alloc] init];
            levelMgr.levels = [[NSMutableDictionary alloc] init];
            
            [levelMgr loadLevels];
        }
        
        return levelMgr;
    }
}

-(void)loadLevels {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    
    NSError *error;
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    for (NSString *file in directoryContents) {
        if ([file hasPrefix:@"level"] &&
            [file hasSuffix:@".json"]) {
            NSString *jsonString = [NSString stringWithContentsOfFile:[path stringByAppendingPathComponent:file] encoding:NSUTF8StringEncoding error:nil];
            Level *level = [[Level alloc] initWithJson:jsonString];
            [self.levels setObject:level forKey:level.levelId];
        }
    }
    
//    NSLog(@"levels ====== %@",self.levels);
}

-(void)dealloc {
    
    [_levels release];
    _levels = nil;
    
    [super dealloc];
    
}

@end
