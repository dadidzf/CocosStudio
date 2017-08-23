
--------------------------------
-- @module CircleBy
-- @extend ActionInterval
-- @parent_module dd

--------------------------------
--  initializes the action 
-- @function [parent=#CircleBy] initWithDuration 
-- @param self
-- @param #float duration
-- @param #vec2_table centerPosition
-- @param #float angle
-- @param #bool adjustRotation
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- Creates the action.<br>
-- param duration Duration time, in seconds.<br>
-- param the center of the circle.<br>
-- param angle the target will circled.<br>
-- return 
-- @function [parent=#CircleBy] create 
-- @param self
-- @param #float duration
-- @param #vec2_table centerPosition
-- @param #float angle
-- @param #bool adjustRotation
-- @return CircleBy#CircleBy ret (return value: CircleBy)
        
--------------------------------
-- 
-- @function [parent=#CircleBy] startWithTarget 
-- @param self
-- @param #cc.Node target
-- @return CircleBy#CircleBy self (return value: CircleBy)
        
--------------------------------
-- 
-- @function [parent=#CircleBy] clone 
-- @param self
-- @return CircleBy#CircleBy ret (return value: CircleBy)
        
--------------------------------
-- 
-- @function [parent=#CircleBy] reverse 
-- @param self
-- @return CircleBy#CircleBy ret (return value: CircleBy)
        
--------------------------------
-- param time in seconds
-- @function [parent=#CircleBy] update 
-- @param self
-- @param #float time
-- @return CircleBy#CircleBy self (return value: CircleBy)
        
--------------------------------
-- 
-- @function [parent=#CircleBy] CircleBy 
-- @param self
-- @return CircleBy#CircleBy self (return value: CircleBy)
        
return nil
