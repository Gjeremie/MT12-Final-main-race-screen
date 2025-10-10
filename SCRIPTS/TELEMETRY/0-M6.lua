local shared = ...

local retourON = false  -- true si telem transmise 

local rot = 39 -- numero item a modifier (commande par rotary)
local modif = 0 --   =0 si pas mode modif et =valeur de rot si modif de cet item 

local st = getValue('ch1') -- position st channel 1

local rebound = 0 -- anti rebond Enter key
local valeur = 0 -- valeur en cour de modif
local G4 --  valeur  g4 expo de 0 a 100
  local ecar
  
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
  

 local function cadre(x,y,sel,pt,n1,n2) -- sel : 0= rect noire 1=cadre selection point
										-- pt : valeur point a afficher         n1 et n2  :  affichage point n1/n2 

	if sel == 0 then 
	
	lcd.drawLine(x-1,y-1,x+1,y-1, SOLID, FORCE)
	lcd.drawLine(x-1,y,x+1,y, SOLID, FORCE)
	lcd.drawLine(x-1,y+1,x+1,y+1, SOLID, FORCE)
	
	 else
	lcd.drawRectangle(x-2, y-2, 5, 5, SOLID)
	end

lcd.drawText(85, 21, "Point " .. n1 .. "/" .. n2, SMLSIZE) -- point n1 sur n2
lcd.drawText(85, 30, pt , SMLSIZE) -- valeur point pt
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
  
  
  
function shared.run(event)
  lcd.clear()



---- touche bascule entre ecran -----------------
 if event == EVT_VIRTUAL_NEXT_PAGE then -- bouton menu 
 playTone(1200, 120,5) -- play tone
 
 	local tab = model.getLogicalSwitch(36) -- RESET mode calibration si enclanché
	tab.v2 = 0
	model.setLogicalSwitch(36, tab) -- assigner valeur de LS37 RESET MODE CALIBRATION
 
    shared.changeScreen(9)
  end
   if event == EVT_VIRTUAL_PREV_PAGE then -- bouton menu 
 playTone(1200, 120,5) -- play tone
 
 	local tab = model.getLogicalSwitch(36) -- RESET mode calibration si enclanché
	tab.v2 = 0
	model.setLogicalSwitch(36, tab) -- assigner valeur de LS37 RESET MODE CALIBRATION
 
    shared.changeScreen(6)
  end
  
 if event == EVT_VIRTUAL_MENU_LONG then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(1)
  end
    
lcd.drawText(1, 1, "CONFIGURATION                   " , 0+INVERS) -- TITRE
  
 G4 = getValue('gvar4')  -- valeur  g4 de 0 a 70
  

--- code -----
if (modif == 0) then -- si mode choix item ====================
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
    rot = rot+1 -- allez item suivant
	playTone(1200, 50,5) -- play tone
		if (rot >39) then -- max item
		shared.changeScreen(7)
		end
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary  prev
    rot = rot-1
	
		if (rot <23) then
		rot =23     --   max item
		else
		playTone(1200, 50,5) -- play tone
		end
	end
	if ( event == EVT_VIRTUAL_ENTER and (getTime() - rebound) > 20 ) then -- bouton rotary ENTER anti rebond
	playTone(1200, 120,5) -- play tone
		rebound = getTime()
	
	 modif = rot -- assigner num item a modif
	 
	 if rot == 23  then -- si modif item calibration courbe st
	 	local tab = model.getLogicalSwitch(36) -- ENTRER mode calibration
	tab.v2 = 100
	model.setLogicalSwitch(36, tab) -- assigner valeur de LS37 ENTRER MODE CALIBRATION
	 end
	   
	end
