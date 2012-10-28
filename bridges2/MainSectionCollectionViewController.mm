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

#import "MainSectionCollectionViewController.h"
#import "LevelCell.h"
#import "LevelMgr.h"
#import "Level.h"
#import "LevelSet.h"
#import "BridgeColors.h"
#import "StyleUtil.h"

@interface MainSectionCollectionViewController () {
    int _noOfSection;
}
@property (readwrite, retain) MainMenuViewController *menuView;

@end

@implementation MainSectionCollectionViewController

- (id)initWithNibNameAndMenuView:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil menu:(MainMenuViewController*) menuView {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.menuView = menuView;
        _noOfSection = 3;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [StyleUtil styleMenuButton:self.backBtn];
    
    [self.collectionView registerClass:[LevelCell class] forCellWithReuseIdentifier:@"levelCell"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    CGSize s = CGSizeMake(250, 250);
    
    [flowLayout setItemSize:s];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setFooterReferenceSize:CGSizeMake(0, 0)];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 * This method gets called when the user taps on a cell in the collection view.
 */
- (void)collectionView:(UICollectionView*) collectionView didSelectItemAtIndexPath:(NSIndexPath*) indexPath {
    int index = indexPath.section * _noOfSection + indexPath.row;
    if (index < [[LevelMgr getLevelMgr].levelSets count]) {
        [self.menuView showLevels:index];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*) collectionView {
    if ([[LevelMgr getLevelMgr].levelSets count] + 1 % _noOfSection == 0) {
        return ([[LevelMgr getLevelMgr].levelSets count] + 1) / _noOfSection;
    } else {
        return (([[LevelMgr getLevelMgr].levelSets count] + 1) / _noOfSection) + 1;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _noOfSection;
}

-(void) viewWillAppear:(BOOL)animated {
    [StyleUtil animateView:self.view];
    
}

/**
 * Create each cell in the collection view that we use to select levels on the iPad
 */
-(UICollectionViewCell*) collectionView:(UICollectionView*) collectionView cellForItemAtIndexPath:(NSIndexPath*) indexPath {
    NSString *cellIdentifier = @"levelCell";
    
    LevelCell *cell = (LevelCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    int index = indexPath.section * _noOfSection + indexPath.row;
    
    if (index >= [[LevelMgr getLevelMgr].levelSets count]) {
        cell.titleLabel.text = @"";
        [cell.screenshot setImage:nil];
        [cell setBorderVisible:false];
        cell.screenshot.backgroundColor = [UIColor colorWithRed:(1.0 * 250) / 255 green:(1.0 * 250) / 255 blue:(1.0 * 240) / 255 alpha:1.0];
        cell.titleLabel.backgroundColor = [UIColor colorWithRed:(1.0 * 250) / 255 green:(1.0 * 250) / 255 blue:(1.0 * 240) / 255 alpha:1.0];
        [cell.checkMark setImage:nil];
        
        if (index == [[LevelMgr getLevelMgr].levelSets count]) {
            cell.titleLabel.text = @"More coming soon";
            [cell setBorderVisible:true];
            [cell.screenshot setImage:[UIImage imageNamed: @"more.png"]];
            cell.screenshot.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_1024_768_River.png"]];
            cell.titleLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_1024_768_River.png"]];
        }
    } else {
        LevelSet *set = [LevelMgr getLevelSet:index];
        cell.titleLabel.text = set.name;
        [cell.screenshot setImage:[UIImage imageNamed: set.imageName]];
        [cell setBorderVisible:true];
        
        if ([self hasWon:set]) {
            [cell.checkMark setImage:[UIImage imageNamed:@"green_check.png"]];
        } else {
            [cell.checkMark setImage:nil];
        }
        
        cell.screenshot.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_1024_768_River.png"]];
        cell.titleLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_1024_768_River.png"]];
    }
    
    return cell;
    
}

-(bool)hasWon: (LevelSet*) set {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (NSString *levelId in set.levels) {
        Level *level = [set.levels objectForKey:levelId];
        if (![defaults boolForKey:[NSString stringWithFormat:@"%@-won", level.fileName]]) {
            return false;
        }
    }
    
    return true;
}

-(CGSize)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout*) collectionViewLayout referenceSizeForHeaderInSection:(NSInteger) section {
    return CGSizeMake(0, 0);
}

-(UIEdgeInsets)collectionView:(UICollectionView*) collectionView layout:(UICollectionViewLayout*) collectionViewLayout insetForSectionAtIndex:(NSInteger) section {
    return UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
}

- (void)dealloc {
    [_collectionView release];
    [self.menuView release];
    [_backBtn release];
    [super dealloc];
}

- (IBAction)backBtnTapped:(id)sender {
    [self.menuView backToMainTapped:sender];
}

@end
