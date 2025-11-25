local shared = ...


local rot = 1 -- numero item a modifier (commande par rotary)
local modif = 0 --   =0 si pas mode modif et =valeur de rot si modif de cet item 
local rebound = 0 -- anti rebond Enter key
local valeur = 0 -- valeur en cour de modif

local maxdrg -- valeur max agresivité drag brake

  
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
 if event == EVT_VIRTUAL_NEXT_PAGE  and modif == 0 then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(9)
  end
   if event == EVT_VIRTUAL_PREV_PAGE and modif == 0  then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(6)
  end
  
 if event == EVT_VIRTUAL_MENU_LONG  and modif == 0 then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(1)
  end
    
lcd.drawText(1, 1, "CONFIGURATION                   " , 0+INVERS) -- TITRE
  
  

--- code -----
if (modif == 0) then -- si mode choix item ====================
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
    rot = rot+1 -- allez item suivant
	
		if (rot >27) then -- max item
		
		rot =27
		else
		playTone(1200, 50,5) -- play tone
		end
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary  prev
    rot = rot-1
	playTone(1200, 50,5) -- play tone
		if (rot <1) then
		shared.changeScreen(8)
		end
	end
	if ( event == EVT_VIRTUAL_ENTER and (getTime() - rebound) > 20 ) then -- bouton rotary ENTER anti rebond
	playTone(1200, 120,5) -- play tone
		rebound = getTime()
	
	 modif = rot -- assigner num item a modif
	   
	end
else -- si mode modif ====================

	if ( event == EVT_VIRTUAL_ENTER and (getTime() - rebound) > 20 ) then -- bouton rotary ENTER anti rebond
	playTone(1200, 120,5) -- play tone
	rebound = getTime()
	modif = 0 -- revenir a mode choix item
	end	
end


if (rot <12) then --========================    PAGE 1    ======================

  --========================= affiche texte fond =================================
lcd.drawText(1, 11, "Tx V. Alert:" , SMLSIZE+INVERS) -- texte fond noir
lcd.drawText(1, 20, "Lipo V. Alert:" , SMLSIZE+INVERS) -- texte fond noir  
lcd.drawText(1, 29, "Temp. Alert Mot:" , SMLSIZE+INVERS) -- texte fond noir
lcd.drawText(1, 38, "Temp. Alert ESC:" , SMLSIZE+INVERS) -- texte fond noir
lcd.drawText(1, 47, "Telemetry Lost Alert:" , SMLSIZE+INVERS) -- texte fond noir
lcd.drawText(1, 56, "20% Jauge Lipo:" , SMLSIZE+INVERS) -- texte fond noir
 
   
 -- ========================== affiche valeur ========================================

if rot==1 then -------------- VALEUR alerte tension Tx   /   Logic Switch L58  
  
------ affiche valeur selectionnne -----
lcd.drawText(74, 11, model.getLogicalSwitch(57).v2/10 .. " V" , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(57)
	valeur = tab.v2 -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,65,83,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,65,83,-1) -- detection rotary next ou prev
	end
	
	tab.v2 = valeur
	model.setLogicalSwitch(57, tab) -- assigner valeur de LS

	end

else ------ affiche valeur non selectionne -----
lcd.drawText(74, 11, model.getLogicalSwitch(57).v2/10 .. " V" , SMLSIZE) -- texte

end ----------------------- 
 
   
if rot==2 then -------------- ACTIVATION alerte tension Tx   /   Special Function CF15   
  
------ affiche valeur selectionnne -----
case(119,10,model.getCustomFunction(14).active+2) -- case fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getCustomFunction(14)
	valeur = tab.active -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,1,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,1,-1) -- detection rotary next ou prev
	end
	
	tab.active = valeur
	model.setCustomFunction(14, tab) -- assigner valeur de LS
	end

else ------ affiche valeur non selectionne -----
case(119,10,model.getCustomFunction(14).active) -- case
end ----------------------- 
   
  
   
