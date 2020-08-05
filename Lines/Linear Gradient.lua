local colorcount=1
local coloridx=1
local ARRAY = {app.fgColor}
local dlg
local lay
local cel
local img
local selection 
local startx = 0
local starty = 0
local dirx = 0
local diry = 0
local stepsize = 0
local sprite
local imgwidth
local imgheight
local brushimage

local length = 1

local minvaluepercent=100

function main()

    if app.apiVersion < 1 then
        return app.alert("This script requires Aseprite v1.2.10-beta3")
    end

    sprite = app.activeSprite
    imgwidth = sprite.width
    imgheight = sprite.height

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

    if(x< 0 or y < 0) then
        do return end
    end

    --if math.isinf(x) ~= 0 then
        --do return end
    --end

    --if math.isinf(y) ~= 0 then
        --do return end
    --end

    --TESTING RANDOM
    local value = math.random(0,100)
    if value <= minvaluepercent then
       if selection.isEmpty or selection:contains(x,y) then
           img:drawPixel(x,y,ARRAY[coloridx])   
       end
    end
end

function procpattern(x,y)

    if(x< 0 or y < 0) then
        do return end
    end

    --if math.isinf(x) ~= 0 then
        --do return end
    --end

    --if math.isinf(y) ~= 0 then
        --do return end
    --end

    if selection.isEmpty or selection:contains(x,y) then
       --img:drawPixel(x,y,ARRAY[coloridx])   
       drawpixelpattern(brushimage,x,y)
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

local function signum(number)
   if number > 0 then
      return 1
   elseif number < 0 then
      return -1
   else
      return 0
   end
end

function algo_line_perfect(px1,py1,px2,py2)
    
    local yaxis = false

    local x1 = px1
    local y1 = py1
    local x2 = px2
    local y2 = py2

    if (math.abs(py2-py1) > math.abs(px2-px1)) then
        x1 = py1
        y1 = px1
        x2 = py2
        y2 = px2
        yaxis = true
    end

    local w = math.abs(x2-x1)+1;
    local h = math.abs(y2-y1)+1;
    local dx = signum(x2-x1);
    local dy = signum(y2-y1);

    local e = 0;
    local y = y1;

    x2 = x2 + dx;

    for x=x1,x2,dx do
     if yaxis then
        proc(y,x)
     else
        proc(x,y)
     end

     e = e+h
     if e >= w then
        y = y+dy
        e= e-w
     end
    end

end

function algo_line_perfect_pattern(px1,py1,px2,py2)
    
    local yaxis = false

    local x1 = px1
    local y1 = py1
    local x2 = px2
    local y2 = py2

    if (math.abs(py2-py1) > math.abs(px2-px1)) then
        x1 = py1
        y1 = px1
        x2 = py2
        y2 = px2
        yaxis = true
    end

    local w = math.abs(x2-x1)+1;
    local h = math.abs(y2-y1)+1;
    local dx = signum(x2-x1);
    local dy = signum(y2-y1);

    local e = 0;
    local y = y1;

    x2 = x2 + dx;

    for x=x1,x2,dx do
     if yaxis then
        procpattern(y,x)
     else
        procpattern(x,y)
     end

     e = e+h
     if e >= w then
        y = y+dy
        e= e-w
     end
    end

end

function algo_line(x0,y0,x1,y1)
    --void plotLine(int x0, int y0, int x1, int y1)
    --int dx =  abs(x1-x0), sx = x0<x1 ? 1 : -1;
    local dx = math.abs(x1-x0)
    local sx = -1
    if x0<x1 then
        sx = 1
    end

    --int dy = -abs(y1-y0), sy = y0<y1 ? 1 : -1; 
    local dy = -1 * math.abs(y1-y0)
    local sy = -1
    if y0<y1 then
        sy = 1
    end

    --int err = dx+dy, e2; /* error value e_xy */
    local err = dx + dy
    local e2 = 0
     
    while true do
        --setPixel(x0,y0);
        proc(x0,y0)

        --if (x0==x1 && y0==y1) break;
        if (x0 == x1 and y0 == y1) then break end

        e2 = 2*err;

        --if (e2 >= dy) { err += dy; x0 += sx; }
        if e2 >= dy then
            err = err + dy
            x0 = x0 + sx
        end

        --if (e2 <= dx) { err += dx; y0 += sy; } /* e_xy+e_y < 0 */
        if e2 <=dx then
            err = err + dx
            y0 = y0 + sy
        end

      end

end