else -- si mode modif ====================

	if ( event == EVT_VIRTUAL_ENTER and (getTime() - rebound) > 20 ) then -- bouton rotary ENTER anti rebond
	playTone(1200, 120,5) -- play tone
	rebound = getTime()
	modif = 0 -- revenir a mode choix item
	
	if rot == 37 or rot == 38 then -- si modif item programmation ESP32
	
		local tab = model.getMix(10, 0) -- copier ligne 1
		tab.multiplex = 2 -- remplacer channel
		tab.offset = 100 -- offset 100
			model.deleteMix(10, 1) -- suppr ligne 2 de channel 11
			model.insertMix(10, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
			
	valeur = 0 -- reset valeur
	
	end
	
		if rot == 23  then -- si modif item calibration courbe st
	
			local tab = model.getLogicalSwitch(36) -- RESET mode calibration si enclanché
	tab.v2 = 0
	model.setLogicalSwitch(36, tab) -- assigner valeur de LS37 RESET MODE CALIBRATION
			
	valeur = 0 -- reset valeur
	
	end
	
	
	end	
end






if (rot >22 and rot<24) then --   ========================    PAGE 3    ======================  


st = getValue('ch1') -- recup valeur st ch1

lcd.drawText(1, 11, "Calibration St" , SMLSIZE+INVERS) 
lcd.drawText(10, 21, "Calibration" , SMLSIZE) 
lcd.drawText(0, 30, "avec Pot DR" , SMLSIZE) 

lcd.drawText(112, 18, "+R" , SMLSIZE) 
lcd.drawText(65, 51, "+L" , SMLSIZE) 

lcd.drawText(0, 47, "St: " , SMLSIZE) 
lcd.drawText(20, 47, math.floor(st/1024*100+0.5) .. " %" , SMLSIZE) 

lcd.drawLine(93+math.floor(st/1024*100/4+0.5),11,93+math.floor(st/1024*100/4+0.5),11+4, SOLID, FORCE)
lcd.drawLine(93+math.floor(st/1024*100/4+0.5),63-4,93+math.floor(st/1024*100/4+0.5),63, SOLID, FORCE) -- axe representant position ST

lcd.drawText(0, 56, "Point: " , SMLSIZE) 

lcd.drawLine(93,17,93,57, SOLID, FORCE) -- axe y
lcd.drawLine(93-28-4,37,93-28,37, SOLID, FORCE) -- axe x
lcd.drawLine(93+28+4,37,93+28,37, SOLID, FORCE) -- axe x
-- centre a  93,37


local tab = model.getCurve(2) -- COURBE st 2
local point = {}
point = tab.y  -- point[1]  c'est la valeur y du premier point de la courbe

-- courbe :
lcd.drawLine(68,37,73,math.floor(37-(point[2]+80)+0.5), SOLID, FORCE)
lcd.drawLine(73,math.floor(37-(point[2]+80)+0.5),78,math.floor(37-(point[3]+60)+0.5), SOLID, FORCE)
lcd.drawLine(78,math.floor(37-(point[3]+60)+0.5),83,math.floor(37-(point[4]+40)+0.5), SOLID, FORCE)
lcd.drawLine(83,math.floor(37-(point[4]+40)+0.5),88,math.floor(37-(point[5]+20)+0.5), SOLID, FORCE)
lcd.drawLine(88,math.floor(37-(point[5]+20)+0.5),93,37, SOLID, FORCE)
lcd.drawLine(93,37,98,math.floor(37-(point[7]-20)+0.5), SOLID, FORCE)
lcd.drawLine(98,math.floor(37-(point[7]-20)+0.5),103,math.floor(37-(point[8]+-40)+0.5), SOLID, FORCE)
lcd.drawLine(103,math.floor(37-(point[8]-40)+0.5),108,math.floor(37-(point[9]+-60)+0.5), SOLID, FORCE)
lcd.drawLine(108,math.floor(37-(point[9]-60)+0.5),113,math.floor(37-(point[10]+-80)+0.5), SOLID, FORCE)
lcd.drawLine(113,math.floor(37-(point[10]-80)+0.5),118,37, SOLID, FORCE)

local x=0

-- dessin POINT
if (st<1076 and st>972) then -- point 11	
	lcd.drawRectangle(117,37-1,3,3,SOLID)
	lcd.drawText(30, 56, "0" , SMLSIZE) 

elseif (st<871 and st>767) then -- point 10
	lcd.drawText(30, 56, (point[10]-80 > 0 and "+" .. point[10]-80 or point[10]-80), SMLSIZE)
	lcd.drawRectangle(112,math.floor(37-(point[10]-80)+0.5)-1,3,3,SOLID)
		x=10
elseif (st<666 and st>562) then -- point 9	
	lcd.drawText(30, 56, (point[9]-60 > 0 and "+" .. point[9]-60 or point[9]-60), SMLSIZE)
	lcd.drawRectangle(107,math.floor(37-(point[9]-60)+0.5)-1,3,3,SOLID)
		x=9
elseif (st<462 and st>358) then -- point 8	
	lcd.drawText(30, 56, (point[8]-40 > 0 and "+" .. point[8]-40 or point[8]-40), SMLSIZE)
	lcd.drawRectangle(102,math.floor(37-(point[8]-40)+0.5)-1,3,3,SOLID)
		x=8
elseif (st<257 and st>153) then -- point 7
	lcd.drawText(30, 56, (point[7]-20 > 0 and "+" .. point[7]-20 or point[7]-20), SMLSIZE)	
	lcd.drawRectangle(97,math.floor(37-(point[7]-20)+0.5)-1,3,3,SOLID)
		x=7
elseif (st<52 and st>-52) then -- point 6	
	lcd.drawRectangle(92,37-1,3,3,SOLID)
	lcd.drawText(30, 56, "0" , SMLSIZE) 

elseif (st<-153 and st>-257) then -- point 5	
	lcd.drawText(30, 56, (-20-point[5] > 0 and "+" .. -20-point[5] or -20-point[5]), SMLSIZE)
	lcd.drawRectangle(87,math.floor(37-(point[5]+20)+0.5)-1,3,3,SOLID)
		x=5
elseif (st<-358 and st>-462) then -- point 4
	lcd.drawText(30, 56, (-40-point[4] > 0 and "+" .. -40-point[4] or -40-point[4]), SMLSIZE) 	
	lcd.drawRectangle(82,math.floor(37-(point[4]+40)+0.5)-1,3,3,SOLID)
		x=4
elseif (st<-562 and st>-666) then -- point 3
	lcd.drawText(30, 56, (-60-point[3] > 0 and "+" .. -60-point[3] or -60-point[3]), SMLSIZE)	
	lcd.drawRectangle(77,math.floor(37-(point[3]+60)+0.5)-1,3,3,SOLID)
		x=3
elseif (st<-767 and st>-871) then -- point 2	
	lcd.drawText(30, 56, (-80-point[2] > 0 and "+" .. -80-point[2] or -80-point[2]), SMLSIZE)
	lcd.drawRectangle(72,math.floor(37-(point[2]+80)+0.5)-1,3,3,SOLID)
		x=2
elseif (st<-972 and st>-1076) then -- point 1	
	lcd.drawRectangle(67,37-1,3,3,SOLID)
	lcd.drawText(30, 56, "0" , SMLSIZE) 
end	






 -------------- ACTIVATION calibration steering  / Logical switch  LS37 
  
------ affiche valeur  -----
case(0,20,model.getLogicalSwitch(36).v2/100) -- case 

if modif == rot and x ~= 0 then -- si mode modif sur cet item et point a modifier different de 0



	

			 tab = model.getCurve(2) -- COURBE st 2
			 point = tab.y  -- point[1]  c'est la valeur y du premier point de la courbe
			
			valeur = point[x] -- lire valeur de y point
			
			if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
				
				if x>6 then
				valeur = choose(valeur,-100,100,1) -- detection rotary next ou prev
				else
				valeur = choose(valeur,-100,100,-1) -- detection rotary next ou prev
				end
				
			end
			if event == EVT_VIRTUAL_PREV then -- bouton rotary next
			
			 if x>6 then
				valeur = choose(valeur,-100,100,-1) -- detection rotary next ou prev
				else
				valeur = choose(valeur,-100,100,1) -- detection rotary next ou prev
				end
			 
			end
		
		point[x] = valeur -- assigner valeur de y point
		tab.y =  point
		model.setCurve(2,tab)  -- COURBE st 2 -- assigner valeur 
	
	
		
end







--  ========================   FIN  PAGE 3    ======================  
   
elseif (rot >23 and rot<31) then --   ========================    PAGE 4    ======================   


-- AXEs de  Courbe Th
lcd.drawText(86, 11, "Courbe Th" , SMLSIZE+INVERS) -- gaz
lcd.drawLine(15,61,66,61, SOLID, FORCE)
lcd.drawLine(17,12,17,60, SOLID, FORCE)
lcd.drawLine(17,62,17,63, SOLID, FORCE)

lcd.drawText(76, 46, "Calibration" , SMLSIZE+INVERS) -- calibration

-- Point Zero a 17,61

local tab = model.getCurve(3) -- COURBE gaz 3
local point = {}
local pos = {}
point = tab.y  -- point[1]  c'est la valeur y du premier point de la courbe
pos = tab.x


if rot == 24 then -- ROT point 3 de courbe

	if modif == rot then -- si selectionné
	valeur =  point[3] -- POINT 3
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,100,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,100,-1) -- detection rotary next ou prev
	end
		
	point[3] = valeur  -- POINT 3
	tab.y = point
	model.setCurve(3,tab)  -- COURBE gaz 3
		
	cadre(17+pos[3]/2,61-point[3]/2,1,point[3],1,6) -- dessin POINT 3   -   PT 1/6
	
	else -- si pas selectionné
	cadre(17+pos[3]/2,61-point[3]/2,0,point[3],1,6)   -- dessin POINT 3   -   PT 1/6
	end