if rot==3 then -------------- VALEUR alerte lipo    /   Logic Switch L59  
------ affiche valeur selectionnne -----
lcd.drawText(62, 20, math.floor(model.getLogicalSwitch(58).v2/10)/100 .. " V" , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(58)
	valeur = tab.v2 -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,4400,50) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,4400,-50) -- detection rotary next ou prev
	end
		
	tab.v2 = valeur
	model.setLogicalSwitch(58, tab) -- assigner valeur de LS

	end

else ------ affiche valeur non selectionne -----
lcd.drawText(62, 20, math.floor(model.getLogicalSwitch(58).v2/10)/100 .. " V" , SMLSIZE) -- texte

end ----------------------- 
  
  
  if rot==4 then -------------- VALEUR DELAY alerte lipo    /   Logic Switch L59  
    lcd.drawText(95, 20, model.getLogicalSwitch(58).delay/10 .. " s" , SMLSIZE+INVERS) -- texte
  
  
  	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(58)
	valeur = tab.delay -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,50,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,50,-1) -- detection rotary next ou prev
	end
		
	tab.delay = valeur
	model.setLogicalSwitch(58, tab) -- assigner valeur de LS

	end
  
  else ------ affiche valeur non selectionne -----
  lcd.drawText(95, 20, model.getLogicalSwitch(58).delay/10 .. " s" , SMLSIZE) -- texte
  end
  
   
if rot==5 then -------------- ACTIVATION alerte lipo Tx   /   Special Function CF16   
  
------ affiche valeur selectionnne -----
case(119,19,model.getCustomFunction(15).active+2) -- case fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getCustomFunction(15)
	valeur = tab.active -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,1,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,1,-1) -- detection rotary next ou prev
	end
	
	tab.active = valeur
	model.setCustomFunction(15, tab) -- assigner valeur de LS

	end

else ------ affiche valeur non selectionne -----
case(119,19,model.getCustomFunction(15).active) -- case

end ----------------------- 
   
  
 if rot==6 then -------------- VALEUR alerte temperature   /   Logic Switch L60  
  
------ affiche valeur selectionnne -----
lcd.drawText(77, 29, model.getLogicalSwitch(59).v2 .. " °C" , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(59)
	valeur = tab.v2 -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,10,99,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,10,99,-1) -- detection rotary next ou prev
	end
		
	tab.v2 = valeur
	model.setLogicalSwitch(59, tab) -- assigner valeur de LS

	end

else ------ affiche valeur non selectionne -----
lcd.drawText(77, 29, model.getLogicalSwitch(59).v2 .. " °C" , SMLSIZE) -- texte

end ----------------------- 
 
   
   
if rot==7 then -------------- ACTIVATION alerte temperature   /   Special Function CF17   
  
