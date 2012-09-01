//
//  LevelMgr.m
//  bridges2
//
//  Created by Zack Grossbart on 9/1/12.
//
//

#import "LevelMgr.h"
#import "JSONKit.h"

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
            [self getLevelName:[path stringByAppendingPathComponent:file]:file];
        }
    }
    
//    NSLog(@"levels ====== %@",self.levels);
}

-(NSString*)getLevelName:(NSString*) path:(NSString*) file {
    NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"jsonString\n: %@", jsonString);
    NSDictionary *level = [[jsonString objectFromJSONString] objectForKey:@"level"];
    
    NSString *name = [level objectForKey:@"name"];
    
    [self.levels setObject:name forKey:file];
    
    return name;
    
}

-(void)dealloc {
    
    [_levels release];
    _levels = nil;
    
    [super dealloc];
    
}

@end
