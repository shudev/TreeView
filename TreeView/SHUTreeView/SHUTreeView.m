

#import "SHUTreeView.h"
#import "SHUTreeViewCell.h"
#import "SHUTreeNode.h"

@interface SHUTreeView ()
{
	NSMutableArray *selectedNodes;
	BOOL inPseudoEditMode;
	SHUTreeNode *_baseDir;
	NSMutableArray *_sortDescriptors;
	NSMutableArray *_sortedNodes;
}
@end

@implementation SHUTreeView

@synthesize sortDescriptors = _sortDescriptors;

@synthesize selectedNodes;
@synthesize isInPseudoEditMode;

- (id) initWithPath:(NSString *)baseDirectoryPath {
	self = [super init];
	if (self) {
		_baseDir = [[SHUTreeNode alloc] initWithName:[baseDirectoryPath lastPathComponent]
										 parentPath:[baseDirectoryPath stringByDeletingLastPathComponent]];
		_sortDescriptors = nil;
		_sortedNodes = nil;
    
		selectedNodes = [[NSMutableArray alloc] init];
		inPseudoEditMode = NO;
	}
	return self;
}

- (NSRange) expandNodeAtIndex:(NSUInteger)index{
	
	SHUTreeNode *node = (SHUTreeNode *)[self.nodes objectAtIndex:index];
	[self _sortChildrenNodesOfNode:node];
	
	[node expand];
	int collapsedNum = [self _insertChildren:node.children inArray:_sortedNodes atIndex:index+1];
	
    
	NSRange expandRange = NSMakeRange(index+1, collapsedNum);
	return expandRange;
}

- (NSRange) collapseNodeAtIndex:(NSUInteger)index{
	
	SHUTreeNode *node = (SHUTreeNode *)[_sortedNodes objectAtIndex:index];
	int collapsedNum = [self _collapseNode:node];
	
	NSRange collapseRange = NSMakeRange(index+1, collapsedNum);
	[_sortedNodes removeObjectsInRange:collapseRange];
	[node collapse];
	return collapseRange;
	
}


#pragma mark - 再起呼び出しメソッド

//recursively composites array, array is assumed to be empty
- (void) _compositeSorteNodes:(NSMutableArray *)array
                  baseDirNode:(SHUTreeNode *)dirNode{
	NSArray *childrenNodes = dirNode.children;
	for (SHUTreeNode *node in childrenNodes) {
		[array addObject:node];
		if (node.directoryIsExpanded) {
			[self _compositeSorteNodes:array baseDirNode:node];
		}
	}
	
}

//recursively collapse nodes, returns number of items collapsed
- (int) _collapseNode:(SHUTreeNode *)node{
	int res = 0;
	if (node.directoryIsExpanded) {
		NSArray *children = node.children;
		res = children.count;
		for (SHUTreeNode *child in children) {
			res += [self _collapseNode:child];
		}
	}
	return res;
}

//recursively add children and all its expanded children to array at position index
- (int) _insertChildren:(NSArray *)children inArray:(NSMutableArray *)array atIndex:(NSUInteger)index{
	
	[array replaceObjectsInRange:NSMakeRange(index, 0) withObjectsFromArray:children];
	int res = 0;
	int i=0;
	for (SHUTreeNode *child in children) {
		if (child.directoryIsExpanded) {
			i += [self _insertChildren:child.children inArray:array atIndex:index+i+1];
			res += child.children.count;
		}
		i++;
	}
	res += children.count;
	return res;
	
}

//recursively sorts arrays
- (void) _sortChildrenNodesOfNode:(SHUTreeNode *)dirNode{
	NSMutableArray *childrenNodes = dirNode.children;
	[childrenNodes sortUsingDescriptors:_sortDescriptors];
	
	for (SHUTreeNode *node in childrenNodes) {
		if (node.directoryIsExpanded) {
			[self _sortChildrenNodesOfNode:node];
		}
	}
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)aTableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
	SHUTreeNode *node = [self.nodes objectAtIndex:indexPath.row];
	return node.depth;
}


//overwrites default implementation in GITree, dont call super. implementation is very basic
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"MyCellIdentifier";
	SHUTreeViewCell *cell = (SHUTreeViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[SHUTreeViewCell alloc] initWithReuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryNone;
		//cell.indentationWidth = cell.frame.size.height;
		cell.indentationWidth = 40.0;//44: icon image size
		
	}
	
	SHUTreeNode *node = (SHUTreeNode *)[self.nodes objectAtIndex:indexPath.row];
	[cell setTitle:[node.filename stringByDeletingPathExtension]];
	[cell setIcon:[UIImage imageNamed:(node.isDirectory)?@"directory44.png":@"file44.png"]
	  isDirectory:node.isDirectory];
	cell.detailTextLabel.text = [[node modificationDate] description];//creationDateFormated];
	cell.indentationLevel = node.depth;
    
	return cell;
    
}

//overrides implementation, call super because
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	SHUTreeNode *node = (SHUTreeNode *)[self.nodes objectAtIndex:indexPath.row];
	//NSLog(@"touching...%@", [node description]);
	if (node.isDirectory) {
		if (node.directoryIsExpanded) {
			
			NSRange collapsedRange = [self collapseNodeAtIndex:indexPath.row];
			NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
			for (int i = 0; i<collapsedRange.length; i++) {
				[indexPaths addObject:[NSIndexPath indexPathForRow:collapsedRange.location+i inSection:0]];
			}
			[aTableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
			
		}else {
			
			NSRange expandedRange = [self expandNodeAtIndex:indexPath.row];
			NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
			for (int i = 0; i<expandedRange.length; i++) {
				[indexPaths addObject:[NSIndexPath indexPathForRow:expandedRange.location+i inSection:0]];
			}
			[aTableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
		}
		
        SHUTreeViewCell *cell = (SHUTreeViewCell *)[aTableView cellForRowAtIndexPath:indexPath];
        [cell setExpanded:!cell.isExpanded];
	}

    
	if (isInPseudoEditMode) {
		[selectedNodes addObject:node];
	}
	
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return self.nodes.count;;
}



#pragma mark - Gettter Setter

- (void)setIsInPseudoEditMode:(BOOL)flag{
	isInPseudoEditMode = flag;
	if (!flag) {
		[selectedNodes removeAllObjects];
	}
}


- (NSArray *)nodes {
	if (!_sortedNodes) {
		_sortedNodes = [[NSMutableArray alloc] init];
		[self _sortChildrenNodesOfNode:_baseDir];
		[self _compositeSorteNodes:_sortedNodes baseDirNode:_baseDir];
	}
	return (NSArray *)_sortedNodes;
}


@end
