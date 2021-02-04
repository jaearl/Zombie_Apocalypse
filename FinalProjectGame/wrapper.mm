//
//  wrapper.m
//  FinalProjectGame
//
//  Created by Jared Earl on 4/28/18.
//  Copyright © 2018 Jared Earl. All rights reserved.
//

#import "wrapper.h"
#include "API.hpp"

using namespace std;

//implementation for wrapper
@implementation API

//implementations for the objective c wrapper. just calls the real api's functions
- (void)printHelloWorldFromCPP {
    CAPI realapi;
    realapi.printHelloWorld();
}
-(double)calcDistanceMoved:(double)timeElapsed :(double)speed {
    CAPI realapi;
    return realapi.calcDistanceMoved(timeElapsed, speed);
}
-(bool)isCollision:(double)x1 :(double)y1 :(double)x2 :(double)y2 :(double)radius1 :(double)radius2 {
    CAPI realapi;
    return realapi.isCollision(x1, y1, x2, y2, radius1, radius2);
}

//creates the list in the necessary form to pass to api
-(NSMutableArray *)checkPlayerHits:(CGPoint)player :(CGPoint[])badGuys :(int)size { //creates the list in the necessary form to pass to api
    CAPI realapi;
    CPoint cplayer = {.x = double(player.x), .y = double(player.y)};
    vector<CPoint> newBadGuys;
    for(int i = 0; i < size; i++){
        CGPoint point = badGuys[i];
        CPoint cpoint = {.x = double(point.x), .y = double(point.y)};
        newBadGuys.push_back(cpoint);
    }
    
    vector<CPoint> resultBadGuys = realapi.checkPlayerHits(cplayer, newBadGuys);
    NSMutableArray * result = [NSMutableArray array];
    for(int i = 0; i < resultBadGuys.size(); i++){
        CGPoint newPoint = {resultBadGuys[i].x, resultBadGuys[i].y};
        [result addObject:[NSValue valueWithCGPoint:newPoint]];
    }
    
    return result;
}
-(int)calcHealth:(int)curHealth :(int)diff {
    CAPI realapi;
    return realapi.calcHealth(curHealth, diff);
}
-(int)calcNewScore:(int)score :(int)diff {
    CAPI realapi;
    return realapi.calcNewScore(score, diff);
}
//creates the lists in the necessary form to pass to the api
-(NSMutableArray *)checkBullets:(CGPoint[])badGuys :(CGPoint[])bullets :(int)badGuySize :(int)bulletsSize {
    CAPI realapi;
    
    vector<CPoint> newBadGuys;
    for(int i = 0; i < badGuySize; i++){
        CGPoint point = badGuys[i];
        CPoint cpoint = {.x = double(point.x), .y = double(point.y)};
        newBadGuys.push_back(cpoint);
    }
    vector<CPoint> newBullets;
    for(int i = 0; i < bulletsSize; i++){
        CGPoint point = bullets[i];
        CPoint cpoint = {.x = double(point.x), .y = double(point.y)};
        newBullets.push_back(cpoint);
    }
    
    vector<CPoint> resultBadGuys = realapi.checkBullets(newBadGuys, newBullets);
    NSMutableArray * result = [NSMutableArray array];
    for(int i = 0; i < resultBadGuys.size(); i++){
        CGPoint newPoint = {resultBadGuys[i].x, resultBadGuys[i].y};
        [result addObject:[NSValue valueWithCGPoint:newPoint]];
    }
    
    return result;
}
//creates the lists in the necessary form to pass to the api
-(NSMutableArray *)checkBadGuys:(CGPoint[])badGuys :(CGPoint[])bullets :(int)badGuySize :(int)bulletsSize {
    CAPI realapi;
    
    vector<CPoint> newBadGuys;
    for(int i = 0; i < badGuySize; i++){
        CGPoint point = badGuys[i];
        CPoint cpoint = {.x = double(point.x), .y = double(point.y)};
        newBadGuys.push_back(cpoint);
    }
    vector<CPoint> newBullets;
    for(int i = 0; i < bulletsSize; i++){
        CGPoint point = bullets[i];
        CPoint cpoint = {.x = double(point.x), .y = double(point.y)};
        newBullets.push_back(cpoint);
    }
    
    vector<CPoint> resultBullets = realapi.checkBadGuys(newBadGuys, newBullets);
    NSMutableArray * result = [NSMutableArray array];
    for(int i = 0; i < resultBullets.size(); i++){
        CGPoint newPoint = {resultBullets[i].x, resultBullets[i].y};
        [result addObject:[NSValue valueWithCGPoint:newPoint]];
    }
    
    return result;
}
//converts the data types and passees it to the capi
-(NSMutableArray *)moveBullets:(CGPoint[])bullets :(int)size :(double)distance {
    CAPI realapi;
    vector<CPoint> newBullets;
    for(int i = 0; i < size; i++){
        CGPoint point = bullets[i];
        CPoint cpoint = {.x = double(point.x), .y = double(point.y) };
        newBullets.push_back(cpoint);
    }
    vector<CPoint> resultBullets = realapi.moveBullets(newBullets, distance);
    NSMutableArray * result = [NSMutableArray array];
    for(int i = 0; i < resultBullets.size(); i++){
     CGPoint newPoint = {resultBullets[i].x, resultBullets[i].y};
     [result addObject:[NSValue valueWithCGPoint:newPoint]];
     }
    
    return result;
}
//converts the data types and passees it to the capi
-(NSMutableArray *)moveBadGuys:(CGPoint[])badGuys : (int)size :(double)distance :(double)heightLimit :(double)widthLimit {
    CAPI realapi;
    vector<CPoint> newBadGuys;
    for(int i = 0; i < size; i++){
        CGPoint point = badGuys[i];
        CPoint cpoint = {.x = double(point.x), .y = double(point.y) };
        newBadGuys.push_back(cpoint);
    }
    vector<CPoint> resultBadGuys = realapi.moveBadGuys(newBadGuys, distance, heightLimit, widthLimit);
    NSMutableArray * result = [NSMutableArray array];
    for(int i = 0; i < resultBadGuys.size(); i++){
        CGPoint newPoint = {resultBadGuys[i].x, resultBadGuys[i].y};
        [result addObject:[NSValue valueWithCGPoint:newPoint]];
    }
    
    return result;
}
//converts the datatype and passes it to the capi
-(CGPoint)movePlayer:(CGPoint)player :(double)distance :(int)buttonPressed :(double)maxHeight :(double)maxWidth {
    CAPI realapi;
    CPoint newPlayer = {.x = player.x, .y = player.y };
    
    CPoint movedPlayer = realapi.movePlayer(newPlayer, distance, buttonPressed, maxHeight, maxWidth);
    
    CGPoint result;
    result.x = CGFloat(movedPlayer.x);
    result.y = CGFloat(movedPlayer.y);
    return result;
}

@end
