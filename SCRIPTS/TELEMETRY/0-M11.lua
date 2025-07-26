local shared = ...    -- varaiabe partage entre ecran

-------------- VARIABLES ------------------------


local icon_drawers = {} -- La table qui stockera nos fonctions de dessin
local gpsData  -- donnee GPS
local gpsDataON  -- true si telem transmise 

local clignot = false -- Variable pour clignotement 

local modif = 0 -- modif capa accu
local rebound = 0 -- anti rebond Enter key

local horl = 0

local FMode = 0  -- mode de vol
local FModeName = {}      -- table nom MODE DE VOL :  largeur max 6 carac
FModeName[0]=model.getFlightMode(0).name-- "Normal"                
  FModeName[1]=model.getFlightMode(1).name-- "Astro"
  FModeName[2]=model.getFlightMode(2).name-- "Grip"
  FModeName[3]=model.getFlightMode(3).name-- "Terre"
  FModeName[4]=model.getFlightMode(4).name-- "Glisse"
  FModeName[5]=model.getFlightMode(5).name-- "Humide"

local TxV -- tension tx         en volt
local Thr -- valeur  channel 2 (throttle)       de -1024 a 1024
local Rbr -- valeur  channel 4 (Frein Arr)       de -1024 a 1024
local St -- valeur  channel 1 (steering)       de -1024 a 1024


local gaz --  pour donne brute gaz
local vol --  pour donne brute volant

local TrimSt -- valeur trim steering de de -4194 a 4194


local sa --  valeur  switch sa   de -1024 a 1024 et 0 en pos centrale


local G2 --  valeur  g2 vitesse gaz  de 0 a 100
local G6 --  valeur  g6 force ABS
local G7 --  valeur  g7 force drag brake
local G8 --  valeur  g8 force SA
local G9 --  valeur  g9 frein arr magnet

local val -- valeur temp
local saval -- valeur switch sa input


local vls58 -- valeur alerte tension TX - ls58

local ls26 -- etat frein ou pas - ls26
local ls27 -- volant neutre ou pas - ls27

local link1 -- qualité signal
local link2 -- qualité signal

local capa  -- en mA/h - variable capacité calculé  
local tab = model.getCurve(4) -- COURBE var 5 (pour stockage variable capa accu)
local memcapa = tab.y -- memcapa[3]  utiliser pour stocker variable caap accu sauvegardé
local memcapatmp = 0

local voltM  -- en mv - variable tension lipo MIN calculé  (utiliser getvalue avec  RXBt-  )

local temp  -- en °C - variable temperature live
local temp2  -- en °C - variable temperature live
local volt  -- en mv - variable tension lipo live
local voltON  -- true si telem transmise 

local voltaff = 0  
local soc =  0

local tempON  -- true si telem transmise 
local tempON2  -- true si telem transmise 










vls58 = model.getLogicalSwitch(57).v2 -- valeur alerte tension TX - ls58





-- fonction dessin:

-- 0= th   1=st    2= br        5 = eclair  6 = C  7 = thermo  8 = timer 9 = chrono  10= ventil   11 =  fleche 12 = compteur vitesse
--  13 = icone abs  14 = icone dr Brake   15 = Abs    16= drg  17 = icone etage frein  18 = icone drag     19 = icone distance    20= icone expo ST     21= icone balance frein Arr

icon_drawers[0] = function(x, y)    
		lcd.drawLine(0+x,0+y,2+x,0+y, SOLID, FORCE)
lcd.drawLine(5+x,3+y,6+x,3+y, SOLID, FORCE)
lcd.drawLine(1+x,1+y,1+x,6+y, SOLID, FORCE)
lcd.drawLine(4+x,0+y,4+x,6+y, SOLID, FORCE)
lcd.drawLine(7+x,0+y,7+x,6+y, SOLID, FORCE)
	
end
icon_drawers[1] = function(x, y)    
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
icon_drawers[2] = function(x, y)    
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

icon_drawers[3] = function(x, y)    
	-- icone alerte
lcd.drawFilledRectangle(0+x, 6+y, 7, 2, FORCE)
lcd.drawFilledRectangle(1+x, 3+y, 5, 3, FORCE)
lcd.drawFilledRectangle(2+x, 1+y, 3, 2, FORCE)
lcd.drawPoint(3+x,0+y)
lcd.drawPoint(3+x,6+y)
lcd.drawLine(3+x,2+y,3+x,4+y, SOLID, ERASE)
	
end



icon_drawers[7] = function(x, y)    
	lcd.drawLine(x+2,y+0,x+3,y+0, SOLID, FORCE)
lcd.drawPoint(x+3,y+2)
lcd.drawPoint(x+3,y+4)
lcd.drawPoint(x+1,y+8)
lcd.drawPoint(x+4,y+8)
lcd.drawLine(x+2,y+9,x+3,y+9, SOLID, FORCE)
lcd.drawLine(x+0,y+6,x+0,y+7, SOLID, FORCE)
lcd.drawLine(x+1,y+1,x+1,y+5, SOLID, FORCE)
lcd.drawLine(x+4,y+1,x+4,y+5, SOLID, FORCE)
lcd.drawLine(x+5,y+6,x+5,y+7, SOLID, FORCE)
	
end
icon_drawers[8] = function(x, y)    
	lcd.drawLine(x+3,y+1,x+5,y+1, SOLID, FORCE)
lcd.drawLine(x+1,y+2,x+2,y+2, SOLID, FORCE)
lcd.drawLine(x+6,y+2,x+7,y+2, SOLID, FORCE)
lcd.drawPoint(x+1,y+3)
lcd.drawPoint(x+7,y+3)
lcd.drawPoint(x+3,y+5)
lcd.drawPoint(x+1,y+7)
lcd.drawPoint(x+7,y+7)
lcd.drawLine(x+1,y+8,x+2,y+8, SOLID, FORCE)
lcd.drawLine(x+6,y+8,x+7,y+8, SOLID, FORCE)
lcd.drawLine(x+3,y+9,x+5,y+9, SOLID, FORCE)
lcd.drawLine(x+0,y+4,x+0,y+6, SOLID, FORCE)
lcd.drawLine(x+4,y+3,x+4,y+5, SOLID, FORCE)
lcd.drawLine(x+8,y+4,x+8,y+6, SOLID, FORCE)
lcd.drawLine(103,56,103,57, SOLID, FORCE)
lcd.drawLine(103,60,103,61, SOLID, FORCE)
lcd.drawText(82, 58, 8-7 , SMLSIZE)
	
end


