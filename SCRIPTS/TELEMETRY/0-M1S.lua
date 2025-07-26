local shared = ...

 local num = model.getInfo().name
local delai = 150 -- delai demarrage 1.5 sec
local start = getTime()+100 -- + delai 1 s 
local pot1
local pot2
local i=0
local alert = 0

function shared.run(event)
  lcd.clear()



---- touche bascule entre ecran -----------------

if shared.strt == 1 then -- si pas demarrage telco 

 if event == EVT_VIRTUAL_MENU    then -- bouton menu 
    shared.changeScreen(2)
  end

lcd.drawText(1, 24, "     ACCUEIL      " , DBLSIZE+INVERS) -- TITRE



else -- si premier demarrage telco

 if  getTime()  > delai + start   then -- bouton menu 
    shared.strt = 1
	shared.changeScreen(2)
  end

-- fond noir
lcd.drawFilledRectangle(0, 23, 128,17, SOLID)
lcd.drawPoint(0,23)
lcd.drawPoint(0,39)
lcd.drawPoint(127,23)
lcd.drawPoint(127,39)


-- fond
lcd.drawPoint(27,25)
lcd.drawPoint(44,25)
lcd.drawPoint(49,25)
lcd.drawPoint(60,25)
lcd.drawPoint(71,25)
lcd.drawLine(71,26,72,26, SOLID, ERASE)
lcd.drawLine(29,29,32,29, SOLID, ERASE)
lcd.drawLine(62,29,65,29, SOLID, ERASE)
lcd.drawPoint(75,29)
lcd.drawLine(71,32,72,32, SOLID, ERASE)
lcd.drawPoint(27,33)
lcd.drawPoint(44,33)
lcd.drawPoint(49,33)
lcd.drawPoint(60,33)
lcd.drawPoint(71,33)
lcd.drawLine(39,28,39,32, SOLID, ERASE)
lcd.drawLine(54,29,54,32, SOLID, ERASE)
lcd.drawLine(55,29,55,33, SOLID, ERASE)
lcd.drawLine(56,29,56,32, SOLID, ERASE)
lcd.drawLine(70,24,70,26, SOLID, ERASE)
lcd.drawLine(70,32,70,34, SOLID, ERASE)
lcd.drawLine(74,28,74,30, SOLID, ERASE)
lcd.drawLine(84,26,84,34, SOLID, ERASE)
lcd.drawLine(90,24,90,25, SOLID, ERASE)
lcd.drawLine(90,33,90,34, SOLID, ERASE)
lcd.drawLine(91,24,91,26, SOLID, ERASE)
lcd.drawLine(91,32,91,34, SOLID, ERASE)
lcd.drawLine(92,24,92,28, SOLID, ERASE)
lcd.drawLine(92,30,92,34, SOLID, ERASE)
lcd.drawLine(93,26,93,32, SOLID, ERASE)
lcd.drawLine(94,28,94,30, SOLID, ERASE)
lcd.drawLine(95,26,95,32, SOLID, ERASE)
lcd.drawLine(96,24,96,28, SOLID, ERASE)
lcd.drawLine(96,30,96,34, SOLID, ERASE)
lcd.drawLine(97,24,97,26, SOLID, ERASE)
lcd.drawLine(97,32,97,34, SOLID, ERASE)
lcd.drawLine(98,24,98,25, SOLID, ERASE)
lcd.drawLine(98,33,98,34, SOLID, ERASE)


-- dessin manuel

lcd.drawFilledRectangle(70, 27, 4, 5, ERASE)
lcd.drawRectangle(79, 24, 9, 2, ERASE)
lcd.drawRectangle(28, 24, 7, 2, ERASE)
lcd.drawRectangle(28, 33, 7, 2, ERASE)
lcd.drawRectangle(37, 24, 7, 2, ERASE)
lcd.drawRectangle(50, 24, 7, 2, ERASE)
lcd.drawRectangle(37, 33, 7, 2, ERASE)
lcd.drawRectangle(61, 24, 7, 2, ERASE)
lcd.drawRectangle(61, 33, 7, 2, ERASE)
lcd.drawRectangle(50, 33, 5, 2, ERASE)
lcd.drawRectangle(37, 28, 2, 5, ERASE)
lcd.drawRectangle(82, 26, 2, 9, ERASE)
lcd.drawFilledRectangle(26, 26, 3, 7, ERASE)
lcd.drawFilledRectangle(43, 26, 3, 7, ERASE)
lcd.drawFilledRectangle(48, 26, 3, 7, ERASE)
lcd.drawFilledRectangle(59, 26, 3, 7, ERASE)

lcd.drawRectangle(26, 37, 42, 2, ERASE) 





if shared.pop > 4  then -- si potar bougé ou SA pas centré
start = getTime() -- attendre avant autre ecran







pot1 = (math.floor((shared.pop % 10000)/1000) .. math.floor((shared.pop % 1000)/100) .. math.floor((shared.pop % 100)/10))
pot2 = (math.floor((shared.pop % 10000000)/1000000) .. math.floor((shared.pop % 1000000)/100000) .. math.floor((shared.pop % 100000)/10000))

pot1 = tonumber(pot1)
pot2 = tonumber(pot2)


i= 0 

	if pot1 > getValue('input4')/10.24+1.5 or pot1 < getValue('input4')/10.24-1.5 then -- si potar pas comme ancienne sauvegarde
	lcd.drawText(22, i, "Pot DR St: "  .. pot1 , 0)
	lcd.drawText(lcd.getLastRightPos()+10, i, math.floor(getValue('input4')/10.24+0.5) , INVERS)
	i=i+9
	end

	if pot2 > getValue('input5')/10.24+1.5 or pot2 < getValue('input5')/10.24-1.5 then -- si potar pas comme ancienne sauvegarde
	lcd.drawText(22, i, "Pot DR Th: "  .. pot2 , 0)
	lcd.drawText(lcd.getLastRightPos()+10, i, math.floor(getValue('input5')/10.24+0.5) , INVERS)
	i=i+9
	end
	
	if getValue('sa') ~= 0 then -- si SA pas centré
	alert = 1 -- vibre pas car vibre deja directemlent avec SA mal positionné
	lcd.drawText(22, i, "Switch SA: -"  , 0)
		if getValue('sa') < 0 then
		lcd.drawSwitch(lcd.getLastRightPos()+10, i, 1, INVERS)
		else
		lcd.drawSwitch(lcd.getLastRightPos()+10, i, 3, INVERS)
		end
	i = i+9
	end


if alert == 0 then
playHaptic(300, 1000 ) -- alerte vibre
alert = 1
end


if i ~= 0 then
	-- icone warning:
	lcd.drawLine(7,0,8,0, SOLID, FORCE)
	lcd.drawLine(1,15,14,15, SOLID, FORCE)
	lcd.drawLine(2,16,13,16, SOLID, FORCE)
	lcd.drawLine(7,6,7,10, SOLID, FORCE)
	lcd.drawLine(7,12,7,13, SOLID, FORCE)
	lcd.drawLine(8,6,8,10, SOLID, FORCE)
	lcd.drawLine(8,12,8,13, SOLID, FORCE)

	lcd.drawLine(6,1,1,14, SOLID, FORCE)
	lcd.drawLine(7,1,2,14, SOLID, FORCE)
	lcd.drawLine(8,1,13,14, SOLID, FORCE)
	lcd.drawLine(9,1,14,14, SOLID, FORCE)
end



end









end


 
lcd.drawText(1, 44, num , MIDSIZE) -- model






end