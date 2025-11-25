local shared = ...

--------------------------------------------------
-- Fichier et constantes
--------------------------------------------------
local FILE_PATH = "/SCRIPTS/TELEMETRY/" .. string.sub(model.getInfo().name, 1, 1) .. "-gps.txt"

local textChars = {
  
  "a","b","c","d","e","f","g","h","i","j",
  "k","l","m","n","o","p","q","r","s","t",
  "u","v","w","x","y","z",
  "A","B","C","D","E","F","G","H","I","J",
  "K","L","M","N","O","P","Q","R","S","T",
  "U","V","W","X","Y","Z",
  "0","1","2","3","4","5","6","7","8","9","-"," "
}

local lines = {}
local selLine = 1
local selField = 1
local editPos = 1
local editing = false
local letterSelect = false
local letterEdit = false
local rebound = 0
local firstLine = 1
local visibleLines = 5

--------------------------------------------------
-- Conversion micro-degrés <-> affichage
--------------------------------------------------
local function intToDeg(val)
  return string.format("%.5f", val / 100000)
end

local function degToInt(val)
  return math.floor(tonumber(val) * 100000 + 0.5)
end

--------------------------------------------------
-- Fonctions io sécurisées
--------------------------------------------------
local function loadFile()
  lines = {}
  local f = io.open(FILE_PATH,  "r")
  if not f then
    local nf = io.open(FILE_PATH,"w")
    if nf then io.close(nf) end
    lines[1] = {lat=0, lon=0, name="------"}
    return
  end

  local content = io.read(f, 2400)
  io.close(f)
  if content then
    for line in string.gmatch(content, "([^\n\r]+)") do
      local lat, lon, name = string.match(line, "([%d%-%.]+)%s+([%d%-%.]+)%s+(.+)")
      if lat and lon and name then
        lines[#lines+1] = {lat=degToInt(lat), lon=degToInt(lon), name=name}
      end
    end
  end
  if #lines == 0 then
    lines[1] = {lat=0, lon=0, name="------"}
  end
end

local function saveFile()
  local f = io.open(FILE_PATH, "w")
  if not f then return end
  local buffer = ""
  for i=1,#lines do
    local pt = lines[i]
    buffer = buffer .. intToDeg(pt.lat) .. " " .. intToDeg(pt.lon) .. " " .. pt.name .. "\n"
  end
  io.write(f, buffer)
  io.close(f)
  
end

--------------------------------------------------
-- Outils texte
--------------------------------------------------
local function chooseChar(index, step)
  index = index + step
  if index < 1 then index = #textChars end
  if index > #textChars then index = 1 end
  return index
end

local function strToTable(s)
  local t = {}
  for i=1,string.len(s) do
    t[i] = string.sub(s,i,i)
  end
  return t
end

local function tableToStr(t)
  local s = ""
  for i=1,#t do
    s = s .. t[i]
  end
  return s
end

local function editText(str, step, pos)
  local chars = strToTable(str)
  if pos > #chars then chars[#chars+1] = " " end
  local c = chars[pos]
  local idx = 1
  for i=1,#textChars do
    if textChars[i] == c then idx = i break end
  end
  idx = chooseChar(idx, step)
  chars[pos] = textChars[idx]
  return tableToStr(chars)
end

--------------------------------------------------
-- Initialisation
--------------------------------------------------
loadFile()

--------------------------------------------------
-- Fonction principale
--------------------------------------------------
function shared.run(event)
  lcd.clear()
  
  ---- touche bascule entre ecran -----------------
 if event == EVT_VIRTUAL_NEXT_PAGE and editing == false then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(15)
  end
   if event == EVT_VIRTUAL_PREV_PAGE and editing == false then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(9)
  end
  
 if event == EVT_VIRTUAL_MENU_LONG and editing == false then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(1)
  end
  
  
  lcd.drawText(1, 1, "EDITEUR GPS SESSIONS                  ", INVERS)

  -- Ajustement du défilement
  if selLine < firstLine then
    firstLine = selLine
  elseif selLine >= firstLine + visibleLines then
    firstLine = selLine - visibleLines + 1
  end

  -- Affichage
  local y = 13
  for i = firstLine, math.min(firstLine + visibleLines - 1, #lines) do
    local pt = lines[i]
    local inv = (i == selLine) and INVERS or 0

    lcd.drawText(0, y, intToDeg(pt.lat), SMLSIZE + ((inv ~= 0 and selField==1) and INVERS or 0))
    lcd.drawText(49, y, intToDeg(pt.lon), SMLSIZE + ((inv ~= 0 and selField==2) and INVERS or 0))

    -- Nom
    if i == selLine and selField==3 then
      local t = strToTable(pt.name)
      if editing and (letterSelect or letterEdit) then
        for j=1,#t do
          if j == editPos then
            lcd.drawText(92 + (j-1)*6, y, t[j], SMLSIZE + INVERS)
          else
            lcd.drawText(92 + (j-1)*6, y, t[j], SMLSIZE)
          end
        end
      else
        -- mode navigation : nom entier en surbrillance
        lcd.drawText(92, y, pt.name, SMLSIZE + INVERS)
      end
    else
      lcd.drawText(92, y, pt.name, SMLSIZE)
    end

    y = y + 9
  end

  local pt = lines[selLine]

  --------------------------------------------------
  -- ÉDITION
  --------------------------------------------------
  if editing then
    -- Latitude
    if selField==1 then
      if event==EVT_VIRTUAL_NEXT then 
	  playTone(1200, 120,5) -- play tone
		if getRotEncSpeed() == ROTENC_HIGHSPEED then
			pt.lat = pt.lat +10000
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then
			pt.lat = pt.lat +100
		else
			pt.lat = pt.lat +1
		end	  
	  
	  
	  
      elseif event==EVT_VIRTUAL_PREV then 
	  playTone(1200, 120,5) -- play tone
		if getRotEncSpeed() == ROTENC_HIGHSPEED then
			pt.lat = pt.lat -10000
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then
			pt.lat = pt.lat -100
		else
			pt.lat = pt.lat -1
		end	  
	  
      elseif event==EVT_VIRTUAL_ENTER and getTime()-rebound>20 then
	  playTone(1200, 120,5) -- play tone
        editing = false
        saveFile()
        rebound = getTime()
      end
    -- Longitude
    elseif selField==2 then
      if event==EVT_VIRTUAL_NEXT then 
	  playTone(1200, 120,5) -- play tone
		if getRotEncSpeed() == ROTENC_HIGHSPEED then
			pt.lon = pt.lon +10000
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then
			pt.lon = pt.lon +100
		else
			pt.lon = pt.lon +1
		end	  
      elseif event==EVT_VIRTUAL_PREV then 
	  playTone(1200, 120,5) -- play tone
		if getRotEncSpeed() == ROTENC_HIGHSPEED then
			pt.lon = pt.lon -10000
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then
			pt.lon = pt.lon -100
		else
			pt.lon = pt.lon -1
		end	  
	  
      elseif event==EVT_VIRTUAL_ENTER and getTime()-rebound>20 then
	  playTone(1200, 120,5) -- play tone
        editing = false
        saveFile()
        rebound = getTime()
      end
    -- Nom
    elseif selField==3 then
      if letterSelect then
        if event==EVT_VIRTUAL_NEXT then
		  editPos = editPos + 1
          if editPos > 6 then editPos = 6 
		  else
		  playTone(1200, 120,5) -- play tone
		  end
        elseif event==EVT_VIRTUAL_PREV then
          editPos = editPos - 1
          if editPos < 1 then editPos = 1
else
playTone(1200, 120,5) -- play tone		  
		  end
        elseif event==EVT_VIRTUAL_ENTER and getTime()-rebound>20 then
		playTone(1200, 120,5) -- play tone
          letterSelect = false
          letterEdit = true
          rebound = getTime()
        end
      elseif letterEdit then
        if event==EVT_VIRTUAL_NEXT then
		playTone(1200, 120,5) -- play tone
          pt.name = editText(pt.name, 1, editPos)
        elseif event==EVT_VIRTUAL_PREV then
		playTone(1200, 120,5) -- play tone
          pt.name = editText(pt.name, -1, editPos)
        elseif event==EVT_VIRTUAL_ENTER and getTime()-rebound>20 then
		playTone(1200, 120,5) -- play tone
          editing = false
          letterEdit = false
          saveFile()
          rebound = getTime()
        end
      end
    end
  --------------------------------------------------
  -- NAVIGATION
  --------------------------------------------------
  else
    if event==EVT_VIRTUAL_NEXT then
	playTone(1200, 120,5) -- play tone
      if getRotEncSpeed() == ROTENC_LOWSPEED then
		selField = selField +1
		else
		selField = selField +3
	  end
      if selField>3 then selField=1; selLine=math.min(selLine+1,#lines) end
      
    elseif event==EVT_VIRTUAL_PREV then
	playTone(1200, 120,5) -- play tone
      if getRotEncSpeed() == ROTENC_LOWSPEED then
		selField = selField -1
		else
		selField = selField -3
	  end
	  
      if selField<1 then selField=3; selLine=math.max(selLine-1,1) end
      
    elseif event==EVT_VIRTUAL_ENTER and getTime()-rebound>20 then
	playTone(1200, 120,5) -- play tone
      editing = true
      letterSelect = (selField==3)
      letterEdit = false
      editPos = 1
      rebound = getTime()
 
    end
  end
  
  
  lcd.drawNumber(123, 57,"7", 0+INVERS) -- texte numero page
end