icon_drawers[11] = function(x, y)    
	lcd.drawPoint(x,y) -- dessin point fleche
	lcd.drawLine(x-1, y+1, x+1, y+1, SOLID, FORCE) -- dessin ligne fleche
		lcd.drawLine(x-2, y+2, x+2, y+2, SOLID, FORCE) -- dessin ligne fleche
	
end

icon_drawers[13] = function(x, y)    
	lcd.drawLine(1+x,y,2+x,y, SOLID, FORCE)
lcd.drawPoint(x,y+1)
lcd.drawPoint(x+3,y+1)
lcd.drawPoint(x,y+6)
lcd.drawPoint(x+3,y+6)
lcd.drawLine(x+1,y+7,x+2,y+7, SOLID, FORCE)
lcd.drawFilledRectangle(x, y+2, 4, 4, SOLID)
	
end
icon_drawers[14] = function(x, y)    
	-- Dr brake 
lcd.drawLine(x,y,x,y+9, SOLID, FORCE)
lcd.drawLine(x+1,y+3,x+1,y+9, SOLID, FORCE)
lcd.drawLine(x+2,y+6,x+2,y+9, SOLID, FORCE)
lcd.drawLine(x+3,y+8,x+3,y+9, SOLID, FORCE)
lcd.drawPoint(x+4,y+9)
	
end
icon_drawers[15] = function(x, y)    
	-- abs
lcd.drawLine(1+x,0+y,2+x,0+y, SOLID, FORCE)
lcd.drawLine(5+x,0+y,7+x,0+y, SOLID, FORCE)
lcd.drawLine(11+x,0+y,12+x,0+y, SOLID, FORCE)
lcd.drawPoint(13+x,1+y)
lcd.drawLine(1+x,3+y,2+x,3+y, SOLID, FORCE)
lcd.drawLine(6+x,3+y,7+x,3+y, SOLID, FORCE)
lcd.drawLine(11+x,3+y,12+x,3+y, SOLID, FORCE)
lcd.drawPoint(10+x,5+y)
lcd.drawLine(5+x,6+y,7+x,6+y, SOLID, FORCE)
lcd.drawLine(11+x,6+y,12+x,6+y, SOLID, FORCE)
lcd.drawLine(0+x,1+y,0+x,6+y, SOLID, FORCE)
lcd.drawLine(3+x,1+y,3+x,6+y, SOLID, FORCE)
lcd.drawLine(5+x,1+y,5+x,5+y, SOLID, FORCE)
lcd.drawLine(8+x,1+y,8+x,2+y, SOLID, FORCE)
lcd.drawLine(8+x,4+y,8+x,5+y, SOLID, FORCE)
lcd.drawLine(10+x,1+y,10+x,2+y, SOLID, FORCE)
lcd.drawLine(13+x,4+y,13+x,5+y, SOLID, FORCE)
	
end
icon_drawers[16] = function(x, y)    
	-- drg
lcd.drawLine(1+x,0+y,2+x,0+y, SOLID, FORCE)
lcd.drawLine(6+x,0+y,7+x,0+y, SOLID, FORCE)
lcd.drawLine(11+x,0+y,12+x,0+y, SOLID, FORCE)
lcd.drawPoint(13+x,1+y)
lcd.drawLine(6+x,3+y,7+x,3+y, SOLID, FORCE)
lcd.drawPoint(7+x,4+y)
lcd.drawLine(12+x,4+y,13+x,4+y, SOLID, FORCE)
lcd.drawPoint(13+x,5+y)
lcd.drawLine(1+x,6+y,2+x,6+y, SOLID, FORCE)
lcd.drawLine(11+x,6+y,12+x,6+y, SOLID, FORCE)
lcd.drawLine(0+x,0+y,0+x,6+y, SOLID, FORCE)
lcd.drawLine(3+x,1+y,3+x,5+y, SOLID, FORCE)
lcd.drawLine(5+x,0+y,5+x,6+y, SOLID, FORCE)
lcd.drawLine(8+x,1+y,8+x,2+y, SOLID, FORCE)
lcd.drawLine(8+x,5+y,8+x,6+y, SOLID, FORCE)
lcd.drawLine(10+x,1+y,10+x,5+y, SOLID, FORCE)
	
end
icon_drawers[17] = function(x, y)    
	-- icone etage frein
lcd.drawLine(10+x,0+y,12+x,0+y, SOLID, FORCE)
lcd.drawPoint(9+x,1+y)
lcd.drawLine(4+x,2+y,8+x,2+y, SOLID, FORCE)
lcd.drawPoint(6+x,5+y)
lcd.drawPoint(9+x,5+y)
lcd.drawLine(5+x,6+y,6+x,6+y, SOLID, FORCE)
lcd.drawLine(9+x,6+y,10+x,6+y, SOLID, FORCE)
lcd.drawPoint(2+x,9+y)
lcd.drawLine(0+x,10+y,1+x,10+y, SOLID, FORCE)
lcd.drawLine(3+x,3+y,3+x,8+y, SOLID, FORCE)
lcd.drawLine(7+x,4+y,7+x,9+y, SOLID, FORCE)
lcd.drawLine(8+x,4+y,8+x,9+y, SOLID, FORCE)
	
end
icon_drawers[18] = function(x, y)    
	-- icone drag
lcd.drawPoint(3+x,0+y)
lcd.drawPoint(2+x,1+y)
lcd.drawPoint(2+x,6+y)
lcd.drawPoint(3+x,7+y)
lcd.drawLine(0+x,3+y,0+x,4+y, SOLID, FORCE)
lcd.drawLine(1+x,3+y,1+x,4+y, SOLID, FORCE)
	
end

icon_drawers[20] = function(x, y)    
	lcd.drawPoint(6+x,5+y)
lcd.drawPoint(5+x,6+y)
lcd.drawLine(3+x,7+y,4+x,7+y, SOLID, FORCE)
lcd.drawLine(1+x,8+y,8+x,8+y, SOLID, FORCE)
lcd.drawLine(0+x,0+y,0+x,8+y, SOLID, FORCE)
lcd.drawLine(7+x,3+y,7+x,4+y, SOLID, FORCE)
lcd.drawLine(8+x,0+y,8+x,2+y, SOLID, FORCE)
	
end
icon_drawers[21] = function(x, y)    
	lcd.drawRectangle(x, y-1, 2, 3, SOLID)
lcd.drawRectangle(x, y+6, 2, 3, SOLID)
lcd.drawRectangle(x+5, y-1, 2, 3, SOLID)
lcd.drawRectangle(x+5, y+6, 2, 3, SOLID)

lcd.drawLine(3+x,y,3+x,7+y, SOLID, FORCE)

