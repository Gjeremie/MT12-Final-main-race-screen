local shared = ...

local fich1 = "/SCRIPTS/TELEMETRY/" .. string.sub(model.getInfo().name,1,1) .. "-log.txt"
local pag = 1 -- numero de session  (de 1 a 180) 90 sessions
local refresh = 1 -- rafraichir lecture session

local	total = 0-- total tps session addition tour
local	nbtour = 0-- total nombre de tour sessions

local locLat = {}
local locLon = {}
local locNom = {}
local fich2 = "/SCRIPTS/TELEMETRY/" .. string.sub(model.getInfo().name,1,1) .. "-gps.txt"
local debut = 0
local locMax = 0  -- nombre d'éléments valides trouvés

local timesess = "0" -- tps de session en seconde
local repet = 0 -- cadence lecture carte sd
local tour = {"0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0"} -- table de tps au tour (table commence a 1) attention tour 0 est stocké dans tour[1]
local top    -- meilleur tour
local topn  = 0  -- numero meilleur tour
local dat = {"0","0","0","0"} -- date

local tab = model.getCurve(4) -- COURBE var 5 (pour stockage variable capa accu)
local memcapa = tab.y -- memcapa[3]  utiliser pour stocker variable caap accu sauvegardé

local capa = 0 -- en mA/h - variable capacité calculé
local tempM = 0 -- en °C - variable temperature MAX calculé
local tempM2 = 0 -- en °C - variable temperature MAX calculé
local voltM = 0 -- en centiv - variable tension lipo MIN calculé 
local voltMalert = 1 -- en centiv - variable tension lipo MIN calculé 
local courantM = 0  -- en A - variable courant max
local volt = 0  -- en centiv - variable tension lipo live
local dist = 0 -- distance sur 3 carac
local lat = 0 -- latitude enregistré sur sd
local lon =  0 -- longitude enregistré sur sd

-- Fonction de nettoyage et conversion de valeurs issues du fichier log
local function cleanvalue(v)
  v = tostring(v)
  v = string.gsub(v, "x", "")
  if v == "" then
    v = "0"
  end
  return tonumber(v)
end


local function lap(num,best,t) -- num: num de tour      best: affiche best si 1      t: tps au tour
local colonne

if (t>0) then -- si tour pas vide
			if num <12 then -- si premier groupe de 12 tour
				if (num<6) then
					colonne = 0
					else
					colonne = 43
				end
				
				lcd.drawNumber(3 + colonne, 1 + 11 * num - 66  * math.floor(0.16* num +0.14), num, 0+INVERS) -- numero lap
				
			else -- si 2eme groupe de 12 tour
				if (num<18) then
					colonne = 0
					else
					colonne = 43
				end
				if num ~=23 then -- ne pas afficher dernier tour pour place tps total
					num = num - 12 -- decaler num pour considerer premier groupe
					lcd.drawNumber(3 + colonne, 1 + 11 * num - 66  * math.floor(0.16* num +0.14), num+12, 0+INVERS) -- numero lap avec affichage corrigé + 12
				end
				
			end
			
			
			
			if num ~= 23 then -- si pas derniere ligne de dernier groupe - pour place tps total
			
				lcd.drawNumber(20 + colonne, 1 + 11 * num - 66  * math.floor(0.16* num +0.14), math.floor(math.fmod(t/100,60)), 0) -- tps tour -- seconde
				lcd.drawNumber(32 + colonne, 1 + 11 * num - 66  * math.floor(0.16* num +0.14), math.fmod(t,100), 0) -- tps tour -- centieme

				if (math.floor(t/100/60)>0) then -- si minute pas vide
				lcd.drawNumber(13 + colonne, 1 + 11 * num - 66  * math.floor(0.16* num +0.14), math.floor(t/100/60), 0) -- tps tour -- minute

				lcd.drawLine(colonne+18, 2 + 11 * num - 66  * math.floor(0.16* num +0.14), colonne+18, 3 + 11 * num - 66  * math.floor(0.16* num +0.14)      , SOLID, FORCE)-- trait entre min et sec
				lcd.drawLine(colonne+18, 5 + 11 * num - 66  * math.floor(0.16* num +0.14), colonne+18, 6 + 11 * num - 66  * math.floor(0.16* num +0.14)      , SOLID, FORCE)-- trait entre min et sec
				end

				lcd.drawLine(colonne+30, 1+ 11 * num - 66  * math.floor(0.16* num +0.14), colonne+30, 3 + 11 * num - 66  * math.floor(0.16* num +0.14)      , SOLID, FORCE)-- trait entre sec et cent
		

				if (best==1) then
				lcd.drawLine(colonne,   11 * num - 66  * math.floor(0.16* num +0.14), colonne, 8+ 11* num - 66  * math.floor(0.16* num +0.14)      , SOLID, ERASE)-- trait best lap
				lcd.drawLine(colonne+1,   11 * num - 66  * math.floor(0.16* num +0.14), colonne+1, 8+ 11* num - 66  * math.floor(0.16* num +0.14)      , SOLID, ERASE)-- trait best lap
				end
				
				if ((num>0 and num<6) or (num>6 and num<12)) then
				lcd.drawLine(colonne,   -2+11 * num - 66  * math.floor(0.16* num +0.14), colonne, -1+ 11* num - 66  * math.floor(0.16* num +0.14)      , SOLID, FORCE)-- trait completer
				lcd.drawLine(colonne+1,  -2+ 11 * num - 66  * math.floor(0.16* num +0.14), colonne+1, -1+ 11* num - 66  * math.floor(0.16* num +0.14)      , SOLID, FORCE)-- trait completer
				end
			end
	end

