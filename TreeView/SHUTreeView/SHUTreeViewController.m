

#import "SHUTreeViewController.h"
#import "SHUTreeView.h"


@interface SHUTreeViewController ()

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation SHUTreeViewController
{
    SHUTreeView *treeView;
}

- (void)initIvars{

	//Initialize here all the ivars that are not views.
	NSString *model= [[UIDevice currentDevice] model];
	NSString *simulator = @"Simulator";
	NSString *path = nil;
	if ([model hasSuffix:simulator]) {
		//Root
		path = @"/";
	} else {
		//Documents
		path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	}
	treeView = [[SHUTreeView alloc] initWithPath:path];

	self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	self.title = @"SHUTreeView";
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[self initIvars];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder{
	self = [super initWithCoder:coder];
	if (self) {
		[self initIvars];
	}
	return self;
}


- (void) viewDidLoad {
	[super viewDidLoad];

    // tableView の frame は view.bounds 全体と仮定。他の UI 部品を配置する場合は要調整。
    UITableView *tblView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tblView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tblView];
    self.tableView = tblView;
    
	self.navigationController.navigationBarHidden = NO;
	self.navigationController.toolbarHidden = NO;

	UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStyleBordered target:self action:@selector(sort:)];
	NSArray *items = [[NSArray alloc] initWithObjects:sortButton, nil];
	self.navigationController.toolbarItems = items;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.tableView.rowHeight = 44;
    }else{
        self.tableView.rowHeight = 66;
    }
	self.tableView.delegate = treeView;
	self.tableView.dataSource = treeView;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



@end
