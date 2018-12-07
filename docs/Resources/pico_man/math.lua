--------------
--math stuff--
--------------
function dist(x1,x2,y1,y2)
 return sqrt((x1-x2)*(x1-x2)+
  (y1-y2)*(y1-y2))
end

--est dist between objects
function gdist(o1,o2)
 return abs(o1.x-o2.x)
       +abs(o1.y-o2.y)
end

function pow(x1,x2)
 local r=1
 for i=1,x2,1 do
  r*=x1
 end
 return r
end