end



function shared.run(event)
  lcd.clear()

  
  
  
  -- recupere valeur GPS et nom circuit
  
if debut == 0 then  
	local f = io.open(fich2, "r")


	  local index = 1
	  local buffer = ""
	  local pos = 0

	  while true do
		io.seek(f, pos)
		local data = io.read(f, 50) -- lecture par bloc de 50
		if not data or #data == 0 then break end
		buffer = buffer .. data
		pos = pos + #data

		-- Lire ligne par ligne
		while true do
		  local line_end = string.find(buffer, "\n")
		  if not line_end then break end
		  local line = string.sub(buffer, 1, line_end - 1)
		  buffer = string.sub(buffer, line_end + 1)

		  -- Nettoyage
		  line = string.gsub(line, "[\r\n]+", "")
		  if #line > 0 then
			-- Extraire lat lon nom (espaces multiples tolérés)
			local lat, lon, nom = string.match(line, "([%d%.-]+)%s+([%d%.-]+)%s+(.+)")
			if lat and lon and nom then
			  locMax = locMax + 1
				locLat[locMax] = tonumber(lat)
				locLon[locMax] = tonumber(lon)
				locNom[locMax] = nom
			end
		  end
		end
	  end

	  io.close(f)
debut = 1
end


  
  
  
  
  
  
  
  
  
  

  
---- touche bascule entre ecran -----------------
 if event == EVT_VIRTUAL_NEXT_PAGE then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(4)
  end
   if event == EVT_VIRTUAL_PREV_PAGE then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(2)
  end
  
 if event == EVT_VIRTUAL_MENU_LONG then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(5)
  end


---- DEBUT fond ------------

lcd.drawLine(0,0,0,63, SOLID, FORCE)
lcd.drawLine(1,0,1,63, SOLID, FORCE)
lcd.drawLine(43,0,43,63, SOLID, FORCE)
lcd.drawLine(44,0,44,63, SOLID, FORCE)



lcd.drawFilledRectangle(87, 0, 10, 20, FORCE)

lcd.drawLine(113,13,114,13, SOLID, FORCE)
lcd.drawLine(98,19,127,19, SOLID, FORCE)
lcd.drawLine(86,0,86,63, SOLID, FORCE)
lcd.drawLine(97,0,97,63, SOLID, FORCE)
lcd.drawLine(112,10,112,16, SOLID, FORCE)
lcd.drawLine(115,10,115,16, SOLID, FORCE)