function magic()
   
    local data = dlg.data

    local amount = colorcount
    x0 = data.inix
    y0 = data.iniy
    x1 = data.dirx
    y1 = data.diry
    stepsize = data.step

    --Line formula
    local a = (y1-y0) / (x1-x0)
    local b = ((y1 + y0) - (a*(x0+x1)))/2.0
    local oa = -1 / a

    --algo_line(x0,y0,x1,y1)

    coloridx = 1
    offset = 0
    minvaluepercent = 100
    for c = 0,colorcount-1,1 do
            coloridx = c+1
            for y=0,stepsize-1,1 do
                local x = (y+offset-b)/a

                --(x,y is common on data line and in each perpendicular line)
                local xl = x-1000
                local yl = oa*xl + b + y + offset

                local xr = x+1000
                local yr = oa*xr + b + y + offset

                local rxl = math.floor(xl+0.5)
                local ryl = math.floor(yl+0.5)
                local rxr  =math.floor(xr+0.5)
                local ryr = math.floor(yr+0.5)

                if x0 == x1 then
                    procline(0,y+offset,imgwidth)
                else
                    algo_line_perfect(xl,yl,xr,yr)
                end

            end
        
        offset = offset + stepsize
    end

    --spatter
    local spatter = data.inispatter1

    if spatter > 0 then
    --before  spatter
    offset=0
    minvaluepercent = data.spatterpercentage
    for c = 1,colorcount-1,1 do
        coloridx = c+1
        for y=stepsize-1-spatter,stepsize-1,1 do
            local x = (y+offset-b)/a

            --(x,y is common on data line and in each perpendicular line)
            local xl = x-1000
            local yl = oa*xl + b + y + offset

            local xr = x+1000
            local yr = oa*xr + b + y + offset

            --algo_line(rxl,ryl,rxr,ryr)
            --algo_line(xl,yl,xr,yr)
            algo_line_perfect(xl,yl,xr,yr)

        end
    
    offset = offset + stepsize
    end
    end

    --after spatter
    spatter = data.inispatter2
    if spatter > 0 then
    offset=0
    minvaluepercent = data.spatterpercentage
    for c = 0,colorcount-1,1 do
        coloridx = c+1
        for y=stepsize-1,stepsize-1+spatter,1 do
            local x = (y+offset-b)/a

            --(x,y is common on data line and in each perpendicular line)
            local xl = x-1000
            local yl = oa*xl + b + y + offset

            local xr = x+1000
            local yr = oa*xr + b + y + offset

            --algo_line(rxl,ryl,rxr,ryr)
            --algo_line(xl,yl,xr,yr)
            algo_line_perfect(xl,yl,xr,yr)

        end
    offset = offset + stepsize
    end
    end

    --dither
    local usedither = data.ckdither

    if usedither then
        --region check pattern
        local activebrush  = app.activeBrush
        if activebrush == nil then
            do return end
        end
        brushimage = activebrush.image

        if brushimage == nil then
            do return end
        end
        --endregion

        c = Color{ r=255, g=255, b=255, a=255 }
        
        local bw = brushimage.width
        local bh = brushimage.height

        --coloridx=2
        --for y=stepsize-bh/2,stepsize*(colorcount-1),stepsize do
            --for x=0,1000,bw do
                --drawpattern(brushimage,x,y)
            --end
            --coloridx = coloridx+1
        --end



        --coloridx=1
        --for y=stepsize-2,stepsize*(colorcount-1),stepsize do
            --for x=0,1000,bw do
                --drawbottompattern(brushimage,x,y)
            --end
            --coloridx = coloridx+1
        --end

        --coloridx=1
        --for y=stepsize,stepsize*(colorcount-1),stepsize do
            --for x=0,imgwidth,bw do
                --drawpattern(brushimage,x,y)
            --end
            --coloridx = coloridx+1
        --end

        offset=0
        for c = 0,colorcount-1,1 do
            coloridx = c+1
            for y=stepsize-1,stepsize-1+bh,1 do
                local x = (y+offset-b)/a
    
                --(x,y is common on data line and in each perpendicular line)
                local xl = x-1000
                local yl = oa*xl + b + y + offset
    
                local xr = x+1000
                local yr = oa*xr + b + y + offset
    
                --algo_line(rxl,ryl,rxr,ryr)
                --algo_line(xl,yl,xr,yr)
                algo_line_perfect_pattern(xl,yl,xr,yr)
    
            end
        offset = offset + stepsize
        end

    end

end

function drawpixelpattern(brushimage, x, y)
    local val = 0
    local pc = app.pixelColor
    local dx = math.fmod(x,brushimage.width)
    local dy = math.fmod(y,brushimage.height)
    val = brushimage:getPixel(dx,dy)
    local alpha = pc.rgbaA(val)
    if alpha > 0 then
    img:drawPixel(x,y,ARRAY[coloridx])   
    end
end

function drawpattern(brushimage, offsetx, offsety)
    local val = 0
    local pc = app.pixelColor
    for dy=0,brushimage.height-1 do
        for dx=0,brushimage.width-1 do
            val = brushimage:getPixel(dx,dy)
            local alpha = pc.rgbaA(val)
            if alpha > 0 then
            img:drawPixel(dx+offsetx,dy+offsety,ARRAY[coloridx])   
            end
        end
    end
end

function drawbottompattern(brushimage, offsetx, offsety)
    local val = 0
    local pc = app.pixelColor
    local h2 = math.floor(brushimage.height/2+0.5)
    for dy=h2,brushimage.height-1 do
        for dx=0,brushimage.width-1 do
            val = brushimage:getPixel(dx,dy)
            local alpha = pc.rgbaA(val)
            if alpha > 0 then
            img:drawPixel(dx+offsetx,dy+offsety,ARRAY[coloridx])   
            end
        end
    end
end


function showDialog()

dlg = Dialog{
      title="Linear Gradients 0.1",
      onclose=function()
        WindowBounds = dlg.bounds
      end
    }

dlg
:number{ id="inix",
        label="Start X",
        text="128",
        decimals=0 }

:number{ id="iniy",
        label="Start Y",
        text="0",
        decimals=0 }


:number{ id="dirx",
        label="Direction X",
        text="128",
        decimals=0 }

:number{ id="diry",
        label="Direction Y",
        text="128",
        decimals=0 }

:number{ id="step",
        label="Step",
        text="10",
        decimals=0 }

:check{ id="ckdither",
           label="Dither",
           text="Dither",
           selected=false,
            }

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

:separator{ label="increase", text="Spatter" }

:number{ id="inispatter1",
    label="Before Level",
    text="0",
    decimals=0 }

:number{ id="inispatter2",
    label="After Level",
    text="0",
    decimals=0 }

:number{ id="spatterpercentage",
    label="Level %",
    text="20",
    decimals=0 }


:button{ text="Fill in new Layer",
          onclick=main
        }

dlg:show{ wait=false, bounds=WindowBounds }
end

do
    showDialog()
end