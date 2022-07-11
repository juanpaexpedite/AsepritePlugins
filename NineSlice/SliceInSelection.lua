local error = 0
local slicesLayerIdx = 0
local sliceIdx=1
local dlg

function check()

  if app.apiVersion < 1 then
    error = 1
    return app.alert("This script requires Aseprite v1.2.10-beta3")
  end

  local sprite = app.activeSprite
  if not sprite then
    error = 1
    return app.alert("There is no sprite")
  end

  local layer = app.activeLayer
  if not layer then
    error = 1
    return app.alert("There is no active layer")
  end

  for i = 1,#sprite.layers do
    if sprite.layers[i].name == "Slices" then
      slicesLayerIdx = i 
      return
    end
  end

  error = 1
  return app.alert("Slices layer required")

end

function fill()
  
  check()

  if error > 0 then
    return 
  end

  local sprite =  app.activeSprite
  local cel =  app.activeLayer.cels[1]
  local oldimage
  local oldpos = Point(0,0)
  if not cel then
    cel = app.activeSprite:newCel(app.activeLayer, 1)
  else
    oldimage = cel.image:clone()
    oldpos = cel.position
    cel = app.activeSprite:newCel(app.activeLayer, 1)
  end

  local sourceimg = sprite.layers[slicesLayerIdx].cels[1].image
  local img = cel.image:clone()

  if oldimage then
    img:drawImage(oldimage,oldpos)
  end

  local selection = app.activeSprite.selection
  local rectangle = selection.bounds
  
  if rectangle.width < 1 then
    return app.alert("There is no selection")
  end

  if rectangle.height < 1 then
    return app.alert("There is no selection")
  end

  local slice = sprite.slices[sliceIdx]
  local sliceBounds = slice.bounds
  local sliceCenter = slice.center

  if not slice then
    return app.alert("there is no slice")
  end
  
  local c1 = Color { r=255, g=0, b=0, a=255 }
  
  if not selection.isEmpty then
    
    drawTopLeft(sourceimg,img,rectangle,sliceBounds,sliceCenter)
    drawTop(sourceimg,img,rectangle,sliceBounds,sliceCenter)
    drawTopRight(sourceimg,img,rectangle,sliceBounds,sliceCenter)
    
    drawBottomLeft(sourceimg,img,rectangle,sliceBounds,sliceCenter)
    drawBottom(sourceimg,img,rectangle,sliceBounds,sliceCenter)
    drawBottomRight(sourceimg,img,rectangle,sliceBounds,sliceCenter)
    
    drawLeft(sourceimg,img,rectangle,sliceBounds,sliceCenter)
    drawInside(sourceimg,img,rectangle,sliceBounds,sliceCenter)
    drawRight(sourceimg,img,rectangle,sliceBounds,sliceCenter)
    
  end
  cel.image = img
  app.refresh()
end

function drawTop(sourceimg,img, destination,bounds, center)
    
    local x0=bounds.x + center.x
    local y0=bounds.y
    local w = destination.width - (bounds.width - center.width)
    local h = center.y
    local modw = center.width
    local destx0 = destination.x + center.x

    for x=0,w-1,1 do
        for y=0,h-1,1 do
          local subx = x % modw
          local c2 = sourceimg:getPixel(x0 + subx,y0 + y)
          img:drawPixel(destx0 + x,destination.y + y,c2)      
        end
    end
end

function drawInside(sourceimg,img, destination,bounds, center)
    
    local x0=bounds.x + center.x
    local y0=bounds.y + center.y
    local w = destination.width - (bounds.width - center.width)
    local h =  destination.height - (bounds.height - center.height)

    local modw = center.width
    local modh = center.height
    local destx0 = destination.x + center.x
    local desty0 = destination.y + center.y
    
    for x=0,w-1,1 do
        for y=0,h-1,1 do
            local subx = x % modw
            local suby = y % modh
            local c2 = sourceimg:getPixel(x0 + subx ,y0 + suby)
          img:drawPixel(destx0 + x, desty0 + y,c2)      
        end
    end
end