lcd.drawPoint(89,1)
lcd.drawPoint(93,1)
lcd.drawLine(87,2,88,2, SOLID, ERASE)
lcd.drawLine(90,2,92,2, SOLID, ERASE)
lcd.drawLine(94,2,95,2, SOLID, ERASE)
lcd.drawLine(87,8,95,8, SOLID, ERASE)
lcd.drawLine(87,3,87,7, SOLID, ERASE)
lcd.drawLine(95,3,95,7, SOLID, ERASE)

lcd.drawFilledRectangle(87,20,10,44,FORCE)



lcd.drawLine(89,53,90,53, SOLID, ERASE)
lcd.drawPoint(90,55)
lcd.drawPoint(90,57)
lcd.drawLine(92,59,92,60, SOLID, ERASE)
lcd.drawPoint(88,61)
lcd.drawPoint(91,61)
lcd.drawLine(89,62,90,62, SOLID, ERASE)
lcd.drawLine(87,59,87,60, SOLID, ERASE)
lcd.drawLine(88,54,88,58, SOLID, ERASE)
lcd.drawLine(91,54,91,58, SOLID, ERASE)

lcd.drawPoint(93,54)
lcd.drawLine(94,53,94,57, SOLID, ERASE)
lcd.drawLine(95,53,95,57, SOLID, ERASE)
lcd.drawPoint(96,54)

lcd.drawLine(117,54,119,54, SOLID, FORCE)
lcd.drawPoint(117,55)
lcd.drawPoint(119,55)
lcd.drawLine(117,56,119,56, SOLID, FORCE)




---- FIN fond ------------




---- touche ROTARY -----------------
if event == EVT_VIRTUAL_NEXT then -- bouton rotary 
    if getRotEncSpeed() == ROTENC_HIGHSPEED then -- rapide
		pag = pag+4
				
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then -- moyen
		pag = pag+2
				
		else -- lent
				
		pag = pag+1
	end
	
	if (pag >180) then
	pag =180
	else
	playTone(1200, 50,5) -- play tone
	refresh = 1
	end
  end

if event == EVT_VIRTUAL_PREV then -- bouton rotary 
    if getRotEncSpeed() == ROTENC_HIGHSPEED then -- rapide
		pag = pag-4
				
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then -- moyen
		pag = pag-2
				
		else -- lent
				
		pag = pag-1
	end
	
	if (pag <1) then
	pag =1
	else
	playTone(1200, 50,5) -- play tone
	refresh = 1
	end
  end
  
if event == EVT_VIRTUAL_ENTER then -- bouton rotary 
    
	if pag ==1 then
	else
	 playTone(1200, 120,5) -- play tone
	 refresh = 1
	end
	pag = 1
  end

 lcd.drawNumber(87, 10, math.floor(pag/2+0.5), 0+INVERS) -- afficher numero de session

 

 ---- ================ recup SD toute les ...  ===============
 if (getTime()> (50+ repet) ) or refresh == 1 then -- A FAIRE TOUTE LES :    50 x 10ms = 0.5s
 

