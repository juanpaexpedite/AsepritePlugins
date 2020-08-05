local colorcount=1
local coloridx=1
local ARRAY = {app.fgColor}
local RC = 0
local GC = 0
local BC = 0
local H = 0
local W = 0
local B = 0
local SHADES = {app.fgColor}
local sprite
local dlg

function max(x,y,z)
    return math.max(x, math.max(y, z));
end

function min(x,y,z)
    return math.min(x, math.min(y, z));
end

function round2(x)
    return math.floor(x*100)/100
end

function updateHWB()
    --1 From Array[1] Get the RGB

    RC = ARRAY[1].red
    GC = ARRAY[1].green
    BC = ARRAY[1].blue

    H = ARRAY[1].hsvHue
    W = (1 / 255.0) * min(RC,GC,BC)
    B = 1 - (1 / 255.0) * max(RC,GC,BC)

    H = round2(H)
    W = round2(W*100)
    B = round2(B*100)

    dlg:modify{ id="idrgbinfo",
        text= (RC .. "," .. GC .. "," .. BC)
    }

    dlg:modify{ id="idhwbinfo",
            text= (H .. "," .. W .. "," .. B)
            }

end

function HWBtoRGB(ih,iw,ib)
    local h = ih / 360.0
    local wh = iw / 100.0
    local bl = ib / 100.0
    local ratio = wh + bl
    local i
    local v
    local f
    local n

    if ratio > 1 then
        wh = wh / ratio
        bl = bl / ratio
    end

    i = math.floor(6 * h)
    v = 1 - bl;
    f = 6 * h - i;

    if (i % 2) == 1 then
        f = 1-f
    end
    --if ((i & 0x01) !== 0) {
        --f = 1 - f;
    --}
    --local b1 = b % 2

    n = wh + f * (v - wh);

    local r = 0
    local g = 0
    local b = 0

    

    if i == 0 then r,g,b = v,n,wh
    elseif i == 1 then r,g,b = n,v,wh
    elseif i == 2 then r,g,b = wh,v,nb
    elseif i == 3 then r,g,b = wh,n,v
    elseif i == 4 then r,g,b = n,wh,v
    elseif i == 5 then r,g,b = v,wh,n
    else r,g,b = v,n,wh
    end

    return Color {r = r*255, g = g*255, b = b*255}
end

function updateRamp()
    SHADES = {}
    
    local data = dlg.data
    local deltah= data.deltah
    local deltaw = data.deltaw
    local deltab = data.deltab

    local nh=0
    local nw =0
    local nb = 0
    for i=1,data.idshades do
        nh = H + (deltah * i)
        if nh < 0 then
            nh = 360 + nh
        end
        nw = W + (deltaw * i)
        if nw < 0 then
            nw = 0
        end
        nb = B + (deltab * i)
        if nb < 0 then
            nb = 0
        end
        local color = HWBtoRGB(nh,nw,nb)
        table.insert(SHADES,color)
    end

    dlg:modify{ id="ramp",
      colors=SHADES
      }
end

function addramptopalette()
    sprite =app.activeSprite

    local palette = sprite.palettes[1]

    local ncolors = #palette
    local data = dlg.data
    local newsize = ncolors+data.idshades
    palette:resize(newsize)

    for i=0,data.idshades-1 do
        palette:setColor(ncolors+i,SHADES[i+1])
    end
end

function showDialog()

dlg = Dialog{
       title="HWB Color Ramp 0.1",
       onclose=function()
         WindowBounds = dlg.bounds
       end
     }

-- COLORS
:shades{ id="cols", label="Color",
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

:label{ id="idrgbinfo",
           label="RGB:",
           text="100,100,100" }

:label{ id="idhwbinfo",
           label="HWB:",
           text="100,100,100" }

:button{ text="Get Color",
          onclick=function()
            ARRAY = { app.fgColor}
            dlg:modify{ id="cols",
            colors=ARRAY
            } 
            updateHWB()
            end 
        }

:number{ id="idshades",
        label="Shades",
        text="2",
        decimals=0 }

:number{ id="deltah",
    label="Delta H",
    text="0",
    decimals=0 }

:number{ id="deltaw",
    label="Delta W",
    text="0",
    decimals=0 }

:number{ id="deltab",
    label="Delta B",
    text="0",
    decimals=0 }   

:button{ text="Create Ramp",
          onclick=updateRamp
        }

:shades{ id="ramp", label="Ramp",
        colors=SHADES
    }

:button{ text="Add ramp to palette",
    onclick=addramptopalette
  }


dlg:show{ wait=false, bounds=WindowBounds }
end
    
do
   showDialog()
   updateHWB()
end