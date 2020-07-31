-- 31/07/2020 Examples of Aseprite
-- This is a not working file

-- Examples of using TOOLS
-- NOTE: For point use Point(x,y)

app.useTool{tool="pencil",color=Color{ r=200, g=200, b=0 },cel = source,points={ Point(20, 2),Point(30, 2) }}
app.useTool{tool="pencil",color=Color{ r=255, g=255, b=255 },layer = alayer,points={ centre }}
app.useTool{tool="filled_rectangle", cel=source,   color=app.fgColor,    points={ p0,p1 },    }


-- Example of message box
app.alert("There is no active image")
app.alert("P0:" .. p0.x .. "," .. p0.y .. ";P1:" .. p1.x .. "," .. p1.y) 