local file = io.open(fich1, "r") -- ouvrir fichier 0-log.txt en acces lecture


 -- recup date -----------
 	
	local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1)) --  positionner curseur dans fichier log - lecture date
	 dat[1] = io.read (file, 2) -- lire 2 carac de  dans fichier log et asssigner a table date

	 local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +2) --  positionner curseur dans fichier log - lecture date
	 dat[2] = io.read (file, 2) -- lire 2 carac de  dans fichier log et asssigner a table date
	 
	 local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +4) --  positionner curseur dans fichier log - lecture date
	 dat[3] = io.read (file, 2) -- lire 2 carac de  dans fichier log et asssigner a table date
	 
	 local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +6) --  positionner curseur dans fichier log - lecture date
	 dat[4] = io.read (file, 2) -- lire 2 carac de  dans fichier log et asssigner a table date


 -- recup tps de session de log sd -----------
	local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +8) --  positionner curseur dans fichier log - lecture tps session
	 timesess = io.read (file, 4) -- lire 4 carac   dans fichier log et asssigner a timesess
	 
	 
 -- recup les tps au tour  -----------
 
	for i = 0,23 do
		
		local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +32 + i*6) --  positionner curseur dans fichier log - lecture tour
		 tour[i+1] = io.read (file, 6) -- lire 6 carac de  dans fichier log et asssigner a table tour
		 
			 
			 tour[i+1] = tostring(tour[i+1])  -- convertir en string
		tour[i+1] = string.gsub(tour[i+1],"x","")  -- enlever les xx et convertir en nombre

		if (tour[i+1]=="") then -- variable vide
			tour[i+1] = "0"  -- mettre variable a zero
		end

		tour[i+1] = tonumber(tour[i+1]) -- convertir en nombre
		
	end


 -- recup tension mini lipo -----------
	local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +12) --  positionner curseur dans fichier log 
	 voltM = io.read (file, 3) -- lire 3 carac   dans fichier log et asssigner
	 
	  -- recup alerte tension mini a eu lieu -----------
	local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +184) --  positionner curseur dans fichier log 
	 voltMalert = io.read (file, 1) -- lire 1 carac   dans fichier log et asssigner
	 
 -- recup temperature max -----------
	local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +18) --  positionner curseur dans fichier log 
	 tempM = io.read (file, 3) -- lire 3 carac   dans fichier log et asssigner	 
	
		 -- recup temperature max -----------
	local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +179) --  positionner curseur dans fichier log 
	 tempM2 = io.read (file, 3) -- lire 3 carac   dans fichier log et asssigner
	
 -- recup capacité conso -----------
	local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +15) --  positionner curseur dans fichier log 
	 capa = io.read (file, 3) -- lire 3 carac   dans fichier log et asssigner		

 -- recup courant max -----------
	local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +24) --  positionner curseur dans fichier log 
	 courantM = io.read (file, 3) -- lire 3 carac   dans fichier log et asssigner	 
	 
	  -- recup volt live fin de pack -----------
	local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +21) --  positionner curseur dans fichier log 
	 volt = io.read (file, 3) -- lire 3 carac   dans fichier log et asssigner	 

 -- recup distance -----------
	local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +27) --  positionner curseur dans fichier log 
	 dist = io.read (file, 3) -- lire 3 carac   dans fichier log et asssigner	

 -- recup latitude  -----------
	local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +185) --  positionner curseur dans fichier log 
	 lat = io.read (file, 6) -- lire 6 carac   dans fichier log et asssigner	

 -- recup longitude  -----------
	local curs = io.seek(file, 1 +200 * (math.floor(pag/2+0.5) -1) +191) --  positionner curseur dans fichier log 
	 lon = io.read (file, 6) -- lire 6 carac   dans fichier log et asssigner

io.close(file) -- fermer fichier log
	

	-- ==================FORMATAGE DATA==========================
	
-- tps session  ---------


timesess = cleanvalue(timesess) -- clean value
	
		
		
-- date session -----------
for i = 1,4 do  -- balayer les date et formater
	dat[i] = tostring(dat[i])  -- convertir en string
		
	dat[i] = string.gsub(dat[i],"x","")  -- enlever les xx 
		
	if (dat[i]=="") then -- variable non assigné
		dat[i] = "0"  -- mettre variable a zero
	end
end	
	
	
	
-- tension mini lipo  ---------

voltM = cleanvalue(voltM) -- cleanvalue
voltMalert = cleanvalue(voltMalert) -- cleanvalue

	
-- courant max  ---------

courantM = cleanvalue(courantM) -- convertir en nombre

-- tension live lipo  ---------

volt = cleanvalue(volt) -- cleanvalue

-- temperature max  ---------

tempM = cleanvalue(tempM) -- cleanvalue

-- temperature max  ---------

tempM2 = cleanvalue(tempM2) -- cleanvalue

-- capacité conso  ---------

capa = cleanvalue(capa) -- cleanvalue

-- distance  ---------

dist = cleanvalue(dist) -- cleanvalue