end

if rot == 25 then -- ROT point 4 de courbe

	if modif == rot then -- si selectionné
	valeur =  point[4] -- POINT 4
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,100,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,100,-1) -- detection rotary next ou prev
	end
		
	point[4] = valeur  -- POINT 4
	tab.y = point
	model.setCurve(3,tab)  -- COURBE gaz 3
		
	cadre(17+pos[4]/2,61-point[4]/2,1,point[4],2,6) -- dessin POINT 4   -   PT 2/6
	
	else -- si pas selectionné
	cadre(17+pos[4]/2,61-point[4]/2,0,point[4],2,6)   -- dessin POINT 4   -   PT 2/6
	end
end

if rot == 26 then -- ROT point 5 de courbe

	if modif == rot then -- si selectionné
	valeur =  point[5] -- POINT 5
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,100,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,100,-1) -- detection rotary next ou prev
	end
			
	point[5] = valeur  -- POINT 5
	tab.y = point
	model.setCurve(3,tab)  -- COURBE gaz 3
		
	cadre(17+pos[5]/2,61-point[5]/2,1,point[5],3,6) -- dessin POINT 5   -   PT 3/6
	
	else -- si pas selectionné
	cadre(17+pos[5]/2,61-point[5]/2,0,point[5],3,6)   -- dessin POINT 5   -   PT 3/6
	end
