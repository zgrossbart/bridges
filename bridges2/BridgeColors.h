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


/*
 * These are used as tags for identifying items
 * after collision detection.
 */
static int const PLAYER = 0;
static int const RIVER = 1;
static int const BRIDGE = 2;
static int const BRIDGE3 = 3;
static int const BRIDGE4 = 4;
static int const HOUSE = 5;
static int const LEVEL = 6;

/*
 * The support object colors in the game.
 */
static int const NONE = -1;
static int const RED = 0;
static int const BLUE = 1;
static int const GREEN = 2;
static int const ORANGE = 3;
static int const BLACK = 4;

/*
 * These are the supported directions for things 
 * like bridges.
 */
static int const LEFT = 1;
static int const RIGHT = 2;
static int const UP = 3;
static int const DOWN = 4;

/*
 * The tile count represents the number of playable 
 * tiles in a give board.  All level object positions
 * are specified in tiles.  
 *
 * The playable level is 42 tiles wide and 28 tiles tall.
 */
static int const TILE_COUNT = 28;

/*
 * This variable controls debug drawing.  Change it to true
 * to see the tile grid and the boxes for each sprite.
 */
static bool const DEBUG_DRAW = false;
