#include "cocos2d.h"
#include "ActionMore.h"

//
// CircleBy
//

USING_NS_CC;

CircleBy* CircleBy::create(float duration, const cocos2d::Vec2& centerPosition, float angle, bool adjustRotation)
{
    CircleBy*ret = new (std::nothrow) CircleBy();
    
    if (ret && ret->initWithDuration(duration, centerPosition, angle, adjustRotation))
    {
        ret->autorelease();
        return ret;
    }
    
    delete ret;
    return nullptr;
}

bool CircleBy::initWithDuration(float duration, const cocos2d::Vec2& centerPosition, float angle, bool adjustRotation)
{
    bool ret = false;
    
    if (ActionInterval::initWithDuration(duration))
    {
        _centerPosition = centerPosition;
        _angle = angle;
        _radian = CC_DEGREES_TO_RADIANS(angle);
        _is3D = true;
        _adjustRotation = adjustRotation;
        ret = true;
    }
    
    return ret;
}

CircleBy* CircleBy::clone() const
{
    // no copy constructor
    return CircleBy::create(_duration, _centerPosition, _angle);
}

void CircleBy::startWithTarget(Node *target)
{
    ActionInterval::startWithTarget(target);
    _originPosition = target->getPosition();
    _previousPosition = _originPosition;
    _originRotation = target->getRotation();
}

CircleBy* CircleBy::reverse() const
{
    return CircleBy::create(_duration, _centerPosition, -_angle);
}

void CircleBy::update(float t)
{
    if (_target)
    {
#if CC_ENABLE_STACKABLE_ACTIONS
        Vec2 currentPos = _target->getPosition();
        Vec2 diff = currentPos - _previousPosition;
        _centerPosition = _centerPosition + diff;
        _originPosition = _originPosition + diff;
#endif // CC_ENABLE_STACKABLE_ACTIONS
        
        _previousPosition = _originPosition.rotateByAngle(_centerPosition, t*_radian);
        _target->setPosition(_previousPosition);
       
        if (_adjustRotation)
        {
            _target->setRotation(_originRotation - t*_angle);
        }
    }
}