end

if rot == 27 then -- ROT point 6 de courbe

	if modif == rot then -- si selectionné
	valeur =  point[6] -- POINT 6
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,100,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,100,-1) -- detection rotary next ou prev
	end
		
	point[6] = valeur  -- POINT 6
	tab.y = point
	model.setCurve(3,tab)  -- COURBE gaz 3
		
	cadre(17+pos[6]/2,61-point[6]/2,1,point[6],4,6) -- dessin POINT 6   -   PT 4/6
	
	else -- si pas selectionné
	cadre(17+pos[6]/2,61-point[6]/2,0,point[6],4,6)   -- dessin POINT 6   -   PT 4/6
	end
end

if rot == 28 then -- ROT point 7 de courbe

	if modif == rot then -- si selectionné
	valeur =  point[7] -- POINT 7
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,100,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,100,-1) -- detection rotary next ou prev
	end
		
	point[7] = valeur  -- POINT 7
	tab.y = point
	model.setCurve(3,tab)  -- COURBE gaz 3
		
	cadre(17+pos[7]/2,61-point[7]/2,1,point[7],5,6) -- dessin POINT 7   -   PT 5/6
	
	else -- si pas selectionné
	cadre(17+pos[7]/2,61-point[7]/2,0,point[7],5,6)   -- dessin POINT 7   -   PT 5/6
	end
end

if rot == 29 then -- ROT point 8 de courbe

	if modif == rot then -- si selectionné
	valeur =  point[8] -- POINT 8
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,100,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,100,-1) -- detection rotary next ou prev
	end
		
	point[8] = valeur  -- POINT 8
	tab.y = point
	model.setCurve(3,tab)  -- COURBE gaz 3
		
	cadre(17+pos[8]/2,61-point[8]/2,1,point[8],6,6) -- dessin POINT 8   -   PT 6/6
	
	else -- si pas selectionné
	cadre(17+pos[8]/2,61-point[8]/2,0,point[8],6,6)   -- dessin POINT 8   -   PT 6/6
	end
end






if rot==30 then -------------- CALIBRATION max gaz /   channel 7 copier  ligne de mix   
   
   ------ affiche valeur selectionnne ------
   
	lcd.drawText(90, 57,model.getMix(6, 2).weight  .. " %" , SMLSIZE+INVERS) -- texte fond noir     weight
	   
    
   	if modif == rot then -- si mode modif sur cet item
	
								
			local tab = model.getMix(6, 0) -- copier ligne 1
			 tab.weight = math.floor( 0.5 + 10000/(getValue('input31')/10.24) ) -- modif weight de ligne copier
			 tab.multiplex = 0 -- additionner channel
			 model.deleteMix(6, 2) -- suppr ligne 3 de channel 7
			 
			model.insertMix(6, 2, tab) -- copier une ligne de mix et la coller dans ligne 3
					

		modif = 0 -- revenir a mode choix item
		

	end
     
   else ------ affiche valeur non selectionne -----
   
	lcd.drawText(90, 57,model.getMix(6, 2).weight .. " %" , SMLSIZE)  -- texte
     
end


  	
	-- Tracer courbe :
lcd.drawLine(17,61,17+pos[3]/2,61-point[3]/2, SOLID, FORCE)

for i = 3 , 7 , 1 do
lcd.drawLine(17+pos[i]/2,61-point[i]/2,17+pos[i+1]/2,61-point[i+1]/2, SOLID, FORCE)
end

lcd.drawLine(17+pos[8]/2,61-point[8]/2,17+50,61-50, SOLID, FORCE)

	-- Tracer valeur live gaz :
if getValue('ch7') >0 then   -- valeur  input 31 (gaz) sur 100
	lcd.drawLine(17+(getValue('ch7')/10.24 )/2,61+1,17+(getValue('ch7')/10.24 )/2,61+2, SOLID, FORCE)    
	lcd.drawText(70, 58, math.floor(getValue('ch7')/10.24), SMLSIZE) 
	else
	lcd.drawText(70, 58, "0", SMLSIZE) 
end

if getValue('ch2') >0 then   -- -- valeur  ch2  avec correction 100*getValue('ch2')/getValue('input5')  pour ne pas prendre en compte reglage DR potar
    
    if getValue('ls44')>0 then -- si limiteur bouton
    
	lcd.drawLine(17-2,61-(getValue('ch2')/10.24)/2,17-1,61-(getValue('ch2')/10.24)/2, SOLID, FORCE)    
	lcd.drawText(0, 11, math.floor(getValue('ch2')/10.24), SMLSIZE) 
	
	else
	    
	lcd.drawLine(17-2,61-(100*getValue('ch2')/getValue('input5'))/2,17-1,61-(100*getValue('ch2')/getValue('input5'))/2, SOLID, FORCE)    

	lcd.drawText(0, 11, math.floor(100*getValue('ch2')/getValue('input5')), SMLSIZE) 

	
	
	
	end
	
	else
		lcd.drawText(0, 11, "0", SMLSIZE) 
