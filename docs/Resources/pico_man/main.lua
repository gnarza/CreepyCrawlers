function _init()
 map_id=0
 mode=0
 hiscore=1800

 title_init()
end

function _update()

 if(mode==0)then
  title_update()
 else
  game_update()
 end

 --game start keys
 if(mode!=1)then
  if(btn(4) or btn(5))then
   game_init()
   mode=1
  end
 end
end

function _draw()
 if(mode==0)then
  title_draw()
 else
  game_draw()
 end
end



------