lcd.drawPoint(2+x,y)
lcd.drawPoint(4+x,y)
lcd.drawPoint(2+x,7+y)
lcd.drawPoint(4+x,7+y)
	
end


local function drawicon(x, y, z)
    local drawer = icon_drawers[z] -- Récupération directe de la fonction
   
        drawer(x, y) -- Exécution de la fonction
    
end


local function jaugelive(x,y,live)  -- x>200= affiche echelle

if live <-1024 then
live = -1024
end
if live >1024 then
live = 1024
end

if x>200 then
lcd.drawLine(67+16,y-2,111+16,y-2, SOLID, FORCE) -- ligne principale
lcd.drawLine(67+16,y-1,68+16,y-1, SOLID, FORCE)
lcd.drawLine(67+16,y-3,68+16,y-3, SOLID, FORCE)

lcd.drawLine(75+16,y-1,75+16,y-3, SOLID, FORCE)
lcd.drawLine(82+16,y-1,82+16,y-3, SOLID, FORCE)
lcd.drawLine(89+16,y-1,89+16,y-3, SOLID, FORCE)
lcd.drawLine(96+16,y-1,96+16,y-3, SOLID, FORCE)
lcd.drawLine(103+16,y-1,103+16,y-3, SOLID, FORCE)

lcd.drawLine(110+16,y-1,111+16,y-1, SOLID, FORCE)
lcd.drawLine(110+16,y-3,111+16,y-3, SOLID, FORCE)

x=x-200

end


if (live > 50) then
	lcd.drawLine(x, y, x + math.floor(live*22/1024), y, SOLID, FORCE)   -- jauge de 22 pixel avec max steering  de 1024 et debut a
	
else	
	if (live < -50) then
		lcd.drawLine(x- math.floor(-live*22/1024), y,  x , y, SOLID, FORCE)   -- jauge de 22 pixel avec min steering  de - 1024
	else
		lcd.drawPoint(x,y) -- dessin ligne centrale
	end
end


end

 
local function sadiff(a,b,z)   -- z:  1= sadiff    10= sadiff2  3= sadiff3

local inv = 0
if getValue('ls9') > 0 then -- ecart reglage sa
inv = 0+INVERS
end

	if sa ~= 0 then

		if z == 1 or z == 10 then


		if math.floor((a * b /100 - a)*z+0.5)/z > 0 then
		
			lcd.drawText(55, 9, "+" .. math.floor(math.floor((a * b /100 - a)*z+0.5)/z) ,  inv) -- valeur avec sa  corrigé
		
		
		else
			if math.floor((a * b /100 - a)*z+0.5)/z < 0 then
			
			lcd.drawText(56, 9, math.floor(math.floor((a * b /100 - a)*z+0.5)/z) ,  inv) -- valeur avec sa  corrigé
			
				
			else
			
			lcd.drawNumber(62, 9, 0 ,  inv) -- valeur 0
			
		
		
			end
		end

				
		elseif z == 3 then
		if (b-a) > 0 then
		
			lcd.drawText(55, 9, "+" .. (b-a) ,  inv) -- valeur avec sa  corrigé
		
		else
			if (b-a) < 0 then
			
			lcd.drawText(56, 9, (b-a) ,  inv) -- valeur avec sa  corrigé
	
			else
			
			lcd.drawNumber(62, 9, 0 ,  inv) -- valeur 0
		
			end
		end
		end
	end
end



local function mod(x,y,val,z) -- z:  99= dualrate0  9= mod1



	if (val>z) then
			-- dessin 100 pourcent
					
			lcd.drawPoint(0+x,1+y) -- 10
			lcd.drawRectangle(x+1, y, 2, 10, SOLID)
			lcd.drawFilledRectangle(x+4, y, 5, 10, SOLID)
			lcd.drawLine(x+6,y+1,x+6,y+8, SOLID, ERASE) 
			
			if z >9 then
			lcd.drawFilledRectangle(x+10, y, 5, 10, SOLID) -- 0 en pluss
			lcd.drawLine(x+12,y+1,x+12,y+8, SOLID, ERASE) 
			end
			
		else
		lcd.drawNumber(x+1, y-1, val , MIDSIZE) -- valeur DR  
	end

		
end




function shared.run(event)  -- BOUCLE PRINCIPALE -- DEBUT  ---------------------- run is called periodically only when screen is visible





---- touche bascule entre ecran -----------------
 if event == EVT_VIRTUAL_NEXT_PAGE then -- bouton menu 
  playTone(1200, 120,5) -- play tone
    shared.changeScreen(3)
  end
   if event == EVT_VIRTUAL_PREV_PAGE then -- bouton menu 
  playTone(1200, 120,5) -- play tone
    shared.changeScreen(4)
  end
  
 if event == EVT_VIRTUAL_MENU_LONG then -- bouton menu 
  playTone(1200, 120,5) -- play tone
    shared.changeScreen(5)
  end


------ affectation valeur ----------


TxV = getValue('tx-voltage')  -- tension tx
Thr = getValue('ch2')  -- valeur  channel 2 (throttle) 
Rbr = getValue('ch4')  -- valeur  channel 4 (frein arr magnetique) 
St = getValue('ch1')  -- valeur  channel 1 (steering) 
gaz = getValue('ch7') -- valeur channel 7 gaz brute
vol = getValue('ch6') -- valeur channel 6 volant brute

sa = getValue('sa')  -- valeur  switch sa

G2 = getValue('gvar2')/1.024  -- valeur  g2 de 0 a 1000
G6 = getValue('gvar6')  -- valeur  g6 de 0 a 100
G7 = getValue('gvar7')  -- valeur  g7 de -100 a 100
G8 = getValue('gvar8')  -- valeur  g8 de 0 a 150
G9 = getValue('gvar9')  -- valeur  g8 de 0 a 100
TrimSt = getValue('gvar5') -- valeur subtrim steering de -80 a 80 par pas de 1 (GVAR5)


saval = getValue('input12')/10.24  -- valeur  input 12 de switch SA en pourcentage


ls26 = getValue('ls26')-- etat frein ou pas - ls26
ls27 = getValue('ls27')-- volant neutre ou pas - ls27

link1 = getValue('1RSS') -- qualité signal
link2 = getValue('2RSS') -- qualité signal


capa = getSourceValue('Capa+') -- en mA/h - variable capacité calculé

voltM = getSourceValue('Lipo-') -- en mv - variable tension lipo MIN calculé  (utiliser getvalue avec  RXBt-  )

-- la deusieme variable (exemple :tempON) contient true ou false en fcontion de si la telemetrei est transmise ou non
temp, tempON = getSourceValue('Temp') -- en °C - variable temperature live
temp2, tempON2 = getSourceValue('Tmp2') -- en °C - variable temperature live