end
   
--  ========================   FIN  PAGE 4    ======================  
   
elseif (rot >30 and rot<34) then -- rot= 21 22 23  ========================    PAGE 5    ======================     
   
-- AXEs de  Courbe br
lcd.drawText(85, 11, "Courbe Br" , SMLSIZE+INVERS) -- brake
lcd.drawLine(17,13,68,13, SOLID, FORCE)
lcd.drawLine(66,11,66,12, SOLID, FORCE)
lcd.drawLine(66,14,66,62, SOLID, FORCE)
lcd.drawText(75, 40, "& DR Br: " .. getValue('gvar1'), SMLSIZE) 
lcd.drawText(75, 48, "& MOD Br: " .. math.floor(getValue('gvar3')/6-40/6+0.5), SMLSIZE) 

-- Point Zero a 66,13

local tab = model.getCurve(0) -- COURBE br 0
local point = {}
local pos = {}
point = tab.y  -- point[1]  c'est la valeur y du premier point de la courbe
pos = tab.x   

if rot == 31 then -- ROT point 5 de courbe

	if modif == rot then -- si selectionné
	valeur =  point[5] -- POINT 5
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,-100,0,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,-100,0,-1) -- detection rotary next ou prev
	end
		
	point[5] = valeur  -- POINT 5
	tab.y = point
	model.setCurve(0,tab)  -- COURBE br 0
		
	cadre(66+pos[5]/2,13-point[5]/2,1,point[5],1,3) -- dessin POINT 5   -   PT 1/3
	
	else -- si pas selectionné
	cadre(66+pos[5]/2,13-point[5]/2,0,point[5],1,3)   -- dessin POINT 5   -   PT 1/3
	end
end

if rot == 32 then -- ROT point 6 de courbe

	if modif == rot then -- si selectionné
	valeur =  point[6] -- POINT 6
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
			valeur = choose(valeur,-100,0,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 	valeur = choose(valeur,-100,0,-1) -- detection rotary next ou prev
	end
		
	point[6] = valeur  -- POINT 6
	tab.y = point
	model.setCurve(0,tab)  -- COURBE br 0
		
	cadre(66+pos[6]/2,13-point[6]/2,1,point[6],2,3) -- dessin POINT 6   -   PT 2/3
	
	else -- si pas selectionné
	cadre(66+pos[6]/2,13-point[6]/2,0,point[6],2,3)   -- dessin POINT 6   -   PT 2/3
	end
end

if rot == 33 then -- ROT point 7 de courbe

	if modif == rot then -- si selectionné
	valeur =  point[7] -- POINT 7
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
			valeur = choose(valeur,-100,0,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 	valeur = choose(valeur,-100,0,-1) -- detection rotary next ou prev
	end
		
	point[7] = valeur  -- POINT 7
	tab.y = point
	model.setCurve(0,tab)  -- COURBE br 0
		
	cadre(66+pos[7]/2,13-point[7]/2,1,point[7],3,3) -- dessin POINT 7   -   PT 3/3
	
	else -- si pas selectionné
	cadre(66+pos[7]/2,13-point[7]/2,0,point[7],3,3)   -- dessin POINT 7   -   PT 3/3
	end
end

-- Tracer courbe :
lcd.drawLine(66+pos[3]/2,13+50,66+pos[4]/2,13+50, SOLID, FORCE)
lcd.drawLine(66+pos[4]/2,13+50,66+pos[5]/2,13-point[5]/2, SOLID, FORCE)
lcd.drawLine(66+pos[5]/2,13-point[5]/2,66+pos[6]/2,13-point[6]/2, SOLID, FORCE)
lcd.drawLine(66+pos[6]/2,13-point[6]/2,66+pos[7]/2,13-point[7]/2, SOLID, FORCE)
lcd.drawLine(66+pos[7]/2,13-point[7]/2,66,13, SOLID, FORCE)
  
	-- Tracer valeur live br :
if getValue('ch7') <0 then   -- valeur  input15 (frein premiere partie) sur 100 

		if getValue('ch7')/10.24 < pos[4] then -- si valeur frein avant le point a 100% 
		lcd.drawLine(66+1,13+50,66+2,13+50, SOLID, FORCE)    
		lcd.drawText(70, 58, "-100", SMLSIZE) 
		else
		lcd.drawLine(66+1,13-(getValue('input15')/10.24 )/2,66+2,13-(getValue('input15')/10.24 )/2, SOLID, FORCE)    
		lcd.drawText(70, 58, math.floor(getValue('input15')/10.24), SMLSIZE) 
		end

	lcd.drawLine(66+(getValue('ch7')/10.24 )/2,13-1,66+(getValue('ch7')/10.24 )/2,13-2, SOLID, FORCE)    
	lcd.drawText(0, 11, math.floor(getValue('ch7')/10.24), SMLSIZE) 
	else
		lcd.drawText(0, 11, "0", SMLSIZE) 
		
	lcd.drawText(70, 58, "0", SMLSIZE) 
end   
   
--  ========================   FIN  PAGE 5    ======================  
   
elseif (rot >33 and rot<36) then -- rot= 24  ========================    PAGE 6    ======================  
   
   -- AXEs de  Courbe St
lcd.drawText(85, 11, "Courbe St" , SMLSIZE+INVERS) -- gaz
lcd.drawLine(15,61,66,61, SOLID, FORCE)
lcd.drawLine(17,12,17,60, SOLID, FORCE)
lcd.drawLine(17,62,17,63, SOLID, FORCE)
-- Point Zero a 17,61



local tab = model.getCurve(5) -- COURBE cor 6
local point = {}
local pos = {}
point = tab.y  -- point[1]  c'est la valeur y du premier point de la courbe
pos = tab.x


if rot == 34 then -- ROT point 2 et 5 de courbe

	if modif == rot then -- si selectionné
	valeur =  point[2] -- POINT 2
	ecar = point[2]-point[3]
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,70,100,5) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,70,100,-5) -- detection rotary next ou prev
	end
		
	point[2] = valeur  -- POINT 2
	point[5] = valeur  -- POINT 5
	point[3] = valeur - ecar  -- POINT 3
	point[4] = valeur - ecar   -- POINT 4
	tab.y = point
	model.setCurve(5,tab)  -- COURBE cor 6
		
			
	end
	