function drawLeft(sourceimg,img, destination,bounds, center)
    
    local x0=bounds.x
    local y0=bounds.y + center.y
    local w = center.x
    local h =  destination.height - (bounds.height - center.height)

    local modh = center.height
    local desty0 =destination.y + center.y

    for x=0,w-1,1 do
        for y=0,h-1,1 do
          local suby = y % modh
          local c2 = sourceimg:getPixel(x0 + x,  y0 + suby)
          img:drawPixel(destination.x + x, desty0 + y,c2)      
        end
    end
end

function drawRight(sourceimg,img, destination,bounds, center)
    
    local y0=bounds.y + center.y
    local x0=bounds.x + center.x + center.width
    local h = destination.height - (bounds.height - center.height)
    local w = bounds.width - center.width - center.x

    local modh = center.width
    local destx0 = destination.x + destination.width - w
    local desty0 = destination.y + center.y

    for x=0,w-1,1 do
        for y=0,h-1,1 do
          local suby = y % modh
          local c2 = sourceimg:getPixel(x0 + x,y0 + suby)
          img:drawPixel(destx0 + x,desty0 + y,c2)      
        end
    end
end

function drawBottom(sourceimg,img, destination,bounds, center)
    
    local x0=bounds.x + center.x
    local y0=bounds.y + center.y + center.height
    local w = destination.width - (bounds.width - center.width)
    local h = bounds.height - center.height - center.y

    local modw = center.width
    local destx0 = destination.x + center.x
    local desty0 = destination.y + destination.height - h

    for x=0,w-1,1 do
        for y=0,h-1,1 do
          local subx = x % modw
          local c2 = sourceimg:getPixel(x0 + subx,y0 + y)
          img:drawPixel(destx0 + x,desty0 + y,c2)      
        end
    end
end

function drawTopLeft(sourceimg,img, destination,bounds, center)

    local w = center.x
    local h = center.y

    for x=0,w-1,1 do
        for y=0,h-1,1 do
          local c2 = sourceimg:getPixel(bounds.x + x,bounds.y + y)
          img:drawPixel(destination.x + x,destination.y+y,c2)      
        end
      end
end

function drawBottomLeft(sourceimg,img, destination,bounds, center)
    local x0 = bounds.x
    local y0 = bounds.y + center.y + center.height
    local w = center.x
    local h = bounds.height - center.height - center.y

    for x=0,w-1,1 do
        for y=0,h-1,1 do
          local c2 = sourceimg:getPixel(x0 + x , y0 + y)
          img:drawPixel(destination.x + x,destination.y + destination.height - h + y,c2)      
        end
    end
end

function drawTopRight(sourceimg,img, destination,bounds, center)
    local x0 = bounds.x + center.x + center.width
    local y0 = bounds.y
    local w = bounds.width - center.width - center.x
    local h = center.y

    local destx0 = destination.x + destination.width - w

    for x=0,w-1,1 do
        for y=0,h-1,1 do
          local c2 = sourceimg:getPixel(x0 + x , y0 + y)
          img:drawPixel(destx0 + x,destination.y + y,c2)      
        end
    end
end



function drawBottomRight(sourceimg,img, destination,bounds, center)
    local x0 = bounds.x + center.x + center.width
    local y0 = bounds.y + center.y + center.height
    local w = bounds.width - center.width - center.x
    local h = bounds.height - center.height - center.y

    local destx0 = destination.x + destination.width - w
    local desty0 = destination.y + destination.height - h

    for x=0,w-1,1 do
        for y=0,h-1,1 do
          local c2 = sourceimg:getPixel(x0 + x , y0 + y)
          img:drawPixel(destx0 + x,desty0 + y,c2)      
        end
    end
end

function selectslice()
  local data = dlg.data
  sliceIdx = tonumber(data.sliceentry)
end


function showDialog()

  dlg = Dialog { title="9-Slice Bucket"}
  dlg:label{ text="This script requires a layer with" }
  dlg:newrow()
  dlg:label{ text="source slices called 'Slices' case sensitive." }
  dlg:newrow()
  dlg:label{ text="The first source slice must be at 0,0." }
  dlg:newrow()

  dlg:entry{ id="sliceentry", label="Slice:",text="1",
  onchange=selectslice }
  dlg:newrow()

  dlg:button { text="Fill", onclick=fill}
  dlg:show { wait=false,bounds = Rectangle(0, 0, 400, 320) }
end

do
  showDialog()
end

--EOF :)