volt = getSourceValue('Lipo') -- en mv - variable tension lipo live
_ , voltON = getSourceValue('Rlip') -- tension telem transmise


------------ cLIGNOTEMENT -----------
if (getTime() % 100) < 38 then -- clignotement sur 1 seconde
clignot = true
else
clignot = false
end 

-------------- AFFICHAGE sur LCD : -------------------------
lcd.clear()



----  DESSIN FOND ------ DEBUT -- 

-- fond noir

lcd.drawFilledRectangle(0, 0, 54, 17, FORCE)

-- Erase carré manuel:
lcd.drawRectangle(10, 2, 5, 2, ERASE)
lcd.drawRectangle(23, 14, 5, 2, ERASE)
lcd.drawRectangle(25, 9, 4, 2, ERASE)


lcd.drawLine(2,13,3,12, SOLID, ERASE)
lcd.drawLine(4,12,5,13, SOLID, ERASE)
lcd.drawLine(25,11,26,12, SOLID, ERASE)

lcd.drawLine(13,1,14,1, SOLID, ERASE)
lcd.drawLine(11,5,13,5, SOLID, ERASE)
lcd.drawLine(11,7,13,7, SOLID, ERASE)
lcd.drawLine(2,10,5,10, SOLID, ERASE)
lcd.drawPoint(31,10)

lcd.drawPoint(1,11)
lcd.drawPoint(6,11)
lcd.drawPoint(23,11)
lcd.drawPoint(27,11)
lcd.drawLine(3,15,4,15, SOLID, ERASE)
lcd.drawPoint(31,15)

lcd.drawLine(1,3,1,5, SOLID, ERASE)
lcd.drawLine(2,2,2,6, SOLID, ERASE)
lcd.drawLine(3,1,3,7, SOLID, ERASE)
lcd.drawLine(10,4,10,7, SOLID, ERASE)
lcd.drawLine(14,4,14,7, SOLID, ERASE)
lcd.drawLine(24,10,24,13, SOLID, ERASE)

lcd.drawLine(47,12,47,13, SOLID, ERASE)



-- carré manuel
lcd.drawFilledRectangle(31, 10, 16, 6, ERASE)


lcd.drawRectangle(25, 21, 2, 7, SOLID)

lcd.drawLine(104,19,109,19, SOLID, FORCE)
lcd.drawLine(106,22,107,22, SOLID, FORCE)
lcd.drawLine(105,23,108,23, SOLID, FORCE)
lcd.drawLine(103,24,105,24, SOLID, FORCE)
lcd.drawLine(108,24,110,24, SOLID, FORCE)
lcd.drawLine(103,25,104,25, SOLID, FORCE)
lcd.drawLine(109,25,110,25, SOLID, FORCE)
lcd.drawLine(104,26,105,26, SOLID, FORCE)
lcd.drawLine(108,26,109,26, SOLID, FORCE)
lcd.drawPoint(22,27)
lcd.drawLine(106,27,107,27, SOLID, FORCE)



lcd.drawLine(23,26,23,27, SOLID, FORCE)
lcd.drawLine(24,24,24,27, SOLID, FORCE)

lcd.drawLine(102,22,102,23, SOLID, FORCE)
lcd.drawLine(103,20,103,21, SOLID, FORCE)

lcd.drawLine(110,20,110,21, SOLID, FORCE)
lcd.drawLine(111,22,111,23, SOLID, FORCE)


-- fond DR MOD TLM :
lcd.drawFilledRectangle(0, 18, 10, 11, FORCE)
lcd.drawFilledRectangle(0, 30, 10, 11, FORCE)
lcd.drawFilledRectangle(0, 42, 14, 11, FORCE)

lcd.drawLine(4,45,6,45, SOLID, ERASE)
lcd.drawLine(2,46,3,46, SOLID, ERASE)
lcd.drawLine(7,46,8,46, SOLID, ERASE)
lcd.drawLine(2,49,3,49, SOLID, ERASE)
lcd.drawLine(7,49,8,49, SOLID, ERASE)
lcd.drawLine(4,50,6,50, SOLID, ERASE)
lcd.drawLine(1,23,1,24, SOLID, ERASE)
lcd.drawLine(2,22,2,25, SOLID, ERASE)
lcd.drawLine(3,21,3,26, SOLID, ERASE)
lcd.drawLine(5,47,5,48, SOLID, ERASE)
lcd.drawLine(6,21,6,26, SOLID, ERASE)
lcd.drawLine(7,22,7,25, SOLID, ERASE)
lcd.drawLine(8,23,8,24, SOLID, ERASE)

lcd.drawRectangle(1, 47, 2, 2, ERASE)
lcd.drawRectangle(8, 47, 2, 2, ERASE)

lcd.drawLine(3,33,4,32, SOLID, ERASE)
lcd.drawLine(3,34,5,32, SOLID, ERASE)
lcd.drawLine(5,36,7,34, SOLID, ERASE)
lcd.drawLine(6,36,7,35, SOLID, ERASE)
lcd.drawLine(1,37,3,35, SOLID, ERASE)
lcd.drawLine(1,38,4,35, SOLID, ERASE)
lcd.drawLine(2,38,4,36, SOLID, ERASE)





  
  -- cadre pour swith SA
 lcd.drawLine(116-57,0,125-57,0, SOLID, FORCE)
  lcd.drawLine(116-57,6,125-57,6, SOLID, FORCE)
  lcd.drawLine(115-57,1,115-57,5, SOLID, FORCE)
  lcd.drawLine(126-57,1,126-57,5, SOLID, FORCE)

-- vitesse gaz icone :
lcd.drawRectangle(23, 33, 2, 4, SOLID)
lcd.drawFilledRectangle(26, 33, 3, 4, FORCE)
lcd.drawLine(29,30,29,39, SOLID, FORCE)
lcd.drawLine(30,31,30,38, SOLID, FORCE)
lcd.drawLine(31,33,31,36, SOLID, FORCE)
lcd.drawLine(32,34,32,35, SOLID, FORCE)



drawicon(74,0,0) -- th de jauge live

drawicon(13,18,0)
drawicon(13,30,0)

drawicon(74,9,1) -- st de jauge live

drawicon(93,18,1)






----  DESSIN FOND ------ FIN --

-- mode de vol --
	FMode = getFlightMode() -- recup flight mode actuel
	lcd.drawText(17, 1,FModeName[FMode], 0+INVERS) -- texte mode de vol
  

-- link --