lcd.drawText(85, 29, point[2] .. " %" , SMLSIZE+INVERS) -- texte	
else -- si pas selection
	lcd.drawText(85, 29, point[2] .. " %" , SMLSIZE) -- texte
	
end



if rot == 35 then -- ROT point 3 et 4 de courbe

	if modif == rot then -- si selectionné
	valeur =  point[2]-point[3] -- POINT 3
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,30,5) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,30,-5) -- detection rotary next ou prev
	end
		
	
	point[3] = point[2] - valeur  -- POINT 3
	point[4] = point[2] - valeur   -- POINT 4
	tab.y = point
	model.setCurve(5,tab)  -- COURBE cor 6
		
			
	end
	
	lcd.drawText(85, 47, point[2]-point[3] .. " %" , SMLSIZE+INVERS) -- texte
else -- si pas selection
	lcd.drawText(85, 47, point[2]-point[3] .. " %" , SMLSIZE) -- texte
	
end



-- valeur linearité courbe
lcd.drawText(75, 21, "Linearity", SMLSIZE) 
lcd.drawText(75, 39, "Prec. Neutre", SMLSIZE) 


lcd.drawText(86, 57, "& Exp:", SMLSIZE) 
lcd.drawText(112, 57,  math.floor(G4/7), SMLSIZE) 

	-- Tracer courbe :
	

	for i= 0, 70, 10 do
		if i < 20 then
		lcd.drawLine(17+i/2,     61-((G4/100*math.pow(i/100,3) + (1-G4/100)*i/100)*point[2]/2)*point[3]/point[2],      17+(i+10)/2,      61-((G4/100*math.pow(i/100+0.1,3) + (1-G4/100)*(i+10)/100)*point[2]/2)*point[3]/point[2], SOLID, FORCE)
		else
		lcd.drawLine(17+i/2,     61-((G4/100*math.pow(i/100,3) + (1-G4/100)*i/100)*point[2]/2)*(point[3]+(i/10-2)*(point[2]-point[3])/6)/point[2],      17+(i+10)/2,      61-((G4/100*math.pow(i/100+0.1,3) + (1-G4/100)*(i+10)/100)*point[2]/2)*(point[3]+(i/10-2)*(point[2]-point[3])/6)/point[2], SOLID, FORCE)
		end
	
	end
	
lcd.drawLine( 17+40,      61-(G4/100*math.pow(0.8,3) + (1-G4/100)*0.8)*point[2]/2,     17+45,      61-(G4/100*math.pow(0.9,3) + (1-G4/100)*0.9)*((100-point[2])/2+point[2])/2   , SOLID, FORCE)	

lcd.drawLine( 17+45,    61-(G4/100*math.pow(0.9,3) + (1-G4/100)*0.9)*((100-point[2])/2+point[2])/2  ,     17+50,   61-50  , SOLID, FORCE)


	-- Tracer valeur live st :
if getValue('input30') >0 then   -- valeur  input 30 (st) sur 100
	lcd.drawLine(17+(getValue('input30')/10.24 )/2,61+1,17+(getValue('input30')/10.24 )/2,61+2, SOLID, FORCE)    
	lcd.drawText(70, 58, math.floor(getValue('input30')/10.24), SMLSIZE) 
	else
	lcd.drawText(70, 58, "0", SMLSIZE) 
end

