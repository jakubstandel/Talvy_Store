-- ==========================================
-- TALVY OS - APP STORE (store.lua)
-- ==========================================

local width, height = getResolution()

local COLOR_BG       = 0x0000 -- Čierna
local COLOR_TEXT     = 0xFFFF -- Biela
local COLOR_SUBTEXT  = 0xAD55 -- Sivá
local COLOR_ACCENT   = 0xFFE0 -- Žltá
local COLOR_INSTALL  = 0x07E0 -- Zelená (Inštalovať)
local COLOR_UNINSTALL= 0xF800 -- Červená (Odinštalovať)

fillScreen(COLOR_BG)
setCursor(10, 10)
setTextColor(COLOR_ACCENT)
print("Stiahujem katalog z GitHubu...")

if fetchStoreCatalog then
    fetchStoreCatalog()
end

local catalog = getStoreCatalog()

function nakresliObchod(statusMsg)
    fillScreen(COLOR_BG)
    
    setCursor(10, 8)
    setTextColor(COLOR_TEXT)
    print("--- APP STORE ---")
    
    if statusMsg then
        setCursor(10, 22)
        setTextColor(COLOR_ACCENT)
        print(statusMsg)
    end

    if not catalog or #catalog == 0 then
        setCursor(10, 45)
        setTextColor(COLOR_UNINSTALL)
        print("Katalog je prazdny!")
        return
    end

    local startY = 60
    local cardHeight = 42
    local gap = 6

    for i, app in ipairs(catalog) do
        local y = startY + (i - 1) * (cardHeight + gap)
        
        if y + cardHeight > height then break end

        -- Karta aplikácie
        obdlznik(5, y, width - 10, cardHeight)

        -- Ikona / farba
        setTextColor(app.color or COLOR_TEXT)
        setCursor(12, y + 12)
        print("[#]") 

        -- Meno a popis
        setCursor(35, y + 6)
        setTextColor(COLOR_TEXT)
        print(app.name or "App")

        setCursor(35, y + 22)
        setTextColor(COLOR_SUBTEXT)
        print(app.desc or "")

        -- Tlačidlo podľa stavu inštalácie
        local installed = isAppInstalled and isAppInstalled(app.script)
        local btnW = 65
        local btnH = 24
        local btnX = width - btnW - 10
        local btnY = y + 9

        obdlznik(btnX, btnY, btnW, btnH)
        setCursor(btnX + 4, btnY + 5)

        if installed then
            setTextColor(COLOR_UNINSTALL)
            print("ODINSTAL")
        else
            setTextColor(COLOR_INSTALL)
            print("INSTAL")
        end
    end
end

nakresliObchod()

local touchedLastFrame = false

while true do
    local touched, x, y = getTouch()

    if touched and not touchedLastFrame then
        touchedLastFrame = true
        
        local startY = 40
        local cardHeight = 42
        local gap = 6

        if catalog and #catalog > 0 then
            for i, app in ipairs(catalog) do
                local cardY = startY + (i - 1) * (cardHeight + gap)
                if cardY + cardHeight > height then break end

                -- Kliknutie na kartu
                if y >= cardY and y <= (cardY + cardHeight) then
                    local installed = isAppInstalled and isAppInstalled(app.script)

                    if installed then
                        -- ODINŠTALOVANIE
                        nakresliObchod("Odinstalujem: " .. app.name .. "...")
                        if uninstallApp then
                            uninstallApp(app.script)
                        end
                        sleep(500)
                        nakresliObchod("Odinstalovane!")
                    else
                        -- INŠTALÁCIA
                        nakresliObchod("Instalujem: " .. app.name .. "...")
                        if installApp then
                            installApp(app.script, app.name, app.color or 0xFFFF)
                        end
                        sleep(500)
                        nakresliObchod("Nainstalovane!")
                    end
                    break
                end
            end
        end

    elseif not touched then
        touchedLastFrame = false
    end

    sleep(20)
end
