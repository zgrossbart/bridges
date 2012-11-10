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

#import "MainPageViewController.h"
#import "MainSectionViewController.h"
#import "LevelMgr.h"
#import "StyleUtil.h"

@interface MainPageViewController () {
}

@property (nonatomic, retain, readwrite) NSMutableArray *views;
@property (readwrite, retain) MainMenuViewController *menuView;

@end

@implementation MainPageViewController

-(id)initWithNibNameAndMenuView:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil menu:(MainMenuViewController*) menuView {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.views = [NSMutableArray arrayWithCapacity:[[LevelMgr getLevelMgr].levelSets count] + 1];
        self.menuView = menuView;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [StyleUtil styleMenuButton:self.backBtn];
    
	_scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * ([[LevelMgr getLevelMgr].levelSets count] + 1), _scrollView.frame.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.delegate = self;
    
    _pageControl.numberOfPages = [[LevelMgr getLevelMgr].levelSets count] + 1;
    _pageControl.currentPage = 0;
}

-(void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
}

-(void)setScrollPage:(int)page {
    _pageControl.currentPage = page;
    [self pageChanged:nil];
}

-(void)loadScrollViewWithPage:(int)page {
    if (page < 0 ||
        page >= [[LevelMgr getLevelMgr].levelSets count] + 1) {
        return;
    }
    
    MainSectionViewController *controller = nil;
    
    if (page < [self.views count]) {
        controller = [self.views objectAtIndex:page];
    } else {
        controller = [[[MainSectionViewController alloc] initWithNibAndMenuView:nil bundle:nil menu:self.menuView index:page] autorelease];
        [self.views addObject:controller];
    }    
	
    if (nil == controller.view.superview) {
        CGRect frame = _scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [_scrollView addSubview:controller.view];
        [self setViewDetails:controller page:page];
        
    }
}

-(void)refresh {
    for (int i = 0; i < [self.views count]; i++) {
        MainSectionViewController *controller = (MainSectionViewController*) [self.views objectAtIndex:i];
        if ([self hasWon:[LevelMgr getLevelSet:i]]) {
            [controller.checkMark setImage:[UIImage imageNamed:@"green_check.png"]];
        }
    }
    
}

-(void)setViewDetails: (MainSectionViewController*) controller page:(int)page {
    if ([[LevelMgr getLevelMgr].levelSets count] == page) {
        controller.label.text = @"More levels are coming soon";
        [controller.playBtn setImage:[UIImage imageNamed: @"more.png"] forState:UIControlStateNormal];
    } else {
        controller.label.text = [LevelMgr getLevelSet:page].name;
        [controller.playBtn setImage:[UIImage imageNamed: [LevelMgr getLevelSet:page].imageName] forState:UIControlStateNormal];
        if ([self hasWon:[LevelMgr getLevelSet:page]]) {
            [controller.checkMark setImage:[UIImage imageNamed:@"green_check.png"]];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
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


-(IBAction)pageChanged:(id)sender {
    int page = _pageControl.currentPage;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    // update the scroll view to the appropriate page
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:NO];
}

-(void) viewWillAppear:(BOOL)animated {
    if ([LevelMgr getLevelMgr].currentSet > -1) {
        [self setScrollPage:[LevelMgr getLevelMgr].currentSet];
        [LevelMgr getLevelMgr].currentSet = -1;
    } else {
        [self loadScrollViewWithPage:0];
    }
    
    [StyleUtil animateView:self.view];
}

-(IBAction)backToMainTapped:(id)sender {
    [self.menuView backToMainTapped:sender];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [_scrollView release];
    [self.views release];
    [_pageControl release];
    [self.menuView release];
    [_backBtn release];
    [super dealloc];
}

@end
