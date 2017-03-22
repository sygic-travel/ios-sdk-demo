//
//  Foundation+TravelKit.h
//  SygicTravel-Demo
//
//  Created by Michal Zelinka on 20/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (TravelKit)

- (void)swizzleSelector:(SEL)swizzled withSelector:(SEL)original;
- (void)swizzleSelector:(SEL)swizzled ofClass:(Class)swizzledClass withSelector:(SEL)original ofClass:(Class)originalClass;

@end

@interface NSArray<ObjectType> (TravelKit)

- (ObjectType)safeObjectAtIndex:(NSUInteger)index;

@end
