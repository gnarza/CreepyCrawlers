--ai--
------
--ghost process
function pr_g(o)

 --in pen
 if(o.m==1)then

  --collisions off
  o.col=0
  o.s=o.ss.p

  local p=pen[o.i-1]
  if(o.t==0)then
   new_sdir(o,3)
   if(o.y<p.y-2)then
    o.t=1
   end
  else
   new_sdir(o,1)
   if(o.y>p.y+2)then
    o.t=0
   end
  end

 --active
 elseif(o.m==2)then

  --collisions on
  o.col=1

  --in tunnel
  if(mget(
   flr((o.x+4)/8),
   flr((o.y+4)/8))==50)then
   o.s=gv.gts--slow
  else
    o.s=o.ss.s--normal
  end

  --scared
  if(o.sc==1)then
   o.s=gv.gfs
   rnd_mv(o)
   return
  end

  if(ai_mode==0)then
   --scatter
   sct_mv(o)
  else
   --ai bug emulate
   local ofs=0
   if(o.ym<0)then
    ofs=-1
   end
   --chase
   if(o.i==1)then
    --target the player
    trg_mv(o,pac.x,pac.y)
   elseif(o.i==2)then
    --target 4 tiles in
    --front of player
    trg_mv(o,
     pac.x+(pac.xm+ofs)*40,
     pac.y+pac.ym*40)
   elseif(o.i==3)then
    --target away from red
    --in relation to the player
    local b=enes[1]
    trg_mv(o,
    b.x+((pac.x+(pac.xm+ofs)*16)-b.x)*2,
    b.y+((pac.y+pac.ym*16)-b.y)*2)
   elseif(o.i==4)then
    --move towards until
    --we get too close then
    --scatter
    if(dist(o.x,pac.x,o.y,pac.y)>70)then
     trg_mv(o,pac.x,pac.y)
    else
     sct_mv(o)
    end
   end
  end

 --back to pen
 elseif(o.m==4)then
  o.s=o.ss.r
  --move towards the pen door
  trg_mv(o,pen_d.x,pen_d.y)
  --check dist from pen
  if(gdist(o,pen_d)<12)then
   o.m=5
  end

 --enter pen
 elseif(o.m==5)then

  --collisions off
  o.col=0
  o.s=o.ss.r

  --move into the door
  new_sdir(o,1)

  --in the pen?
  if(o.y>=pen_d.y+8)then
   restore_anim(o)
   o.m=6
   --not scared
   o.sc=0
  end

 --exit pen
 elseif(o.m==6)then

  --collisions off
  o.col=0
  o.s=o.ss.p

  if(pen_d.x-o.x>1)then
   new_sdir(o,0)
  elseif(pen_d.x-o.x<-1)then
   new_sdir(o,2)
  else
   o.x=pen_d.x
   new_sdir(o,3)
  end

  --out of the pen?
  if(o.y<=pen_d.y-6)then
   o.m=2
   o.r=0
   o.it=0
   release_flag=0
  end

 end

end

--returns true when
--at an intersection
function ck_it(o)
 if(flr(o.x)%8==0
  and flr(o.y)%8==0)then
  if(o.it==0)then
   o.it=1
   --reverse flag check
   if(o.r==1)then
    o.r=0
    o.xm*=-1 o.ym*=-1
    return false
   end
   return true
  end
 else
  o.it=0
 end
 return false
end

--check directions
--finds avalible directions
function ck_dir(o)
 --get current tile id
 local tid=mget(
   flr((o.x+4)/8),
   flr((o.y+4)/8))
 local dl={}
 local b=(get_sdir(o)+2)%4
 if(col_ck(o,1,0)==false
  and b!=0)then
  add(dl,0) end
 if(col_ck(o,0,1)==false
  and b!=1)then
  add(dl,1) end
 if(col_ck(o,-1,0)==false
  and b!=2)then
  add(dl,2) end
 if(col_ck(o,0,-1)==false
  and b!=3
  --not over an up blocker
  and ((tid!=49
  and tid!=51)
  --scared mode ignores
  --the up blocker
  or o.sc==1))then
  add(dl,3) end
 return dl