------ affiche valeur selectionnne -----
case(119,28,model.getCustomFunction(16).active+2) -- case fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getCustomFunction(16)
	valeur = tab.active -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
			valeur = choose(valeur,0,1,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 	valeur = choose(valeur,0,1,-1) -- detection rotary next ou prev
	end
	
	tab.active = valeur
	model.setCustomFunction(16, tab) -- assigner valeur de LS

	end

else ------ affiche valeur non selectionne -----
case(119,28,model.getCustomFunction(16).active) -- case

end ----------------------- 
   
   
   
    if rot==8 then -------------- VALEUR alerte temperature   /   Logic Switch L40  
  
------ affiche valeur selectionnne -----
lcd.drawText(77, 38, model.getLogicalSwitch(39).v2 .. " °C" , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(39)
	valeur = tab.v2 -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,10,99,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,10,99,-1) -- detection rotary next ou prev
	end
		
	tab.v2 = valeur
	model.setLogicalSwitch(39, tab) -- assigner valeur de LS

	end

else ------ affiche valeur non selectionne -----
lcd.drawText(77, 38, model.getLogicalSwitch(39).v2 .. " °C" , SMLSIZE) -- texte

end ----------------------- 
 
   
   
if rot==9 then -------------- ACTIVATION alerte temperature   /   Special Function CF19   
  
------ affiche valeur selectionnne -----
case(119,37,model.getCustomFunction(18).active+2) -- case fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getCustomFunction(18)
	valeur = tab.active -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
			valeur = choose(valeur,0,1,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 	valeur = choose(valeur,0,1,-1) -- detection rotary next ou prev
	end
	
	tab.active = valeur
	model.setCustomFunction(18, tab) -- assigner valeur de LS

	end

else ------ affiche valeur non selectionne -----
case(119,37,model.getCustomFunction(18).active) -- case

end ----------------------- 
   
   





if rot==10 then -------------- ACTIVATION alerte telemetry   /   Special Function CF54  
  
------ affiche valeur selectionnne -----
case(119,46,model.getCustomFunction(53).active+2) -- case fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getCustomFunction(53)
	valeur = tab.active -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,1,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,1,-1) -- detection rotary next ou prev
	end
	
	tab.active = valeur
	model.setCustomFunction(53, tab) -- assigner valeur de LS
	end

else ------ affiche valeur non selectionne -----
case(119,46,model.getCustomFunction(53).active) -- case
end ----------------------- 








local tab = model.getCurve(4) -- COURBE var 5
local pos = {}
pos = tab.y
 
   
   
if rot==11 then -------------- VALEUR reglage tension jauge lipo   /   curve var 5
  

   ------ affiche valeur selectionnne -----

   lcd.drawText(78, 56, pos[4] + 3700 .. " mV", SMLSIZE+INVERS) -- texte  
	
      
	    if modif == rot then -- si mode modif sur cet item
	

	valeur = pos[4]
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,-100,100,5) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
		valeur = choose(valeur,-100,100,-5) -- detection rotary next ou prev
	end
		
	pos[4] = valeur  -- POINT 4
	tab.y = pos
	model.setCurve(4,tab)  -- COURBE


	end
	  
  
   
   else ------ affiche valeur non selectionne -----
 
   lcd.drawText(78, 56,pos[4] + 3700 .. " mV", SMLSIZE) -- texte  

end ----------------------- 
   
 
   
elseif (rot >11 and rot<21) then --========================    PAGE 2    ======================  
    
    --========================= affiche texte fond =================================

lcd.drawText(1, 11, "EPA St:" , SMLSIZE+INVERS) -- texte fond noir
	lcd.drawText(45, 11, "-L" , SMLSIZE+INVERS) -- texte fond noir
	lcd.drawText(92, 11, "+R" , SMLSIZE+INVERS) -- texte fond noir
lcd.drawText(1, 20, "Centre St:" , SMLSIZE+INVERS) -- texte fond noir  
lcd.drawText(1, 29, "Pignon moteur:" , SMLSIZE+INVERS) -- texte fond noir
lcd.drawText(1, 38, "Thr Speed point %:" , SMLSIZE+INVERS) -- texte fond noir
lcd.drawText(1, 47, "Coef frein:" , SMLSIZE+INVERS) -- texte fond noir
lcd.drawText(54, 47, "Av" , SMLSIZE+INVERS) -- texte fond noir
lcd.drawText(89, 47, "Arr" , SMLSIZE+INVERS) -- texte fond noir
lcd.drawText(1, 56, "Feeling St:" , SMLSIZE+INVERS) -- texte fond noir

   
 -- ========================== affiche valeur ========================================
   
 if rot==12 then -------------- VALEUR reglage epa direction left   /   output 0 (ch1)
  
------ affiche valeur selectionnne -----
lcd.drawText(59, 11, model.getOutput(0).min  , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getOutput(0)
	valeur = tab.min -- lire valeur de output
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,-900,-100,5) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,-900,-100,-5) -- detection rotary next ou prev
	end
	
	tab.min = valeur
	model.setOutput(0, tab) -- assigner valeur de output

	end

else ------ affiche valeur non selectionne -----
lcd.drawText(59, 11, model.getOutput(0).min  , SMLSIZE) -- texte

end -----------------------   
      
	  
if rot==13 then -------------- VALEUR reglage epa direction right   /   output 0 (ch1)
  
------ affiche valeur selectionnne -----
lcd.drawText(106, 11, model.getOutput(0).max  , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getOutput(0)
	valeur = tab.max -- lire valeur de output
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,100,900,5) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,100,900,-5) -- detection rotary next ou prev
	end

	tab.max = valeur
	model.setOutput(0, tab) -- assigner valeur de output
	end

