#ifndef __ACTION_MORE_H__
#define __ACTION_MORE_H__ 

#include "cocos2d.h"

/** @class CircleBy
 *
 */
class CircleBy : public cocos2d::ActionInterval
{
public:
    /** 
     * Creates the action.
     *
     * @param duration Duration time, in seconds.
     * @param the center of the circle.
     * @param angle the target will circled.
     * @return 
     */
    static CircleBy* create(float duration, const cocos2d::Vec2& centerPosition, float angle, bool adjustRotation = false);

    //
    // Overrides
    //
    virtual CircleBy* clone() const override;
    virtual CircleBy* reverse(void) const  override;
    virtual void startWithTarget(cocos2d::Node *target) override;
    /**
     * @param time in seconds
     */
    virtual void update(float time) override;
    
CC_CONSTRUCTOR_ACCESS:
    CircleBy():_is3D(false) {}
    virtual ~CircleBy() {}

    /** initializes the action */
    bool initWithDuration(float duration, const cocos2d::Vec2& centerPosition, float angle, bool adjustRotation);

protected:
    bool _is3D;
    cocos2d::Vec2 _originPosition;
    cocos2d::Vec2 _centerPosition;
    cocos2d::Vec2 _previousPosition;
    float _originRotation;
    float _radian;
    float _angle;
    bool _adjustRotation;

private:
    CC_DISALLOW_COPY_AND_ASSIGN(CircleBy);
};

#endif