end

--attract movement
function atr_mv(o)
 o.sc=1
 --at intersection
 if(ck_it(o))then
  --get avalible directions
  local dl=ck_dir(o,p)
  --count directions
  local c=0
  for _ in all(dl)do c+=1 end
  --pick one at random
  if(c>1 or col_ck(o))then
   dn+=1
   new_sdir(o,dr[dn])
  end
 end
end

--scatter movement
--moves to a corner based
--on id
function sct_mv(o)
 if(o.i==1)then
  trg_mv(o,cx*2-40,0)
 elseif(o.i==2)then
  trg_mv(o,30,0)
 elseif(o.i==3)then
  trg_mv(o,cx*2-40,cy*2)
 elseif(o.i==4)then
  trg_mv(o,30,cy*2)
 end
end

--random movement
--picks a random avalible
--direction
function rnd_mv(o)
 --at intersection
 if(ck_it(o))then
  --get avalible directions
  local dl=ck_dir(o)
  --count directions
  local c=0
  for _ in all(dl)do c+=1 end
  --pick one at random
  if(c>0)then
   new_sdir
    (o,dl[flr(rnd(c)+1)])
  end
 end
end

--target move
--move towards a target
function trg_mv(o,tx,ty)
 --at intersection
 if(ck_it(o))then
  --get avalible directions
  local dl=ck_dir(o)
  --count directions
  local c=0
  for _ in all(dl)do c+=1 end
  local cd=0--closest dist
  local fd=0--final direction
  --find closest to target
  for i=1,c,1 do
   local d=dl[i]--dir to test
   local dt=0--dir dist
   --get dir dist
   if(d==0)then
    dt=dist(o.x+8,tx,o.y,ty)
   elseif(d==1)then
    dt=dist(o.x,tx,o.y+8,ty)
   elseif(d==2)then
    dt=dist(o.x-8,tx,o.y,ty)
   elseif(d==3)then
    dt=dist(o.x,tx,o.y-8,ty)
   end
   if(i==1 or dt<cd)then
    cd=dt
    fd=d
   end
  end
  if(c>0)then
   new_sdir(o,fd)
  end
 end
end

--change actor direction
--(if possible)
function new_dir(o,xm,ym)
-- if collision of actor o, when xmoved and ymoved is false
 if(col_ck(o,xm,ym)==false
  --turn radius
  and col_ck(o,xm,ym,o.xm*2,o.ym*2)==false)then
  o.xm=xm or 0
  o.ym=ym or 0
  if(o.col==1)then
   --snap to grid
   if(o.ym!=0)then
    o.x=flr((o.x+4)/8)*8
   elseif(o.xm!=0)then
    o.y=flr((o.y+4)/8)*8
   end
  end
 end
end

function new_sdir(o,d)
 if(d==0)then
  new_dir(o,1,0)
 elseif(d==1)then
  new_dir(o,0,1)
 elseif(d==2)then
  new_dir(o,-1,0)
 elseif(d==3)then
  new_dir(o,0,-1)
 end
end

function get_sdir(o)
 return max(o.ym,0)
   +(min(o.xm,0)*-2)
   +(min(o.ym,0)*-3)
end

--check actor collision
--in a particular direction
function col_ck(o,xm,ym,xs,ys)

 --collision off flag
 if(o.col==0)then
  return false
 end

 xm=xm or o.xm
 ym=ym or o.ym
 local x=o.x-(xs or 0)
 local y=o.y-(ys or 0)

 if(ym!=0)then
  x=flr((x+4)/8)*8
 end
 if(xm!=0)then
  y=flr((y+4)/8)*8
 end

 --get the tile in front
 --of the actor
 local idx=flr((x+min(xm,0))/8)+max(xm,0)
 local idy=flr((y+min(ym,0))/8)+max(ym,0)

 --out of bounds?
 if(idx>=19 or idx<0)then
  return false
 end

 --get tile id
 local id=mget(idx+msh,idy)

 --true if collision
 return (fget(id,0)==true)
end