else ------ affiche valeur non selectionne -----
lcd.drawText(106, 11, model.getOutput(0).max  , SMLSIZE) -- texte

end ----------------------- 
   
 
   	  
if rot==14 then -------------- VALEUR reglage  direction ppm center   /   output 0 (ch1)
  
------ affiche valeur selectionnne -----
lcd.drawText(66, 20, model.getOutput(0).ppmCenter  , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getOutput(0)
	valeur = tab.ppmCenter -- lire valeur de output
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,-80,80,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,-80,80,-1) -- detection rotary next ou prev
	end
	
	
	 tab.ppmCenter = valeur
	  model.setOutput(0, tab) -- assigner valeur de output
end

else ------ affiche valeur non selectionne -----
lcd.drawText(66, 20, model.getOutput(0).ppmCenter  , SMLSIZE) -- texte

end ----------------------- 
 
   
   
   
   if rot==15 then -------------- VALEUR reglage  inversion servo steering   /   output 0 (ch1)
  
------ affiche valeur selectionnne -----
if model.getOutput(0).revert == 0 then
	lcd.drawText(96, 20, "Nor"  , SMLSIZE+INVERS) -- texte fond noir
	else
	lcd.drawText(96, 20, "Rev"  , SMLSIZE+INVERS) -- texte fond noir
	end



	if modif == rot then -- si mode modif sur cet item

	local tab = model.getOutput(0)
	valeur = tab.revert -- lire valeur de output
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,1,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,1,-1) -- detection rotary next ou prev
	end
	
	
	 tab.revert = valeur
	  model.setOutput(0, tab) -- assigner valeur de output
end

else ------ affiche valeur non selectionne -----
if model.getOutput(0).revert == 0 then
	lcd.drawText(96, 20, "Nor"  , SMLSIZE) -- texte  
	else
	lcd.drawText(96, 20, "Rev"  , SMLSIZE) -- texte  
	end

end ----------------------- 
   
   
   
     
 if rot==16 then -------------- nb dent pinion moteur /   Logic Switch L08  
  
------ affiche valeur selectionnne -----
lcd.drawText(73, 29, model.getLogicalSwitch(7).v2 .. " dents" , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(7)
	valeur = tab.v2 -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,10,25,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,10,25,-1) -- detection rotary next ou prev
	end
		
	tab.v2 = valeur
	model.setLogicalSwitch(7, tab) -- assigner valeur de LS

	end

else ------ affiche valeur non selectionne -----
lcd.drawText(73, 29, model.getLogicalSwitch(7).v2 .. " dents" , SMLSIZE) -- texte

end ----------------------- 
   
    
   
   
   
   
   if rot==17 then -------------- VALEUR point speed thr   /   Logic Switch L14 
  
------ affiche valeur selectionnne -----
lcd.drawText(86, 38, model.getLogicalSwitch(13).v2 .. " %" , SMLSIZE+INVERS) -- texte fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(13)
	valeur = tab.v2 -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,5,95,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,5,95,-1) -- detection rotary next ou prev
	end
	
	tab.v2 = valeur
	model.setLogicalSwitch(13, tab) -- assigner valeur de LS

	end

else ------ affiche valeur non selectionne -----
lcd.drawText(86, 38, model.getLogicalSwitch(13).v2 .. " %" , SMLSIZE) -- texte

end ----------------------- 
   
  
  
  
  
if rot==18 then -------------- VALEUR coeff frein Av /  Input 8
------ affiche valeur  selectionne -----
-- lcd.drawText(66, 47,model.getInput(7, 0).weight+200 .. "%" , SMLSIZE+INVERS) -- texte
lcd.drawText(66, 47,model.getInput(7, 0).weight+200-1024 .. "%" , SMLSIZE+INVERS) -- DEBUGGGGGGGGGGGGGG   correction bug EDGETX

   	if modif == rot then -- si mode modif sur cet item
		  
		   valeur = model.getInput(7, 0).weight+200 -- recup valeur actuelle weight
			valeur = valeur -1024  -- DEBUGGGGGGGGGGGGGG   correction bug EDGETX
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
			valeur = choose(valeur,100,190,5) -- detection rotary next ou prev
						
			tab = model.getInput(7, 1) -- copier ligne 2
			model.deleteInput(7, 0) -- suppr ligne 1
			
			valeur = valeur + 1024  -- DEBUGGGGGGGGGGGGGG   correction bug EDGETX
			
				tab.weight = valeur - 200
			model.insertInput(7, 0,tab) -- inserer en ligne 1
			
			
	end
	
	
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 	valeur = choose(valeur,100,190,-5) -- detection rotary next ou prev
		
		tab = model.getInput(7, 1) -- copier ligne 2
			model.deleteInput(7, 0) -- suppr ligne 1
			
			valeur = valeur + 1024  -- DEBUGGGGGGGGGGGGGG   correction bug EDGETX
			
				tab.weight = valeur - 200
			model.insertInput(7, 0,tab) -- inserer en ligne 1
	
	end

	end