if getValue('ch1') >0 then   -- valeur  ch1  avec correction 100*getValue('ch1')/getValue('input4')  pour ne pas prendre en compte reglage DR potar
	lcd.drawLine(17-2,61-(100*getValue('ch1')/getValue('input4'))/2,17-1,61-(100*getValue('ch1')/getValue('input4'))/2, SOLID, FORCE)    
	lcd.drawText(0, 11, math.floor(100*getValue('ch1')/getValue('input4')), SMLSIZE) 
	else
		lcd.drawText(0, 11, "0", SMLSIZE) 
   
end
   --  ========================   FIN  PAGE 6    ======================  
   
 elseif (rot >35 and rot<40) then --   ========================    PAGE 7    ======================    
   
   --========================= affiche texte fond =================================
lcd.drawText(1, 11, "Reglage Rapide:" , SMLSIZE+INVERS) -- texte fond noir
 lcd.drawText(10, 20, "MOD Br      ou" , SMLSIZE) -- texte
    lcd.drawText(85, 20, "Drag Br" , SMLSIZE) -- texte
	 lcd.drawText(10, 29, "Expo St     ou" , SMLSIZE) -- texte
    lcd.drawText(85, 29, "Ratio Br" , SMLSIZE) -- texte
	lcd.drawText(1, 38, "Config ESP32 Telemetry:" , SMLSIZE+INVERS) -- texte fond noir

 -- ========================== affiche valeur ========================================  
   
   
local tab = model.getCurve(20) -- COURBE ro2 21
local point = {}
point = tab.y  -- point[1]  c'est la valeur y du premier point de la courbe

   
   
   
if rot == 36 then -- reglage rapide SA sur etage frein ou drag brake  ( point 9 et 10 de courbe CV21 ro2 )

	------ affiche valeur selectionnne -----
	if point[9] == 50 then -- reglage rapide sur etage frein
	case(0,19,3) -- case fond noir
	case(75,19,2) -- case fond noir
	else -- reglage rapide sur drag brake
	case(0,19,2) -- case fond noir
	case(75,19,3) -- case fond noir
	end
	


	if modif == rot then -- si mode modif sur cet item


	valeur = point[9] -- lire valeur point 9
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,50,80,30) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,50,80,-30) -- detection rotary next ou prev
	end
	
	point[9] = valeur
	point[10] = valeur
	tab.y = point -- assigner les points
	model.setCurve(20,tab)  -- assigner COURBE
			
		
	end

else ------ affiche valeur non selectionne -----
if point[9] == 50 then -- reglage rapide sur etage frein
	case(0,19,1) -- case fond noir
	case(75,19,0) -- case fond noir
	else -- reglage rapide sur drag brake
	case(0,19,0) -- case fond noir
	case(75,19,1) -- case fond noir
	end
	
	
end   
   
   
   if rot == 37 then -- reglage rapide SA sur etage frein ou drag brake  ( point 11 et 12 de courbe CV21 ro2 )

	------ affiche valeur selectionnne -----
	if point[11] == 60 then -- reglage rapide sur etage frein
	case(0,28,3) -- case fond noir
	case(75,28,2) -- case fond noir
	else -- reglage rapide sur drag brake
	case(0,28,2) -- case fond noir
	case(75,28,3) -- case fond noir
	end
	


	if modif == rot then -- si mode modif sur cet item


	valeur = point[11] -- lire valeur point 9
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,60,70,10) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,60,70,-10) -- detection rotary next ou prev
	end
	
	point[11] = valeur
	point[12] = valeur
	tab.y = point -- assigner les points
	model.setCurve(20,tab)  -- assigner COURBE
			
		
	end

else ------ affiche valeur non selectionne -----
if point[11] == 60 then -- reglage rapide sur etage frein
	case(0,28,1) -- case fond noir
	case(75,28,0) -- case fond noir
	else -- reglage rapide sur drag brake
	case(0,28,0) -- case fond noir
	case(75,28,1) -- case fond noir
	end
	
	
end   
   
   
   
   
   
   
   
   
 _ , retourON = getSourceValue('Bat')  -- recup etat capteur ( si telem active)
   
 
   
     
