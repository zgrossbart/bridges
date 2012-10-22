//
//  LevelSet.m
//  bridges2
//
//  Created by Zack Grossbart on 10/21/12.
//
//

#import "LevelSet.h"

@interface LevelSet()

@property (readwrite, retain) NSString *name;
@property (readwrite, retain) NSString *imageName;
@property (readwrite) int index;
@property (readwrite, retain) NSArray *levelIds;
@property (readwrite, retain) NSDictionary *levels;

@end

@implementation LevelSet

-(id)initWithNameAndLevels: (NSString*) name levelIds:(NSArray*) levelIds levels:(NSDictionary*) levels index:(int) index imageName:(NSString*) imageName {
    if( (self=[super init] )) {
        self.name = name;
        self.levelIds = levelIds;
        self.levels = levels;
        self.index = index;
        self.imageName = imageName;
    }
    
    return self;
    
}

@end
