 local colorcount=1
 local coloridx=1
 local ARRAY = {app.fgColor}
 local dlg
 local lay
 local cel
 local img
 local selection 
 local startwidth = 100
 local startheight = 100
 local startx = 0
 local starty = 0
 
 local minvaluepercent=100
 
 function main()
 
     if app.apiVersion < 1 then
         return app.alert("This script requires Aseprite v1.2.10-beta3")
     end

     local sprite = app.activeSprite
     local imgwidth = sprite.width
     local imgheight = sprite.height

     img = Image(imgwidth, imgheight)
     lay = app.activeSprite:newLayer()
     app.activeLayer = lay
     cel = app.activeSprite:newCel(app.activeLayer, 1)
   
     selection = app.activeSprite.selection

     math.randomseed(os.time())
 
     magic()
    
     cel.position = Point(0,0)
     cel.image = img
     
 
     app.refresh()
 
 end

 function proc(x,y)

     --TESTING RANDOM
     local value = math.random(0,100)
     if value < minvaluepercent then
        if selection.isEmpty or selection:contains(x,y) then
            img:drawPixel(x,y,ARRAY[coloridx])   
        end
     end
 end

function procline(x0,y,x1)
 
    local selection = app.activeSprite.selection
    for x=x0,x1,1 do
       if selection.isEmpty or selection:contains(x,y) then
           img:drawPixel(x,y,ARRAY[coloridx])   
       end
    end
