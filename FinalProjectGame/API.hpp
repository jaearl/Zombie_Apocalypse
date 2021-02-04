//
//  API.hpp
//  FinalProjectGame
//
//  Created by Jared Earl on 4/28/18.
//  Copyright © 2018 Jared Earl. All rights reserved.
//

#ifndef API_hpp
#define API_hpp

#include <stdio.h>
#include <math.h>
#include <iostream>
#include <vector>

using namespace std;

//wrapper header for CPoint
struct CPoint
{
    double x;
    double y;
    
    bool operator==(const CPoint& other) {
        return (x == other.x && y == other.y);
    }
};

/**
 this is the api that the model uses to complete its functions
 */
class CAPI {
public:
    //constructor
    CAPI() {
    }
    
    //members
    //****constants*******
    double bulletRadius = 10.0;
    double badGuyRadius = 20.0;
    double playerRadius = 20.0;
    double bulletSpeed = 900.0;
    double badGuySpeed = 5.0;
    double playerSpeed = 200.0;
    double nextFireTimeLimit = 0.25;
    //******End constants*****
    
    //mirror variables
    
    
    //functions
    void printHelloWorld();
    double calcDistanceMoved(double timeElapsed, double speed);
    bool isCollision(double x1, double y1, double x2, double y2, double radius1, double radius2);
    vector<CPoint> checkPlayerHits(CPoint player, vector<CPoint> badGuys);
    vector<CPoint> checkBullets(vector<CPoint> badGuys, vector<CPoint> bullets);
    vector<CPoint> checkBadGuys(vector<CPoint> badGuys, vector<CPoint> bullets);
    int calcHealth(int curHealth, int diff);
    int calcNewScore(int score, int diff);
    vector<CPoint> moveBullets(vector<CPoint> bullets, double distance);
    vector<CPoint> moveBadGuys(vector<CPoint> badGuys, double distance, double heightLimit, double widthLimit);
    CPoint movePlayer(CPoint player, double distance, int buttonPressed, double maxHeight, double maxWidth);
};


#endif /* API_hpp */