else ------ affiche valeur non selectionne -----
--lcd.drawText(66, 47,model.getInput(7, 0).weight+200 .. "%" , SMLSIZE) -- texte
lcd.drawText(66, 47,model.getInput(7, 0).weight+200-1024 .. "%" , SMLSIZE) -- texte  -- DEBUGGGGGGGGGGGGGG   correction bug EDGETX 

end
  
  
  
if rot==19 then -------------- VALEUR coeff frein Av /  Input 7
------ affiche valeur  selectionne -----
lcd.drawText(107, 47,200-model.getInput(6, 0).weight .. "%" , SMLSIZE+INVERS) -- texte


   	if modif == rot then -- si mode modif sur cet item
		  
		   valeur = 200-model.getInput(6, 0).weight -- recup valeur actuelle weight
	
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
			valeur = choose(valeur,100,190,5) -- detection rotary next ou prev
						
			tab = model.getInput(6, 1) -- copier ligne 2
			model.deleteInput(6, 0) -- suppr ligne 1
				tab.weight = 200 - valeur
				tab.offset = valeur-100
			model.insertInput(6, 0,tab) -- inserer en ligne 1
			
			
	end
	
	
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 	valeur = choose(valeur,100,190,-5) -- detection rotary next ou prev
		
		tab = model.getInput(6, 1) -- copier ligne 2
			model.deleteInput(6, 0) -- suppr ligne 1
				tab.weight = 200 - valeur
				tab.offset = valeur-100
			model.insertInput(6, 0,tab) -- inserer en ligne 1
	
	end

	end


else ------ affiche valeur non selectionne -----
lcd.drawText(107, 47,200-model.getInput(6, 0).weight .. "%" , SMLSIZE) -- texte
   
end  
  
  
  
  
if rot==20 then -------------- VALEUR feeling St  Ultra Fast ou Fast ou Medium ou Slow /   channel 10 copier les ligne de mix   
   
   ------ affiche valeur selectionnne -----
   
  if model.getMix(9, 2).speedUp == 0 then
   lcd.drawText(74, 56, "Instant" , SMLSIZE+INVERS) -- texte fond noir
	else
	lcd.drawText(74, 56,model.getMix(9, 2).speedUp/100 .. " s" , SMLSIZE+INVERS) -- texte fond noir
	end
   

    
   	if modif == rot then -- si mode modif sur cet item
	
	
	valeur = model.getMix(9, 2).speedUp
	
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
			valeur = choose(valeur,0,30,1) -- detection rotary next ou prev
			
			
			model.deleteMix(9, 3) -- suppr ligne 4 de channel 10
			model.deleteMix(9, 2) -- suppr ligne 3 de channel 10
			
			local tab = model.getMix(9, 0) -- copier ligne 1
			 tab.speedUp = valeur -- modif time de ligne copier
			 tab.multiplex = 2 -- remplacer channel
			model.insertMix(9, 2, tab) -- copier une ligne de mix et la coller dans ligne 3
			
			tab = model.getMix(9, 1) -- copier ligne 2
			 tab.speedDown = valeur -- modif time de ligne copier
			 tab.multiplex = 0 -- additionner channel
			model.insertMix(9, 3, tab) -- copier une ligne de mix et la coller dans ligne 4
			
			
	end
	
	
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 	valeur = choose(valeur,0,30,-1) -- detection rotary next ou prev
		
			model.deleteMix(9, 3) -- suppr ligne 4 de channel 10
			model.deleteMix(9, 2) -- suppr ligne 3 de channel 10
			
			local tab = model.getMix(9, 0) -- copier ligne 1
			 tab.speedUp = valeur -- modif time de ligne copier
			 tab.multiplex = 2
			model.insertMix(9, 2, tab) -- copier une ligne de mix et la coller dans ligne 3
			
			tab = model.getMix(9, 1) -- copier ligne 2
			 tab.speedDown = valeur -- modif time de ligne copier
			 tab.multiplex = 0
			model.insertMix(9, 3, tab) -- copier une ligne de mix et la coller dans ligne 4
		
	end

		
		

	end
  
   
   else ------ affiche valeur non selectionne -----
   

  if model.getMix(9, 2).speedUp == 0 then
   lcd.drawText(74, 56, "Instant" , SMLSIZE) -- texte
	else
	lcd.drawText(74, 56,model.getMix(9, 2).speedUp/100 .. " s" , SMLSIZE) -- texte
	end


   

   
