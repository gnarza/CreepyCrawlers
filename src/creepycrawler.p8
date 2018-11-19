pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- creepy crawlers
-- by natalie garza
-- version 0.2

function _init()
 allbutts={0,1,2,3,4,5}
 zbutt={4}
 xbutt={5}

 sound=true

 splash_init()
end

function _update()
	update()
end

function _draw()
	draw()
end

function buttpress(butts,dothis)
	for i=1,#butts do
		if(btnp(butts[i])) dothis()
	end
end

function togglesound()
	if(sound==true) then
		sound=false
	else sound=true end
end
-->8
-- splash screen state

function splash_init()
 update=splash_update
	draw=splash_draw
end

function splash_update()
	buttpress(allbutts,menu_init)
end

function splash_draw()
	cls()
	print('splash screen\n')
end
-->8
-- menu screen state

function menu_init()
 update=menu_update
	draw=menu_draw
end

function menu_update()
	buttpress(zbutt,play_init)
	buttpress(xbutt,togglesound)
end

function menu_draw()
	cls()
	print('menu screen\n')
	print(sound)
end

-->8
-- play game state

-- flags
-- wall:0
-- spawn spot:1
-- enemyhead:3
-- enemybody:4
-- playerhead:5
-- playerbody:6
-- turning point:7

function play_init()
 update=play_update
 draw=play_draw

 centerX=108
 centerY=120

 cam={}
 cam.x=0
 cam.y=0
 cam.toX=0
 cam.toY=0

 opp = {0,0}

 crawlers={}
 bugs={}
 levels={}
 currentLvl=1
 rndSpawns=1

 spwn1=make_spawning_manager()
 make_level(spwn1,1)

 spwn2=make_spawning_manager()
 spwn2.bugFreq={600,900,1200,1500,1800,2700,0,0,0}
 spwn2.bugLife={600,600,450,300,300,300,0,0,0}
 spwn2.crawlerFreq={300,300,300,300,300,150,150,150,150}
 spwn2.crawlerLen={2,3,4,5,7,8,9,10,11}
 spwn2.crawlerSpawned={2,3,3,4,4,4,5,5,5}
 spwn2.e={0.9,0.7,0.5,0.3,0.1,0,0,0,0}
 spwn2.m={0.1,0.3,0.5,0.7,0.9,0.9,0.7,0.5,0.3}
 spwn2.h={0,0,0,0,0,0.1,0.3,0.5,0.7}
 make_level(spwn2,2)

 spwn3=make_spawning_manager()
 spwn3.bugFreq={600,1200,1800,2700,3600,0,0,0,0}
 spwn3.bugLife={450,450,300,300,300,0,0,0,0}
 spwn3.crawlerFreq={300,300,300,300,300,150,150,150,150}
 spwn3.crawlerLen={2,3,5,6,7,8,10,11,12}
 spwn3.crawlerSpawned={3,3,4,4,4,5,5,5,5}
 spwn3.e={0.3,0.2,0.1,0,0,0,0,0,0}
 spwn3.m={0.7,0.8,0.7,0.5,0.3,0.1,0,0,0}
 spwn3.h={0,0,0.2,0.5,0.7,0.9,1,1,1}
 make_level(spwn3,3)


-- timer for tail draw
 t=0

 pl=make_crawler(112,192)
 pl.pl=true
 -- start by going right
 change_dir(pl,1,0)

end

function play_update()
	buttpress(zbutt,end_init)
	buttpress(xbutt,togglesound)

  update_game()
	update_crawlers()
  update_bugs()
end

