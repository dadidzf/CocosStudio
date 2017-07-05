#include "cocos2d.h"
#include "Triangulate.h"

static const float EPSILON = 0.0000000001f;

float Triangulate::area(const std::vector<cocos2d::Vec2> &contour)
{
    size_t n = contour.size();
    
    float A=0.0f;
    
    for(size_t p = n - 1, q = 0; q < n; p = q++)
    {
        A += contour[p].x*contour[q].y - contour[q].x*contour[p].y;
    }
    
    return A*0.5f;
}

/*
 InsideTriangle decides if a point P is Inside of the triangle
 defined by A, B, C.
 */
bool Triangulate::insideTriangle(float Ax, float Ay,
                                 float Bx, float By,
                                 float Cx, float Cy,
                                 float Px, float Py)

{
    float ax, ay, bx, by, cx, cy, apx, apy, bpx, bpy, cpx, cpy;
    float cCROSSap, bCROSScp, aCROSSbp;
    
    ax = Cx - Bx;  ay = Cy - By;
    bx = Ax - Cx;  by = Ay - Cy;
    cx = Bx - Ax;  cy = By - Ay;
    apx= Px - Ax;  apy= Py - Ay;
    bpx= Px - Bx;  bpy= Py - By;
    cpx= Px - Cx;  cpy= Py - Cy;
    
    aCROSSbp = ax*bpy - ay*bpx;
    cCROSSap = cx*apy - cy*apx;
    bCROSScp = bx*cpy - by*cpx;
    
    return ((aCROSSbp >= 0.0f) && (bCROSScp >= 0.0f) && (cCROSSap >= 0.0f));
};

bool Triangulate::snip(const std::vector<cocos2d::Vec2> &contour, size_t u, size_t v, size_t w, size_t n, size_t *V)
{
    int p;
    float Ax, Ay, Bx, By, Cx, Cy, Px, Py;
    
    Ax = contour[V[u]].x;
    Ay = contour[V[u]].y;
    
    Bx = contour[V[v]].x;
    By = contour[V[v]].y;
    
    Cx = contour[V[w]].x;
    Cy = contour[V[w]].y;
    
    if ( EPSILON > (((Bx-Ax)*(Cy-Ay)) - ((By-Ay)*(Cx-Ax))) ) return false;
    
    for (p=0;p<n;p++)
    {
        if( (p == u) || (p == v) || (p == w) ) continue;
        Px = contour[V[p]].x;
        Py = contour[V[p]].y;
        if (insideTriangle(Ax,Ay,Bx,By,Cx,Cy,Px,Py)) return false;
    }
    
    return true;
}

std::vector<cocos2d::Vec2> Triangulate::process(const std::vector<cocos2d::Vec2> &contour)
{
    std::vector<cocos2d::Vec2> result;
    result.clear();
    
    /* allocate and initialize list of Vertices in polygon */
    size_t n = contour.size();
    if ( n < 3 ) return result;
    
    size_t *V = new size_t[n];
    
    /* we want a counter-clockwise polygon in V */
    if (0.0f < area(contour))
    {
        for (size_t v = 0; v < n; v++)
        {
            V[v] = v;
        }
    }
    else
    {
        for(size_t v = 0; v < n; v++)
        {
            V[v] = (n - 1) - v;
        }
    }
    
    size_t nv = n;
    
    /*  remove nv-2 Vertices, creating 1 triangle every time */
    size_t count = 2*nv;   /* error detection */
    
    for(size_t m = 0, v = nv - 1; nv > 2;)
    {
        /* if we loop, it is probably a non-simple polygon */
        if (0 >= (count--))
        {
            //** Triangulate: ERROR - probable bad polygon!
            return result;
        }
        
        /* three consecutive vertices in current polygon, <u,v,w> */
        size_t u = v;
        if (nv <= u)
        {
            u = 0;     /* previous */
        }
        v = u + 1;
        if (nv <= v)
        {
            v = 0;     /* new v    */
        }
        
        size_t w = v + 1;
        if (nv <= w)
        {
            w = 0;     /* next     */
        }
        
        if (snip(contour, u, v, w, nv, V))
        {
            size_t a, b, c, s, t;
            
            /* true names of the vertices */
            a = V[u]; b = V[v]; c = V[w];
            
            /* output Triangle */
            result.push_back(contour[a]);
            result.push_back(contour[b]);
            result.push_back(contour[c]);
            
            m++;
            
            /* remove v from remaining polygon */
            for(s = v, t = v + 1; t < nv; s++, t++)
            {
                V[s] = V[t];
            }
            nv--;
            
            /* resest error detection counter */
            count = 2*nv;
        }
    }
    
    delete []V;
    
    return result;
}