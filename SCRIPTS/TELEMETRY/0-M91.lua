local shared = ...

-- Configuration du fichier
local fich1 = "/NOTES/" .. string.sub(model.getInfo().name, 1, 1) .. "-note.txt"

-- Variables de travail
local texteLignes = {}
local ligneDepart = 1
local MAX_LIGNES_ECRAN = 6
local CHARS_PAR_LIGNE = 25 
local charger = true

local function chargerNote()
    texteLignes = {} 
    local f = io.open(fich1, "r")
    if f then
        local contenu = io.read(f, 4000)
        io.close(f)
        
        if contenu then
            -- Normalisation des fins de ligne
            contenu = string.gsub(contenu, "\r\n", "\n")
            contenu = string.gsub(contenu, "\r", "\n")
            contenu = contenu .. "\n"

            -- Découpage par ligne réelle
            for paragraphe in string.gmatch(contenu, "(.-)\n") do
                if paragraphe == "" then
                    texteLignes[#texteLignes + 1] = ""
                else
                    local ligneActuelle = ""
                    for mot in string.gmatch(paragraphe, "([^%s]+)") do 
                        if string.len(ligneActuelle .. " " .. mot) <= CHARS_PAR_LIGNE then
                            ligneActuelle = (ligneActuelle == "" and mot or ligneActuelle .. " " .. mot)
                        else
                            texteLignes[#texteLignes + 1] = ligneActuelle
                            ligneActuelle = mot
                        end
                    end
                    if ligneActuelle ~= "" then
                        texteLignes[#texteLignes + 1] = ligneActuelle
                    end
                end
            end
        end
    end
    ligneDepart = 1
end

function shared.run(event)
    lcd.clear()

    if charger then
        chargerNote()
        charger = false
    end

---- touche bascule entre ecran -----------------
 if event == EVT_VIRTUAL_NEXT_PAGE  then 
    playTone(1200, 120,5)
    shared.changeScreen(6)
 end

 if event == EVT_VIRTUAL_PREV_PAGE   then 
    playTone(1200, 120,5)
    shared.changeScreen(10)
 end

 if event == EVT_VIRTUAL_MENU_LONG   then 
    playTone(1200, 120,5)
    shared.changeScreen(1)
 end

    -- Navigation Molette avec gestion de la vitesse
    local s = getRotEncSpeed()
    local saut = 1
    if s == ROTENC_MIDSPEED then 
        saut = 2 
    elseif s == ROTENC_HIGHSPEED then 
        saut = 5 
    end

    if event == EVT_VIRTUAL_NEXT then
        if ligneDepart < (#texteLignes - MAX_LIGNES_ECRAN + 1) then
            ligneDepart = ligneDepart + saut
            -- Securite fin
            if ligneDepart > (#texteLignes - MAX_LIGNES_ECRAN + 1) then
                ligneDepart = #texteLignes - MAX_LIGNES_ECRAN + 1
            end
        end
    elseif event == EVT_VIRTUAL_PREV then
        if ligneDepart > 1 then
            ligneDepart = ligneDepart - saut
            -- Securite debut
            if ligneDepart < 1 then ligneDepart = 1 end
        end
    elseif event == EVT_VIRTUAL_ENTER then
        chargerNote()
    end

    -- Affichage
    lcd.drawText(1, 1, "NOTES                                   " , 0+INVERS)

    for i = 0, MAX_LIGNES_ECRAN - 1 do
        local idx = math.floor(ligneDepart) + i
        if texteLignes[idx] then
            lcd.drawText(0, 11 + (i * 9), texteLignes[idx], SMLSIZE)
        end
    end

    -- Barre de defilement
    if #texteLignes > MAX_LIGNES_ECRAN then
        local scrollH = 46 
        local curseurH = 7 
        local curseurPos = ((ligneDepart - 1) / (#texteLignes - MAX_LIGNES_ECRAN)) * (scrollH - curseurH)
        lcd.drawFilledRectangle(125, 9 + curseurPos, 2, curseurH, SOLID)
    end

-- page:
lcd.drawNumber(118, 56, 10, 0+INVERS)
end