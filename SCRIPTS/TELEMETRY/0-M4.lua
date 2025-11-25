local shared = ...

local valeur = 0 -- valeur en cour de modif

local fich2 = "/SCRIPTS/TELEMETRY/" .. string.sub(model.getInfo().name,1,1) .. "-timr.txt"
local sess -- dernier preset ouvert
local modif = 0 --   =0 si pas mode modif et =valeur de rot si modif de cet item 
local rebound = 0 -- anti rebond Enter key
local rot = 26 -- numero item a modifier (commande par rotary)
local text =  {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", " " } -- derniere index= 37
local mem = {37,37,37,37,37,37,37,37,37,37,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} -- stockage mem  circuit + sauvegarde valeur + pos GPS lat et lon Origine et secteur 1
--  mem[16] disponible car vide
local debut = 0
local dent

dent = model.getLogicalSwitch(7).v2 -- nb de dent pignon moteur stocké dans LS08

local lat = 0 -- latitude
local lon = 0 -- longitude

local SD = 0 --valeur switch SD

local gpsData  -- donnee GPS
local gpsDataON  -- true si telem transmise 


local function affgps(n)

  local sign = ""
  if n < 0 then
    sign = "-"       -- on retient le signe
    n = -n           -- on travaille avec la valeur absolue
  end

  local s = tostring(n)
  -- Ajoute des zéros à gauche pour avoir au moins 8 caractères
  s = string.rep("0", 8 - #s) .. s

  local g1 = string.sub(s, -1)             -- dernier chiffre
  local g2 = string.sub(s, -4, -2)         -- 3 chiffres avant le dernier
  local g3 = string.sub(s, -7, -5)         -- 3 chiffres avant ceux-ci
  local reste = string.sub(s, 1, #s - 7)   -- ce qu'il reste au début

  local result = sign .. reste .. "." .. g3 .. " " .. g2 .. " " .. g1 .. " °"
  return result
end
  
  
  
 local function case(x,y,coche) -- coche : 0= rien 1=cocher 2=rien noir 3=coche noir

lcd.drawRectangle(x, y, 8, 8, SOLID)

if coche == 1 then
lcd.drawLine(x+1,y+1,x+6,y+6, SOLID, FORCE)
lcd.drawLine(x+1,y+6,x+6,y+1, SOLID, FORCE)
elseif coche == 2 then
lcd.drawFilledRectangle(x+1, y+1, 6, 6, FORCE)
elseif coche == 3 then
lcd.drawFilledRectangle(x+1, y+1, 6, 6, FORCE)
lcd.drawLine(x+1,y+1,x+6,y+6, SOLID, ERASE)
lcd.drawLine(x+1,y+6,x+6,y+1, SOLID, ERASE)
end
end
  
  
local function rond(x,y,coche) -- coche : 0= rien 1=cocher 

lcd.drawLine(2+x,0+y,3+x,0+y, SOLID, FORCE)
lcd.drawPoint(1+x,1+y)
lcd.drawPoint(4+x,1+y)
lcd.drawPoint(1+x,4+y)
lcd.drawPoint(4+x,4+y)
lcd.drawLine(2+x,5+y,3+x,5+y, SOLID, FORCE)
lcd.drawLine(0+x,2+y,0+x,3+y, SOLID, FORCE)
lcd.drawLine(5+x,2+y,5+x,3+y, SOLID, FORCE)

if coche == 1 then
lcd.drawFilledRectangle(x+1, y+1, 4, 4, SOLID)
end

end
  
function choose(val,mi,ma,int) -- fonction bouton rotary next ou prev avec intervalle de changement et min et max 
	val = val+int 
	if int>0  then
	
		if val>ma then
		val=ma
		else
		playTone(1200, 50,5) -- play tone
		end
	
	else
		if val<mi then
		val=mi
		else
		playTone(1200, 50,5) -- play tone
		end
	end
		
return val
end  
  
  
local function data(x) -- sauvegarde mise en forme 2 carac

		x = tostring(x)  -- convertir en string  
		
		if (#x==1) then -- nombre a 1 chiffre
			x = "x" .. x  -- completer pour 2 carac 
			
			elseif (#x>2) then -- si = 2 ou plus
			x = "11"   -- completer pour 2 carac
			
		end
		
		return x
end


local function data10(x)   -- sauvegarde mise en forme 10 carac
    x = tostring(x)  -- convertir en string
    
    if #x < 10 then
        -- Ajouter des "x" devant pour compléter jusqu'à 10 caractères
        x = string.rep("x", 10 - #x) .. x
    elseif #x > 10 then
        -- Si la chaîne est trop longue, la tronquer à 10 caractères
        x = string.sub(x, 1, 10)
    end

    return x
end



local function lire(x) -- lire de carte sd
x = tostring(x)  -- convertir en strings
x = string.gsub(x,"x","")  -- enlever les xx 
if (x=="") then -- variable non assigné
	x = "1"  -- mettre variable a a
end
x = tonumber(x) -- convertir en nombre

return x
end  
  
  
  
local function sdmem(x,y) -- sd vers mem puis ver LS et vers shared     -- x= fich2     y= sess

	local file = io.open(x, "r") -- ouvrir fichier 0-timr.txt en acces lecture
		
	---- lire sd et copie dans mem[..] ------
		for i = 1,19 do 
			local curs = io.seek(file, 10+2*i+90*(y-1) ) --  positionner curseur dans fichier  
			mem[i] = io.read (file, 2) -- lire 2 carac   dans fichier  et asssigner
			mem[i] = lire(mem[i]) -- convertir lecture
		end
		
		local curs = io.seek(file, 10+40+90*(y-1) ) --  positionner curseur dans fichier  pour lire latO
			mem[20] = io.read (file, 10) -- lire 10 carac   dans fichier  et asssigner
			mem[20] = lire(mem[20]) -- convertir lecture
			
			local curs = io.seek(file, 10+50+90*(y-1) ) --  positionner curseur dans fichier  pour lire lonO
			mem[21] = io.read (file, 10) -- lire 10 carac   dans fichier  et asssigner
			mem[21] = lire(mem[21]) -- convertir lecture
			
				local curs = io.seek(file, 10+60+90*(y-1) ) --  positionner curseur dans fichier  pour lire latO
			mem[22] = io.read (file, 10) -- lire 10 carac   dans fichier  et asssigner
			mem[22] = lire(mem[22]) -- convertir lecture
			
			local curs = io.seek(file, 10+70+90*(y-1) ) --  positionner curseur dans fichier  pour lire lonO
			mem[23] = io.read (file, 10) -- lire 10 carac   dans fichier  et asssigner
			mem[23] = lire(mem[23]) -- convertir lecture
			
	io.close(file) -- fermer fichier
	
	
	---- copie mem[..] vers LS ------
	
			
		local tab = model.getLogicalSwitch(11)
		tab.v2 = mem[15]*25
			model.setLogicalSwitch(11, tab) -- assigner valeur de LS
			
			tab = model.getLogicalSwitch(37)
		tab.v2 = mem[14]*25
			model.setLogicalSwitch(37, tab) -- assigner valeur de LS
			
		tab = model.getLogicalSwitch(12)
		tab.v2 = mem[17]
		shared.ls13 = mem[17] -- reassigner valeur lap mini
			model.setLogicalSwitch(12, tab) -- assigner valeur de LS
			
		tab = model.getLogicalSwitch(34)
			tab.delay = mem[19]
			tab.v2 = mem[18]*1000/2
			model.setLogicalSwitch(34, tab) -- assigner valeur de LS
			

			
		tab = model.getLogicalSwitch(32)
		tab.v2 = mem[11]
		tab.delay = mem[12]
			model.setLogicalSwitch(32, tab) -- assigner valeur de LS	
			
	
			
			tab = model.getLogicalSwitch(33)
		tab.delay = mem[13]
			model.setLogicalSwitch(33, tab) -- assigner valeur de LS
			
				tab = model.getLogicalSwitch(35)
		tab.delay = mem[13]
			model.setLogicalSwitch(35, tab) -- assigner valeur de LS
			
		shared.latO = mem[20] -- reassigner valeur latO
		shared.lonO = mem[21] -- reassigner valeur lonO
		
		shared.lat1 = mem[22] -- reassigner valeur lat1
		shared.lon1 = mem[23] -- reassigner valeur lon1

end  
  
  
  
  
  
  
  
function shared.run(event)
  lcd.clear()



if debut == 0 then
	local file = io.open(fich2, "r") -- ouvrir fichier 0-timr.txt en acces lecture
	
	---- lire sd et copie dans sess ------
	local curs = io.seek(file, 1 ) --  positionner curseur dans fichier  
			sess = io.read (file, 2) -- lire 2 carac   dans fichier  et asssigner
	sess = lire(sess) -- conversion
			
	io.close(file) -- fermer fichier
	
	sdmem(fich2,sess) -- lire sd et copie vers mem et LS
			
	
	
debut = 1
end


---- touche bascule entre ecran -----------------
 if event == EVT_VIRTUAL_NEXT_PAGE  and modif == 0 then -- bouton menu 
 playTone(1200, 120,5) -- play tone
 			-- reactiver switch SD pour Lap
		if model.getInput(13, 0).weight == 1024  then-- lire ligne 1 de input 14         DEBUG =si  weight 0 BUG edgetx
			local tab = model.getInput(13, 1) -- copier ligne 2 input 14
			model.deleteInput(13, 0) -- suppr ligne 1
			tab.weight = 100 --      weight 100
			model.insertInput(13, 0,tab) -- inserer en ligne 1
		end
    shared.changeScreen(7)
  end
   if event == EVT_VIRTUAL_PREV_PAGE  and modif == 0 then -- bouton menu 
 playTone(1200, 120,5) -- play tone
 			-- reactiver switch SD pour Lap
		if model.getInput(13, 0).weight == 1024  then-- lire ligne 1 de input 14         DEBUG =si  weight 0 BUG edgetx
			local tab = model.getInput(13, 1) -- copier ligne 2 input 14
			model.deleteInput(13, 0) -- suppr ligne 1
			tab.weight = 100 --      weight 100
			model.insertInput(13, 0,tab) -- inserer en ligne 1
		end
    shared.changeScreen(10)
  end
  
 if event == EVT_VIRTUAL_MENU_LONG  and modif == 0 then -- bouton menu 
 playTone(1200, 120,5) -- play tone
 			-- reactiver switch SD pour Lap
		if model.getInput(13, 0).weight == 1024  then-- lire ligne 1 de input 14         DEBUG =si  weight 0 BUG edgetx
			local tab = model.getInput(13, 1) -- copier ligne 2 input 14
			model.deleteInput(13, 0) -- suppr ligne 1
			tab.weight = 100 --      weight 100
			model.insertInput(13, 0,tab) -- inserer en ligne 1
		end
    shared.changeScreen(1)
  end
    
lcd.drawText(1, 1, "LAP TIMER                                " , 0+INVERS) -- TITRE
  

  

--- code -----
if (modif == 0) then -- si mode choix item ====================
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
    rot = rot+1 -- allez item suivant
	playTone(1200, 50,5) -- play tone
		if (rot >30) then -- max item
		rot =1
		end
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary  prev
    rot = rot-1
	playTone(1200, 50,5) -- play tone
		if (rot <1) then
		rot =30     --   max item
		end
	end
	if ( event == EVT_VIRTUAL_ENTER and (getTime() - rebound) > 20 ) then -- bouton rotary ENTER anti rebond
	playTone(1200, 120,5) -- play tone
		rebound = getTime()
	
	 modif = rot -- assigner num item a modif
	   
	end
else -- si mode modif ====================

	if ( event == EVT_VIRTUAL_ENTER and (getTime() - rebound) > 20 ) or ( SD > 0 and modif == 19 ) or ( SD > 0 and modif == 22 ) then -- bouton rotary ENTER anti rebond
	-- ou switch SD et mode modif sur definir pos GPS
	playTone(1200, 120,5) -- play tone
	

	
	
	
	---- sauver num preset sur sd ----
	 local file = io.open(fich2, "a") -- ouvrir fichier 0-mem.txt en acces ecriture et en preservant son contenu
		    			
			 local curs = io.seek(file, 1) --  positionner curseur dans fichier 
			 local ecri = io.write (file, data(sess)) --  ecri 2 carac  dans fichier 
	
	---- sauver mem[..]  sur sd ----
	for i = 1,19 do
			 local curs = io.seek(file, 10+2*i+90*(sess-1)) --  positionner curseur dans fichier 
			 local ecri = io.write (file, data(mem[i])) --  ecri 2 carac  dans fichier 
			end
		
		local curs = io.seek(file, 10+40+90*(sess-1) ) --  positionner curseur dans fichier  pour lire latO
			local ecri = io.write (file, data10(mem[20])) --  ecri 10 carac  dans fichier 
			
			
			local curs = io.seek(file, 10+50+90*(sess-1) ) --  positionner curseur dans fichier  pour lire lonO
			local ecri = io.write (file, data10(mem[21])) --  ecri 10 carac  dans fichier 
		
			local curs = io.seek(file, 10+60+90*(sess-1) ) --  positionner curseur dans fichier  pour lire latO
			local ecri = io.write (file, data10(mem[22])) --  ecri 10 carac  dans fichier 
			
			
			local curs = io.seek(file, 10+70+90*(sess-1) ) --  positionner curseur dans fichier  pour lire lonO
			local ecri = io.write (file, data10(mem[23])) --  ecri 10 carac  dans fichier 
		
	 io.close(file) -- fermer fichier   
	
	
	rebound = getTime()

	modif = 0 -- revenir a mode choix item
	end	
end




 
 -- =============  calcul gps live =========
 
 	gpsData, gpsDataON = getSourceValue('GPS') 
			
if 	gpsData == nil or gpsData == ""  or gpsDataON == false then	-- verif si valeur gps
	lat = 0
	lon = 0
	
	else
				
	-- Conversion en int avant addition (très important)
	lat = math.floor(gpsData.lat * 10000000 )
	lon = math.floor(gpsData.lon * 10000000 ) -- en degré * 10e7    exemple: 458956321 correspond a 45.8956321 degré
	
end






if (rot <19) then --========================    PAGE 1    ======================

  --========================= affiche texte fond =================================

lcd.drawText(1, 11, "Preset:" , SMLSIZE+INVERS) -- texte fond noir
lcd.drawText(54, 11, "-" , SMLSIZE) -- texte
lcd.drawLine(0,18,127,18, SOLID, FORCE)

if getValue('ls34') < 0 then -- affiche rond si detection ok
	rond(4,21,1) -- affiche rond
	else
	rond(4,21,0) -- affiche rond vide
end

lcd.drawText(13, 21, "Th:" , SMLSIZE+INVERS) -- texte fond noir  
lcd.drawText(28, 21, ">" , SMLSIZE) -- texte    
lcd.drawText(74, 21, "durant" , SMLSIZE) -- texte   


lcd.drawLine(0,28,4,28, SOLID, FORCE)
lcd.drawLine(2,26,2,27, SOLID, FORCE)
lcd.drawLine(2,29,2,30, SOLID, FORCE)

if getValue('ls36') < 0 then -- affiche rond si detection ok
	rond(4,30,1) -- affiche rond
	else
	rond(4,30,0) -- affiche rond vide
end

lcd.drawText(13, 30, "Rpm:" , SMLSIZE+INVERS) -- texte fond noir  
lcd.drawText(35, 30, ">" , SMLSIZE) -- texte    
lcd.drawText(74, 30, "durant" , SMLSIZE) -- texte   




lcd.drawText(5, 39, "Puis dans delai de:" , SMLSIZE) -- texte  


if getValue('ls12') > 0 then -- affiche rond si detection ok
	rond(4,48,1) -- affiche rond
	else
	rond(4,48,0) -- affiche rond vide
end

lcd.drawText(13, 48, "Distance GPS:" , SMLSIZE+INVERS) -- texte fond noir  
lcd.drawText(75, 48, "<" , SMLSIZE) -- texte    


lcd.drawText(55, 57, "Lap mini:" , SMLSIZE+INVERS) -- texte fond noir
 
 
if getValue('ls13') > 0 then -- affiche rond si detection ok
	rond(0,57,1) -- affiche rond
	else
	rond(0,57,0) -- affiche rond vide
end
 
lcd.drawText(9, 57, "Trigger" , SMLSIZE+INVERS) -- texte fond noir
   
 -- ========================== affiche valeur ========================================







if rot==1 then -------------- Choix preset reglage 
	------ affiche valeur selectionnne -----
	lcd.drawText(40, 11, sess , SMLSIZE+INVERS) -- texte fond noir

		if modif == rot then -- si mode modif sur cet item

		
		valeur = sess -- lire valeur session en cours
		
		if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
			valeur = choose(valeur,1,30,1) -- detection rotary next ou prev
			sess = valeur -- assigne nouvelle valeur
			sdmem(fich2,sess) -- lire sd et copie vers mem et LS
		end
		if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
		 valeur = choose(valeur,1,30,-1) -- detection rotary next ou prev
		 sess = valeur -- assigne nouvelle valeur
		 sdmem(fich2,sess) -- lire sd et copie vers mem et LS
		end
		
		
		
		end


	else ------ affiche valeur non selectionne -----
	lcd.drawText(40, 11, sess , SMLSIZE) -- texte 

end -- fin rot


for i = 2,11 do -- balaye tous les carac

		if rot==i then -------------- Choix preset reglage 
			------ affiche valeur selectionnne -----
			lcd.drawText(63+6*(i-2), 11, text[mem[i-1]] , SMLSIZE+INVERS) -- texte fond noir

				if modif == rot then -- si mode modif sur cet item

				
				valeur = mem[i-1] -- lire valeur session en cours
				
				if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
					valeur = choose(valeur,1,37,1) -- detection rotary next ou prev
					
				end
				if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
				 valeur = choose(valeur,1,37,-1) -- detection rotary next ou prev
				 
				end
				
				mem[i-1] = valeur
				
				end


			else ------ affiche valeur non selectionne -----
			lcd.drawText(63+6*(i-2), 11, text[mem[i-1]] , SMLSIZE) -- texte  

		end -- fin rot
		
end



if rot==12 then -------------- VALEUR pourcentage th - lap auto  /   Logic Switch  L33 

------ affiche valeur selectionnne -----
lcd.drawText(37, 21, model.getLogicalSwitch(32).v2 .. " %" , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(32)
	valeur = tab.v2 -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,1,99,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,1,99,-1) -- detection rotary next ou prev
	end
	
	tab.v2 = valeur
	model.setLogicalSwitch(32, tab) -- assigner valeur de LS
	mem[11] = valeur -- copier dans mem
	end

else ------ affiche valeur non selectionne -----
lcd.drawText(37, 21, model.getLogicalSwitch(32).v2 .. " %" , SMLSIZE) -- texte

 end -- fin rot
   
   
if rot==13 then -------------- VALEUR delai th - lap auto  /   Logic Switch L33  

------ affiche valeur selectionnne -----
lcd.drawText(108, 21, model.getLogicalSwitch(32).delay/10 .. " s" , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(32)
	valeur = tab.delay -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,1,99,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,1,99,-1) -- detection rotary next ou prev
	end
	
	tab.delay = valeur
	model.setLogicalSwitch(32, tab) -- assigner valeur de LS
	mem[12] = valeur -- copier dans mem
	end

else ------ affiche valeur non selectionne -----
lcd.drawText(108, 21, model.getLogicalSwitch(32).delay/10 .. " s" , SMLSIZE) -- texte

 end -- fin rot
 
 
 
 
 
 if rot==14 then -------------- VALEUR  rpm - lap auto  /   Logic Switch    L35

------ affiche valeur selectionnne -----
lcd.drawText(41, 30, math.floor(model.getLogicalSwitch(34).v2*2204/100000*14/46*dent/46) .. " Kmh" , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(34)
	valeur = tab.v2*2/1000 -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,1,70,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,1,70,-1) -- detection rotary next ou prev 
	end
	
	tab.v2 = valeur*1000/2
	model.setLogicalSwitch(34, tab) -- assigner valeur de LS
	
	mem[18] = math.floor(valeur) -- copier dans mem
	end

else ------ affiche valeur non selectionne -----
lcd.drawText(41, 30, math.floor(model.getLogicalSwitch(34).v2*2204/100000*14/46*dent/46) .. " Kmh" , SMLSIZE) -- texte

 end -- fin rot
   
   
if rot==15 then -------------- VALEUR delai rpm - lap auto  /   Logic Switch L35

------ affiche valeur selectionnne -----
lcd.drawText(108, 30, model.getLogicalSwitch(34).delay/10 .. " s" , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(34)
	valeur = tab.delay -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,1,99,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,1,99,-1) -- detection rotary next ou prev
	end
	
	tab.delay = valeur
	model.setLogicalSwitch(34, tab) -- assigner valeur de LS
	mem[19] = valeur -- copier dans mem
	end

else ------ affiche valeur non selectionne -----
lcd.drawText(108, 30, model.getLogicalSwitch(34).delay/10 .. " s" , SMLSIZE) -- texte

 end -- fin rot
 
 
 
 
 
 
 
 
 
 
 
 
if rot==16 then -------------- VALEUR dans un delai apres  th - lap auto  /   Logic Switch L34 et L36  

------ affiche valeur selectionnne -----
lcd.drawText(93, 39, model.getLogicalSwitch(33).delay/10 .. " s" , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(33)
	valeur = tab.delay -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,1,99,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,1,99,-1) -- detection rotary next ou prev
	end
	
	tab.delay = valeur
	model.setLogicalSwitch(33, tab) -- assigner valeur de LS
	tab = model.getLogicalSwitch(35)
	tab.delay = valeur
	model.setLogicalSwitch(35, tab) -- assigner valeur de LS
	mem[13] = valeur -- copier dans mem
	end

else ------ affiche valeur non selectionne -----
lcd.drawText(93, 39, model.getLogicalSwitch(33).delay/10 .. " s" , SMLSIZE) -- texte

 end -- fin rot
   
   
   
 if rot==17 then -------------- VALEUR distance gps   - lap auto  /   Logic Switch L12  

------ affiche valeur selectionnne -----


	lcd.drawText(85, 48, model.getLogicalSwitch(11).v2/100 .. " m" , SMLSIZE+INVERS) -- texte fond noir


	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(11)
	valeur = math.floor(tab.v2/25) -- lire valeur de LS par pas de 25cm
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,99,1) -- detection rotary next ou prev  distance en pas de 25cm
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,99,-1) -- detection rotary next ou prev
	end
	
	tab.v2 = valeur *25
	
	model.setLogicalSwitch(11, tab) -- assigner valeur de LS
	
		
		mem[15] = valeur -- copier dans mem
		
	end

else ------ affiche valeur non selectionne -----


	lcd.drawText(85, 48, model.getLogicalSwitch(11).v2/100 .. " m" , SMLSIZE) -- texte  


 end -- fin rot
 
 
 
 

 
 
if rot==18 then -------------- VALEUR lap mini   - lap auto  /   Logic Switch L13  

------ affiche valeur selectionnne -----
lcd.drawText(99, 57, model.getLogicalSwitch(12).v2 .. " s" , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(12)
	valeur = tab.v2 -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,1,90,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,1,90,-1) -- detection rotary next ou prev
	end
	
	tab.v2 = valeur
	model.setLogicalSwitch(12, tab) -- assigner valeur de LS
	mem[17] = valeur -- copier dans mem
	
	shared.ls13 = valeur -- reassigner valeur lap mini
	end

else ------ affiche valeur non selectionne -----
	lcd.drawText(99, 57, model.getLogicalSwitch(12).v2 .. " s" , SMLSIZE) -- texte

end -- fin rot
 
 elseif (rot >18 and rot<22) then --========================    PAGE 2    ======================  
 
SD = getValue('sd') --recup valeur switch SD
 
 --========================= affiche texte fond =================================
 
 lcd.drawText(1, 11, "Origine GPS" , SMLSIZE+INVERS) -- texte fond noir  
lcd.drawText(40, 21, "Lat:" , SMLSIZE) -- texte    
lcd.drawText(40, 30, "Lon:" , SMLSIZE) -- texte  
 lcd.drawText(1, 39, "Live GPS" , SMLSIZE+INVERS) -- texte fond noir  
 lcd.drawText(40, 39, "Lat:" , SMLSIZE) -- texte    
 lcd.drawText(40, 48, "Lon:" , SMLSIZE) -- texte 
 
 
 if  gpsDataON == false then
 
		lcd.drawText(61, 39, "  ...." , SMLSIZE+BLINK) -- texte
		 lcd.drawText(61, 48, "  ...." , SMLSIZE+BLINK) -- texte
 
 else
		 if math.abs(lat) < 100 or math.abs(lon) < 100 then
		   lcd.drawText(61, 39, " No Fix" , SMLSIZE+BLINK) -- texte
		   lcd.drawText(61, 48, " No Fix" , SMLSIZE+BLINK) -- texte
		 else
		  lcd.drawText(61, 39, affgps(lat+450000000) , SMLSIZE) -- texte
		   lcd.drawText(61, 48, affgps(lon+50000000) , SMLSIZE) -- texte
		 end
end


lcd.drawText(40, 57, "Distance:" , SMLSIZE) -- texte 

-- soustraction pour distance , on fera la racine ensuite
	   lon = (lon - shared.lonO)  * 67 // 100 -- coeff car difference entre latitude et longitude degré sur terre
	   lat = (lat - shared.latO)

	lat = math.floor((( math.max(math.abs(lat), math.abs(lon)) + math.min(math.abs(lat), math.abs(lon)) ) //2 )*111/100 )-- approximation de la distance sans utiliser pythagore et conversion en cm
	
 lcd.drawNumber(83, 57, math.floor(lat/10+0.5) , PREC1+SMLSIZE) -- texte distance en m type 2.5 m
  lcd.drawText(lcd.getLastPos(), 57, " m" , SMLSIZE) -- texte unité m
 

 
 if getValue('ls12') > 0 then -- affiche rond si detection ok
	rond(30,57,1) -- affiche rond
	else
	rond(30,57,0) -- affiche rond vide
end

 
   if rot==19 then -------------- Définition latO et LonO 
  
  ------ affiche valeur selectionnne -----


	if modif == rot then -- si mode modif sur cet item
	
		-- desactiver switch SD pour Lap
		if model.getInput(13, 0).weight == 100  then-- lire ligne 1 de input 14      si  weight 100
			local tab = model.getInput(13, 1) -- copier ligne 2 input 14
			model.deleteInput(13, 0) -- suppr ligne 1
			tab.weight = 1024 --    DEBUG correspond a weight 0 pour l'instant BUG edgetx
			model.insertInput(13, 0,tab) -- inserer en ligne 1
		end

	lcd.drawText(63, 11, "Def pos/SD" , SMLSIZE+INVERS) -- texte
	lcd.drawText(113, 9, "...." , SMLSIZE+BLINK) -- texte
	
	
	
			gpsData, gpsDataON = getSourceValue('GPS') -- aquisition pos GPS
					
			if 	gpsData == nil or gpsData == "" or gpsDataON == false then	-- verif si valeur gps
			mem[20] = 0
			mem[21] = 0
			
			else
						
			-- Conversion en int avant addition (très important)
			mem[20] = math.floor(gpsData.lat * 10000000 )
			mem[21] = math.floor(gpsData.lon * 10000000 ) -- en degré * 10e7    exemple: 458956321 correspond a 45.8956321 degré
			
			end
		
		shared.latO = mem[20]
		shared.lonO = mem[21]
	
	else
	
	lcd.drawText(63, 11, "Def pos/SD" , SMLSIZE+INVERS) -- texte
	
	
	end


else ------ affiche valeur non selectionne -----
lcd.drawText(63, 11, "Def pos/SD" , SMLSIZE) -- texte


end -- fin rot
 
 
 
 
    if rot==20 then -------------- Modif valeur latO 
  
  ------ affiche valeur selectionnne -----
lcd.drawText(61, 21, affgps(shared.latO+450000000) , SMLSIZE+INVERS) -- texte

	if modif == rot then -- si mode modif sur cet item

			valeur = shared.latO
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		if getRotEncSpeed() == ROTENC_HIGHSPEED then
			valeur = choose(valeur,-2000000000,2000000000,50000) -- detection rotary next ou prev
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then
			valeur = choose(valeur,-2000000000,2000000000,500) -- detection rotary next ou prev
		else
			valeur = choose(valeur,-2000000000,2000000000,5) -- detection rotary next ou prev
		end
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 	 if getRotEncSpeed() == ROTENC_HIGHSPEED then
			valeur = choose(valeur,-2000000000,2000000000,-50000) -- detection rotary next ou prev
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then
			valeur = choose(valeur,-2000000000,2000000000,-500) -- detection rotary next ou prev
		else
			valeur = choose(valeur,-2000000000,2000000000,-5) -- detection rotary next ou prev
		end
	end
	
	mem[20] = valeur -- copier dans mem
	
	shared.latO = valeur -- reassigner valeur

	end


else ------ affiche valeur non selectionne -----

lcd.drawText(61, 21, affgps(shared.latO+450000000) , SMLSIZE) -- texte

end -- fin rot





   if rot==21 then -------------- modif valeur  LonO 
  
  ------ affiche valeur selectionnne -----
lcd.drawText(61, 30, affgps(shared.lonO+50000000) , SMLSIZE+INVERS) -- texte

	if modif == rot then -- si mode modif sur cet item

			valeur = shared.lonO
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
	
		if getRotEncSpeed() == ROTENC_HIGHSPEED then
			valeur = choose(valeur,-2000000000,2000000000,50000) -- detection rotary next ou prev
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then
			valeur = choose(valeur,-2000000000,2000000000,500) -- detection rotary next ou prev
		else
			valeur = choose(valeur,-2000000000,2000000000,5) -- detection rotary next ou prev
		end
	
		
		
		
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	
	 	 if getRotEncSpeed() == ROTENC_HIGHSPEED then
			valeur = choose(valeur,-2000000000,2000000000,-50000) -- detection rotary next ou prev
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then
			valeur = choose(valeur,-2000000000,2000000000,-500) -- detection rotary next ou prev
		else
			valeur = choose(valeur,-2000000000,2000000000,-5) -- detection rotary next ou prev
		end
	 
	end
	
	mem[21] = valeur -- copier dans mem
	
	shared.lonO = valeur -- reassigner valeur

	end


else ------ affiche valeur non selectionne -----

lcd.drawText(61, 30, affgps(shared.lonO+50000000) , SMLSIZE) -- texte



end -- fin rot
 
 
 
  elseif (rot >21 and rot<26) then --========================    PAGE 3    ======================  
 
SD = getValue('sd') --recup valeur switch SD
 
 --========================= affiche texte fond =================================
 
 lcd.drawText(1, 11, "Secteur 1 GPS" , SMLSIZE+INVERS) -- texte fond noir  
lcd.drawText(40, 21, "Lat:" , SMLSIZE) -- texte    
lcd.drawText(40, 30, "Lon:" , SMLSIZE) -- texte  


lcd.drawText(13, 39, "Distance GPS:" , SMLSIZE+INVERS) -- texte fond noir  
lcd.drawText(75, 39, "<" , SMLSIZE) -- texte    


 lcd.drawText(1, 48, "Live GPS" , SMLSIZE+INVERS) -- texte fond noir  
 lcd.drawText(40, 48, "Lat:" , SMLSIZE) -- texte    
 lcd.drawText(40, 57, "Lon:" , SMLSIZE) -- texte 
 
 
 
 
 if  gpsDataON == false then
 
		lcd.drawText(61, 48, "  ...." , SMLSIZE+BLINK) -- texte
		 lcd.drawText(61, 57, "  ...." , SMLSIZE+BLINK) -- texte
 
 else
		 if math.abs(lat) < 100 or math.abs(lon) < 100 then
		   lcd.drawText(61, 48, " No Fix" , SMLSIZE+BLINK) -- texte
		   lcd.drawText(61, 57, " No Fix" , SMLSIZE+BLINK) -- texte
		 else
		  lcd.drawText(61, 48, affgps(lat+450000000) , SMLSIZE) -- texte
		   lcd.drawText(61, 57, affgps(lon+50000000) , SMLSIZE) -- texte
		 end
end




-- soustraction pour distance , on fera la racine ensuite
	   lon = (lon - shared.lon1)  * 67 // 100 -- coeff car difference entre latitude et longitude degré sur terre
	   lat = (lat - shared.lat1)

	lat = math.floor((( math.max(math.abs(lat), math.abs(lon)) + math.min(math.abs(lat), math.abs(lon)) ) //2 )*111/100 )-- approximation de la distance sans utiliser pythagore et conversion en cm
	
 lcd.drawNumber(1, 57, math.floor(lat/10+0.5) , PREC1+SMLSIZE) -- texte distance en m type 2.5 m
  lcd.drawText(lcd.getLastPos(), 57, " m" , SMLSIZE) -- texte unité m
 
 
 if getValue('ls38') > 0 then -- affiche rond si detection ok
	rond(4,39,1) -- affiche rond
	else
	rond(4,39,0) -- affiche rond vide
end
 


 
   if rot==22 then -------------- Définition lat1 et Lon1 
  
  ------ affiche valeur selectionnne -----


	if modif == rot then -- si mode modif sur cet item



		-- desactiver switch SD pour Lap
		if model.getInput(13, 0).weight == 100  then-- lire ligne 1 de input 14      si  weight 100
			local tab = model.getInput(13, 1) -- copier ligne 2 input 14
			model.deleteInput(13, 0) -- suppr ligne 1
			tab.weight = 1024 --    DEBUG correspond a weight 0 pour l'instant BUG edgetx
			model.insertInput(13, 0,tab) -- inserer en ligne 1
		end

	lcd.drawText(68, 11, "Def pos/SD" , SMLSIZE+INVERS) -- texte
	lcd.drawText(118, 9, "...." , SMLSIZE+BLINK) -- texte
	
			gpsData, gpsDataON = getSourceValue('GPS') -- aquisition pos GPS
					
			if 	gpsData == nil or gpsData == "" or gpsDataON == false then	-- verif si valeur gps
			mem[22] = 0
			mem[23] = 0
			
			else
						
			-- Conversion en int avant addition (très important)
			mem[22] = math.floor(gpsData.lat * 10000000 )
			mem[23] = math.floor(gpsData.lon * 10000000 ) -- en degré * 10e7    exemple: 458956321 correspond a 45.8956321 degré
			
			end
		
		shared.lat1 = mem[22]
		shared.lon1 = mem[23]
	
	else
	
	lcd.drawText(68, 11, "Def pos/SD" , SMLSIZE+INVERS) -- texte
	
	
	end


else ------ affiche valeur non selectionne -----
lcd.drawText(68, 11, "Def pos/SD" , SMLSIZE) -- texte


end -- fin rot
 
 
 
 
    if rot==23 then -------------- Modif valeur lat1 
  
  ------ affiche valeur selectionnne -----
lcd.drawText(61, 21, affgps(shared.lat1+450000000) , SMLSIZE+INVERS) -- texte

	if modif == rot then -- si mode modif sur cet item

			valeur = shared.lat1
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		if getRotEncSpeed() == ROTENC_HIGHSPEED then
			valeur = choose(valeur,-2000000000,2000000000,50000) -- detection rotary next ou prev
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then
			valeur = choose(valeur,-2000000000,2000000000,500) -- detection rotary next ou prev
		else
			valeur = choose(valeur,-2000000000,2000000000,5) -- detection rotary next ou prev
		end
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 	 if getRotEncSpeed() == ROTENC_HIGHSPEED then
			valeur = choose(valeur,-2000000000,2000000000,-50000) -- detection rotary next ou prev
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then
			valeur = choose(valeur,-2000000000,2000000000,-500) -- detection rotary next ou prev
		else
			valeur = choose(valeur,-2000000000,2000000000,-5) -- detection rotary next ou prev
		end
	end
	
	mem[22] = valeur -- copier dans mem
	
	shared.lat1 = valeur -- reassigner valeur

	end


else ------ affiche valeur non selectionne -----

lcd.drawText(61, 21, affgps(shared.lat1+450000000) , SMLSIZE) -- texte

end -- fin rot





   if rot==24 then -------------- modif valeur  Lon1 
  
  ------ affiche valeur selectionnne -----
lcd.drawText(61, 30, affgps(shared.lon1+50000000) , SMLSIZE+INVERS) -- texte

	if modif == rot then -- si mode modif sur cet item

			valeur = shared.lon1
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		if getRotEncSpeed() == ROTENC_HIGHSPEED then
			valeur = choose(valeur,-2000000000,2000000000,50000) -- detection rotary next ou prev
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then
			valeur = choose(valeur,-2000000000,2000000000,500) -- detection rotary next ou prev
		else
			valeur = choose(valeur,-2000000000,2000000000,5) -- detection rotary next ou prev
		end
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 if getRotEncSpeed() == ROTENC_HIGHSPEED then
			valeur = choose(valeur,-2000000000,2000000000,-50000) -- detection rotary next ou prev
		elseif getRotEncSpeed() == ROTENC_MIDSPEED then
			valeur = choose(valeur,-2000000000,2000000000,-500) -- detection rotary next ou prev
		else
			valeur = choose(valeur,-2000000000,2000000000,-5) -- detection rotary next ou prev
		end
	end
	
	mem[23] = valeur -- copier dans mem
	
	shared.lon1 = valeur -- reassigner valeur

	end


else ------ affiche valeur non selectionne -----

lcd.drawText(61, 30, affgps(shared.lon1+50000000) , SMLSIZE) -- texte



end -- fin rot
 
 
 
 
 if rot==25 then -------------- VALEUR distance gps secteur 1    /   Logic Switch L38 

------ affiche valeur selectionnne -----


	lcd.drawText(85, 39, model.getLogicalSwitch(37).v2/100 .. " m" , SMLSIZE+INVERS) -- texte fond noir


	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(37)
	valeur = math.floor(tab.v2/25) -- lire valeur de LS par pas de 25cm
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,99,1) -- detection rotary next ou prev  distance en pas de 25cm
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,99,-1) -- detection rotary next ou prev
	end
	
	tab.v2 = valeur *25
	
	model.setLogicalSwitch(37, tab) -- assigner valeur de LS
	
		
		mem[14] = valeur -- copier dans mem
		
	end

else ------ affiche valeur non selectionne -----


	lcd.drawText(85, 39, model.getLogicalSwitch(37).v2/100 .. " m" , SMLSIZE) -- texte  


 end -- fin rot
 
 
   
elseif (rot >25 and rot<31) then --========================    PAGE 4    ======================  
    
  
   --========================= affiche texte fond =================================


lcd.drawText(1, 11, "Lap Auto" , SMLSIZE+INVERS) -- texte 

 lcd.drawText(1, 21, "Preset:" , SMLSIZE+INVERS) -- texte fond noir
 
lcd.drawText(65, 21, text[mem[1]] , SMLSIZE) -- texte
   for i = 2,10 do -- balaye tous les carac
		
	  lcd.drawText(lcd.getLastRightPos(), 21, text[mem[i]] , SMLSIZE) -- texte  
		
   end
 
 lcd.drawText(54, 21, "-" , SMLSIZE) -- texte
 
lcd.drawText(1, 34, "Annonce Tps Secteur" , SMLSIZE+INVERS) -- texte  

 lcd.drawText(1, 45, "Bip alerte best lap" , SMLSIZE+INVERS) -- texte fond noir
   lcd.drawText(1, 56, "Alerte vocale minute" , SMLSIZE+INVERS) -- texte fond noir
  
  
  
  if rot==26 then -------------- VALEUR activation mode lap auto   /   Logic Switch L13  
  
  ------ affiche valeur selectionnne -----
if model.getLogicalSwitch(12).func == LS_FUNC_VPOS then -- si logical switch a>x  (lap auto activé)
														-- valeur de LS : -100 pour Off et 100 pour ON
	case(43,10,3)
	else
	case(43,10,2)
end

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(12)
	
	if  tab.func ==  LS_FUNC_VPOS then -- si ls13   a>x (lap auto activé)
	valeur = 1
	else
	valeur = 0
	end
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,1,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,1,-1) -- detection rotary next ou prev
	end
	
	if  valeur ==  1 then -- si ls13   (lap auto activé)
	tab.func = LS_FUNC_VPOS
	model.setLogicalSwitch(12, tab) -- assigner valeur de LS
	else
	tab.func = LS_FUNC_VEQUAL
	model.setLogicalSwitch(12, tab) -- assigner valeur de LS
	end
	
	

	end

else ------ affiche valeur non selectionne -----

if model.getLogicalSwitch(12).func == LS_FUNC_VPOS then -- si logical switch a>x  (lap auto activé)
	case(43,10,1)
	else
	case(43,10,0)
end

end -- fin rot
  
  
  
  
  if rot==27 then -------------- Choix preset reglage 
	------ affiche valeur selectionnne -----
	lcd.drawText(40, 21, sess , SMLSIZE+INVERS) -- texte fond noir

		if modif == rot then -- si mode modif sur cet item

		
		valeur = sess -- lire valeur session en cours
		
		if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
			valeur = choose(valeur,1,30,1) -- detection rotary next ou prev
			sess = valeur -- assigne nouvelle valeur
			sdmem(fich2,sess) -- lire sd et copie vers mem et LS
		end
		if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
		 valeur = choose(valeur,1,30,-1) -- detection rotary next ou prev
		 sess = valeur -- assigne nouvelle valeur
		 sdmem(fich2,sess) -- lire sd et copie vers mem et LS
		end
		
		
		
		end


	else ------ affiche valeur non selectionne -----
	lcd.drawText(40, 21, sess , SMLSIZE) -- texte 

end -- fin rot
  
  

  
    if rot==28 then -------------- VALEUR activation annonce tps secteur   /   Logic Switch L38 
  
  ------ affiche valeur selectionnne -----
if model.getLogicalSwitch(37)["and"] == -150 then -- si AND du logical switch est egal a !L30  (on utilise L30 pour desactiver le logical switch car L30 n'est actif que pdt 3s au demarrage de telco
-- L30 c'est index 150
-- !L30 c'est index -150
														
	case(93,33,3)
	else
	case(93,33,2)
end

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(37)
	
	if  tab["and"] ==  -150 then 
	valeur = 1
	else
	valeur = 0
	end
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,1,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,1,-1) -- detection rotary next ou prev
	end
	
	if  valeur ==  1 then 
	tab["and"] = -150 -- and !L30
	model.setLogicalSwitch(37, tab) -- assigner valeur de LS
	else
	tab["and"] = 150 -- and L30
	model.setLogicalSwitch(37, tab) -- assigner valeur de LS
	end
	
	

	end

else ------ affiche valeur non selectionne -----

if model.getLogicalSwitch(37)["and"] == -150 then -- si and logical switch == !L30  (secteur activé)
	case(93,33,1)
	else
	case(93,33,0)
end

end -- fin rot

  
  
  
  
  
  
  
  
  
  
  
  if rot==29 then -------------- VALEUR bip tps best lap   /   Logic Switch L13  

------ affiche valeur selectionnne -----

if model.getLogicalSwitch(12).duration == 5 then -- si annonce bip tps mini activé
	case(91,44,3)
	else
	case(91,44,2)
end


	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(12)
	valeur = tab.duration -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,5,6,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,5,6,-1) -- detection rotary next ou prev
	end
	
	tab.duration = valeur
	model.setLogicalSwitch(12, tab) -- assigner valeur de LS
	shared.bip = model.getLogicalSwitch(12).duration
	end

else ------ affiche valeur non selectionne -----

	if model.getLogicalSwitch(12).duration == 5 then -- si annonce bip tps mini activé
	case(91,44,1)
	else
	case(91,44,0)
end

end -- fin rot
   

local tab = model.getTimer(1) -- recup timer 2


  if rot==30 then -------------- VALEUR alerte minute   /   Timer 2

------ affiche valeur selectionnne -----

if tab.minuteBeep == true then -- si alerte minute mini activé
	case(97,55,3)
	else
	case(97,55,2)
end


	if modif == rot then -- si mode modif sur cet item


	valeur = tab.minuteBeep -- lire valeur timer
	if valeur == true then
		valeur = 1
		else
		valeur = 0
	end
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,1,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,1,-1) -- detection rotary next ou prev
	end
	
	if valeur == 1 then
		valeur = true
		else
		valeur = false
	end
	
	tab.minuteBeep = valeur
	model.setTimer(1, tab) -- assigner valeur  
	
	end

else ------ affiche valeur non selectionne -----

	if tab.minuteBeep == true then -- si alerte minute mini activé
	case(97,55,1)
	else
	case(97,55,0)
end

end -- fin rot



end   -- ==========FIN PAGES ------------
	  
  
  -- page:
lcd.drawNumber(123, 56,"4", 0+INVERS) -- texte numero page

end