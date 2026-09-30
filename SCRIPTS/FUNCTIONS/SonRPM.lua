-- 2. Variables persistantes (en dehors de run)
local last_run = -200
local send = 0
local mode_rpm = true
local var5 = 0

local function run()
    local now = getTime()
    
    -- Récupération des données brutes
    local rpm, rpmON = getSourceValue('Rpm')
    local ch2 = getValue('ch2') * 8
    local ch31 = getValue('ch31') * 8 -- recup valeur frein sans ABS
	
	
    -- Sécurisation du RPM (on évite le nil et on divise une seule fois)
    if not rpm or not rpmON then
        rpm = 0
    else
        rpm = rpm / 4
    end

    -- 3. Bloc de mise à jour lente (Toutes les 2 secondes)
    -- On ne calcule le mode et le 'send' qu'ici pour économiser le CPU
    if now - last_run >= 200 then
        local tab = model.getCurve(4)
        var5 = tab.y[5]
        
        -- Détermination du coefficient 'send'
        if     var5 == -90  then send = 1
        elseif var5 == -100 then send = 0
        elseif var5 == -80  then send = -1
        elseif var5 == 90   then send = -1
        elseif var5 == 100  then send = 0
        elseif var5 == 80   then send = 1
        end
        
        -- Optimisation : On remplace var[5]/math.abs(var[5]) par un simple booléen
        mode_rpm = (var5 < 0)
        
        last_run = now
    end

    -- 4. Logique de calcul de la valeur finale
    local final_val = 0
    
    if mode_rpm then
        -- MODE RPM : Seuil à 400
        if ch2 > 400 then -- quanq gaz
            final_val = rpm
        else -- quand neutre ou frein
            final_val = send * rpm
        end
    else
        -- MODE GAZ : Seuil à 0
        if ch2 > 0 then -- quanq gaz
            final_val = ch2
        else -- quand neutre ou frein
            final_val = send * ch31
        end
    end

    -- 5. Envoi unique à la télémétrie (ID 0x0026)
    setTelemetryValue(0x0026, 0, 0, final_val, 0, 2) -- si envoi 2 aficche 0.02
end

return { run = run }