lcd.drawLine(8,13,8,15, SOLID, ERASE)
lcd.drawLine(10,12,10,15, SOLID, ERASE)
lcd.drawLine(12,11,12,15, SOLID, ERASE)
lcd.drawLine(14,10,14,15, SOLID, ERASE)






	if ((link1 < -98 and link2 < -98) or link1 == nil  or link1 == 0 ) then 
	lcd.drawLine(8, 13, 8, 14, SOLID, FORCE) -- dessin puissance link  à 1	
	end
	if ((link1 < -90 and link2 < -90)  or link1 == nil or link1 == 0) then 
	lcd.drawLine(10, 12, 10, 14, SOLID, FORCE) -- dessin puissance link  à 2	
	end
	if ((link1 < -80 and link2 < -80)  or link1 == nil or link1 == 0) then 
	lcd.drawLine(12, 11, 12, 14, SOLID, FORCE)  -- dessin puissance link  à 3	
	end
	if ((link1 < -60 and link2 < -60)  or link1 == nil or link1 == 0) then 
	lcd.drawLine(14, 10, 14, 14, SOLID, FORCE)  -- dessin puissance link  à 4	
	end

	
-- Affichage mode volume ou Mute --

if (getValue('ls10') > 0) then --   ls volume ou mute

lcd.drawLine(5,4,7,6, SOLID, ERASE)
lcd.drawPoint(7,4)
lcd.drawPoint(5,6)



end
	

-- FIX GPS ---
gpsData, gpsDataON = getSourceValue('GPS') 
			
lcd.drawPoint(18,15) -- base gps
			
if 	gpsData == nil or gpsData == ""  or gpsDataON == false then	-- verif si valeur gps
		
	else
				
	-- Conversion en int avant addition (très important)
	if math.abs(math.floor(gpsData.lat * 10000000 )) <100 then -- pas de fix
	else -- fix
	 lcd.drawPoint(18,10)
	 lcd.drawPoint(17,11)
	 lcd.drawPoint(19,11)
	 lcd.drawLine(18,12,18,14, SOLID, ERASE)-- FIX GPS
	end
	
	
end
	
	
	
	
	
	
	
-- Jauge tension TX --



if (((TxV-vls58/10)*14/(8.4-vls58/10)) > 2) then
	lcd.drawFilledRectangle(32, 11, math.floor((TxV-vls58/10)*14/(8.4-vls58/10)), 4, FORCE)        -- Jauge tension Tx ( mini recup de LS 58 et 8.4 max) ) jauge de 14 case
	
else

	if getValue('ls58') >0 then -- si alerte tension
	
	
		if clignot == true then -- affiche en clignotant
		lcd.drawRectangle(32, 11, 2, 4) -- affiche barre
		end
	
	

	
	else
	lcd.drawRectangle(32, 11, 2, 4)
	end
end




-- Lap ou Timer enclenché --
if getValue('ls47') >0 then -- si timer enclenché

lcd.drawLine(50,11,52,11, SOLID, ERASE) -- T
lcd.drawLine(51,12,51,15, SOLID, ERASE) -- T

else
	if shared.num >-1 then -- lap enclenché
	lcd.drawLine(50,11,50,15, SOLID, ERASE) -- L
	lcd.drawLine(51,15,52,15, SOLID, ERASE) -- L
	
	end
end


-- SWITCH sa
	lcd.drawLine(118-57,2-sa/512,123-57,2-sa/512, SOLID, FORCE)
		lcd.drawLine(117-57,3-sa/512,124-57,3-sa/512, SOLID, FORCE)
		lcd.drawLine(118-57,4-sa/512,123-57,4-sa/512, SOLID, FORCE)




-- trim steering
if (TrimSt >0) then -- trim positif

	drawicon(89+math.floor((TrimSt*10+13)/13)+16,9+3,11)
		
	lcd.drawNumber(89+12+16, 9+2, math.abs(TrimSt*10) , SMLSIZE) -- valeur trim
	
else
if (TrimSt <0) then  -- trim negatif
	
	drawicon(89+math.ceil((TrimSt*10-13)/13)+16,9+3,11)
				
	lcd.drawNumber(89-20+16, 9+2, math.abs(TrimSt*10) , SMLSIZE) -- valeur trim

else -- trim central
	drawicon(89+16,9+3,11)
		
end
end


-- Affiche horloge heure actuelle --

 if math.floor(getValue('input28')) ~= math.floor(getValue('input29')) then -- verif si volant et gaz pas au milieu
 horl= getTime()

 end



if getTime() > horl +500  then -- verif si volant et gaz pas touché depuis 5 sec
 lcd.drawText(92, 1, getDateTime().hour .. ":" .. getDateTime().min .. ":" .. getDateTime().sec .. "        "  , 0+INVERS)

 

    
   lcd.drawLine(83,6,89,6, SOLID, FORCE)
   lcd.drawLine(83,7,84,7, SOLID, FORCE)
 lcd.drawLine(83,5,84,5, SOLID, FORCE)
 
 lcd.drawPoint(89+16,10)
 
 
 
 else
 
 -- Valeur live throttle --
 jaugelive(105,3,Thr)
 jaugelive(105,4,Thr)
 jaugelive(105,0,gaz)

 -- Valeur live frein Arr magnet --
 jaugelive(105,1,Rbr)
 jaugelive(105,2,Rbr)

-- Valeur live steering --
jaugelive(305,8,St)
jaugelive(105,9,St)
jaugelive(105,10,vol)
 
end


-- Dual rate  throttle --
val = math.floor(getValue('input5')/10.24)  -- valeur  Dualrate throttle  remis a 100

if getValue('ls44') > 0 then -- si mode bouton limiteur dr th
-- avec bouton limiteur DR Th
lcd.drawLine(23,20,31,20, SOLID, FORCE)
lcd.drawLine(29,22,30,22, SOLID, FORCE)
lcd.drawLine(28,23,31,23, SOLID, FORCE)
lcd.drawLine(29,24,29,27, SOLID, FORCE)
lcd.drawLine(30,24,30,27, SOLID, FORCE)
else
-- sans bouton reglage DR th
lcd.drawLine(26,18,26,20, SOLID, FORCE)
end



if (getValue('ls50')>0) then -- valeur ls choix fonction SA1
sadiff (val,saval,1)
val = math.floor(val * saval /100+0.5)
lcd.drawLine(13,26,13+7,26, SOLID, FORCE)
lcd.drawLine(13+2,26+1,13+7-2,26+1, SOLID, FORCE)
end



if model.getOutput(1).max == 1000 then --si PAS mode enfant
mod(34,18,val,99)
else
lcd.drawText(34, 21,"KID", 0) -- texte mode enfant
end


