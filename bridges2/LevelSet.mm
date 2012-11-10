/*******************************************************************************
 *
 * Copyright 2012 Zack Grossbart
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************/

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
