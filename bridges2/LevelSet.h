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

#import <Foundation/Foundation.h>

/**
 * Levels are organized into sets so we can group them along similar themes and into
 * easier chunks to deal with.  This object is a little struct containing the information
 * about a specific set of levels.
 */
@interface LevelSet : NSObject

/**
 * Create a new LevelSet
 *
 * @param name the display name of the level
 * @param the sorted IDs of the levels in this set
 * @param the levels in this set
 * @param the index of this set in relation to the other sets
 * @param the name of the image for this set
 */
-(id)initWithNameAndLevels: (NSString*) name levelIds:(NSArray*) levelIds levels:(NSDictionary*) levels index:(int) index imageName:(NSString*) imageName;

/**
 * The name of this level set
 */
@property (readonly, retain) NSString *name;

/**
 * The name of the image for this level set
 */
@property (readonly, retain) NSString *imageName;

/**
 * The index of this level set in the array of level sets
 */
@property (readonly) int index;

/**
 * The sorted list of IDs for the level in this set
 */
@property (readonly, retain) NSArray *levelIds;

/**
 * The levels in this set
 */
@property (readonly, retain) NSDictionary *levels;

@end