-- GPS  ---------	
	lat = cleanvalue(lat) -- cleanvalue
	lon = cleanvalue(lon) -- cleanvalue
		
		
	-- =================================================
repet =  getTime() -- init  tps
refresh = 0 -- init refresh
end



------- Affiche ---------- heure session

lcd.drawText(100, 10, dat[3] , 0) 
lcd.drawText(119, 10, dat[4] , 0) 
 
 


--------- Affiche ----------   lap ---------

top = 60000 -- assigner  meilleur tour a bcp
total = 0 -- reset
nbtour = 0 -- reset

for i = 0,23 do  -- balayer les 24 tours recherche meilleur

if (tour[i+1]>0) then

	total = tour[i+1] + total
	nbtour = i+1

	if (tour[i+1]<top) then
	
	top = tour[i+1]
	topn = i

	end
end

 end



 
  
 
 if math.fmod(pag,2) == 1 then -- affiche premiere page de la session ----------------------------------
 
  lcd.drawPoint(89,4)
  lcd.drawPoint(91,4)
  lcd.drawPoint(93,4)
 
lcd.drawLine(111,6,115,2, SOLID, FORCE) -- slash date
 
 lcd.drawLine(90,20,92,20, SOLID, ERASE)
lcd.drawPoint(89,21)
lcd.drawPoint(93,21)
lcd.drawLine(90,24,91,24, SOLID, ERASE)
lcd.drawPoint(89,27)
lcd.drawPoint(93,27)
lcd.drawLine(90,28,92,28, SOLID, ERASE)
lcd.drawPoint(93,31)
lcd.drawPoint(90,39)
lcd.drawLine(91,50,92,50, SOLID, ERASE)
lcd.drawLine(87,23,87,25, SOLID, ERASE)
lcd.drawLine(88,21,88,22, SOLID, ERASE)
lcd.drawLine(88,26,88,27, SOLID, ERASE)
lcd.drawLine(89,43,89,50, SOLID, ERASE)
lcd.drawLine(90,34,90,35, SOLID, ERASE)
lcd.drawLine(90,42,90,45, SOLID, ERASE)
lcd.drawLine(90,49,90,50, SOLID, ERASE)
lcd.drawLine(91,22,91,23, SOLID, ERASE)
lcd.drawLine(91,33,91,35, SOLID, ERASE)
lcd.drawLine(91,37,91,38, SOLID, ERASE)
lcd.drawLine(91,42,91,44, SOLID, ERASE)
lcd.drawLine(91,46,91,48, SOLID, ERASE)
lcd.drawLine(92,32,92,33, SOLID, ERASE)
lcd.drawLine(92,35,92,37, SOLID, ERASE)
lcd.drawLine(92,42,92,44, SOLID, ERASE)
lcd.drawLine(92,46,92,48, SOLID, ERASE)
lcd.drawLine(93,35,93,36, SOLID, ERASE)
lcd.drawLine(93,43,93,50, SOLID, ERASE)
lcd.drawLine(94,21,94,22, SOLID, ERASE)
lcd.drawLine(94,26,94,27, SOLID, ERASE)
lcd.drawLine(95,23,95,25, SOLID, ERASE)
lcd.drawPoint(120,38)
lcd.drawPoint(122,38)
lcd.drawPoint(121,39)
lcd.drawLine(120,44,121,44, SOLID, FORCE)
lcd.drawLine(120,47,121,47, SOLID, FORCE)
lcd.drawLine(125,47,126,47, SOLID, FORCE)
lcd.drawLine(111,23,111,24, SOLID, FORCE)
lcd.drawLine(111,26,111,27, SOLID, FORCE)
lcd.drawLine(119,33,119,37, SOLID, FORCE)
lcd.drawLine(119,45,119,50, SOLID, FORCE)
lcd.drawLine(122,45,122,50, SOLID, FORCE)
lcd.drawLine(123,33,123,37, SOLID, FORCE)
lcd.drawLine(124,44,124,50, SOLID, FORCE)
lcd.drawLine(127,44,127,50, SOLID, FORCE)




