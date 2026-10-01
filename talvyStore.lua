-- ==========================================
-- TALVY OS - APP STORE (store.lua)
-- ==========================================

local width, height = getResolution()

-- Zadané RGB565 farby pre UI
local COLOR_BG       = 0x0000 -- Čierna
local COLOR_TEXT     = 0xFFFF -- Biela
local COLOR_SUBTEXT  = 0xAD55 -- Svetlosivá
local COLOR_ACCENT   = 0xFFE0 -- Žltá (pre hlásenia)
local COLOR_SUCCESS  = 0x07E0 -- Zelená
local COLOR_BTN_BG   = 0x18E3 -- Tmavomodrá/Sivá pre tlačidlo
local COLOR_BTN_TEXT = 0xFFFF -- Biela

-- 1. Úvodná obrazovka načítavania
fillScreen(COLOR_BG)
setCursor(10, 10)
setTextColor(COLOR_ACCENT)
print("Stiahujem katalog z GitHubu...")

-- Stiahneme čerstvý store.json (z volania C++)
if fetchStoreCatalog then
    fetchStoreCatalog()
end

-- Načítame katalóg do Lua tabuľky
local catalog = getStoreCatalog()

-- Funkcia pre vykreslenie celého rozhrania obchodu
function nakresliObchod(statusMsg)
    fillScreen(COLOR_BG)
    
    -- Hlavička Obchodu
    setCursor(10, 8)
    setTextColor(COLOR_TEXT)
    print("--- APP STORE ---")
    
    -- Zobrazenie stavovej správy (napr. "Inštalujem...")
    if statusMsg then
        setCursor(10, 22)
        setTextColor(COLOR_ACCENT)
        print(statusMsg)
    end

    if not catalog or #catalog == 0 then
        setCursor(10, 45)
        setTextColor(0xF800) -- Červená
        print("Katalog je prazdny alebo zlyhal download!")
        return
    end

    -- Kreslenie zoznamu aplikácií
    local startY = 40
    local cardHeight = 42
    local gap = 6

    for i, app in ipairs(catalog) do
        local y = startY + (i - 1) * (cardHeight + gap)
        
        -- Kontrola, či sa karta ešte zmestí na obrazovku
        if y + cardHeight > height then
            break
        end

        -- 1. Pozadie karty
        obdlznik(5, y, width - 10, cardHeight)

        -- 2. Ikona/Farba aplikácie (štvorec vľavo)
        -- Použijeme farbu aplikácie z JSONu
        setTextColor(app.color or COLOR_TEXT)
        setCursor(12, y + 12)
        print("[#]") 

        -- 3. Názov aplikácie
        setCursor(35, y + 6)
        setTextColor(COLOR_TEXT)
        print(app.name or "Aplikacia")

        -- 4. Popis aplikácie
        setCursor(35, y + 22)
        setTextColor(COLOR_SUBTEXT)
        print(app.desc or "")

        -- 5. Tlačidlo "INSTAL" vpravo
        local btnW = 55
        local btnH = 24
        local btnX = width - btnW - 12
        local btnY = y + 9

        obdlznik(btnX, btnY, btnW, btnH)
        setCursor(btnX + 6, btnY + 5)
        setTextColor(COLOR_SUCCESS)
        print("INSTAL")
    end
end

-- Vykreslíme obchod pri štarte
nakresliObchod()

-- 2. Hlavná slučka obchodu (Sledovanie dotykov)
local touchedLastFrame = false

while true do
    local touched, x, y = getTouch()

    -- Detekcia jediného kliknutia (Edge trigger - stlačené TERAZ, minule NEBOLO)
    if touched and not touchedLastFrame then
        touchedLastFrame = true
        
        local startY = 40
        local cardHeight = 42
        local gap = 6

        if catalog and #catalog > 0 then
            for i, app in ipairs(catalog) do
                local cardY = startY + (i - 1) * (cardHeight + gap)
                if cardY + cardHeight > height then break end

                -- Kontrola kliknutia do oblasti celej karty alebo tlačidla
                if x >= 5 and x <= (width - 5) and y >= cardY and y <= (cardY + cardHeight) then
                    
                    -- Informujeme používateľa
                    nakresliObchod("Instalujem: " .. app.name .. "...")
                    print("instalujem")
                    
                    -- Zavoláme tvoju inštalačnú funkciu
                    if installApp then
                        installApp(app.script, app.name, app.color or 0xFFFF)
                    end
                    print("nainstalovane")
                    sleep(800)
                    nakresliObchod("Nainstalovane: " .. app.name)
                    break
                end
            end
        end

    elseif not touched then
        -- Ak sa nikto nedotýka, uvoľníme zámok
        touchedLastFrame = false
    end

    -- Krátke neblokujúce čakanie pre odľahčenie procesora
    sleep(20)
end