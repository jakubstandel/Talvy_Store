
print("Start ")
local i = 0
setFullScreen(true)

while true do
    local touched, x, y = getTouch()

    if touched then
        fillScreen(0)
        setCursor(x, y)
        print("Dotyk na X: " .. x .. " Y: " .. y)

        i = i + 1 
        sleep(10)
        if y >= 200 then
            setFullScreen(false)


        end
        
        -- Príklad: Nakresli bodku tam, kde sa používateľ dotkol
        
    end
end