-- M:
lcd.drawLine(94,59,94,63, SOLID, ERASE)
lcd.drawPoint(95,60)
lcd.drawLine(96,59,96,63, SOLID, ERASE)


------- Affiche ---------- date session

lcd.drawText(100, 1, dat[1] , 0) 
lcd.drawText(118, 1, dat[2] , 0) 

 
------ affiche lap ---
 for i = 0,11 do  -- balayer les 12 premier tours

if ( i == topn ) then
top = 1
else
top = 0
end

  lap(i,top,tour[i+1])

 end
  
 
--------- Affiche ---------- tps session
lcd.drawNumber(100, 22, math.floor(timesess/60) , 0 ) -- minute tps ecoulé timer 1
lcd.drawNumber(114, 22, math.floor(math.fmod(timesess,60)) , 0 ) -- seconde tps ecoulé timer 1
 

    --------- Affiche ---------- tension live fin pack lipo 
 
 if volt < math.floor(model.getLogicalSwitch(58).v2/10) then
 
 lcd.drawNumber(100, 33, volt , 0+PREC2+BLINK ) -- tension  lipo format 3.75 V

else
 lcd.drawNumber(100, 33, volt , 0+PREC2 ) -- tension  lipo format 3.75 V
end


--------- Affiche ----------  temperature max
if  tempM > model.getLogicalSwitch(59).v2 then
lcd.drawNumber(100, 55, tempM , 0+BLINK ) -- temperature max
else
lcd.drawNumber(100, 55, tempM , 0 ) -- temperature max
end


--------- Affiche ----------  capacité conso
if capa > memcapa[3]*8 then -- si sup a 80% capa
lcd.drawNumber(100, 44, capa , 0+PREC2+BLINK ) -- capapacité consommé format 4.20  (= 4.20Ah)
else
lcd.drawNumber(100, 44, capa , 0+PREC2 ) -- capapacité consommé format 4.20  (= 4.20Ah)
end
 
 
 
else -- affiche 2eme page de la session ---------------------------------------
 
  lcd.drawPoint(89,6)
  lcd.drawPoint(91,6)
  lcd.drawPoint(93,6)
 
lcd.drawLine(89,21,90,21, SOLID, ERASE)
lcd.drawPoint(91,22)
lcd.drawPoint(93,24)
lcd.drawPoint(96,24)
lcd.drawPoint(91,27)
lcd.drawLine(89,28,90,28, SOLID, ERASE)
lcd.drawPoint(90,31)
lcd.drawPoint(93,37)
lcd.drawPoint(96,37)
lcd.drawPoint(87,39)
lcd.drawLine(87,23,87,26, SOLID, ERASE)
lcd.drawLine(87,34,87,35, SOLID, ERASE)
lcd.drawLine(88,22,88,27, SOLID, ERASE)
lcd.drawLine(88,33,88,35, SOLID, ERASE)
lcd.drawLine(88,37,88,38, SOLID, ERASE)
lcd.drawLine(89,32,89,33, SOLID, ERASE)
lcd.drawLine(89,35,89,37, SOLID, ERASE)
lcd.drawLine(90,35,90,36, SOLID, ERASE)
lcd.drawLine(94,23,94,27, SOLID, ERASE)
lcd.drawLine(94,34,94,38, SOLID, ERASE)
lcd.drawLine(95,23,95,27, SOLID, ERASE)
lcd.drawLine(95,34,95,38, SOLID, ERASE)


lcd.drawLine(120,22,121,22, SOLID, FORCE)
lcd.drawLine(120,25,121,25, SOLID, FORCE)
lcd.drawPoint(120,38)
lcd.drawPoint(122,38)
lcd.drawPoint(121,39)
lcd.drawLine(119,23,119,28, SOLID, FORCE)
lcd.drawLine(119,33,119,37, SOLID, FORCE)
lcd.drawLine(122,23,122,28, SOLID, FORCE)
lcd.drawLine(123,33,123,37, SOLID, FORCE)


