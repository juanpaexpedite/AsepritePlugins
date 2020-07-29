-- NOTES:
 --app.useTool{tool="pencil",color=Color{ r=200, g=200, b=0 },cel = source,points={ Point(20, 2),Point(30, 2) }}
 --app.useTool{tool="filled_rectangle", cel=source,   color=app.fgColor,    points={ p0,p1 },    }

local colorcount=1
local ARRAY = {app.fgColor}
local dlg

local startwidth = 100
local startheight = 100
local startx = 0
local starty = 0

function main()

    if app.apiVersion < 1 then
        return app.alert("This script requires Aseprite v1.2.10-beta3")
    end
  
    local cel = app.activeCel
        if not cel then
        return app.alert("There is no active image")
    end
  
    math.randomseed(os.time())
    --local img = cel.image:clone()

    if cel.image.colorMode == ColorMode.RGB then
    
        magic(cel)
        --algo_ellipse()

        
    end

    --cel.image = img
    app.refresh()

end

function proc(x,y)
    app.activeCel.image:drawPixel(x,y,ARRAY[1])   
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
  y0 = y0 + b+1/2
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


function magic(source)
   
    local selection = app.activeLayer.sprite.selection

    local sox = selection.bounds.x
    local soy = selection.bounds.y
    local sow = selection.bounds.width
    local soh = selection.bounds.height

    local data = dlg.data

    local width = data.iniwidth
    local height = data.iniheight

    local amount = colorcount
    local increasex = data.iniincreasex
    local increasey = data.iniincreasey
    local acel = app.activeCel
    local alayer = app.activeLayer

    local centre = Point(data.inix, data.iniy)

    local p0 = Point(centre.x - width/2,centre.y - height/2)
    local p1 = Point(centre.x + width/2,centre.y + height/2)

    local deltax = 0
    local deltay = 0

    for i=amount,0,-1 do

        width = data.iniwidth + i*increasex*data.iniwidth/100
        height =  data.iniheight +  i*increasey+data.iniheight/100

        deltax = data.inideltax*i/100
        deltay = data.inideltay*i/100

        p0 = Point(deltax + centre.x - width/2,deltay + centre.y - height/2)
        p1 = Point(deltax + centre.x + width/2,deltay + centre.y + height/2)

        --app.useTool
        --{
        --tool="filled_ellipse",
        --color=ARRAY[i+1],
        --points={ p0,p1 },
        --layer = alayer,
        --}

        algo_ellipse(p0.x, p0.y, p1.x, p1.y)

        
    end

    --app.useTool{tool="pencil",color=Color{ r=255, g=255, b=255 },layer = alayer,points={ centre }}
end


function showDialog()

dlg = Dialog{
      title="Circular Gradients 0.1",
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

:number{ id="iniincreasex",
    label="Increase Width %",
    text="2",
    decimals=0 }

:number{ id="iniincreasey",
    label="Increase Height %",
    text="2",
    decimals=0 }

:number{ id="inideltax",
    label="Increase X %",
    text="2",
    decimals=0 }

:number{ id="inideltay",
    label="Increase Y %",
    text="2",
    decimals=0 }


:button{ text="Fill",
          onclick=main
        }

dlg:show{ wait=false, bounds=WindowBounds }
end

do
    showDialog()
end