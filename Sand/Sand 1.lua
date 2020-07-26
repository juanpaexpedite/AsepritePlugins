
local colorcount=1
local ARRAY = {app.fgColor}
local decrease = true
local divide = false


function changedecrease()

    if decrease then
        decrease = false
    else 
        decrease  =true
    end
end

function changedivide()

    if divide then
        divide = false
    else 
        divide =true
    end
end

function getColor(idx)

    if colorcount < 2 then
        return ARRAY[1]
    end

    return ARRAY[idx + 1]
end

function normalfill()

    if app.apiVersion < 1 then
        return app.alert("This script requires Aseprite v1.2.10-beta3")
    end
  
    local cel = app.activeCel
        if not cel then
        return app.alert("There is no active image")
    end
  
    math.randomseed(os.time())
    local img = cel.image:clone()

    if img.colorMode == ColorMode.RGB then
    
        local w = img.width
        local h = img.height

        local selection = app.activeSprite.selection

            for x=0,w do
                for y=0,h do
                    if selection:contains(x,y) then
                        coloridx = math.random(1,colorcount)
                        img:drawPixel(x,y,ARRAY[coloridx])   
                    end
                end
            end
    end

    cel.image = img
    app.refresh()

end

function decreasefill()

    if app.apiVersion < 1 then
        return app.alert("This script requires Aseprite v1.2.10-beta3")
    end
  
    local cel = app.activeCel
        if not cel then
        return app.alert("There is no active image")
    end
  
    math.randomseed(os.time())
  
    local img = cel.image:clone()
  
    if img.colorMode == ColorMode.RGB then
    
        local w = img.width
        local h = img.height

        local selection = app.activeSprite.selection

        local percentage = 100.0
        local step = 100/colorcount
        for x=0,w do
            for y=0,h do
                if selection:contains(x,y) then
                    img:drawPixel(x,y,ARRAY[1])   
                end
            end
        end

        for i=0,colorcount-1,1 do
            for x=0,w do
                for y=0,h do
                    if selection:contains(x,y) then
                        local value = math.random(0,100)
                        if(value < percentage) then
                            local color = getColor(i) 
                            img:drawPixel(x,y,color)   
                        end   
                    end
                end
            end

            if divide then
                percentage = percentage / 2.0
            else
                percentage = percentage - step
            end
        end
    end


  cel.image = img
  app.refresh()

end

 -- DIALOGUE
function showDialog()

    local dlg
    dlg = Dialog{
      title="SAND 1.0",
      onclose=function()
        FloorGeneratorWindowBounds = dlg.bounds
      end
    }

dlg
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



:check{ id="dccheck",
           label="Amount",
           text="Decrease",
           selected=true,
           onclick=changedecrease
         }

:check{ id="dvcheck",
         label="Mode",
         text="Divide",
         selected=false,
         onclick=changedivide
       }
         

:button{ text="Fill",
          onclick=function(ev)
            if decrease then
                decreasefill()
            else
                normalfill()
            end
          end
        }
          
dlg:show{ wait=false, bounds=FloorGeneratorWindowBounds }

end

--Now we have defined the functions and dialog let's show it
do
    showDialog()
end  
