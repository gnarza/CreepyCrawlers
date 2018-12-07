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
	-- print('PRESS Z TO CONTINUE\n')
  print('SPLASH SCREEN GOES HERE\n', 0,0)
  print('PRESS Z TO CONTINUE\n', 0,8)
  print('~CREEPY CRAWLERS~\n', 0,16)
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
  print('MENU GOES HERE\n', 0,0)
  print('PRESS Z TO CONTINUE\n', 0,8)
  print('USE ARROWS TO MOVE AROUND\n', 0,16)
  print('EAT ONLY SHORTER LENGTH CRAWLERS AND LIL BUGS\n', 0,24)
  print('YOU ONLY HAVE ONE LIFE...\n', 0,32)

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
 centerY=128

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
 spwn2.bugFreq={150,150,150,150,150,150,150,150,150,150}
 spwn2.bugLife={600,600,450,300,300,300,300,300,300}
 spwn2.crawlerFreq={300,300,300,300,300,150,150,150,150}
 spwn2.crawlerLen={2,3,4,5,7,8,9,10,11}
 spwn2.crawlerSpawned={2,2,2,2,2,2,2,2,2}
 spwn2.e={0.9,0.7,0.5,0.3,0.1,0,0,0,0}
 spwn2.m={0.1,0.3,0.5,0.7,0.9,0.9,0.7,0.5,0.3}
 spwn2.h={0,0,0,0,0,0.1,0.3,0.5,0.7}
 make_level(spwn2,2)

 spwn3=make_spawning_manager()
 spwn3.bugFreq={150,150,150,150,150,150,150,150,150,150}
 spwn3.bugLife={450,450,300,300,300,300,300,300,300}
 spwn3.crawlerFreq={300,300,300,300,300,150,150,150,150}
 spwn3.crawlerLen={2,3,5,6,7,8,10,11,12}
 spwn3.crawlerSpawned={2,2,2,2,2,2,2,2,2}
 spwn3.e={0.3,0.2,0.1,0,0,0,0,0,0,0}
 spwn3.m={0.7,0.8,0.9,0.5,0.3,0.1,0,0,0,0}
 spwn3.h={0,0,0,0.5,0.7,0.9,1,1,1,1}
 make_level(spwn3,3)

-- timer for tail draw
 t=0

 pl=make_crawler(104,152)
 pl.pl=true
 -- start by going right
 change_dir(pl,1,0)
 --
 -- for i=1, 8 do
 --   add(pl.tail,tail_node(pl,pl.x,pl.y,pl.tailSpr))
 --   pl.length+=1
 -- end

end

function play_update()
	buttpress(zbutt,menu_init)
	buttpress(xbutt,togglesound)

  update_game()
  if(currentLvl>3 and pl.length>=9)then
    currentLvl=1
    menu_init()
  end
	update_crawlers()
  update_bugs()
end