function play_draw()
	cls()
	map(0,0,0,0,28,31)

	draw_crawlers()
  draw_bugs()
  if(#crawlers>1)then
    print(pl.length,pl.x-16,pl.y+32)
    print(lvl.sc,pl.x-16,pl.y+24)
  end
  print(pl.x, pl.x-16,pl.y+8)
  print(pl.y, pl.x-16,pl.y+16)
end

-- [[ Make Methods For Play State ]]
function make_level(spwn,level)
  local l={}
  l.level=level or 1
  l.spwnMgr=spwn
  --timers for spawning crawlers and bugs
  l.sc=0
  l.sb=0

  add(levels,l)
end

function make_spawning_manager()
  local s={}
  s.bugFreq={300,450,600,750,900,1050,0,0,0}
  s.bugLife={600,600,600,600,450,300,0,0,0}
  -- no more than this amount of bugs can exist on the map at a time
  s.bugSpawned={1,1,1,1,1,1,0,0,0}

  s.crawlerFreq={300,300,300,300,300,300,300,300,150,150}
  s.crawlerLen={1,2,3,4,5,6,7,8,9,10}
  -- no more than this amount of crawlers can exist on the map at a time
  s.crawlerSpawned={1,2,2,3,3,3,4,4,4}

  s.spawns={{0,80},{216,80}}
  s.tunnels={{0,144},{216,144}}

  s.e={1,0.9,0.8,0.7,0.6,0.5,0.2,0.1,0}
  s.m={0,0.1,0.2,0.3,0.4,0.5,0.8,0.9,1}
  s.h={0,0,0,0,0,0,0,0,0}

  return s
end

function make_bug(x,y)
  local b={}
  b.x=x
  b.y=y
  b.speed=1.1
  b.dx=0
  b.dy=0
  b.sprite=34
  -- bug updated 30/sec
  -- 20 secs default life
  b.lifecyle=1200
  b.deathPt=1
  --states:
  --1=crawl/wander
  --2=evade
  --3=go back to spawning point
  b.state=1

  add(bugs,b)
end

function make_crawler(x,y)
	local c={}
  -- is player?
  c.pl=false
	-- position
	c.x=x
	c.y=y
	-- movement
	c.speed=1
	c.dx=0
  c.dy=0
  c.rest=0
  -- animation
	c.sprite=32
  c.timer=0
  c.timrCap=8

  -- body
  c.tail={}
  c.length=0
  c.maxLength=10
  c.tailSpr=33

  -- states:
  --1=crawl/wander
  --2=evade
  --3=chase
  --4=bugging
  c.state=1

  c.bugx=0
  c.bugy=0

  add(crawlers,c)
	return c
end

function make_e(x,y)
  myE = make_crawler(x,y)
  myE.speed=.5
  myE.timrCap=12
  -- put e sprite...
  myE.sprite=48
  myE.tailSpr=49
  myE.type="easy"
end

function make_m(x,y)
  myM = make_crawler(x,y)
  myM.speed=.5
  myM.timrCap=12
  -- put e sprite...
  myM.sprite=48
  myM.tailSpr=49
  myM.type="medium"
end

function make_h(x,y)
  myH = make_crawler(x,y)
  myH.speed=1.02
  myH.timrCap=7
  -- put e sprite...
  myH.sprite=48
  myH.tailSpr=49
  myH.type="hard"
end

function tail_node(a,x,y,sp)
  local t={}
  t.x=x
  t.y=y
  t.node=a.length+1
  t.sprite=sp or 33

  -- add(a.tail,t)
  return t
end

-- [[ Update Methods For Play State ]]

function update_game()
  if(cam.toX<64) then
    cam.toX=64
  end
  if(cam.toX>160) then
    cam.toX=160
  end
  cam.x+=(cam.toX-cam.x)*0.14

  if(cam.toY<64) then
    cam.toY=64
  end
  if(cam.toY>160) then
    cam.toY=190
  end
  cam.y+=(cam.toY-cam.y)*0.14
  camera(cam.x-63,cam.y-63)

  -- code for spawning bugs and crawlers
  lvl=levels[currentLvl]
  spawner=lvl.spwnMgr
  lvl.sc+=1
  if(#bugs==0) then
    lvl.sb+=1
  end
  -- make a new crawler if reached frequency and meet other criteria
  if((spawner.crawlerFreq[pl.length+1] <= lvl.sc) and (spawner.crawlerSpawned[pl.length+1] > (#crawlers-1)))then
    lvl.sc=0
    prob=flr(rnd(1 * 10)) / 10
    -- make_crawler
    tunnels=spawner.tunnels
    rndTunn = flr(rnd(#tunnels))+1
    if((spawner.e[pl.length+1]+spawner.m[pl.length+1])==1)then
      if(prob <= spawner.e[pl.length+1])then
        make_e(tunnels[rndTunn][1], tunnels[rndTunn][2])
      else
        make_m(tunnels[rndTunn][1], tunnels[rndTunn][2])
      end
    else
      if(prob <= spawner.m[pl.length+1])then
        make_m(tunnels[rndTunn][1], tunnels[rndTunn][2])
      else
        make_h(tunnels[rndTunn][1], tunnels[rndTunn][2])
      end
    end

    for i=1, spawner.crawlerLen[pl.length+1] do
      add(crawlers[#crawlers].tail,tail_node(crawlers[#crawlers],crawlers[#crawlers].x,crawlers[#crawlers].y,crawlers[#crawlers].tailSpr))
      crawlers[#crawlers].length+=1
    end

    if(tunnels[rndTunn][1]==0)then
      crawlers[#crawlers].dx=1
    else
      crawlers[#crawlers].dx=-1
    end
  end
  -- make a new bug if reached frequency and meet other criteria
  if((spawner.bugFreq[pl.length+1]<=lvl.sb) and (spawner.bugSpawned[pl.length+1]>#bugs))then
    lvl.sb=0
    spwnPoints=spawner.spawns
    rndSpawns = flr(rnd(#spwnPoints))+1
    make_bug(spwnPoints[rndSpawns][1],spwnPoints[rndSpawns][2])
    bugs[#bugs].dx=1
    bugs[#bugs].lifecyle=spawner.bugLife[pl.length+1]
    bugs[#bugs].deathPt=rndSpawns
  end

end

function update_crawlers()
  -- left
	if(btn(0)) then
		change_dir(pl,-1,0)
  -- right
	elseif(btn(1)) then
    change_dir(pl,1,0)
  -- up
	elseif(btn(2)) then
    change_dir(pl,0,-1)
  -- down
	elseif(btn(3)) then
    change_dir(pl,0,1)
	end

  for a in all(crawlers) do
    a.timer+=1

    -- this is to make sure crawlers don't have a bug set as target when
    -- their lifecyle is over
    if(#bugs==0)then
      a.bugx=0
      a.bugy=0
      if(a.state==4)then
        a.state=1
      end
    end

    -- change the state of opponent crawlers if not colliding with player
    if(a.pl==false)then
      -- if head collide and player is bigger than opponent
      if(coll(a,pl) and pl.length > a.length)then
        add(pl.tail,tail_node(pl,pl.x,pl.y,a.tailSpr))

        pl.length+=1
        pl.speed-=.01

        del(crawlers,a)
        break
      end
      -- you died start over sucker
      if(coll(a,pl) and pl.length <= a.length)then
        menu_init()
      end
      -- tail nibbled off opponent
      eaten=false
      for tl=1,(#a.tail) do
        if(eaten)then
          del(a.tail, a.tail[tl])
          a.length-=1
        elseif(coll(pl,a.tail[tl]))then
          eaten=true
          del(a.tail, a.tail[tl])
          a.length-=1
        end
      end
      -- tail nibbled off player
      eaten=false
      for tl=1,(#pl.tail) do
        if(eaten)then
          del(pl.tail, pl.tail[tl])
          pl.length-=1
        elseif(coll(pl.tail[tl],a))then
          eaten=true
          del(pl.tail, pl.tail[tl])
          pl.length-=1
        end
      end


      -- chase if tail longer than player
      if(a.length >= pl.length)then
        a.state=3
        a.rest+=1
        -- evade if player close by and tail shorter
      elseif(dist(pl.x,a.x,pl.y,a.y)<80 and a.length < pl.length)then
        a.state=2
        --rest if its been in chase mode for > one minute
      elseif(a.rest>1800 and a.state==3)then
        if(a.rest>3150)then
          r=0
        end
        a.state=1
      end

      -- bugging state if bug is close by to crawler and tail length meets
      -- shorter than criteria
      for e in all(bugs) do
        if(dist(e.x,a.x,e.y,a.y)<80 and a.length < pl.length)then
          a.state=4
          a.bugx=e.x
          a.bugy=e.y
        end
      end
    end

    -- depending on the state of the opponent crawlers change the direction when
    -- colliding with wall or at a fork
    -- CHANGE TRGMV DEPENDING ON TYPE OF CRAWLER
    if(a.pl==false and (atFork(a)==true or wallColl(a)==true))then
      --1=crawl/wander
      if(a.state==1)then
        rnd_mv(a)

        --2=evade
      elseif(a.state==2) then
        opp=opp_quad(pl)
        trg_mv(a,opp[1],opp[2])

        --3=chase
      elseif(a.state==3)then
        trg_mv(a,pl.x,pl.y)

        --4=bugging
      elseif(a.state==4)then
        trg_mv(a,a.bugx,a.bugy)

      end
    end

    for b in all(bugs) do
      -- if the bug gets eaten +1 tail node of the same sprite
      if(coll(a,b))then
        add(a.tail,tail_node(a,a.x,a.y,a.tailSpr))

        a.length+=1
        if(a.pl)then
          pl.speed-=.01
        end

        -- check all the crawlers to make sure you delete and replace the
        -- coords for bugx and bugy
        for c in all(crawlers) do
          if(c.bugx==b.x and c.bugy==b.y)then
            c.state=1
            c.bugx=0
            c.bugy=0
          end
        end

        del(bugs,b)
      end
    end

    -- if not colliding with wall update x and y accordingly)
    if(wallColl(a)==false)then
      a.x+=a.dx*a.speed
      a.y+=a.dy*a.speed
    -- if colliding with wall snap to grid
    else
     a.x=flr((a.x+4)/8)*8
     a.y=flr((a.y+4)/8)*8
    end

    if(a.timer>=a.timrCap and a.length!=0) then
      local mvTail={}
      add(mvTail,tail_node(a,a.x,a.y,a.tail[1].sprite))
      for tl=1,(#a.tail-1) do
        add(mvTail, tail_node(a,a.tail[tl].x, a.tail[tl].y,a.tail[tl+1].sprite))
      end
      a.tail=mvTail
      a.timer=0
    end

    -- screen wrapping
    if(a.x>centerX*2-6)then
      a.x=0
    end
    if(a.x<-4)then
      a.x=centerX*2-6
    end
  end

  cam_player()
end

function update_bugs()
  for b in all(bugs) do
    -- if the bug lifecyle is up go back to a spawning point and die
    if(b.lifecyle==0) then
      b.state=3
      if(atSpawn(b))then
        del(bugs,b)
        break
      end
    else
      b.lifecyle-=1
    end

    -- change the state of the bug depending on how far away the player is
    -- also the current state must not be terminate
    -- evade
    if(dist(pl.x,b.x,pl.y,b.y)<80 and b.state!=3)then
      b.state=2
    -- wander
    else
      b.state=1
    end

    -- move according to the state the bug is in
    if(atFork(b) or wallColl(b))then
      --1=crawl/wander
      if(b.state==1)then
        rnd_mv(b)

      --2=evade
      elseif(b.state==2)then
        opp=opp_quad(pl)
        trg_mv(b,opp[1],opp[2])

      --3=terminate/go back to spawning point
      elseif(b.state==3)then
        trg_mv(b,levels[currentLvl].spwnMgr.spawns[b.deathPt][1],levels[currentLvl].spwnMgr.spawns[b.deathPt][2])
      end
    end
    b.x+=b.dx*b.speed
    b.y+=b.dy*b.speed

    -- screen wrapping
    if(b.x>centerX*2-6)then
      b.x=0
    end
    if(b.x<-4)then
      b.x=centerX*2-6
    end
  end
end

-- [[ Additional Methods For Play State ]]

-- randomly chooses an available direction
function rnd_mv(o)
    local dl=check_dir(o)
    if(#dl>0)then
      change_dirA(o,dl[flr(rnd(#dl+1))])
    end
end

--target move
--move towards a target
function trg_mv(o,tx,ty)
  --get avalible directions
  local dl=check_dir(o)
  --count directions
  local c=#dl
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
   change_dirA(o,fd)
  end
end

function dist(x1,x2,y1,y2)
 return sqrt((x1-x2)*(x1-x2)+
  (y1-y2)*(y1-y2))
end

-- return a tile that is in the opposite
-- quadrant of actor
function opp_quad(o)
  local x=o.x
  local y=o.y

  if(x>112 and y>120)then
    return {0,0}
  elseif(x<=112 and y>120)then
   return {224,0}
  elseif(x>112 and y<=120)then
    return {0,248}
  elseif(x<=112 and y<=120)then
    return {224,248}
  end
end

-- finds available directions
function check_dir(o)
  local oTile=mget(flr(o.x)/8,flr((o.y)/8))
  local dir={}
  local b=(get_dir(o)+2)%4

  if(wallColl(o,1,0)==false and b!=0)then
    add(dir,0)
  end
  if(wallColl(o,0,1)==false and b!=1)then
    add(dir,1)
  end
  if(wallColl(o,-1,0)==false and b!=2)then
    add(dir,2)
  end
  if(wallColl(o,0,-1)==false and b!=3)then
    add(dir,3)
  end

  return dir
end

-- change the direction of actor o based on directions
-- right,down,left,up=1,2,3,4
function change_dirA(o,d)
  if(d==0)then
    change_dir(o,1,0)
  elseif(d==1)then
    change_dir(o,0,1)
  elseif(d==2)then
    change_dir(o,-1,0)
  elseif(d==3)then
    change_dir(o,0,-1)
  end
end

-- returns the current direction
function get_dir(o)
  return max(o.dy,0)+(min(o.dx,0)*-2)+(min(o.dy,0)*-3)
end

-- follow player around map
function cam_player()
  cam.toX=centerX-(centerX-pl.x)*.9
  cam.toY=centerY-(centerY-pl.y)*.9
end

-- return true if colliding with wall
function wallColl(a,dx,dy,xs,ys)
  local dx=dx or a.dx
  local dy=dy or a.dy

  local x=a.x-(xs or 0)
  local y=a.y-(ys or 0)

  if(dy!=0) x=flr((x+4)/8)*8
  if(dx!=0) y=flr((y+4)/8)*8

  -- get tile ahead of crawler
  local xtile=flr((x+min(dx,0))/8)+max(dx,0)
  local ytile=flr((y+min(dy,0))/8)+max(dy,0)

  return(fget(mget(xtile,ytile), 0))
end

function atFork(a)
  local dx=a.dx
  local dy=a.dy

  local x=a.x
  local y=a.y

  if(dy!=0) x=flr((x+4)/8)*8
  if(dx!=0) y=flr((y+4)/8)*8

  -- get tile ahead of crawler
  local xtile=flr((x+min(dx,0))/8)+max(dx,0)
  local ytile=flr((y+min(dy,0))/8)+max(dy,0)

  return(fget(mget(xtile,ytile), 7))
end

function atSpawn(a)
  local dx=a.dx
  local dy=a.dy

  local x=a.x
  local y=a.y

  if(dy!=0) x=flr((x+4)/8)*8
  if(dx!=0) y=flr((y+4)/8)*8

  -- get tile ahead of crawler
  local xtile=flr((x+min(dx,0))/8)+max(dx,0)
  local ytile=flr((y+min(dy,0))/8)+max(dy,0)

  return(fget(mget(xtile,ytile), 1))
end

-- return true if a collides with b
function coll(a,b)
  local axTile=flr(a.x/8)
  local ayTile=flr(a.y/8)
  local bxTile=flr(b.x/8)
  local byTile=flr(b.y/8)

  if(axTile==bxTile and ayTile==byTile) return true
end

-- update crawler dx and dy if possible
function change_dir(a,dx,dy)
 if(wallColl(a,dx,dy)==false and
    wallColl(a,dx,dy,a.x*2,a.y*2)==false) then
   a.dx=dx or 0
   a.dy=dy or 0
  if(a.dy!=0) then
     a.x=flr((a.x+4)/8)*8
  elseif(a.dx!=0) then
     a.y=flr((a.y+4)/8)*8
  end
 end
end

-- [[ Draw Methods For Play State ]]

function draw_crawlers()
  local sx=0
  local sy=0

  for crawler in all(crawlers) do
    -- draw tail
    for node in all(crawler.tail) do
      sx=(node.x*8)/8
      sy=(node.y*8)/8
      spr(node.sprite,sx,sy)
    end
    -- draw head
    sx=(crawler.x*8)/8
    sy=(crawler.y*8)/8
    spr(crawler.sprite,sx,sy)
  end
end

function draw_bugs()
  local sx=0
  local sy=0

  for bug in all(bugs) do
    sx=(bug.x*8)/8
    sy=(bug.y*8)/8
    spr(bug.sprite,sx,sy)
  end
end

-->8
-- end of game state

function end_init()
	update=end_update
	draw=end_draw

end

function end_update()
		buttpress(allbutts,menu_init)
end

function end_draw()
	cls()
	print('end screen\n')
end
-->8
-- actors code





__gfx__
00000000333333330b3333330b3333b0333333b0000000000b333333333333b000000000000000000b3333b00b3333330b3333b00b333333333333b033333333
00000000333333330b333333b33333b0333333b0bbbbbbbb0b333333333333b0bbbbbb0000bbbbbb0b3333b00b3333330b33333b0b333333333333b033333333
00700700333333330b333333333333b0333333b0333333330b333333333333b033333bb00bb333330b3333b00b3333330b3333330b333333333333b033333333
00077000333333330b333333333333b0333333b0333333330b333333333333b0333333b00b3333330b3333b00b3333330b3333330b333333333333b033333333
00077000333333330b333333333333b0333333b0333333330b333333333333b0333333b00b3333330b3333b00b3333330b3333330b333333333333b033333333
00700700333333330b333333333333b0333333b0333333330bb3333333333bb0333333b00b3333330b3333b00b3333330b3333330b333333333333b033333333
00000000333333330b33333b333333b0b33333b0bbbbbbbb00bbbbbbbbbbbb00333333b00b3333330b3333b00b33333b0b3333330b333333333333b0bbbbbbbb
00000000333333330b3333b0333333b00b3333b0000000000000000000000000333333b00b3333330b3333b00b3333b00b3333330b333333333333b000000000
333333330b333333333333b033333333333333b00b3333330b3333b00b3333b000000000000000000b3333b0333333b00b3333b0000000000000000000000000
33333333b33333333333333b333333333333333bb33333330b33333bb33333b0bbbbbb0000bbbbbb0b33333b333333b0b33333b0bbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333333333333330b333333333333b033333bb00bb333330b333333333333b0333333b0333333333333333333333333
3333333333333333333333333333333333333333333333330b333333333333b0333333b00b3333330b333333333333b0333333b0333333333333333333333333
3333333333333333333333333333333333333333333333330b333333333333b0333333b00b3333330b333333333333b0333333b0333333333333333333333333
3333333333333333333333333333333333333333333333330bb3333333333bb0333333b00b3333330b333333333333b0333333b0333333333333333333333333
3333333b3333333333333333b3333333bbbbbbbbbbbbbbbb00bbbbbbbbbbbb00b33333b00b33333b0b333333b33333b0333333b033333333b33333333333333b
333333b033333333333333330b333333000000000000000000000000000000000b3333b00b3333b00b3333330b3333b0333333b0333333330b333333333333b0
005555000055d5000000000011111111055555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d5775500d5555500000000010000001557775500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d57c1755d55655550007700010000001570007550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d771177d65555d5d0088880010000001705550750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0777705dd55555d0087880010000001055750550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd07705ddd655d6d0008800010000001057075570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dd006d00dddddd00000000010000001075555700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddd0000dd6d000000000011111111007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009999000099a9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a9779900a9999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a97b3799a99b99990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a773377ab9999a9a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0777709aa99999a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa07709aaab99aba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aa00aa00aaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa0000aaba000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001010101010101010101010101010101010101010101010101010101010101204000800300000000000000010101012040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1905050505050505050505051e1d1d1f05050505050505050505051800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000002300000000000d01010e00000000002300000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00091d1d0800091d1d0800060f0f0700091d1d0800091d1d08000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00060f130e00060f130e2300000000230d100f07000d100f07000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0000000d0e0000000d0e00091d1d08000d0e0000000d0e0000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1d08000d121d0800060700060f0f0700060700091d110e00091d1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0f0700060f0f07000000232300002323000000060f0f0700060f1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00002323000000091d1d0800090800091d1d08000000232300000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00090800090800060f130e000607000d100f07000908000908000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000d0e000d0e0000000d0e230000230d0e0000000d0e000d0e000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24230d0e000d121d0800060700090800060700091d110e000d0e232400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00060700060f0f07230000230d0e23000023060f0f07000607000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0000002300002300000908000d0e0009080000230000230000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00091d1d1d0800091d110e000d0e000d121d0800091d1d1d08000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00060f0f130e000d01010e000d0e000d01010e000d100f0f07000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000000000d0e00060f0f0700060700060f0f07000d0e000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1d1d08000d0e23000023002300002300230000230d0e00091d1d1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060f0f0700060700090800091d1d1d1d0800090800060700060f0f0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000023000023060700060f0f0f0f07000607230000230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
091d1d080009082300002323000000002323000023090800091d1d0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0f0f0700060700091d0800091d1d0800091d0800060700060f0f1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000023000000020f07000613100700060f04000000230000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00090800091d1d03000023000d0e002300000c1d1d08000908000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000d0e00060f0f0700090800060700090800060f0f07000d0e000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000d0e2300000000230d0e230000230d0e2300000000230d0e000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00060700091d1d08000d0e000908000d0e00091d1d08000607000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a230000230d100f07000607000d0e00060700060f130e230000230a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000908000d0e0000230000230d0e2300002300000d0e000908000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00060700060700091d1d0800060700091d1d08000607000607000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000000230000000d01010e000000000d01010e000000230000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1605050505050505150f0f1405050505150f0f14050505050505051700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