end
   
   

elseif (rot >20 and rot<28) then --========================    PAGE 3    ======================  
   
    --========================= affiche texte fond =================================

lcd.drawText(1, 11, "ABS:" , SMLSIZE+INVERS) -- texte fond noir

lcd.drawText(22, 11, "Duty cycle" , SMLSIZE) -- texte fond noir  
lcd.drawText(1, 20, "Hold" , SMLSIZE) -- texte fond noir  
lcd.drawText(61, 20, "(" , SMLSIZE) -- texte fond noir  
lcd.drawText(65, 20, "Release" , SMLSIZE) -- texte fond noir  

lcd.drawText(1, 29, "DRAG Brake:" , SMLSIZE+INVERS) -- texte fond noir
lcd.drawText(58, 29, "Hold" , SMLSIZE) -- texte fond noir
lcd.drawText(1, 38, "Rise" , SMLSIZE) -- texte fond noir
 lcd.drawText(67, 38, "Fall" , SMLSIZE) -- texte fond noir
 
lcd.drawText(1, 47, "LIMITEUR DR Bouton:" , SMLSIZE+INVERS) -- texte fond noir

lcd.drawText(1, 56, "Mode Enfant:" , SMLSIZE+INVERS) -- texte fond noir
   
 -- ========================== affiche valeur ========================================
  
  

  
  
   if rot==21 then -------------- VALEUR reglage duty cycle  ABS  LS20
 lcd.drawText(71, 11, (129+model.getLogicalSwitch(19).v1)/10 .. " s" , SMLSIZE+INVERS) -- texte fond noir
 
 
 if modif == rot then -- si mode modif sur cet item

	local tab = model.getLogicalSwitch(19)
	valeur = tab.v1 -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,1-129,5-129,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,1-129,5-129,-1) -- detection rotary next ou prev
	end
		
	tab.v1 = valeur
	tab.v2 = valeur
	model.setLogicalSwitch(19, tab) -- assigner valeur de LS 

		 model.deleteMix(23, 1) -- suppr ligne 2 de channel 24
			tab = model.getMix(23, 0) -- copier ligne 1
			 tab.speedUp = 129+valeur -- modif time de ligne copier
			 tab.speedDown = 129+valeur -- modif time de ligne copier
			 tab.multiplex = 2
		model.insertMix(23, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
		

	end
 
 else ------ affiche valeur non selectionne -----
  lcd.drawText(71, 11, (129+model.getLogicalSwitch(19).v1)/10 .. " s" , SMLSIZE) 
end  
  
  	local tab = model.getCurve(31) -- COURBE abs 32
		local pos = {}
		pos = tab.x -- pos[1]  c'est la valeur x du premier point de la courbe
  


if rot==22 then -------------- VALEUR reglage hold time ABS curve abs
  lcd.drawText(24, 20, (129+model.getLogicalSwitch(19).v1)/1000*(100+pos[2]) .. " s" , SMLSIZE+INVERS) -- texte fond noir

  if modif == rot then -- si mode modif sur cet item


	

	valeur = pos[2]
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,-75,-25,2) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
		valeur = choose(valeur,-75,-25,-2) -- detection rotary next ou prev
	end
	
	
		
	pos[2] = valeur  -- POINT 2
	pos[3] = valeur  -- POINT 3
	pos[4] = - valeur  -- POINT 4 sym
	pos[5] = - valeur  -- POINT 5 sym
	tab.x = pos
	model.setCurve(31,tab)  -- COURBE
	
	
	
	

	end
 
 
 else ------ affiche valeur non selectionne -----
   lcd.drawText(24, 20, (129+model.getLogicalSwitch(19).v1)/1000*(100+pos[2]) .. " s" , SMLSIZE) 
