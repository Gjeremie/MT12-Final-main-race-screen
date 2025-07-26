local shared = ...

local fich2 = "/SCRIPTS/TELEMETRY/" .. string.sub(model.getInfo().name,1,1) .. "-mem.txt"
local carac = 1
local edit = 1
local modif = 0 --   =0 si pas mode modif et =valeur de rot si modif de cet item 
local rebound = 0 -- anti rebond Enter key
local rot = 1 -- numero item a modifier (commande par rotary)
local text =  {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", " " } -- derniere index= 37
local mem = {37,37,37,37,37,37,37,37,37,37,0,0,0,0,0,0,0,0,0,0} -- stockage nom circuit + sauvegarde valeur
local debut = 0
local ret11 = -200 -- variable stockage delai affichage valeur modifier
local old11 = math.floor(getValue('input5')/10.24)
local ret18 = -200 -- variable stockage delai affichage valeur modifier
local old18 = math.floor(getValue('gvar6'))

local ret12 = -200 -- variable stockage delai affichage valeur modifier
local old12 = math.floor(getValue('gvar1'))
local ret13 = -200 -- variable stockage delai affichage valeur modifier
local old13 = math.floor(getValue('input4')/10.24)
local ret14 = -200 -- variable stockage delai affichage valeur modifier
local old14 = math.floor(getValue('gvar2')/100)
local ret15 = -200 -- variable stockage delai affichage valeur modifier
local old15 = math.floor(getValue('gvar3')/10)
local ret16 = -200 -- variable stockage delai affichage valeur modifier
local old16 = math.floor(getValue('gvar4')/7)

local ret17 = -200 -- variable stockage delai affichage valeur modifier
local old17 = getFlightMode()

local ret19 = -200 -- variable stockage delai affichage valeur modifier
local old19 = math.floor(getValue('gvar7'))

local ret20 = -200 -- variable stockage delai affichage valeur modifier
local old20 = math.floor(getValue('gvar9'))

local FModeName = {}      -- table nom MODE DE VOL :  largeur max 6 carac
FModeName[0]=model.getFlightMode(0).name-- "Normal"                
  FModeName[1]=model.getFlightMode(1).name-- "Astro"
  FModeName[2]=model.getFlightMode(2).name-- "Grip"
  FModeName[3]=model.getFlightMode(3).name-- "Terre"
  FModeName[4]=model.getFlightMode(4).name-- "Glisse"
  FModeName[5]=model.getFlightMode(5).name-- "Humide"

local function data(x) -- sauvegarde mise en forme 2 carac

		x = tostring(x)  -- convertir en string  
		
		if (#x==1) then -- nombre a 1 chiffre
			x = "x" .. x  -- completer pour 2 carac 
			
			elseif (#x>2) then -- si = 2 ou plus
			x = "11"   -- completer pour 2 carac
			
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


local function drawicon(x,y,z) -- 0= th   1=st    2= br  

if z == 0 then
	lcd.drawLine(0+x,0+y,2+x,0+y, SOLID, FORCE)
lcd.drawLine(5+x,3+y,6+x,3+y, SOLID, FORCE)
lcd.drawLine(1+x,1+y,1+x,6+y, SOLID, FORCE)
lcd.drawLine(4+x,0+y,4+x,6+y, SOLID, FORCE)
lcd.drawLine(7+x,0+y,7+x,6+y, SOLID, FORCE)
end

if z == 1 then
lcd.drawLine(1+x,0+y,2+x,0+y, SOLID, FORCE)
lcd.drawLine(5+x,0+y,7+x,0+y, SOLID, FORCE)
lcd.drawPoint(3+x,1+y)
lcd.drawLine(1+x,3+y,2+x,3+y, SOLID, FORCE)
lcd.drawPoint(0+x,5+y)
lcd.drawLine(1+x,6+y,2+x,6+y, SOLID, FORCE)
lcd.drawLine(0+x,1+y,0+x,2+y, SOLID, FORCE)
lcd.drawLine(3+x,4+y,3+x,5+y, SOLID, FORCE)
lcd.drawLine(6+x,1+y,6+x,6+y, SOLID, FORCE)
end

if z == 2 then
lcd.drawLine(0+x,0+y,2+x,0+y, SOLID, FORCE)
lcd.drawLine(5+x,0+y,7+x,0+y, SOLID, FORCE)
lcd.drawLine(1+x,3+y,2+x,3+y, SOLID, FORCE)
lcd.drawLine(6+x,3+y,7+x,3+y, SOLID, FORCE)
lcd.drawPoint(7+x,4+y)
lcd.drawLine(0+x,6+y,2+x,6+y, SOLID, FORCE)
lcd.drawLine(0+x,1+y,0+x,5+y, SOLID, FORCE)
lcd.drawLine(3+x,1+y,3+x,2+y, SOLID, FORCE)
lcd.drawLine(3+x,4+y,3+x,5+y, SOLID, FORCE)
lcd.drawLine(5+x,1+y,5+x,6+y, SOLID, FORCE)
lcd.drawLine(8+x,1+y,8+x,2+y, SOLID, FORCE)
lcd.drawLine(8+x,5+y,8+x,6+y, SOLID, FORCE)
end



end




function shared.run(event)
  lcd.clear()


if debut == 0 then
	local file = io.open(fich2, "r") -- ouvrir fichier 0-mem.txt en acces lecture
	
	local curs = io.seek(file, 1 ) --  positionner curseur dans fichier  
			rot = io.read (file, 2) -- lire 2 carac   dans fichier  et asssigner
	rot = lire(rot) -- conversion
	
		for i = 1,20 do
			local curs = io.seek(file, 10+2*i+50*(rot-1) ) --  positionner curseur dans fichier  
			mem[i] = io.read (file, 2) -- lire 2 carac   dans fichier  et asssigner
			mem[i] = lire(mem[i]) -- convertir lecture
		end
		io.close(file) -- fermer fichier
debut = 1
end






---- touche bascule entre ecran -----------------
 if event == EVT_VIRTUAL_NEXT_PAGE then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(2)
  end
   if event == EVT_VIRTUAL_PREV_PAGE then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(3)
  end
  
 if event == EVT_VIRTUAL_MENU_LONG then -- bouton menu 
  playTone(1200, 120,5) -- play tone
    shared.changeScreen(5)
  end

lcd.drawText(1, 1, "MEMOIRE SETUP                    " , 0+INVERS) -- TITRE


-- icone dossier flight mode
lcd.drawLine(4,28,6,28, SOLID, FORCE) 
lcd.drawFilledRectangle(0, 29, 7, 9, FORCE)
lcd.drawLine(1,31,5,31, SOLID, ERASE) 
lcd.drawLine(1,33,5,33, SOLID, ERASE) 
lcd.drawLine(1,35,5,35, SOLID, ERASE) 
 
 
 lcd.drawFilledRectangle(44, 44, 3, 5, SOLID)
 
 lcd.drawRectangle(102, 30, 2, 6, SOLID)
 lcd.drawRectangle(69, 58, 2, 2, SOLID)
 
 
 
 
 
 
 
 lcd.drawLine(96,28,104,28, SOLID, FORCE)
lcd.drawPoint(101,31)
lcd.drawPoint(104,31)
lcd.drawPoint(95,35)
lcd.drawLine(97,40,102,40, SOLID, FORCE)
lcd.drawLine(44,42,46,42, SOLID, FORCE)
lcd.drawPoint(43,43)
lcd.drawPoint(47,43)
lcd.drawLine(99,43,100,43, SOLID, FORCE)
lcd.drawLine(98,44,101,44, SOLID, FORCE)
lcd.drawLine(96,45,98,45, SOLID, FORCE)
lcd.drawLine(101,45,103,45, SOLID, FORCE)
lcd.drawLine(96,46,97,46, SOLID, FORCE)
lcd.drawLine(102,46,103,46, SOLID, FORCE)
lcd.drawLine(97,47,98,47, SOLID, FORCE)
lcd.drawLine(101,47,102,47, SOLID, FORCE)
lcd.drawLine(99,48,100,48, SOLID, FORCE)
lcd.drawPoint(43,49)
lcd.drawPoint(47,49)
lcd.drawPoint(15,50)
lcd.drawLine(44,50,46,50, SOLID, FORCE)
lcd.drawLine(49,53,50,53, SOLID, FORCE)
lcd.drawPoint(48,54)
lcd.drawLine(45,55,47,55, SOLID, FORCE)
lcd.drawPoint(72,55)
lcd.drawPoint(71,56)
lcd.drawPoint(48,57)
lcd.drawLine(47,58,49,58, SOLID, FORCE)
lcd.drawLine(46,59,50,59, SOLID, FORCE)
lcd.drawPoint(71,61)
lcd.drawPoint(103,61)
lcd.drawPoint(43,62)
lcd.drawPoint(72,62)
lcd.drawPoint(102,62)
lcd.drawLine(41,63,42,63, SOLID, FORCE)
lcd.drawLine(101,63,105,63, SOLID, FORCE)
lcd.drawLine(11,41,11,50, SOLID, FORCE)
lcd.drawLine(12,44,12,50, SOLID, FORCE)
lcd.drawLine(13,47,13,50, SOLID, FORCE)
lcd.drawLine(14,49,14,50, SOLID, FORCE)
lcd.drawLine(44,56,44,61, SOLID, FORCE)
lcd.drawLine(48,60,48,62, SOLID, FORCE)
lcd.drawLine(95,43,95,44, SOLID, FORCE)
lcd.drawLine(96,34,96,35, SOLID, FORCE)
lcd.drawLine(96,41,96,42, SOLID, FORCE)
lcd.drawLine(97,32,97,35, SOLID, FORCE)
lcd.drawLine(98,29,98,35, SOLID, FORCE)
lcd.drawLine(99,29,99,35, SOLID, FORCE)
lcd.drawLine(100,54,100,63, SOLID, FORCE)
lcd.drawLine(103,41,103,42, SOLID, FORCE)
lcd.drawLine(104,43,104,44, SOLID, FORCE)
lcd.drawLine(104,58,104,60, SOLID, FORCE)
lcd.drawLine(105,54,105,57, SOLID, FORCE)

 
 lcd.drawRectangle(10, 54, 2, 3, SOLID)
lcd.drawRectangle(15, 54, 2, 3, SOLID)

lcd.drawRectangle(10, 61, 2, 3, SOLID)
lcd.drawRectangle(15, 61, 2, 3, SOLID)


lcd.drawLine(12,55,14,55, SOLID, FORCE)
lcd.drawLine(12,62,14,62, SOLID, FORCE)
lcd.drawLine(13,56,13,61, SOLID, FORCE)
lcd.drawLine(55,31,55,34, SOLID, FORCE)
lcd.drawLine(57,31,57,34, SOLID, FORCE)
lcd.drawLine(58,31,58,34, SOLID, FORCE)
lcd.drawLine(59,28,59,37, SOLID, FORCE)
lcd.drawLine(60,30,60,35, SOLID, FORCE)
lcd.drawLine(61,32,61,33, SOLID, FORCE)

 


 
 
 
 lcd.drawLine(0,23,127,23, SOLID, FORCE) -- ligne
 
 -- pot
lcd.drawText(80, 27, "P" , SMLSIZE+INVERS) -- pot
 lcd.drawText(80, 34, "O" , SMLSIZE+INVERS) -- pot
 lcd.drawText(80, 41, "T" , SMLSIZE+INVERS) -- pot
  lcd.drawLine(84,41,84,47, SOLID, FORCE)
 
 
  drawicon(86,26,0)

 drawicon(0,41,2)
  drawicon(87,38,1)
 
 drawicon(91,53,1)

  drawicon(0,53,2)
   drawicon(45,26,0) -- vitesse gaz
   
 -- affichage valeur actuelle en faisant bouger volant
 
 if math.floor(getValue('input28')) ~= 0 then -- verif si volant pas au milieu
 ret11= getTime()-170
  ret12= getTime()-170
   ret13= getTime()-170
    ret14= getTime()-170
	 ret15= getTime()-170
	  ret16= getTime()-170
	   ret17= getTime()-170
	   	   ret18= getTime()-170
		    ret19= getTime()-170
			ret20= getTime()-170
 end
 
 
 
 -- valeurs
 
 
if math.floor(getValue('input5')/10.24)  ~= old11 then -- regarde si action sur changement de valeur avec  potar
 	ret11 =  getTime()
end
old11 =  math.floor(getValue('input5')/10.24) -- assigne ancienne valeur
 
if getTime() < ret11 + 200  then -- vérif si depuis 2 seconde valeur a plus bougé

  lcd.drawNumber(108, 25, math.floor(getValue('input5')/10.24) , MIDSIZE+INVERS) --  si depuis moin de 2 sec alors affiche valeur live du potar
else -- afficher valeur sauvegardé

 	if mem[11] == 0 then
		  lcd.drawNumber(108, 25, 100 , MIDSIZE) -- valeur 
	else
		 lcd.drawNumber(108, 25, mem[11] , MIDSIZE) -- valeur  
	end
 end
 
 
 
 
 if   math.floor(getValue('gvar6')) ~= old18 then -- regarde si action sur changement de valeur avec  potar
 	ret18 =  getTime()
end
old18 =  math.floor(getValue('gvar6')) -- assigne ancienne valeur
 
if getTime() < ret18 + 200  then -- vérif si depuis 2 seconde valeur a plus bougé

   lcd.drawNumber(51, 40, math.abs(math.floor(getValue('gvar6'))-100) , MIDSIZE+INVERS) -- valeur --  si depuis moin de 2 sec alors affiche valeur live du potar
else -- afficher valeur sauvegardé
   if mem[18] == 0 then
 lcd.drawNumber(51, 40, 0 , MIDSIZE) -- valeur 
 else
  lcd.drawNumber(51, 40, math.abs(mem[18]-100) , MIDSIZE) -- valeur 
  end
 	
 end

 
 
if   math.floor(getValue('gvar1')) ~= old12 then -- regarde si action sur changement de valeur avec  potar
 	ret12 =  getTime()
end
old12 =  math.floor(getValue('gvar1')) -- assigne ancienne valeur
 
if getTime() < ret12 + 200  then -- vérif si depuis 2 seconde valeur a plus bougé

   lcd.drawNumber(18, 40, math.floor(getValue('gvar1')) , MIDSIZE+INVERS) -- valeur --  si depuis moin de 2 sec alors affiche valeur live du potar
else -- afficher valeur sauvegardé
  if mem[12] == 0 then
 lcd.drawNumber(18, 40, 100 , MIDSIZE) -- valeur 
 else
  lcd.drawNumber(18, 40, mem[12] , MIDSIZE) -- valeur 
  end
 	
end



if  math.floor(getValue('input4')/10.24) ~= old13 then -- regarde si action sur changement de valeur avec  potar
 	ret13 =  getTime()
end
old13 =  math.floor(getValue('input4')/10.24) -- assigne ancienne valeur
 
if getTime() < ret13 + 200  then -- vérif si depuis 2 seconde valeur a plus bougé

  lcd.drawNumber(108, 37, math.floor(getValue('input4')/10.24) , MIDSIZE+INVERS) --  si depuis moin de 2 sec alors affiche valeur live du potar
else -- afficher valeur sauvegardé
   if mem[13] == 0 then
 lcd.drawNumber(108, 37, 100 , MIDSIZE) -- valeur 
 else
   lcd.drawNumber(108, 37, mem[13] , MIDSIZE) -- valeur 
   end
 	
end
 
 
 
 if  math.floor(getValue('gvar2')/100) ~= old14 then -- regarde si action sur changement de valeur avec  potar
 	ret14 =  getTime()
end
old14 = math.floor(getValue('gvar2')/100)  -- assigne ancienne valeur
 
if getTime() < ret14 + 200  then -- vérif si depuis 2 seconde valeur a plus bougé

    lcd.drawNumber(64, 27, math.floor(getValue('gvar2')/100) , MIDSIZE+INVERS) -- valeur --  si depuis moin de 2 sec alors affiche valeur live du potar
else -- afficher valeur sauvegardé
 lcd.drawNumber(64, 27, mem[14] , MIDSIZE) -- valeur 
 	
end




if  math.floor(getValue('gvar3')/10) ~= old15 then -- regarde si action sur changement de valeur avec  potar
 	ret15 =  getTime()
end
old15 =  math.floor(getValue('gvar3')/10) -- assigne ancienne valeur
 
if getTime() < ret15 + 200  then -- vérif si depuis 2 seconde valeur a plus bougé


  lcd.drawNumber(53, 52, math.floor(getValue('gvar3')/10) , MIDSIZE+INVERS) -- valeur  --  si depuis moin de 2 sec alors affiche valeur live du potar
else -- afficher valeur sauvegardé
lcd.drawNumber(53, 52, mem[15] , MIDSIZE) -- valeur 
 	

	
end



if  math.floor(getValue('gvar4')/7) ~= old16 then -- regarde si action sur changement de valeur avec  potar
 	ret16 =  getTime()
end
old16 = math.floor(getValue('gvar4')/7)  -- assigne ancienne valeur
 
if getTime() < ret16 + 200  then -- vérif si depuis 2 seconde valeur a plus bougé

   lcd.drawNumber(108, 52, math.floor(getValue('gvar4')/7) , MIDSIZE+INVERS) -- valeur --  si depuis moin de 2 sec alors affiche valeur live du potar
else -- afficher valeur sauvegardé
lcd.drawNumber(108, 52, mem[16] , MIDSIZE) -- valeur 
 	
end




if getFlightMode()  ~= old17 then -- regarde si action sur changement de valeur avec  potar
 	ret17 =  getTime()
end
old17 =  getFlightMode() -- assigne ancienne valeur
 
if getTime() < ret17 + 200  then -- vérif si depuis 2 seconde valeur a plus bougé

  lcd.drawText(9, 31,FModeName[getFlightMode()], 0+INVERS) -- texte mode de vol --  si depuis moin de 2 sec alors affiche valeur live du potar
else -- afficher valeur sauvegardé

 	if mem[17]<6 then
 lcd.drawText(9, 31,FModeName[mem[17]], 0) -- texte mode de vol
 end
 
end
 
 
 
 
 
 if  math.floor(getValue('gvar7')) ~= old19 then -- regarde si action sur changement de valeur avec  potar
 	ret19 =  getTime()
end
old19 =  math.floor(getValue('gvar7')) -- assigne ancienne valeur
 
if getTime() < ret19 + 200  then -- vérif si depuis 2 seconde valeur a plus bougé


if math.floor(getValue('gvar7')) == 4 then
lcd.drawNumber(75, 52, 0 , MIDSIZE+INVERS) -- valeur 0
else
  lcd.drawNumber(75, 52, math.floor(getValue('gvar7')) , MIDSIZE+INVERS) -- valeur  --  si depuis moin de 2 sec alors affiche valeur live du potar
end

else -- afficher valeur sauvegardé

if mem[19] == 4 then
lcd.drawNumber(75, 52, 0 , MIDSIZE) -- valeur 0
else
lcd.drawNumber(75, 52, mem[19] , MIDSIZE) -- valeur 
 end

	
end
 
 
 
 
  if  math.floor(getValue('gvar9')) ~= old20 then -- regarde si action sur changement de valeur avec  potar
 	ret20 =  getTime()
end
old20 =  math.floor(getValue('gvar9')) -- assigne ancienne valeur
 
if getTime() < ret20 + 200  then -- vérif si depuis 2 seconde valeur a plus bougé


lcd.drawNumber(19, 52, math.floor(getValue('gvar9')) , MIDSIZE+INVERS) -- valeur  --  si depuis moin de 2 sec alors affiche valeur live


else -- afficher valeur sauvegardé


if mem[20] == 0 then
lcd.drawNumber(19, 52, 100 , MIDSIZE) --  valeur 0 affiche 100
else
lcd.drawNumber(19, 52, mem[20] , MIDSIZE) -- valeur 
 end




	
end
 
 
 
-- choix memoire:

if modif == 0 then

if rot>1 and rot<10 then
lcd.drawNumber(1, 13,rot, 0+INVERS) -- texte num item
else
lcd.drawNumber(0, 13,rot, 0+INVERS) -- texte num item
end

lcd.drawText(98, 10,".............", 0) -- 

for i = 1,10 do
lcd.drawText(15+6*i, 13,text[mem[i]], 0) -- texte carac par carac
end

	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
	
    rot = rot+1 -- allez item suivant
		if (rot >30) then -- max item
		rot =30
		else
		playTone(1200, 50,5) -- play tone
		end
		
		local file = io.open(fich2, "r") -- ouvrir fichier 0-mem.txt en acces lectur
				
		for i = 1,20 do
			local curs = io.seek(file, 10+2*i+50*(rot-1) ) --  positionner curseur dans fichier  
			mem[i] = io.read (file, 2) -- lire 2 carac   dans fichier  et asssigner
			mem[i] = lire(mem[i]) -- convertir lecture
		end
				
		io.close(file) -- fermer fichier
		
		 local file = io.open(fich2, "a") -- ouvrir fichier 0-mem.txt en acces ecriture et en preservant son contenu
		    
			
			 local curs = io.seek(file, 1) --  positionner curseur dans fichier 
			 local ecri = io.write (file, data(rot)) --  ecri 2 carac  dans fichier 
			
	 io.close(file) -- fermer fichier   
		
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary  prev
	
    rot = rot-1
		if (rot <1) then
		rot =1     --   max item
		else
		playTone(1200, 50,5) -- play tone
		end
		
				local file = io.open(fich2, "r") -- ouvrir fichier 0-mem.txt en acces lecture
								
		for i = 1,20 do
			local curs = io.seek(file, 10+2*i+50*(rot-1) ) --  positionner curseur dans fichier  
			mem[i] = io.read (file, 2) -- lire 2 carac   dans fichier  et asssigner
			mem[i] = lire(mem[i]) -- convertir lecture
		end
		io.close(file) -- fermer fichier
		
		local file = io.open(fich2, "a") -- ouvrir fichier 0-mem.txt en acces ecriture et en preservant son contenu
		    
			
			 local curs = io.seek(file, 1) --  positionner curseur dans fichier 
			 local ecri = io.write (file, data(rot)) --  ecri 2 carac  dans fichier 
			
	 io.close(file) -- fermer fichier   
		
	end 
	
	if ( event == EVT_VIRTUAL_ENTER and (getTime() - rebound) > 100 ) then -- bouton rotary ENTER anti rebond
	playTone(1200, 120,5) -- play tone
	rebound = getTime()
	
	 modif = 1 -- action
	   
	end
 end
 
 if modif == 1 then -- si en mode modif etage 1
 
if rot>1 and rot<10 then
lcd.drawNumber(1, 13,rot, 0) -- texte num item
else
lcd.drawNumber(0, 13,rot, 0) -- texte num item
end

 if edit == 11 then -- bouton save
  lcd.drawText(93, 13,"SAVE", 0+INVERS) --
  else
   if edit == 12 then -- bouton apply
  lcd.drawText(93, 13,"APPLY", 0+INVERS) --
  else
    if edit == 13 then -- bouton cancel
  lcd.drawText(93, 13,"CANCEL", 0+INVERS) --
  else
   lcd.drawText(93, 13,"SAVE", 0) -- 
   end
   end
 end
 
for i = 1,10 do
	if edit == i then
	lcd.drawText(15+6*i, 13,text[mem[i]], 0+INVERS) -- texte carac par carac
	else
	lcd.drawText(15+6*i, 13,text[mem[i]], 0) -- texte carac par carac
	end
end
 
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
	playTone(1200, 50,5) -- play tone
    edit = edit+1 -- allez item suivant
		if (edit >13) then -- max item
		edit =1
		end
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary  prev
	playTone(1200, 50,5) -- play tone
    edit = edit-1
		if (edit <1) then
		edit =13     --   max item
		end
	end
	
	if ( event == EVT_VIRTUAL_ENTER and (getTime() - rebound) > 100 ) then -- bouton rotary ENTER anti rebond
	playTone(1200, 120,5) -- play tone
	rebound = getTime()
	 
	 
	  if edit == 11 then -- bouton save
	  
	  
	   local file = io.open(fich2, "a") -- ouvrir fichier 0-mem.txt en acces ecriture et en preservant son contenu
		    
			
					mem[11] = math.floor(getValue('input5')/10.24)  -- valeur  Dualrate throttle  remis a 100
					mem[12] = math.floor(getValue('gvar1'))  -- valeur  Dualrate   brake 1 a 100
					mem[13] = math.floor(getValue('input4')/10.24)  -- valeur  Dualrate steering  remis a 100
					mem[18] = math.floor(getValue('gvar6'))  -- valeur  abs de 5 a 100

					for i = 11,13 do
						if mem[i] == 100 then
						mem[i] = 0
						end
					end
					if mem[18] == 100 then
						mem[18] = 0
						end
					
					mem[14] = math.floor(getValue('gvar2')/100)  -- valeur  g2 de 0 a 10 vitesse gaz
					mem[15] = math.floor(getValue('gvar3')/10)  -- valeur  g3 de 0 a 10 etage frein
					mem[16] = math.floor(getValue('gvar4')/7)  -- valeur  g4 de 0 a 10 expo stering
					mem[17] = getFlightMode()
					mem[19] = math.floor(getValue('gvar7'))  -- valeur  drag brake de 4 a 90
					mem[20] = math.floor(getValue('gvar9'))  -- valeur  ratio frein Arr de 1 a 100		
						if mem[20] == 100 then
						mem[20] = 0
						end
								
			for i = 11,20 do
			 local curs = io.seek(file, 10+2*i+50*(rot-1)) --  positionner curseur dans fichier 
			 local ecri = io.write (file, data(mem[i])) --  ecri 2 carac  dans fichier 
			end
	 io.close(file) -- fermer fichier   
	  
	  
	modif = 0 -- ACTION sauvegarde valeur actuelle et revien etage 0
	
	
	
	
	else
		if edit == 12 then -- bouton apply
		
			if mem[12] == 0 then
				
				model.setGlobalVariable(0, getFlightMode(), 100) -- applique sauvegarde a valeur   gvar1
				else
				model.setGlobalVariable(0, getFlightMode(), mem[12]) -- applique sauvegarde a valeur   gvar1
				end
				
				if mem[18] == 0 then
					model.setGlobalVariable(5, getFlightMode(), 100) -- applique sauvegarde a valeur   gvar6
					else
						model.setGlobalVariable(5, getFlightMode(), mem[18]) -- applique sauvegarde a valeur   gvar6
					end
		
		if mem[20] == 0 then
					model.setGlobalVariable(8, getFlightMode(), 100) -- applique sauvegarde a valeur   gvar9
					else
						model.setGlobalVariable(8, getFlightMode(), mem[20]) -- applique sauvegarde a valeur   gvar9
					end
		
		
		model.setGlobalVariable(1, getFlightMode(), mem[14]*100) -- applique sauvegarde a valeur   gvar2
		model.setGlobalVariable(2, getFlightMode(), mem[15]*10) -- applique sauvegarde a valeur   gvar3
		model.setGlobalVariable(3, getFlightMode(), mem[16]*7) -- applique sauvegarde a valeur   gvar4
		model.setGlobalVariable(6, getFlightMode(), mem[19]) -- applique sauvegarde a valeur   gvar7
				
		modif = 0 -- ACTION  revien etage 0
		else
		
			if edit == 13 then -- bouton cancel
							
			modif = 0 -- ACTION  revien etage 0
			else
			carac = 1
			modif = 2 -- action rentre etage 2
			end
		end
	
	end
	 
	   
	end
 end
 
 
 if modif == 2 then -- si en mode modif etage 2
 
if rot>1 and rot<10 then
lcd.drawNumber(1, 13,rot, 0) -- texte num item
else
lcd.drawNumber(0, 13,rot, 0) -- texte num item
end
 

 
 for i = 1,10 do
	if edit == i then
	lcd.drawLine(15+6*i,21,20+6*i,21, SOLID, FORCE)
	
	end
	lcd.drawText(15+6*i, 13,text[mem[i]], 0) -- texte carac par carac
	
end
 
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
	playTone(1200, 50,5) -- play tone
    carac = carac+1 -- allez item suivant
		if (carac >37) then -- max item
		carac =1
		end
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary  prev
	playTone(1200, 50,5) -- play tone
    carac = carac-1
		if (carac <1) then
		carac =37     --   max item
		end
	end
	
	mem[edit] = carac
	
	if ( event == EVT_VIRTUAL_ENTER and (getTime() - rebound) > 100 ) then -- bouton rotary ENTER anti rebond
	playTone(1200, 120,5) -- play tone
	rebound = getTime()
	
	 
	 local file = io.open(fich2, "a") -- ouvrir fichier 0-mem.txt en acces ecriture et en preservant son contenu
		    
			for i = 1,10 do
			 local curs = io.seek(file, 10+2*i+50*(rot-1)) --  positionner curseur dans fichier 
			 local ecri = io.write (file, data(mem[i])) --  ecri 2 carac  dans fichier 
			end
	 io.close(file) -- fermer fichier   
	 modif = 0 -- action  
	end
 end
 
 
 	  
--popup new session
if (shared.pop  == 1 ) then -- si reset session
	lcd.drawFilledRectangle(15, 20, 98, 23, ERASE)
	lcd.drawRectangle(17, 22, 94, 19, FORCE)
	lcd.drawText(21, 28, "Nouvelle Session" , 0)
end
  
  
-- page:
lcd.drawNumber(123, 56,"3", 0+INVERS) -- texte numero page
end