lcd.drawPoint(6+87,4+41)
lcd.drawLine(3+87,9+41,4+87,9+41, SOLID, ERASE)
lcd.drawLine(0+87,6+41,0+87,7+41, SOLID, ERASE)
lcd.drawLine(1+87,5+41,1+87,9+41, SOLID, ERASE)
lcd.drawLine(2+87,6+41,2+87,7+41, SOLID, ERASE)
lcd.drawLine(5+87,5+41,5+87,8+41, SOLID, ERASE)
lcd.drawLine(7+87,1+41,7+87,2+41, SOLID, ERASE)
lcd.drawLine(8+87,0+41,8+87,4+41, SOLID, ERASE)
lcd.drawLine(9+87,1+41,9+87,2+41, SOLID, ERASE)

 



-- E:
lcd.drawLine(94,59,94,63, SOLID, ERASE)
lcd.drawPoint(95,61)
lcd.drawLine(95,59,96,59, SOLID, ERASE)
lcd.drawLine(95,63,96,63, SOLID, ERASE)
 
 
 
 ------- Affiche ---------- nom circuit session

debut = 2

for i = 1,locMax do


	if lat+4500000 > math.floor( locLat[i]*100000)-450 and lat+4500000 < math.floor( locLat[i]*100000)+450 and lon+500000 > math.floor( locLon[i]*100000)-450 and lon+500000 < math.floor( locLon[i]*100000)+450  then -- si reconnait position a moins de 500m de listing position
	-- affiche position
	lcd.drawText(99, 1, locNom[i] , SMLSIZE) 
	debut  = 1
		break -- sortir boucle quand on a trouvé ligne
	
	 end 
 end
 
 if debut == 2 then -- pas trouvé nom circuit pour session alors affiche date
 lcd.drawText(100, 1, dat[1] , 0) 
lcd.drawText(118, 1, dat[2] , 0) 
lcd.drawLine(111,6,115,2, SOLID, FORCE) -- slash date
 end
 
 ------ affiche lap ---
 for i = 12,23 do  -- balayer les 12 dernier tours

if ( i == topn ) then
top = 1
else
top = 0
end

  lap(i,top,tour[i+1])

 end
  
 ------ affiche total lap et tps ---
 
  lcd.drawText(44, 57, nbtour .. 'L ', SMLSIZE+INVERS) -- affichage en de tour et tps en minute / seconde 
  lcd.drawText(lcd.getLastRightPos(), 57,math.floor(total/100/60) .. ':' .. math.floor(math.fmod(total/100,60)), SMLSIZE+INVERS)
  
  lcd.drawRectangle(43,53,2,3, ERASE) -- separation
  

  --------- Affiche ---------- courant max
  lcd.drawNumber(100, 22, courantM , 0 ) -- courant max
  
 
  --------- Affiche ---------- tension mini lipo 

if voltMalert > 0 then -- alert
lcd.drawNumber(100, 33, voltM , 0+PREC2+BLINK ) -- tension mini lipo format 3.73 V
else
lcd.drawNumber(100, 33, voltM , 0+PREC2 ) -- tension mini lipo format 3.73 V
end
 
   --------- Affiche ---------- distance 
lcd.drawNumber(100, 44, dist , 0+PREC2 ) -- distance en dizaine de m
  lcd.drawText(118, 44, "km" , 0) -- distance
  
    --------- Affiche ----------  temperature max
	if  tempM2 > model.getLogicalSwitch(39).v2 then
lcd.drawNumber(100, 55, tempM2 , 0+BLINK ) -- temperature max
  else
  lcd.drawNumber(100, 55, tempM2 , 0 ) -- temperature max
  end
  
  
 end
  
-- page:
lcd.drawNumber(123, 56,"2", 0+INVERS) -- texte numero page


--popup new session
if (shared.pop  == 1 ) then -- si reset session
	lcd.drawFilledRectangle(15, 20, 98, 23, ERASE)
	lcd.drawRectangle(17, 22, 94, 19, FORCE)
	lcd.drawText(21, 28, "Nouvelle Session" , 0)
end



end