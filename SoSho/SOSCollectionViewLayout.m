//
//  SOSCollectionViewLayout.m
//  SoSho
//
//  Created by Mikko Malmari on 1.11.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSCollectionViewLayout.h"

@implementation SOSCollectionViewLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *allItems = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    __block BOOL headerFound = NO;
    __block BOOL footerFound = NO;
    
    [allItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if([[obj representedElementKind] isEqualToString:UICollectionElementKindSectionHeader]){
            headerFound = YES;
            [self updateHeaderAttributes:obj];
        }else if([[obj representedElementKind] isEqualToString:UICollectionElementKindSectionFooter]){
            footerFound = YES;
            [self updateFooterAttributes:obj];
        }
    }];
    
    if(!headerFound){
        [allItems addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:[allItems count] inSection:0]]];
    }else if(!footerFound){
        [allItems addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:[allItems count] inSection:0]]];
    }
    
    return allItems;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, 44);
    if([elementKind isEqualToString:UICollectionElementKindSectionHeader]){
        [self updateHeaderAttributes:attributes];
    }else{
        [self updateFooterAttributes:attributes];
    }
    return attributes;
}

- (void) updateHeaderAttributes:(UICollectionViewLayoutAttributes *)attributes{
    CGRect currentBounds = self.collectionView.bounds;
    attributes.zIndex = 1;
    attributes.hidden = NO;
    CGFloat yCenterOffset = currentBounds.origin.y + attributes.size.height/2.0f;
    attributes.center = CGPointMake(CGRectGetMidX(currentBounds), yCenterOffset);
}

- (void) updateFooterAttributes:(UICollectionViewLayoutAttributes *)attributes{
    CGRect currentBounds = self.collectionView.bounds;
    attributes.zIndex = 1;
    attributes.hidden = NO;
    CGFloat yCenterOffset = currentBounds.origin.y - attributes.size.height/2.0f;
    attributes.center = CGPointMake(CGRectGetMidX(currentBounds), yCenterOffset);
}

@end