end
 
 function algo_ellipsefill(x0,y0,x1,y1)
    --  void algo_ellipsefill(int x0, int y0, int x1, int y1, void* data, AlgoPixel proc)
    --local x0 = 100
    --local x1 = 200
    --local y0 = 50
    --local y1 = 101
  
    
    --long a = abs(x1-x0), b = abs(y1-y0), b1 = b&1;                 -- diameter
    local a = math.abs(x1-x0)
    local b = math.abs(y1-y0)
    --?local b1 = b&1 this is used to know if b is even or odd
    local b1 = b % 2
  
    --double dx = 4*(1.0-a)*b*b, dy = 4*(b1+1)*a*a;           -- error increment
    local dx = 4*(1.0-a)*b*b
    local dy = 4*(b1+1)*a*a
  
   --double err = dx+dy+b1*a*a, e2;                          -- error of 1.step
    local err = dx+dy+b1*a*a
    local e2 = 0
   
    --if (x0 > x1) { x0 = x1; x1 += a; }        -- if called with swapped points
    if x0 > x1 then
       x0 = x1 
       x1 = x1 + a
    end
  
    --if (y0 > y1) y0 = y1;                                  -- .. exchange them
    if y0 > y1 then
      y0 = y1
    end
  
    --y0 += (b+1)/2; y1 = y0-b1;               
    y0 = y0 + (b+1)/2
    y1 = y0-b1
  
    --a = 8*a*a; b1 = 8*b*b;
    a = 8*a*a;
    b1 = 8*b*b;
  
    while x0 <= x1 do
      
      procline(x0, y0,x1)
      procline(x0, y1,x1)
      
      e2 = 2*err
      
      --if (e2 <= dy) { y0++; y1--; err += dy += a; }                 // y step
      if e2 <= dy then
          y0 = y0+1
          y1 = y1-1
          dy = dy+a
          err = err + dy
      end
      
      --if (e2 >= dx || 2*err > dy) { x0++; x1--; err += dx += b1; }  // x step
      if e2 >= dx or 2*err > dy then
          x0 = x0+1
          x1 = x1 - 1
          dx = dx+b1
          err = err + dx
      end
    end
  
    while y0-y1 <= b do
  
      proc(x0-1, y0)       -- -> finish tip of ellipse
      proc(x1+1, y0)
      proc(x0-1, y1)
      proc(x1+1, y1)
      y0 = y0 + 1
      y1 = y1 -1
  
    end     
  
  end
 
 function algo_ellipse(x0,y0,x1,y1)
   --  void algo_ellipse(int x0, int y0, int x1, int y1, void* data, AlgoPixel proc)
   --local x0 = 100
   --local x1 = 200
   --local y0 = 50
   --local y1 = 101
 
   
   --long a = abs(x1-x0), b = abs(y1-y0), b1 = b&1;                 -- diameter
   local a = math.abs(x1-x0)
   local b = math.abs(y1-y0)
   --?local b1 = b&1 this is used to know if b is even or odd
   local b1 = b % 2
 
   --double dx = 4*(1.0-a)*b*b, dy = 4*(b1+1)*a*a;           -- error increment
   local dx = 4*(1.0-a)*b*b
   local dy = 4*(b1+1)*a*a
 
  --double err = dx+dy+b1*a*a, e2;                          -- error of 1.step
   local err = dx+dy+b1*a*a
   local e2 = 0
  
   --if (x0 > x1) { x0 = x1; x1 += a; }        -- if called with swapped points
   if x0 > x1 then
      x0 = x1 
      x1 = x1 + a
   end
 
   --if (y0 > y1) y0 = y1;                                  -- .. exchange them
   if y0 > y1 then
     y0 = y1
   end
 
   --y0 += (b+1)/2; y1 = y0-b1;               
   y0 = y0 + (b+1)/2
   y1 = y0-b1
 
   --a = 8*a*a; b1 = 8*b*b;
   a = 8*a*a;
   b1 = 8*b*b;
 
   while x0 <= x1 do
     
     proc(x1, y0)                                      --   I. Quadrant
     proc(x0, y0)                                      --  II. Quadrant
     proc(x0, y1)                                      -- III. Quadrant
     proc(x1, y1)                                      --  IV. Quadrant
     
     e2 = 2*err
     
     --if (e2 <= dy) { y0++; y1--; err += dy += a; }                 // y step
     if e2 <= dy then
         y0 = y0+1
         y1 = y1-1
         dy = dy+a
         err = err + dy
     end
     
     --if (e2 >= dx || 2*err > dy) { x0++; x1--; err += dx += b1; }  // x step
     if e2 >= dx or 2*err > dy then
         x0 = x0+1
         x1 = x1 - 1
         dx = dx+b1
         err = err + dx
     end
   end
 
   while y0-y1 <= b do
 
     proc(x0-1, y0)       -- -> finish tip of ellipse
     proc(x1+1, y0)
     proc(x0-1, y1)
     proc(x1+1, y1)
     y0 = y0 + 1
     y1 = y1 -1
 
   end     
 
 end
 
 
 function magic()
    
     local data = dlg.data
 
     local width = data.iniwidth
     local height = data.iniheight
 
     local amount = colorcount
     local increasex = data.iniincreasex
     local increasey = data.iniincreasey
 
     local centre = Point(data.inix, data.iniy)
 
     local p0 = Point(centre.x - width/2,centre.y + height/2)
     local p1 = Point(centre.x + width/2,centre.y - height/2)
 
     local deltax = 0
     local deltay = 0
     local iniwidth = data.iniwidth
     local iniheight = data.iniheight
 
     for i=amount-1,0,-1 do
 
         coloridx = i+1
         width = iniwidth + i*increasex*iniwidth/100
         height = iniheight + i*increasey*iniheight/100
 
         deltax = data.inideltax*i/100
         deltay = data.inideltay*i/100
 
        
         --p0 has to be bottom left, p1 top right
         p0 = Point(deltax + centre.x - width/2,deltay + centre.y + height/2)
         p1 = Point(deltax + centre.x + width/2,deltay + centre.y - height/2)
         
         algo_ellipsefill(p0.x, p0.y, p1.x, p1.y)

         if data.inispatter == 0 then
             algo_ellipse(p0.x, p0.y, p1.x, p1.y)
         else
 
             local stepscount = data.inispatter
             for step=stepscount,0,-1 do
                 minvaluepercent = 100 - step * 100/stepscount
                 algo_ellipse(p0.x-step, p0.y+step, p1.x+step, p1.y-step)
             end
         end
 
     end
 
    
 end
 
 
 function showDialog()
 
 dlg = Dialog{
       title="Circular Gradients 1.0",
       onclose=function()
         WindowBounds = dlg.bounds
       end
     }
 
 dlg
 :number{ id="iniwidth",
         label="Initial Width",
         text="62",
         decimals=0 }
 
 :number{ id="iniheight",
         label="Initial Height",
         text="6",
         decimals=0 }
 
 :number{ id="inix",
         label="Start X",
         text="146",
         decimals=0 }
 
 :number{ id="iniy",
         label="Start Y",
         text="109",
         decimals=0 }
 
 -- COLORS
 :shades{ id="cols", label="Colors",
 colors=ARRAY,
 onclick=function(ev) 
   --app.fgColor=ev.color 
   if ev.button == MouseButton.LEFT then
       --TODO Aseprite get ev.index from shades
       --table.insert(ARRAY,ev.color)
       dlg:modify{ id="cols",
       colors=ARRAY
       }
   else
       --TODO Aseprite get ev.index from shades
       --table.remove(ARRAY,ev.idx + 1)
       dlg:modify{ id="cols",
       colors=ARRAY
       }
   end
   end 
 }
 
 :button{ text="Add",
           onclick=function()
             colorcount = colorcount+1
             table.insert(ARRAY, app.fgColor)
             dlg:modify{ id="cols",
             colors=ARRAY
             }
         end }
 
 :button { id="addrange", text="Set Range",
         onclick=function()
             local selectedindexes = app.range.colors
             local spr = app.activeSprite
             local palette = spr.palettes[1]
             colorcount=0
             ARRAY = {}
             for index, value in pairs(selectedindexes) do
                 colorcount = colorcount+1
                 local color = palette:getColor(value)
                 table.insert(ARRAY, color)
             end
             dlg:modify { id="cols",
             colors=ARRAY
             }
         end
         }
 
 :button{ text="Clear",
           onclick=function()
             colorcount = 0
             ARRAY = { }
             dlg:modify{ id="cols",
             colors=ARRAY
             }
         end }
 
 :separator{ label="increase", text="Increasing" }
 
 :number{ id="iniincreasex",
     label="Increase Width %",
     text="50",
     decimals=0 }
 
 :number{ id="iniincreasey",
     label="Increase Height %",
     text="50",
     decimals=0 }
 
 :number{ id="inideltax",
     label="Increase X %",
     text="0",
     decimals=0 }
 
 :number{ id="inideltay",
     label="Increase Y %",
     text="0",
     decimals=0 }
 
 :separator{ label="increase", text="Spatter" }
 
 :number{ id="inispatter",
     label="Levels",
     text="0",
     decimals=0 }
 
 :button{ text="Fill in new Layer",
           onclick=main
         }
 
 dlg:show{ wait=false, bounds=WindowBounds }
 end
 
 do
     showDialog()
 end