-- Dual rate  brake --
if ls26>0 then -- si on freine
val = math.abs(G6-100)
	drawicon(53,18,15) -- abs
	
else -- si pas frein
drawicon(53,18,2) -- br
drawicon(64,18,14) -- br icon
val = getValue('gvar1') -- dr frein de 0 a 100

	if (getValue('ls51')>0) then -- valeur ls choix focntion sa2
	sadiff (val,saval,1)

	val = math.floor(val * saval /100+0.5)
	lcd.drawLine(53,26,53+8,26, SOLID, FORCE)
	lcd.drawLine(53+2,26+1,53+8-2,26+1, SOLID, FORCE)
	end

	
end

mod(69,18,val,99) -- affiche valeur frein ou Abs

	-- affiche icone ABS :
	
if G6 <100 then
	
	if ls26>0 then -- si on freine
			
			if getValue('ch8') ~= 0 then -- si abs en marche
					
						
					if clignot == true then -- affiche en clignotant
					drawicon(85,19,13) -- affiche icone abs
					end
					
					
					
			end		
					
	else -- si pas frein
	drawicon(85,19,13) -- affiche icone abs
	end
	
end



-- Dual rate  steering --
val = math.floor(getValue('input4')/10.24) -- dualrate steering remis a 100
if (getValue('ls52')>0) then -- ls choix fonction sa 3
sadiff (val,saval,1)

val = math.floor(val * saval /100+0.5)
lcd.drawLine(93,26,93+7,26, SOLID, FORCE)
lcd.drawLine(93+2,26+1,93+7-2,26+1, SOLID, FORCE)
end

mod(113,18,val,99)


-- vitesse gaz
val = math.floor(G2/100 +0.5)

if (getValue('ls53')>0) then -- si choix SA 4

		val = math.floor(G2/100+saval/10 +0.5)
		
		sadiff(math.floor(G2/100 +0.5),val,3)
		
		if val < 0 then
		val = 0
		end
		if val > 10 then
		val = 10
		end
		
	

	lcd.drawLine(14,38,14+7,38, SOLID, FORCE)
	lcd.drawLine(14+2,38+1,14+7-2,38+1, SOLID, FORCE)
end

mod(35,30,val,9)


-- etage frein

if ls26>0 then -- si on freine

	val = G7 -- affiche valeur drag brake
	
	drawicon(51,30,16) -- texte drag brake

		
		if (getValue('ls17')>0) then -- si choix sa 8
	
	sadiff(val,saval,1)

	val = math.floor(val * saval /100+0.5)
	lcd.drawLine(51,38,64,38, SOLID, FORCE) -- ligne selection MOD
	lcd.drawLine(51+2,38+1,64-2,38+1, SOLID, FORCE) -- ligne selection MOD
	end
	
	if val > 4 then -- affiche icone drag brake si sup a 4
	drawicon(84,31,18) -- icone drag brake
	else
	val = 0 -- affiche 0 si G7 = 4
	end
	
mod(67,30,val,99) --  affiche drag brake

else -- si on freine pas
	val = getValue('gvar3')/10  -- valeur  g3 de 0 a 10

	if (getValue('ls54')>0) then -- si choix sa 5
	sadiff(val,saval,10)

	val = math.floor(val * saval /100+0.5)
	lcd.drawLine(51,38,51+8,38, SOLID, FORCE) -- ligne selection MOD
	lcd.drawLine(51+2,38+1,51+8-2,38+1, SOLID, FORCE) -- ligne selection MOD
	end
	
	if (getValue('ls17')>0) then -- si choix sa 8
	sadiff(G7,saval,1)
	G7 = math.floor(G7 * saval /100+0.5) -- correction G7
	
	end
	
	
	if G7 > 4 then -- affiche icone drag brake si sup a 4
	
	if getValue('ls43') > 0 and getValue('ch19') ~= 0  then -- ICI SI L43 > 0 (etat neutre)  AND ch19 ~= 0 THEN faire clignoter ELSE fixe
	    
		if clignot == true then -- affiche en clignotant
		drawicon(84,31,18) -- affiche icone drag brake
		end
		
		
						
					
		else
		drawicon(84,31,18) -- affiche icone drag brake
	end
	
	end

drawicon(51,30,2) -- texte br
drawicon(59,30,17) -- icone etage frein
mod(74,30,val,9) -- afiche mod etage frein
end



-- expo steering

if ls27>0 then -- si volant pas au neutre

		
		drawicon(98,30,1) -- icone texte ST
		drawicon(108,31,20) -- icone expo ST
		
		val = getValue('gvar4')/7 -- pour que valeur G4 0 a 70 apparaisse de 0 a 10

		 
		if (getValue('ls55')>0)  then -- si choix sa 6

					if  saval ~= 0	then
				sadiff(val,val-saval/math.abs(saval)*math.floor(G8/5+0.5)/10,3)
				
				val = val-saval/math.abs(saval)*math.floor(G8/50+0.5)
				
				if val < 0 then
				val = 0
				end
				if val > 10 then
				val = 10
				end
					end
		lcd.drawLine(98,38,98+7,38, SOLID, FORCE)
		lcd.drawLine(98+2,38+1,98+7-2,38+1, SOLID, FORCE)
		end

		if (getValue('ls28')>0)  then -- si choix sa 7
					
		sadiff(G9,saval,1)
		
		end


		mod(118,30,val,9)

else -- si volant au neutre

		val = G9 -- affiche valeur g9 frein Arr
		
		drawicon(94,30,2) -- icone texte BR
		drawicon(105,31,21) -- icone balance frein Arr

		
	if (getValue('ls28')>0)  then -- si choix sa 7
					
	sadiff(val,saval,1)

	val = math.floor(val * saval /100+0.5)
		lcd.drawLine(94,38,94+8,38, SOLID, FORCE)
		lcd.drawLine(94+2,38+1,94+8-2,38+1, SOLID, FORCE)
	end

	mod(113,30,val,99) -- affiche valeur G9
end





---- touche ROTARY -----------------
if modif == 1 then -- si en mode modif
-- bloque pag
	else -- sinon change ecran


	  
	if event == EVT_VIRTUAL_PREV then -- bouton rotary 
		
	playTone(1200, 120,5) -- play tone
	shared.changeScreen(12)
	
	  end
  
end






-------- ECRAN 1 TELEM   -------

lcd.drawRectangle(11, 49, 2, 3, ERASE)



-- icone capa :
lcd.drawFilledRectangle(16, 42, 5, 11, SOLID)
lcd.drawLine(17,41,19,41, SOLID, FORCE)
lcd.drawPoint(16,52)
lcd.drawPoint(20,52)




