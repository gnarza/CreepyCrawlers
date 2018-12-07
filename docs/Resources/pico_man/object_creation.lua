-------------------
--object creation--
-------------------
function title_init()
 mode=0
 title_timer=0
 pac=nil

 --ghost colors
 ghost_cols={8,14,12,9}

 enes={}
 actors={}

 eat_c=0

 pause_t=0
 pause_m=0
 --pause mode
 --0=none
 --1=ready
 --2=eat
 --3=die
 --4=next level
 --5=gameover
 pause_a=0--animation pause
end

--called once before a games
--starts to setup all the
--objects
function game_init()
-- play_snd(0)

 srand(0)

 --attract values
 dr=
  {0,0,1,0,0,1,2,2,2,3
  ,0,0,3,0,1,0,1,0,3,0
  ,3,0,3,3,0,3,2,3,3,0
  ,1,0,1,0,1,0,3,0,3,0
  ,1,0,3,3,2,2,1,2,3,2
  ,1,1,1,1,2,1,0,1,0,3
  ,3,0,1,1,0,3,0,0,3,0
  ,3,3,2,1,0,1,1,1,0,2}
 dn=0

 --map colors
 map_cs={12,11,10,9,8,7,13,14}
 map_c=0
 map_blink=0

 --objects
 actors={}
 dots={}
 enes={}

 --fruit spawn
 f_spawn={}
 f_spawn.x=0
 f_spawn.y=0
 f_spawn.h=1
 f_spawn.t=0

 --fruit bonus
 f_bonus=
  {10,30,50,70,100,200,300,500}

 --player spawn
 p_spawn={}
 p_spawn.x=0
 p_spawn.y=0

 --camera
 cam={}
 cam.x=0
 cam.y=0
 cam.tox=0
 cam.toy=0

 --pen spaces
 pen={}
 --pen space count
 pen_c=0

 --pen door
 pen_d={}
 pen_d.x=0
 pen_d.y=0

 --ghost start spawn
 g_spawn={}

 --ghost pen order
 pen_o={3,2,4,1}

 --game values
 score=0
 lives=3
 level=0
 ai_mode=0
 --ai modes
 --0=scatter
 --1=chase
 ai_mode_timer=0
 scared_timer=0
 eat_gid=0
 eat_c=0
 release_flag=0

 pause_t=0
 pause_m=0
 --pause mode
 --0=none
 --1=ready
 --2=eat
 --3=die
 --4=next level
 pause_a=0--animation pause

 dot_c=0 --dot count
 dot_sc=0--dot starting count

 --dot images
 di={12,13}

 --center
 cx=76
 cy=88

 --create player
 pac=new_actor(0,0,0,3)
 pac.xm=1--move right
 pac.sa=1

 --create ghosts
 for i=1,4,1 do
  new_ghost(i)
 end

 --proccess the map
 load_map()
 game_update()
end

function load_map()
 set_level_values()

 --get map shift
 msh=map_id*19

 --set ghost speeds
 for o in all(enes)do
  o.ss.s=gv.gs
 end

 --get map color
 map_c=map_color()

 --reset dots
 dots={}

 --clear pen spaces
 pen={}
 pen_c=0

 --clear pen door
 pen_d.x=0
 pen_d.y=0

 --clear ghost spawn
 g_spawn={}

 --clear dot count
 dot_c=0
 dot_sc=0

 --scan the map
 for x=0,19,1 do
  for y=0,21,1 do

   local id=mget(msh+x,y)

   --player
   if(id==1)then
    p_spawn.x=x*8
    p_spawn.y=y*8
   end

   --dots
   if(id==12 or id==51)then
    local lid=mget(x+1+msh,y)
    local tid=mget(x+msh,y+1)
    new_dot(x*8,y*8)
    if(lid==12 or lid==51)then
     new_dot(x*8+4,y*8)
    end
    if(tid==12 or tid==51)then
     new_dot(x*8,y*8+4)
    end
   end

   --power dots
   if(id==13)then
    new_dot(x*8,y*8,2)
   end

   --ghosts
   if(id>=32 and id<=35)then
    --get ghost id
    local i=id-31
    local s={}
    s.x=x*8
    s.y=y*8
    s.gid=i
    add(g_spawn,s)
   end

   --pen door
   if(id==60)then
    pen_d.x=x*8
    pen_d.y=y*8
   end

   --pen spaces
   if(id==48)then
    --add the pen space
    local p={}
    pen_c+=1
    p.i=pen_c
    p.x=x*8
    p.y=y*8
    add(pen,p)
   end

   --fruit spawn
   if(id==52)then
    f_spawn.x=x*8
    f_spawn.y=y*8
   end

  end
 end

 new_round()

end

function new_actor(x,y,as,ae,c)
 local o={}

 --position
 o.x=x
 o.y=y

 --movement
 o.xm=0
 o.ym=0
 o.s=1

 --animation
 o.as=as
 o.ae=ae
 o.a=0
 o.sa=0.5
 o.al=1--loop

 --hidden
 o.h=0

 --flip image x/y
 o.fx=false
 o.fy=false

 --color replace
 o.c=c or 0

 --intersection flag
 o.it=0

 --id
 o.i=0

 --collision flag
 o.col=1

 add(actors,o)
 return o
end

function new_ghost(i)
 --get ghost color
 col=ghost_cols[i]

 --create ghost
 local p=new_actor
  (-50,-50,96,97,col)

 --set default values
 p.i=i--id

 --speeds
 p.ss={}
 p.ss.s=0
 p.ss.p=0.4--pen speed
 p.ss.r=2--return to pen

 p.m=0--ai mode
 --ai modes
 --0=none
 --1=pen wait
 --2=active->scatter/chase
 --4=back to pen
 --5=enter pen
 --6=exit pen

 p.sc=0 --scared flag
 p.r=0--reverse flag
 p.sa=0.125--animation speed

 add(enes,p)
 return p
end

function new_dot(x,y,t)
 local o={}

 --position
 o.x=x
 o.y=y

 --type
 o.t=t or 1

 add(dots,o)

 dot_c+=1--count the dots
 dot_sc+=1

 return o
end