function play_draw()
	cls()
	map(0,0,0,0,27,32)

	draw_crawlers()
  draw_bugs()
  -- -- if(#crawlers>1)then
  -- print(currentLvl,pl.x-50,pl.y-30)
  -- -- end
  -- print(pl.length,pl.x-16,pl.y+32)
  -- print(pl.x, pl.x-16,pl.y+8)
  -- print(pl.y, pl.x-16,pl.y+16)
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
  -- s.bugFreq={300,450,600,750,900,1050,0,0,0}
  s.bugFreq={150,150,150,150,150,150,150,150,150,150}
  s.bugLife={600,600,600,600,450,300,300,300,300}
  -- no more than this amount of bugs can exist on the map at a time
  s.bugSpawned={10,10,10,10,10,10,10,10,10,10}

  s.crawlerFreq={150,300,300,300,300,300,300,300,150,150}
  s.crawlerLen={1,2,3,4,5,6,7,8,9,10}
  -- no more than this amount of crawlers can exist on the map at a time
  s.crawlerSpawned={2,2,2,2,2,2,2,2,2,2}

  s.spawns={{0,8},{208,8},{208,240},{0,240}}
  s.tunnels={{0,128},{208,128}}

  s.e={1,0.9,0.8,0.7,0.6,0.5,0.2,0.1,0}
  s.m={0,0.1,0.2,0.3,0.4,0.5,0.8,0.9,1}
  s.h={0,0,0,0,0,0,0,0,0}

  return s
end

function make_bug(x,y)
  local b={}
  b.x=x
  b.y=y
  b.width=4
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
	c.speed=1.2
	c.dx=0
  c.dy=0

  c.rest=0
  -- Rest every 30 seconds from attack mode
  c.restCap=900
  -- rest for 10 seconds
  c.restTot=300

  -- animation
	c.sprite=32
  c.timer=0
  c.timrCap=6

  -- body
  c.tail={}
  c.length=0
  c.maxLength=9
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
  myE.speed=.8
  myE.timrCap=11
  -- put e sprite...
  myE.sprite=48
  myE.tailSpr=49
  myE.type="easy"
end

function make_m(x,y)
  myM = make_crawler(x,y)
  myM.speed=.85
  myM.timrCap=10
  -- put e sprite...
  myM.sprite=50
  myM.tailSpr=51
  myM.type="medium"
end

function make_h(x,y)
  myH = make_crawler(x,y)
  myH.speed=.9
  myH.timrCap=9
  -- put e sprite...
  myH.sprite=52
  myH.tailSpr=53
  myH.type="hard"
end

function tail_node(a,x,y,sp)
  local t={}
  t.x=x
  t.y=y
  -- t.node=a.length+1
  t.sprite=sp or 33

  -- add(a.tail,t)
  return t
end

-- [[ Update Methods For Play State ]]

function update_game()
  if(currentLvl>3 and pl.length>=9)then
   currentLvl=1
   menu_init()
  end
  if(cam.toX<64) cam.toX=64
  if(cam.toX>160) cam.toX=160
  cam.x+=(cam.toX-cam.x)*0.14

  if(cam.toY<64) cam.toY=64
  if(cam.toY>160) cam.toY=190
  cam.y+=(cam.toY-cam.y)*0.14

  camera(cam.x-63,cam.y-63)

  if(pl.length >= pl.maxLength) then
    -- remove all crawlers and bugs from table
    -- clean up player object, reset length, tail, speed(maybe), coords
    -- change level

    -- currBug = #bugs
    -- for bu=1,currBug do
    --   del(bugs, bugs[1])
    -- end

    bugs={}

    currCrawl = (#crawlers - 1)
    for cr=1,currCrawl do
      del(crawlers, crawlers[2])
    end

    -- plTail = #pl.tail
    pl.length=0
    pl.x=104
    pl.y=152
    pl.tail={}
    -- for ta in plTail do
    --   del(pl.tail, pl.tail[1])
    -- end

    currentLvl+=1
    if(currentLvl>3)then
      return
    end
  end


  -- code for spawning bugs and crawlers
  lvl=levels[currentLvl]
  spawner=lvl.spwnMgr
  lvl.sc+=1
  -- if(#bugs==0) then
  lvl.sb+=1
  -- end

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

    if(spwnPoints[rndSpawns][1]==0)then
      bugs[#bugs].dx=1
    else
      bugs[#bugs].dx=-1
    end
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

  -- update all crawler movements and mechanisms including player
  for a in all(crawlers) do
    a.timer+=1

    -- this is to make sure crawlers don't have a bug set as target when
    -- their lifecyle is over
    -- if(#bugs==0)then
    --   a.bugx=0
    --   a.bugy=0
    --   if(a.state==4)then
    --     a.state=1
    --   end
    -- end

    for b in all(bugs) do
      -- if the bug gets eaten +1 tail node of the same sprite
      if(coll(a,b))then
        add(a.tail,tail_node(a,a.x,a.y,a.tailSpr))
        a.length+=1
        if(a.pl)then
          pl.speed+=.01
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

    -- change the state of opponent crawlers if not colliding with player and
    -- handle nibbling and dying mechanisms
    if(a.pl==false)then
      -- if head collide and player is bigger than opponent
      if(coll(a,pl) and pl.length > a.length)then
        add(pl.tail,tail_node(pl,pl.x,pl.y,a.tailSpr))
        pl.length+=1
        pl.speed+=.01

        del(crawlers,a)
        break
      end
      -- you died start over sucker
      if(coll(a,pl) and pl.length <= a.length)then
        menu_init()
      end

      -- tail nibbled off opponent
      eaten=false
      eatAt= 0
      aLen= #a.tail
      for tl=1,aLen do
        if(eaten)then
          del(a.tail, a.tail[eatAt])
          a.length-=1
        elseif(coll(pl,a.tail[tl]))then
          eaten=true
          eatAt=tl
          del(a.tail, a.tail[eatAt])
          a.length-=1
        end
        if(a.length==0)then
          if(#a.tail!=0)then
            for rem in all(a.tail) do
              del(a.tail, rem)
            end
          end
          break
        end
      end
      -- tail nibbled off player
      eaten=false
      eatAt= 0
      plLen= #pl.tail
      for tl=1,plLen do
        if(eaten)then
          del(pl.tail, pl.tail[eatAt])
          pl.length-=1
        elseif(coll(pl.tail[tl],a))then
          eaten=true
          eatAt=tl
          del(pl.tail, pl.tail[eatAt])
          pl.length-=1
        end
        if(pl.length==0)then
          if(#pl.tail!=0)then
            for rem in all(pl.tail) do
              del(pl.tail, rem)
            end
          end
          break
        end
      end
      eaten=false

      -- chase if tail longer than player
      if(a.length >= pl.length)then
        a.state=3
        a.rest+=1
        -- evade if player close by and tail shorter
      elseif(dist(pl.x,a.x,pl.y,a.y)<80 and a.length < pl.length)then
        a.state=2
      end

      --rest if its been in chase mode for > one minute
      if(a.rest>=a.restCap and a.state==3)then
        if(a.rest>(a.restCap+a.restTot))then
          a.rest=0
        end
        a.rest+=1
        a.state=1
      end

      -- bugging state if bug is close to crawler and tail length meets
      -- shorter than criteria
      for e in all(bugs) do
        if(dist(e.x,a.x,e.y,a.y)<100 and a.length < pl.length)then
          a.state=4
          a.bugx=e.x
          a.bugy=e.y
        end
      end
    end

    -- depending on the state of the opponent crawlers change the direction when
    -- colliding with wall or at a fork
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
        -- target the exact player coordinates
        if(a.type=="hard")then
          trg_mv(a,pl.x,pl.y)
          -- target 4 tiles ahead of player for ambush effect
        elseif(a.type=="medium")then
          four=four_ahead(pl)
          trg_mv(a,four[1],four[2])
          -- target player only if dist between player and crawler > 50 pixels
        elseif(a.type=="easy")then
          if(dist(pl.x,a.x,pl.y,a.y)>=80)then
            trg_mv(a,pl.x,pl.y)
          else
            opp=opp_quad(pl)
            trg_mv(a,opp[1],opp[2])
          end
        end

        --4=bugging
      elseif(a.state==4)then
        trg_mv(a,a.bugx,a.bugy)
      end
    end


    -- 2DO ADD CODE FOR SLOWING DOWN IN TUNNELS

    -- move crawler
    if(a.pl) then
      if(wallColl(a)==false)then
        a.x+=a.dx*a.speed
        a.y+=a.dy*a.speed
      -- if colliding with wall snap to grid
      else
       a.x=flr((a.x+4)/8)*8
       a.y=flr((a.y+4)/8)*8
      end
    else
        a.x+=a.dx*a.speed
        a.y+=a.dy*a.speed
    end

    -- code that moves tail of crawlers along with head
    if(a.timer>=a.timrCap and a.length>0) then
      local mvTail={}
      add(mvTail,tail_node(a,a.x,a.y,a.tail[1].sprite))
      for tl=1,(#a.tail-1) do
        add(mvTail, tail_node(a,a.tail[tl].x, a.tail[tl].y, a.tail[tl+1].sprite))
      end
      a.tail=mvTail
      a.timer=0
    end

    -- screen wrapping
    if(a.x>centerX*2-6) a.x=0
    if(a.x<-4) a.x=centerX*2-6

  end

  cam_player()
end

function update_bugs()
  for b in all(bugs) do
    -- if the bug lifecyle is up go back to a spawning point and die
    if(b.lifecyle<=0) then
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
    elseif(dist(pl.x,b.x,pl.y,b.y)>=80 and b.state!=3)then
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
    if(b.x>centerX*2-6) b.x=0
    if(b.x<-4) b.x=centerX*2-6
  end
end

-- [[ Additional Methods For Play State ]]

-- randomly chooses an available direction
function rnd_mv(o)
    local dl=check_dir(o)
    if(#dl>0) change_dirA(o,dl[flr(rnd(#dl))])
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
  if(c>0) change_dirA(o,fd)
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

  if(x>108 and y>128)then
    return {0,0}
  elseif(x<=108 and y>128)then
   return {224,0}
  elseif(x>108 and y<=128)then
    return {0,264}
  elseif(x<=108 and y<=128)then
    return {224,264}
  end
end

-- return a tile 4 positions ahead of the player
function four_ahead(o)
  local x=o.x
  local y=o.y

  x+=o.dx*o.speed*4
  y+=o.dy*o.speed*4

  return {x,y}
end

-- finds available directions
function check_dir(o)
  local dir={}
  local b=(get_dir(o)+2)%4
  -- left,down,right,up = 0,1,2,3
  -- local currDir = get_dir(o)

  -- if(wallColl(o,1,0)==false and currDir!=0 and currDir!=2)then
  if(wallColl(o,1,0)==false and b!=0)then
    add(dir,0)
  end
  -- if(wallColl(o,0,1)==false and currDir!=1 and currDir!=3)then
  if(wallColl(o,0,1)==false and b!=1)then
    add(dir,1)
  end
  -- if(wallColl(o,-1,0)==false and currDir!=2 and currDir!=0)then
  if(wallColl(o,-1,0)==false and b!=2)then
    add(dir,2)
  end
  -- if(wallColl(o,0,-1)==false and currDir!=3 and currDir!=1)then
  if(wallColl(o,0,-1)==false and b!=3)then
    add(dir,3)
  end

  return dir
end

-- change the direction of actor o based on directions
-- left,down,right,up= 1,2,3,4 || 0,1,2,3
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
  print('YOU DIED\n', 0,0)
  print('PRESS Z TO CONTINUE\n', 0,8)
  print('END GAME STATE\n', 0,16)

end
-->8
-- actors code





__gfx__
0000000013b1313100000000000000000000000000000000bbb11b11131b33bbb22bb2b22222bb222229229224494422000000002b3b1313b3133bb23131b31b
00000000b13b333b00000000000000000000000000000000bb3b11b33b311b32b3bb3bb2bbbb3bbb4949444422449442000000002b333b311b3bb3bb13b133b3
0070070031311313000000000000000000000000000000002b31b331b13b1bb23bb33bb22bb3133b244249492494924200000000bb3b3bb3331333bb3bb3b131
00077000b33b33bb00000000000000000000000000000000b313bb1b11bb33bb3113b3b2233b31b14949444224424442000000002bbb1311b3bb33b21331b3b3
0007700031311b33000000000000000000000000000000002b3b31131b13b332b1bb313bbb33bb1b4444442422444942000000002b33bb3b1131bbb2b3bb33b3
0070070033b13313000000000000000000000000000000002bb33bb3b3313bbb333b13bb2bb1b31b249444942449442200000000bb3331333bb3b3bb333b333b
0000000013b33b31000000000000000000000000000000002bb3bb3bbbb3bbbbbb11b3b223b113b1444429422944244200000000bb3bb3b113b333b2bbbbbbbb
000000003b13b133000000000000000000000000000000002b22b22bb22b2b2213b11bb2bb33b13b2292424224944922000000002bb3313b3131b3b222b22bb2
000000000000000000000000000000000000000000000000000000000000000000000000000000002222222200000000000000002bb22b220000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000944244240000000000000000bbbbbbbb0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000494494420000000000000000b333b3330000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000004494424900000000000000003b33bb3b0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000002449944400000000000000003b3b13310000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000494444940000000000000000131b3bb30000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000004224444200000000000000003b331b310000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000222222220000000000000000b13b13130000000000000000
005555000055d5000000000022292292055555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d5775500d5555500000000049494444557775500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d57c1755d55655550007700024444949570007550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d771177d65555d5d0088880049494444705550750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0777705dd55555d0087880044444444055750550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd07705ddd655d6d0008800024944494057075570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dd006d00dddddd00000000044444942075555700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddd0000dd6d000000000022924242007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009999000099a900001111000011c100008888000088280000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a9779900a9999900c1771100c111110028778800288888000000000000000000000000000000000000000000000000000000000000000000000000000000000
a97b3799a99b9999c17a9711c11a1111287fe788288e888800000000000000000000000000000000000000000000000000000000000000000000000000000000
a773377ab9999a9ac779977ca1111c1c277ee772e888828200000000000000000000000000000000000000000000000000000000000000000000000000000000
a0777709aa99999ac0777701cc11111c207777082288888200000000000000000000000000000000000000000000000000000000000000000000000000000000
aa07709aaab99abacc07701ccca11cac22077082222882e200000000000000000000000000000000000000000000000000000000000000000000000000000000
0aa00aa00aaaaaa00cc00cc00cccccc0022002200222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa0000aaba0000cccc0000ccac00002222000022e20000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000100000101010100000101010100000000010000000000000101010101204000800300000000000000010101012040204000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
010f0f0f0f0f0f0f0f01010f0f0f0f0f01010f0f0f0f0f0f0f0f010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
240a1a1a231a1a1a0a0d0e0a1a1a1a0a0d0e0a1a1a1a231a1a0a240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0b09080b091d080b0d0e0b091d080b0d0e0b091d080b09080b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0b0d0e0b060f070b06070b060f070b06070b060f070b0d0e0b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0b0d0e231a1a23231a1a231a1a1a231a1a23231a1a230d0e0b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0b06070b09080b091d080b091d080b091d080b09080b06070b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e231a1a2306070b060f070b060f070b060f070b0607231a1a230d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0b0908231a1a231a231a231a231a231a231a231a1a2309080b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0b0d0e0b091d1d080b091d080b091d080b091d1d080b0d0e0b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0b06070b060f0f070b060f070b060f070b060f0f070b06070b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0a1a23231a1a1a23231a231a231a231a23231a1a1a23231a1a0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011d080b091d1d080b09080b091d080b09080b091d1d080b091d010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010e0b060f0f070b06070b060f070b06070b060f0f070b0d01010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010e0a231a1a23231a23231a1a1a23231a23231a1a230b0d01010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101080b09080b09080b091d1d1d080b09080b09080b090101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060f0f070b0d0e0b0d0e0b060f0f0f070b0d0e0b0d0e0b060f0f070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1a1a1a230d0e0b0607231a1a231a1a2306070b0d0e231a1a1a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011d1d080b0d0e231a1a2309080b0908231a1a230d0e0b091d1d010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101070b06070b09080b06070b06070b09080b06070b060101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010e0a231a1a230d0e231a1a231a1a230d0e231a1a230a0d01010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010e0b091d080b0d0e0b091d1d1d080b0d0e0b091d080b0d01010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f070b060f070b06070b060f0f0f070b06070b060f070b060f010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0a1a23231a1a231a1a231a1a231a1a231a1a231a1a23231a0a0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0b09080b09080b09080b09080b09080b09080b09080b09080b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0b0d0e0b06070b06070b0d0e0b0d0e0b06070b06070b0d0e0b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0b0d0e231a1a231a1a2306070b0607231a1a231a1a230d0e0b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0b06070b09080b0908231a1a231a1a2309080b09080b06070b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e231a1a230d0e0b06070b09080b09080b06070b0d0e231a1a230d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0b09080b0d0e231a1a230d0e0b0d0e231a1a230d0e0b09080b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0b06070b06070b09080b06070b06070b09080b06070b06070b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
240a1a1a231a1a0a0d0e0a1a1a231a1a0a0d0e0a1a1a231a1a0a240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
061d1d1d1d1d1d1d01011d1d1d1d1d1d1d01011d1d1d1d1d1d1d010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