if rot == 38 then -- echantillon telemetry sur moyenne tension (choix CH11 avec offset de 20)

	------ affiche valeur selectionnne -----
	



	lcd.drawText(0, 47, "Taille Moy Tension" , SMLSIZE+INVERS) -- texte
	
	
	if getSourceValue('Bat') ~= nil and retourON == true then
		lcd.drawText(112, 47, getSourceValue('Bat')*2 , SMLSIZE) -- recup sensor affichant valeur variable actuel ESP32
				
		else
			lcd.drawText(112, 47, " ..." , SMLSIZE+BLINK) -- texte
		end
	

	if modif == rot then -- si mode modif sur cet item
	
		
		
		if model.getMix(10, 1).offset ~= 20  then -- si premiere fois modif
		
			if getSourceValue('Bat') ~= nil and retourON == true then
			 -- recup sensor affichant valeur variable actuel ESP32
					valeur = getSourceValue('Bat')*2
					
					-- met channel 11 a offset 10
		local tab = model.getMix(10, 0) -- copier ligne 1
		tab.multiplex = 2 -- remplacer channel
		tab.offset = 20 -- offset 20
			model.deleteMix(10, 1) -- suppr ligne 2 de channel 11
			model.insertMix(10, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
			else
				valeur = 0 -- valeur defaut
			end
		
		
			 		
		end
		
		
		
		if valeur ~= 0 then
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,1,199,2) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,1,199,-2) -- detection rotary next ou prev
	end	
		
		-- met channel 12 a offset correspondant a valeur que l'on veut envoyer a ESP32
		local tab = model.getMix(11, 0) -- copier ligne 1
		tab.multiplex = 2 -- remplacer channel
		tab.offset = valeur -- offset 10
			model.deleteMix(11, 1) -- suppr ligne 2 de channel 12
			model.insertMix(11, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
	

		lcd.drawText(89, 47, model.getMix(11, 1).offset  , SMLSIZE+INVERS) -- texte
	else
		lcd.drawText(89, 47, "..."  , SMLSIZE+INVERS) -- texte
	end
		
	else -- si pas mode modif sur item
	
			if model.getMix(10, 1).offset ~= 40  then -- si premiere fois modif
		
		-- met channel 11 a offset 40
		local tab = model.getMix(10, 0) -- copier ligne 1
		tab.multiplex = 2 -- remplacer channel
		tab.offset = 40 -- offset 40
			model.deleteMix(10, 1) -- suppr ligne 2 de channel 11
			model.insertMix(10, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
			 	
		end
					
		
			
		
			
		
	end

else ------ affiche valeur non selectionne -----
lcd.drawText(0, 47, "Taille Moy Tension"  , SMLSIZE) -- texte
	lcd.drawText(112, 47, " ..." , SMLSIZE) -- texte
	
end   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
if rot == 39 then --coeff telemetry sur courant (choix CH11 avec offset de 10) 

	------ affiche valeur selectionnne -----
	



	lcd.drawText(0, 56, "Coef courant" , SMLSIZE+INVERS) -- texte
	
	
	if getSourceValue('Bat') ~= nil and retourON == true then
		lcd.drawText(92, 56, (getSourceValue('Bat')*2+900)/10.0 .. "%" , SMLSIZE) -- recup sensor affichant valeur variable actuel ESP32
				
		else
			lcd.drawText(92, 56, " ..." , SMLSIZE+BLINK) -- texte
			
		end
	

	if modif == rot then -- si mode modif sur cet item
	
		
		
		if model.getMix(10, 1).offset ~= 10  then -- si premiere fois modif
		
			if getSourceValue('Bat') ~= nil and retourON == true then
			 -- recup sensor affichant valeur variable actuel ESP32
					valeur = getSourceValue('Bat')*2
					
					-- met channel 11 a offset 10
		local tab = model.getMix(10, 0) -- copier ligne 1
		tab.multiplex = 2 -- remplacer channel
		tab.offset = 10 -- offset 10
			model.deleteMix(10, 1) -- suppr ligne 2 de channel 11
			model.insertMix(10, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
					
			else
				valeur = 0 -- valeur defaut
			end
		
		
			 		
		end
		
		
		
	if valeur ~= 0 then	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,1,199,2) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,1,199,-2) -- detection rotary next ou prev
	end	
		
		-- met channel 12 a offset correspondant a valeur que l'on veut envoyer a ESP32
		local tab = model.getMix(11, 0) -- copier ligne 1
		tab.multiplex = 2 -- remplacer channel
		tab.offset = valeur -- offset 10
			model.deleteMix(11, 1) -- suppr ligne 2 de channel 12
			model.insertMix(11, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
	

		lcd.drawText(64, 56, (model.getMix(11, 1).offset+900)/10.0  , SMLSIZE+INVERS) -- texte
	else
		lcd.drawText(64, 56, "..."  , SMLSIZE+INVERS) -- texte
	end
		
	else -- si pas mode modif sur item
	
			if model.getMix(10, 1).offset ~= 30  then -- si premiere fois modif
		
		-- met channel 11 a offset 10
		local tab = model.getMix(10, 0) -- copier ligne 1
		tab.multiplex = 2 -- remplacer channel
		tab.offset = 30 -- offset 30
			model.deleteMix(10, 1) -- suppr ligne 2 de channel 11
			model.insertMix(10, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
			 	
		end
					
		
			
		
			
		
	end

else ------ affiche valeur non selectionne -----
lcd.drawText(0, 56, "Coef courant" , SMLSIZE) -- texte
	lcd.drawText(92, 56, " ..." , SMLSIZE) -- texte
	
end   
   
   
   

   
   
   
    --  ========================   FIN  PAGE 7   ====================== 
	
end   -- ==========FIN PAGES ------------
	  
  
  -- page:
lcd.drawNumber(123, 56,"5", 0+INVERS) -- texte numero page

end