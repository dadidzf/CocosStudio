#ifndef __TRIANGULATE_H__
#define __TRIANGULATE_H__ 

#include "cocos2d.h"

class Triangulate
{
public:
    
    // triangulate a contour/polygon, places results in STL vector
    // as series of triangles.
    static std::vector<cocos2d::Vec2> process(const std::vector<cocos2d::Vec2> &contour);
    
    // compute area of a contour/polygon
    static float area(const std::vector<cocos2d::Vec2> &contour);
    
    // decide if point Px/Py is inside triangle defined by
    // (Ax,Ay) (Bx,By) (Cx,Cy)
    static bool insideTriangle(float Ax, float Ay,
                               float Bx, float By,
                               float Cx, float Cy,
                               float Px, float Py);
    
private:
    static bool snip(const std::vector<cocos2d::Vec2> &contour, size_t u, size_t v, size_t w, size_t n, size_t *V);
};

#endif
