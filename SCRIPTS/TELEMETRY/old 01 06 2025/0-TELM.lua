-- Main telemetry script


-- This is the manager script
-- Here will be the added variables
-- Screen Manager
local shared = { }   
shared.screens = {
"/SCRIPTS/TELEMETRY/0-M1S.lua",
  "/SCRIPTS/TELEMETRY/0-M1.lua",
  "/SCRIPTS/TELEMETRY/0-M2.lua",
  "/SCRIPTS/TELEMETRY/0-M3.lua",
  "/SCRIPTS/TELEMETRY/0-M4S.lua",
  "/SCRIPTS/TELEMETRY/0-M4.lua",
  "/SCRIPTS/TELEMETRY/0-M5.lua",
  "/SCRIPTS/TELEMETRY/0-M6.lua",
  "/SCRIPTS/TELEMETRY/0-M7.lua",
  "/SCRIPTS/TELEMETRY/0-M8.lua"
}



-- variables:
local fich1 = "/SCRIPTS/TELEMETRY/" .. string.sub(model.getInfo().name,1,1) .. "-log.txt"

local lap = 60000-- pour stocker tps tour
local num = -1 -- numero du tour
local lapold = 0 -- pour stocker ancien tps 
local stock = 0 -- variable stockage temps repetition enregistrement log SD card
local tim1 -- variable timer 1
local tim3 -- variable timer 3
local mini = 60000 -- tour mini
local mina = 0 -- 
local ses = 1 -- session lancer
local dire = -1 -- annonce tps tour
local sc --  valeur  switch sc   de -1024 a 1024 

local slow = 0 -- viteses gaz

local capa = 0 -- en mA/h - variable capacité calculé
local tempM = 0 -- en °C - variable temperature MAX calculé
local voltM = 0 -- en mv - variable tension lipo MIN calculé  (utiliser getvalue avec  RXBt-  )
local courantM = 0  -- en mA - variable courant max
local dist = 0 -- distance

local volt = 0  -- en mv - variable tension lipo live
local voltON  -- true si telem transmise 

local oldI13 = math.floor(getValue('input13')/10.24) -- valeur reglage vitesse gaz
local I13 = oldI13

local pop1 = 0 -- variable stockage temps pour popup
local dent
dent = model.getLogicalSwitch(7).v2 -- nb de dent pignon moteur stocké dans LS08
setTelemetryValue(0x0020, 0, 0, dent) -- note nombre de dent pour log


local tab = model.getCurve(4) -- COURBE var 5 (pour stockage variable potar)
local var = tab.y -- var[1]  utiliser pour stocker variable 

local sens = 0 -- sensor a ajouter a dist et Capa
setTelemetryValue(0x0021, 0, 0, 0) -- remettre fake sensor distance a 0
setTelemetryValue(0x0022, 0, 0, 0) -- remettre fake sensor capa a 0		
		
		
		
-- Screen Manager
function shared.changeScreen(ecran)
  shared.current =  ecran

  local chunk = loadScript(shared.screens[shared.current])
  chunk(shared)
end



local function decal()


local file = io.open(fich1, "a") -- ouvrir fichier 0-log.txt en acces ecriture et en preservant son contenu