end  
  
  
  
  lcd.drawText(102, 20, (129+model.getLogicalSwitch(19).v1)/10-(129+model.getLogicalSwitch(19).v1)/1000*(100+pos[2]), SMLSIZE)  -- affiche realese time abs
lcd.drawText(lcd.getLastPos()+2, 20, ")", SMLSIZE)  
  
  
  
  
  
  if rot==23 then -------------- VALEUR Tps drag brake /   channel 19 copier les ligne de mix   
   
   ------ affiche valeur selectionnne -----
  
   lcd.drawText(81, 29,model.getMix(18, 1).speedUp/50 .. " s", SMLSIZE+INVERS) -- texte fond noir
	
      
   	if modif == rot then -- si mode modif sur cet item
		  
		   valeur = model.getMix(18, 1).speedUp -- recup valeur actuelle tps drag brake
	
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
			valeur = choose(valeur,15,80,5) -- detection rotary next ou prev
			
			model.deleteMix(18, 1) -- suppr ligne 2 de channel 19
			tab = model.getMix(18, 0) -- copier ligne 1
			tab.speedUp = valeur -- modif time de ligne copier
			tab.multiplex = 2
		model.insertMix(18, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
		
		if model.getMix(19, 1).speedUp> valeur/5 then -- si valeur agressive drag brake trop grande
		model.deleteMix(19, 1) -- suppr ligne 2 de channel 20
			tab = model.getMix(19, 0) -- copier ligne 1
			tab.speedUp = math.floor( model.getMix(18, 1).speedUp/5 ) -- modif time de ligne copier
			tab.multiplex = 2
		model.insertMix(19, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
			end
			
	end
	
	
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 	valeur = choose(valeur,15,80,-5) -- detection rotary next ou prev
		
		model.deleteMix(18, 1) -- suppr ligne 2 de channel 19
			tab = model.getMix(18, 0) -- copier ligne 1
			tab.speedUp = valeur -- modif time de ligne copier
			tab.multiplex = 2
		model.insertMix(18, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
		
			if model.getMix(19, 1).speedUp> valeur/5 then -- si valeur agressive drag brake trop grande
		model.deleteMix(19, 1) -- suppr ligne 2 de channel 20
			tab = model.getMix(19, 0) -- copier ligne 1
			tab.speedUp = math.floor( model.getMix(18, 1).speedUp/5 ) -- modif time de ligne copier
			tab.multiplex = 2
		model.insertMix(19, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
			end
	end

	end
  
   
   else ------ affiche valeur non selectionne -----
   
   lcd.drawText(81, 29,model.getMix(18, 1).speedUp/50 .. " s", SMLSIZE) -- texte fond noir
   
end
  
  
  
  
  
  
  
  
    
  if rot==24 then -------------- VALEUR agressivité drag brake /   channel 20 copier les ligne de mix   
   
   ------ affiche valeur selectionnne -----

   lcd.drawText(24, 38,model.getMix(19, 1).speedUp/10 .. " s", SMLSIZE+INVERS) -- texte  
	
      
   	if modif == rot then -- si mode modif sur cet item
		  
		   
	maxdrg = math.floor( model.getMix(18, 1).speedUp/5 )
	valeur = model.getMix(19, 1).speedUp
	
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
			valeur = choose(valeur,0,maxdrg,1) -- detection rotary next ou prev
			
		model.deleteMix(19, 1) -- suppr ligne 2 de channel 19
			tab = model.getMix(19, 0) -- copier ligne 1
			tab.speedUp = valeur -- modif time de ligne copier
			tab.multiplex = 2
		model.insertMix(19, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
			
			
	end
	
	
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 	valeur = choose(valeur,0,maxdrg,-1) -- detection rotary next ou prev
		
		model.deleteMix(19, 1) -- suppr ligne 2 de channel 19
			tab = model.getMix(19, 0) -- copier ligne 1
			tab.speedUp = valeur -- modif time de ligne copier
			tab.multiplex = 2
		model.insertMix(19, 1, tab) -- copier une ligne de mix et la coller dans ligne 2
		
	end

	end
  
   
   else ------ affiche valeur non selectionne -----
 
   lcd.drawText(24, 38,model.getMix(19, 1).speedUp/10 .. " s", SMLSIZE) -- texte  
   
end
  
  
local tab = model.getCurve(25) -- COURBE drag dg3
local pos = {}
pos = tab.x
  
  
 if rot==25 then -------------- VALEUR fall drag brake  /   curve 25
   

   
   ------ affiche valeur selectionnne -----

   lcd.drawText(89, 38,(75+pos[3])* model.getMix(18, 1).speedUp/1000 .. " s", SMLSIZE+INVERS) -- texte  
	
      
	    if modif == rot then -- si mode modif sur cet item
	

	valeur = pos[3]
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,-75,-25,5) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
		valeur = choose(valeur,-75,-25,-5) -- detection rotary next ou prev
	end
		
	pos[3] = valeur  -- POINT 3
	tab.x = pos
	model.setCurve(25,tab)  -- COURBE


	end
	  
  
   
   else ------ affiche valeur non selectionne -----
 
   lcd.drawText(89, 38,(75+pos[3])* model.getMix(18, 1).speedUp/1000 .. " s", SMLSIZE) -- texte  
   
end
  
  
  
  
  
 if rot==26 then -------------- ACTIVATION limiteur DR bouton    /   Special Function CF11  / Logical switch  LS44 
  
------ affiche valeur selectionnne -----
case(94,46,model.getCustomFunction(10).active+2) -- case fond noir

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getCustomFunction(10)
	valeur = tab.active -- lire valeur de LS
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,0,1,1) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,0,1,-1) -- detection rotary next ou prev
	end
	
	tab.active = valeur
	model.setCustomFunction(10, tab) -- assigner valeur de LS
	
	local tab = model.getLogicalSwitch(43) -- recup valeur LS44
		
			tab.v2 = model.getCustomFunction(10).active*100
	model.setLogicalSwitch(43, tab) -- assigner valeur de LS44 

	
		
	end

else ------ affiche valeur non selectionne -----
case(94,46,model.getCustomFunction(10).active) -- case
end -----------------------  
  
  
  
  
  
  
   if rot==27 then -------------- VALEUR reglage mode enfant /   output 1 (ch2)
  
------ affiche valeur selectionnne -----

lcd.drawText(97, 56, model.getOutput(1).max  , SMLSIZE+INVERS) -- texte fond noir

if model.getOutput(1).max == 1000 then -- PAS mode enfant
case(86,55,2) -- case fond noir deselect
else
case(86,55,3) -- case fond noir select
end

	if modif == rot then -- si mode modif sur cet item

	local tab = model.getOutput(1)
	valeur = tab.max -- lire valeur de output
	
	if event == EVT_VIRTUAL_NEXT then -- bouton rotary next 
		valeur = choose(valeur,100,1000,50) -- detection rotary next ou prev
	end
	if event == EVT_VIRTUAL_PREV then -- bouton rotary next 
	 valeur = choose(valeur,100,1000,-50) -- detection rotary next ou prev
	end
		
	tab.max = valeur
	model.setOutput(1, tab) -- assigner valeur de output

	end

else ------ affiche valeur non selectionne -----

if model.getOutput(1).max == 1000 then -- PAS mode enfant
case(86,55,0) -- case   deselect
else
case(86,55,1) -- case   select
end

lcd.drawText(97, 56, model.getOutput(1).max  , SMLSIZE) -- texte

end ----------------------- 


	
end   -- ==========FIN PAGES ------------
	  
  
  -- page:
lcd.drawNumber(123, 56,"5", 0+INVERS) -- texte numero page

end