lcd.drawText(96, 45, "M" , 0)
lcd.drawLine(102,46,102,51, SOLID, FORCE) -- I
lcd.drawText(104, 46, "N" , SMLSIZE)
lcd.drawPoint(109,48)
lcd.drawPoint(109,51)
drawicon(0,54,7)
drawicon(72,54,8)



-- tps de roulage venant de timer 1
lcd.drawNumber(88, 53, math.floor(model.getTimer(0).value/60) , MIDSIZE ) -- minute tps ecoulé timer 1
lcd.drawNumber(106, 53, math.floor(math.fmod(model.getTimer(0).value,60)) , MIDSIZE ) -- seconde tps ecoulé timer 1


-- icone tension lipo
lcd.drawLine(56,45,59,42, SOLID, FORCE)
lcd.drawLine(58,46,62,42, SOLID, FORCE)
lcd.drawLine(55,52,59,48, SOLID, FORCE)
lcd.drawLine(58,52,61,49, SOLID, FORCE)
lcd.drawLine(60,42,61,42, SOLID, FORCE)
lcd.drawLine(59,46,61,46, SOLID, FORCE)
lcd.drawLine(56,48,58,48, SOLID, FORCE)
lcd.drawLine(56,52,57,52, SOLID, FORCE)
lcd.drawLine(55,46,55,48, SOLID, FORCE)
lcd.drawLine(62,46,62,48, SOLID, FORCE)





-- affiche tension LIPO Live
if volt == nil or voltON == false then
	lcd.drawText(65, 41, " ...." , BLINK)-- affiche vide tiret clignotant
	
	
	
	else
	
	if volt > 4800 and volt < 5500 then -- si telem hobywing perdu = esp32 envoie 5000
		lcd.drawText(65, 41, " ...." , BLINK)-- affiche vide tiret clignotant
	else
	
		if volt<4400 then
		voltaff = volt
		end
		
		
	   soc = ((0.0000008594 * voltaff - 0.0105397052) * voltaff + 43.2187106) * voltaff - 59169.326 -- calcul pourcentage a partir de tension (le 0% represente encire 20 % dans batterie donc safe)
	   soc = 9*soc/100 -- jauge de 9 barres

	  
			if soc > 0 then 
		lcd.drawLine(57,51,58,51, SOLID, FORCE) -- Jauge
		end
			if soc > 1 then 
		lcd.drawLine(58,50,59,50, SOLID, FORCE) -- Jauge
		end
			if soc > 2 then 
		lcd.drawLine(59,49,60,49, SOLID, FORCE) -- Jauge
		end
			if soc > 3 then 
		lcd.drawLine(60,48,61,48, SOLID, FORCE) -- Jauge
		end
			if soc > 4 then 
		lcd.drawLine(56,47,61,47, SOLID, FORCE) -- Jauge
		end
			if soc > 5 then 
		lcd.drawLine(56,46,57,46, SOLID, FORCE) -- Jauge
		end
			if soc > 6 then 
		lcd.drawLine(57,45,58,45, SOLID, FORCE) -- Jauge
		end
			if soc > 7 then 
		lcd.drawLine(58,44,59,44, SOLID, FORCE) -- Jauge
		end
			if soc > 8 then 
		lcd.drawLine(59,43,60,43, SOLID, FORCE) -- Jauge
		end
			
		
		

	  


		
		
		
			if getValue('ls59') >0 then -- si alerte tension lipo clignote
			
			if clignot == true then -- affiche en clignotant
			drawicon(65+2, 41+2, 3) -- icone alerte
			else
			lcd.drawNumber(65, 41, math.floor(voltaff/10+0.5) , MIDSIZE+PREC2) -- valeur tension lipo 3900mv format  affiché 3.90 V
			lcd.drawPoint(lcd.getLastRightPos()-1,42) --V
		lcd.drawPoint(lcd.getLastRightPos()+2,42) --V
		lcd.drawText(lcd.getLastRightPos()-1, 43, "V" , SMLSIZE)
			end
			
			
			
			else
			lcd.drawNumber(65, 41, math.floor(voltaff/10+0.5) , MIDSIZE+PREC2)
			lcd.drawPoint(lcd.getLastRightPos()-1,42) --V
		lcd.drawPoint(lcd.getLastRightPos()+2,42) --V
		lcd.drawText(lcd.getLastRightPos()-1, 43, "V" , SMLSIZE)
			end
		
		
		
	
	end
	
end  




-- affiche tension LIPO MINI
if voltM == nil then
	-- affiche vide
	else
	
	if voltM < 4800 then
	
	

		
		if getValue('ls31')>0 then -- si alerte lipo min a eu lieu durant session
			if clignot == true then -- affiche en clignotant
			drawicon(112+2, 41+2, 3) -- icone alerte
			else
			lcd.drawNumber(112, 41, math.floor(voltM/100+0.5) , MIDSIZE+PREC1) -- valeur tension MINI lipo 3900mv format 32 V affiché 3.2 V  
			end
		else
			lcd.drawNumber(112, 41, math.floor(voltM/100+0.5) , MIDSIZE+PREC1) -- valeur tension MINI lipo 3900mv format 32 V affiché 3.2 V  
		end
	
	end
end











-- modif capa accu
if modif == 0 then



-- affiche capacité 
if capa == nil then
	-- affiche vide
	lcd.drawFilledRectangle(17, 43, 3, 9,ERASE) -- Jauge vide
	else
			

			if capa > (0.8*memcapa[3]*100) then
			lcd.drawFilledRectangle(17, 43, 3, 9,ERASE) -- Jauge vide
			
				if clignot == true then -- affiche en clignotant
				drawicon(23+2, 41+2, 3) -- icone alerte
				else
				lcd.drawNumber(23, 41, math.floor(capa/100+0.5) , MIDSIZE+PREC1) -- valeur courant   5230 mah format  affiché 5.23 Ah 
				lcd.drawText(lcd.getLastRightPos()-1, 43, "H" , SMLSIZE) -- A
				lcd.drawLine(lcd.getLastRightPos()-4,42,lcd.getLastRightPos()-3,42, SOLID, FORCE)  -- A
				lcd.drawText(lcd.getLastRightPos(), 43, "H" , SMLSIZE)	
				end
			
			
			else
			lcd.drawFilledRectangle(17, 43, 3, math.floor(9*(capa/(0.8*memcapa[3]*100))),ERASE) -- Jauge 
			
				lcd.drawNumber(23, 41, math.floor(capa/100+0.5) , MIDSIZE+PREC1) -- valeur courant   5230 mah format  affiché 5.23 Ah 
				lcd.drawText(lcd.getLastRightPos()-1, 43, "H" , SMLSIZE) -- A
				lcd.drawLine(lcd.getLastRightPos()-4,42,lcd.getLastRightPos()-3,42, SOLID, FORCE)  -- A
				lcd.drawText(lcd.getLastRightPos(), 43, "H" , SMLSIZE)				
			end