-- verif si session pas vide (avec tps session pas vide sinon ne decale pas
	local file = io.open(fich1, "r") -- ouvrir fichier 0-log.txt en acces lecture
		local curs = io.seek(file,9) --  positionner curseur dans fichier log
		local li = io.read (file, 4) -- lire 4 carac de  dans fichier log et asssigner a temp
		io.close(file) -- fermer fichier log

		li = tostring(li)  -- convertir en string	
		li = string.gsub(li,"x","")  -- enlever les xx 
		if (li=="") then -- variable non assigné
			li = "0"  -- mettre variable a zero
		end
		li = tonumber(li) -- convertir en nombre
		
	

if (li>0) then
			for i = 89,0,-1 do -- parcourir les 90 sessions en commencant par 89

				 for j = 1,4 do -- copier par bloc de 44 carac (4*44 = 176 : sequence complete )

					local file = io.open(fich1, "r") -- ouvrir fichier 0-log.txt en acces lecture
					local curs = io.seek(file,1+(j-1)*44 + i*176 ) --  positionner curseur dans fichier log
					local temp = io.read (file, 44) -- lire 26 carac de  dans fichier log et asssigner a temp
					io.close(file) -- fermer fichier log
					
					local file = io.open(fich1, "a") -- ouvrir fichier 0-log.txt en acces ecriture et en preservant son contenu
					local curs = io.seek(file, 1+(j-1)*44 + 176 + i*176) --  positionner curseur dans fichier log decaler a session suivante
					local ecri = io.write (file, temp) -- ecri 26 carac   dans fichier log
					io.close(file) -- fermer fichier log
				end

			end
end



local file = io.open(fich1, "a") -- ouvrir fichier 0-log.txt en acces ecriture et en preservant son contenu

local curs = io.seek(file,1 ) --  positionner curseur debut log

for i = 1,4 do
local ecri = io.write (file, "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx") -- remplir de x carte sd session 1 par bloc de 44
end
	
	local curs = io.seek(file,1 ) --  positionner curseur debut log
	local ecri = io.write (file, getDateTime().day ) -- jour
	local curs = io.seek(file,3 ) --  positionner curseur debut log
	local ecri = io.write (file, getDateTime().mon ) -- mois
	local curs = io.seek(file,5 ) --  positionner curseur debut log
	local ecri = io.write (file, getDateTime().hour ) -- huere
	local curs = io.seek(file,7 ) --  positionner curseur debut log
	local ecri = io.write (file, getDateTime().min ) -- min
	

io.close(file) -- fermer fichier log

end

local function form(x,y) -- y = valeur de division
x = tonumber(x)
		x = math.floor(x/y+0.5)  --  converti mV en centiV  (3200 devient 320)
		x = tostring(x)  -- convertir en string  
		
		if (#x==1) then -- nombre a 1 chiffre
			x = "xx" .. x  -- completer pour 3 carac 
			
			elseif (#x==2) then -- si = 2
			x = "x" .. x  -- completer pour 3 carac 
				
			elseif (#x>3) then -- si = 4 ou plus
			x = "999"   -- completer pour 3 carac
			
		end
		
		return x
end


local function init()

 decal() -- on decale les entrées de la carte sd

shared.strt = 0 -- init telco menu 1S
shared.ls13 = model.getLogicalSwitch(12).v2 -- recup tps lap mini
shared.bip = model.getLogicalSwitch(12).duration -- bip tps mini activation si = 5
shared.pop = 2

  shared.current = 1
  shared.changeScreen(1)
end



local function run(event)
  shared.run(event)
end



local function background()

	
-- ========== RECUP VALEUR SENSOR ==========
tim3 = model.getTimer(2).value -- recup valeur timer 3 pour reset
-- pour temps tour
sc = getValue('input14') -- valeur switch sc entree 14


	if (tim3>3) then 
	
		ses =0
				
	end
	
	if (tim3<2 and ses ==0) then -- variable timer 3 a 0 (ce qui veut dire debut de SESSION 
		 lap = 60000-- pour stocker tps tour
		 num = -1 -- numero du tour
		 lapold = 0 -- pour stocker ancien tps 
		 mini = 60000 -- tour mini
		 mina = 0 -- 
		
		-- reset les sensor telemetrie =   Volt  Curr   Temp    Capa   Rpm
		model.resetSensor(10) -- sensor 11
		model.resetSensor(11) -- sensor 12
		model.resetSensor(12) -- sensor 13
		model.resetSensor(13)
		model.resetSensor(15)
		model.resetSensor(16)
		model.resetSensor(17)
		model.resetSensor(18)
		model.resetSensor(19)
		model.resetSensor(20)
		model.resetSensor(21)
		model.resetSensor(22)
		model.resetSensor(23)
		setTelemetryValue(0x0021, 0, 0, 0) -- remettre fake sensor distance a 0
		setTelemetryValue(0x0022, 0, 0, 0) -- remettre fake sensor capa a 0
	
		ses =1
		decal() -- on decale les entrées de la carte sd
		
		shared.pop = 1 -- variable partagé -- variable pour afficher popup
		pop1 = getTime()
		
	end

	
-- pour temps tour :

if ( sc > 1 or (getValue('ls13') > 0 and num>-1) ) and  ( (getTime() - lapold) > shared.ls13 * 100 )  then -- si appui bouton tps tour et superieur a  (model.getLogicalSwitch(12).v2)  lap mini stocké dans Ls13 seconde depuis dernier appui ou automatique avec ls13

lap = getTime() - lapold -- assigner tps tour
dire = lap
mina= 1
lapold = getTime()

		if (num>-1) then
		
			if (lap<mini) then
		mini = lap
		playTone(1200, 400,20,0,2) -- play tone meilleur tour
		else
		playTone(2000, 150,20) -- play tone aigu
		end
		

	

		-- copie lap sur carte sd :

				if (num<23) then -- si tour sup a 23 on nenregistre plus sur sd

					-- formater lap :
						lap = string.format("%06d", lap)
						lap = string.gsub(lap, "^0", "x")

					local file = io.open(fich1, "a") -- ouvrir fichier 0-log.txt en acces ecriture et en preservant son contenu


					-- lap :
						local curs = io.seek(file, 33+num*6) --  positionner curseur dans fichier log
						local ecri = io.write (file, lap) -- tps de roulage - ecri 6 carac de lap dans fichier log


					io.close(file) -- fermer  fichier log

				end
				
		else  -- si numero de tour debut
		playTone(2000, 150,20) -- play tone aigu
		dire = 0

		end

num = num+1-- ajoute 1 au num de tour
end


if (num>-1) then -- faire bipper au moment meilleur tour et annonce tour avec retard
		

		if (getTime()> (lapold + mini) and mina==1) then
		
		if shared.bip == 5 then -- si bip alert best lap activé
			playTone(900, 350,20) -- play tone grave
		end
		
		mina = 0
		end
		
		if dire ~= -1 and (getTime() - lapold) > 250 then -- apres 2.5 sec
			playNumber(math.floor(dire/10),0, PREC1)  -- lire nombre avec 1 decimale si 123 il lit 12.3
			dire = -1
		end
end


-- fin tps tour
	
	
	
	-- stokage valeur carte SD
if (getTime()> (5*100+ stock) ) then -- A FAIRE TOUTE LES :    5*100 x 10ms = 5s
			

dent = model.getLogicalSwitch(7).v2 -- nb de dent pignon moteur stocké dans LS08
setTelemetryValue(0x0020, 0, 0, dent) -- note nombre de dent pour log
	
	-- ======== FORMATAGE VALEUR SENSOR ==============
	
		-- tps de roulage :
		
		tim1 = model.getTimer(0).value -- recup valeur timer 1 pour tps de roulage - en seconde
		
		if (tim1==nil) then -- variable non assigné 
		tim1 = "0"  -- mettre variable a zero
		end
		
		tim1 = string.format("%04d", tim1) -- formater 4 carac
		tim1 = string.gsub(tim1, "^0", "x")
		
	
			
-- capteur en live recu recepteur CRSF

voltM = getSourceValue('Lipo-')  -- tension: recup valeur de sensor CRSF : tension mini
tempM = getSourceValue('Temp+')  -- temperature maxi : HACKED recup valeur de sensor CRSF : capacité
capa = getSourceValue('Capa+')  -- capacité : custom sensor Cap de EdgeTX: valeur capacité avec consumpt de Curr
dist = getSourceValue('dist+')  -- distance sur 2 chiffre
volt, voltON = getSourceValue('Lipo') -- en mv - variable tension lipo live
courantM  = getSourceValue('Curr+') -- en ma - variable courant maximum


	------------- tension live lipo -------------
		if (volt==nil) then -- variable non assigné 
		volt = 0  -- mettre variable a zero
		end
		volt = form(volt,10)


	------------- tension mini lipo -------------
		if (voltM==nil) then -- variable non assigné 
		voltM = 0  -- mettre variable a zero
		end
		voltM = form(voltM,10)


------------- temperature max -------------
		
		if (tempM==nil) then -- variable non assigné 
		tempM = 0  -- mettre variable a zero
		end
		tempM = form(tempM,1)


	------------- capacité conso -------------
		if (capa==nil) then -- variable non assigné 
		capa = 0  -- mettre variable a zero
		end
		capa = form(capa,10) -- en centiAh
		
	------------- courant max -------------
		if (courantM==nil) then -- variable non assigné 
		courantM = 0  -- mettre variable a zero
		end
	courantM = form(courantM,1000)

	------------- distance -------------
		if (dist==nil) then -- variable non assigné 
		dist = 0  -- mettre variable a zero
		end
		
		dist=math.floor(dist*dent*1/2) -- convertir en prenant nb de dent
		dist = form(dist,1) -- en dizaine de m
		
		
	-- ====================================	
		
		
	local file = io.open(fich1, "a") -- ouvrir fichier 0-log.txt en acces ecriture et en preservant son contenu

	-- ======== ECRITURE SD ==============
	
	-- tps roulage :
		local curs = io.seek(file, 9) --  positionner curseur dans fichier log
		local ecri = io.write (file, tim1) -- tps de roulage - ecri 4 carac de tim1 dans fichier log
		
	-- tension lipo mini :
		local curs = io.seek(file, 13) --  positionner curseur dans fichier log
		local ecri = io.write (file, voltM) -- ecri 3 carac dans fichier log

-- temperature max :
		local curs = io.seek(file, 19) --  positionner curseur dans fichier log
		local ecri = io.write (file, tempM) -- ecri 3 carac dans fichier log

-- capacité conso :
		local curs = io.seek(file, 16) --  positionner curseur dans fichier log
		local ecri = io.write (file, capa) -- ecri 3 carac dans fichier log

	-- tension lipo live :
		if voltON == true then
				local curs = io.seek(file, 22) --  positionner curseur dans fichier log
				local ecri = io.write (file, volt) -- ecri 3 carac dans fichier log
		end

-- distance :
		local curs = io.seek(file, 28) --  positionner curseur dans fichier log
		local ecri = io.write (file, dist) -- ecri 3 carac dans fichier log
		
	-- courant max :
		local curs = io.seek(file, 25) --  positionner curseur dans fichier log
		local ecri = io.write (file, courantM) -- ecri 3 carac dans fichier log

	-- ========================================


	io.close(file) -- fermer fichier log

	
	
	
-- sauvegarde valeur potar	
if shared.pop < 2 then -- si PAS premier lancement

	 var[1] = math.floor(getValue('input4')/10.24+0.5) -- valeur potar P1
	 var[2] = math.floor(getValue('input5')/10.24+0.5) -- valeur potar P2
	 tab.y = var
	 model.setCurve(4,tab)  -- sauvegarde valeur dans courbe 5
	
end

		
		
	
stock =  getTime() -- init tps
end






-- Gestion des capa et dist Si ESP32 a Planté et Reset
if getSourceValue('disL') == 0 and getSourceValue('CapL') == 0 then

	sens = getSourceValue('dist+')
	setTelemetryValue(0x0021, 0, 0, sens ) -- remettre fake sensor distance a ancienne valeur afin de lajouter a disL (live)
	
	sens = getSourceValue('Capa+')
	setTelemetryValue(0x0022, 0, 0, sens ) -- remettre fake sensor capa a ancienne valeur afin de lajouter a CapL (live)
	
end


-- remet la meme valeur dans sensor afin de les conserver actif (avec asterisque)
sens = getSourceValue('disF') 
setTelemetryValue(0x0021, 0, 0, sens )
sens = getSourceValue('CapF')
setTelemetryValue(0x0022, 0, 0, sens )
	
	
	
	
	
	
	
-- différentes Vitesses des GAZ gerer avec Input13 G2
I13 = math.floor(getValue('input13')/10.24)

if I13 ~= oldI13 then -- si réglage valeur Input 13 G2 vitesse gaz a changé
	
	if I13 < 5 then -- vitesse instant donc rien faire
	elseif I13 < 15 then
	slow = 6
	elseif I13 < 25 then
	slow = 15
	elseif I13 < 35 then
	slow = 25
	elseif I13 < 45 then
	slow = 39
	elseif I13 < 55 then
	slow = 55
	elseif I13 < 65 then
	slow = 73
	elseif I13 < 75 then
	slow = 93
	elseif I13 < 85 then
	slow = 110
	elseif I13 < 95 then
	slow = 130
	elseif I13 > 94 then
	slow = 160
end
	
	
model.deleteMix(26, 1) -- suppr ligne 2 de channel 27
local tab = model.getMix(26, 0) -- copier ligne 1
tab.speedUp = slow -- modif time de ligne copier
tab.multiplex = 2 -- remplacer channel
model.insertMix(26, 1, tab) -- copier une ligne de mix et la coller dans ligne 2

oldI13 = I13 -- assigne nouvelle valeur viteses gaz
end

	
	
	



-- pour vérif potar pas bougé :
if shared.strt == 0 then -- si premier lancement

	if var[1] > getValue('input4')/10.24 +1.5 or var[1] < getValue('input4')/10.24 -1.5 or var[2] > getValue('input5')/10.24 +1.5 or var[2] < getValue('input5')/10.24 -1.5 or getValue('sa') ~= 0 then -- si potar P1 déregler de pluss de 2
	shared.pop = 5+var[1]*10 + var[2]*10000 -- afficher popup potar bougé
	else
		shared.pop = 0
	end
	
	else -- si pas premier lancement
	
		
		-- pour popup new session 
		if (pop1< getTime() - 200) then -- si delai popup 2 sec
		shared.pop = 0
		end
	
end
	
	
end

return { run = run, init = init, background = background}