end



	if ( event == EVT_VIRTUAL_ENTER and (getTime() - rebound) > 20 ) then -- bouton rotary ENTER
	playTone(1200, 120,5) -- play tone
		rebound = getTime()
	

		   modif = 1
		memcapatmp = memcapa[3]
	   
	end
end


if modif == 1 then

-- affiche icone C capa accu
lcd.drawLine(18,45,19,45, SOLID, ERASE) -- C
lcd.drawLine(18,49,19,49, SOLID, ERASE) -- C
lcd.drawLine(17,46,17,48, SOLID, ERASE) -- C



---- touche ROTARY -----------------
if event == EVT_VIRTUAL_NEXT then -- bouton rotary 

    memcapatmp = memcapatmp+1
	if (memcapatmp >99) then
	memcapatmp =99
	else
	playTone(1200, 50,5) -- play tone
	end
  end

if event == EVT_VIRTUAL_PREV then -- bouton rotary 

    memcapatmp = memcapatmp-1
	if (memcapatmp <2) then
	memcapatmp =2
	else
	playTone(1200, 50,5) -- play tone
	end
  end


	if ( event == EVT_VIRTUAL_ENTER and (getTime() - rebound) > 20 ) then -- bouton rotary ENTER
	playTone(1200, 120,5) -- play tone
		rebound = getTime()
	
		-- assigne valeur memcapa et save dans courbe VAR
		 tab = model.getCurve(4) -- COURBE var 5 (pour stockage variable capa accu)

	 memcapa = tab.y
	 memcapa[3] = memcapatmp
	 tab.y = memcapa
	 model.setCurve(4,tab)  -- sauvegarde valeur dans courbe 5
		
		
		
	   modif = 0
	   
	   
	end
	
	
	lcd.drawNumber(23, 41, math.floor(memcapatmp+0.5) , MIDSIZE+PREC1+INVERS) -- valeur capa accu   5200 mah format  affiché 5.2 Ah 
lcd.drawText(lcd.getLastRightPos(), 43, "H" , SMLSIZE) -- A
lcd.drawLine(lcd.getLastRightPos()-4,42,lcd.getLastRightPos()-3,42, SOLID, FORCE)  -- A
lcd.drawText(lcd.getLastRightPos(), 43, "H" , SMLSIZE)
	
	
end





















-- affiche temperatureS LIVE

lcd.drawText(7, 58, "M" , SMLSIZE)






if temp == nil or tempON == false then
	lcd.drawText(14, 53, " ...." , BLINK)-- affiche vide tiret clignotant
	else
		
			if volt > 4800 and volt < 5500 then -- si telem hobywing perdu = esp32 envoie 5000
		lcd.drawText(14, 53, " ...." , BLINK)-- affiche vide tiret clignotant
	else
		if getValue('ls60')>0 then -- si alerte temperature clignote
		
		if clignot == true then -- affiche en clignotant
		
		drawicon(14+2, 53+2, 3) -- icone alerte
		else
		lcd.drawNumber(14, 53, math.floor(temp+0.5) , MIDSIZE) -- valeur    temperature 
		lcd.drawPoint(lcd.getLastRightPos()-1,56)
		lcd.drawPoint(lcd.getLastRightPos()+1,56)
		lcd.drawLine(lcd.getLastRightPos()-1,55,lcd.getLastRightPos()+1,55, SOLID, FORCE)
		lcd.drawLine(lcd.getLastRightPos()-1,57,lcd.getLastRightPos()+1,57, SOLID, FORCE)
		end
		
		
		
		else
		lcd.drawNumber(14, 53, math.floor(temp+0.5) , MIDSIZE)
		lcd.drawPoint(lcd.getLastRightPos()-1,56)
		lcd.drawPoint(lcd.getLastRightPos()+1,56)
		lcd.drawLine(lcd.getLastRightPos()-1,55,lcd.getLastRightPos()+1,55, SOLID, FORCE)
		lcd.drawLine(lcd.getLastRightPos()-1,57,lcd.getLastRightPos()+1,57, SOLID, FORCE)
		end
		
	end

end

lcd.drawText(40, 58, "E" , SMLSIZE)

if temp2 == nil or tempON2 == false then
	lcd.drawText(46, 53, " ...." , BLINK)-- affiche vide tiret clignotant
	else
	
	
			if volt > 4800 and volt < 5500 then -- si telem hobywing perdu = esp32 envoie 5000
		lcd.drawText(46, 53, " ...." , BLINK)-- affiche vide tiret clignotant
	else
		if getValue('ls40')>0 then -- si alerte temperature clignote
		
		if clignot == true then -- affiche en clignotant
		
		drawicon(46+2, 53+2, 3) -- icone alerte
		else
		lcd.drawNumber(46, 53, math.floor(temp2+0.5) , MIDSIZE) -- valeur    temperature 
				lcd.drawPoint(lcd.getLastRightPos()-1,56)
		lcd.drawPoint(lcd.getLastRightPos()+1,56)
		lcd.drawLine(lcd.getLastRightPos()-1,55,lcd.getLastRightPos()+1,55, SOLID, FORCE)
		lcd.drawLine(lcd.getLastRightPos()-1,57,lcd.getLastRightPos()+1,57, SOLID, FORCE)
		end
		
		
		
		else
		lcd.drawNumber(46, 53, math.floor(temp2+0.5) , MIDSIZE)
				lcd.drawPoint(lcd.getLastRightPos()-1,56)
		lcd.drawPoint(lcd.getLastRightPos()+1,56)
		lcd.drawLine(lcd.getLastRightPos()-1,55,lcd.getLastRightPos()+1,55, SOLID, FORCE)
		lcd.drawLine(lcd.getLastRightPos()-1,57,lcd.getLastRightPos()+1,57, SOLID, FORCE)
		end
		

	end
		
end







-- page:
lcd.drawNumber(123, 56,"1", 0+INVERS) -- texte numero page
	
--popup new session
if (shared.pop  == 1 ) then -- si reset session
	lcd.drawFilledRectangle(15, 20, 98, 23, ERASE)
	lcd.drawRectangle(17, 22, 94, 19, FORCE)
	lcd.drawText(21, 28, "Nouvelle Session" , 0)
end





end ------------------ BOUCLE PRINCIPALE -- FIN -----

