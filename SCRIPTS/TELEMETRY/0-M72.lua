local shared = ...
  
  
  local function channel(y,ch) -- dessin channel
  
  lcd.drawText(1+12, y-3,   "CH" .. ch+1 , SMLSIZE+INVERS)  
  
  
  if ch == 0 then -- correction pour channel St 988-2012  a  700-2300  us
  
		if -100+math.floor(((700+math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*1600/1024+0.5))-988)*200/1024+0.5) <0 then -- si negatif
			if -100+math.floor(((700+math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*1600/1024+0.5))-988)*200/1024+0.5) < -99 then -- si -100
			lcd.drawLine(29,y+3,31,y+3, SOLID, FORCE) -- signe -
			lcd.drawText(18+14, y,  100-math.floor(((700+math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*1600/1024+0.5))-988)*200/1024+0.5), SMLSIZE)   -- valeur % de CH
			else -- sinon
			lcd.drawLine(29,y+3,31,y+3, SOLID, FORCE) -- signe -
			lcd.drawText(18+16, y,  100-math.floor(((700+math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*1600/1024+0.5))-988)*200/1024+0.5), SMLSIZE)   -- valeur % de CH
			end
		else-- positif
		lcd.drawText(18+12, y,  -100+math.floor(((700+math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*1600/1024+0.5))-988)*200/1024+0.5), SMLSIZE)   -- valeur % de CH
		end
		lcd.drawText(lcd.getLastRightPos()+2 , y, "%" , SMLSIZE)

		lcd.drawText(97, y, (700+math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*1600/1024+0.5))  , SMLSIZE)   -- valeur us de CH

		lcd.drawLine(54+math.floor(((700+math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*1600/1024+0.5))-988)*40/1024+0.5),y-5,54+math.floor(((700+math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*1600/1024+0.5))-988)*40/1024+0.5),y-2, SOLID, FORCE) -- curseur live
		
		
	else -- affiche normale
	
		if -100+math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*200/1024+0.5) <0 then -- si negatif
			if -100+math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*200/1024+0.5) < -99 then -- si -100
			lcd.drawLine(29,y+3,31,y+3, SOLID, FORCE) -- signe -
			lcd.drawText(18+14, y,  100-math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*200/1024+0.5), SMLSIZE)   -- valeur % de CH
			else -- sinon
			lcd.drawLine(29,y+3,31,y+3, SOLID, FORCE) -- signe -
			lcd.drawText(18+16, y,  100-math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*200/1024+0.5), SMLSIZE)   -- valeur % de CH
			end
		else-- positif
		lcd.drawText(18+12, y,  -100+math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*200/1024+0.5), SMLSIZE)   -- valeur % de CH
		end
		lcd.drawText(lcd.getLastRightPos()+2 , y, "%" , SMLSIZE)

		lcd.drawText(97, y, (1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)  , SMLSIZE)   -- valeur us de CH

		lcd.drawLine(54+math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*40/1024+0.5),y-5,54+math.floor(((1500 + math.floor(getOutputValue(ch)/2+0.5) + model.getOutput(ch).ppmCenter)-988)*40/1024+0.5),y-2, SOLID, FORCE) -- curseur live
		
		
	end	
  
  
  
  lcd.drawText(lcd.getLastRightPos()+2 , y, "us" , SMLSIZE)
lcd.drawLine(54,y-1,94,y-1, SOLID, FORCE)
lcd.drawLine(54,y,94,y, SOLID, FORCE)
lcd.drawLine(54,y,54,y+1, SOLID, FORCE)
lcd.drawLine(94,y,94,y+1, SOLID, FORCE)
lcd.drawLine(74,y,74,y+1, SOLID, FORCE)
  end
  
function shared.run(event)
  lcd.clear()
--  titre
  lcd.drawText(1, 1, "CHANNELS                                   ", INVERS)


-- valeur us channels

-- echelle
lcd.drawText(46, 58,   "988 1500 2012" , SMLSIZE) 
lcd.drawLine(54,54,54,55+1, SOLID, FORCE)
lcd.drawLine(94,54,94,55+1, SOLID, FORCE)
lcd.drawLine(74,54,74,55+1, SOLID, FORCE)



channel(17,(1)-1) -- dessin channel CH1
lcd.drawText(1, 14,   "St"  , SMLSIZE+INVERS)  

channel(27,(2)-1) -- dessin channel CH2
lcd.drawText(1, 24,   "Th"  , SMLSIZE+INVERS)  

channel(37,(3)-1) -- dessin channel CH3
lcd.drawText(1, 34,   "Fa"  , SMLSIZE+INVERS)  

channel(47,(4)-1) -- dessin channel CH4
lcd.drawText(1, 44,   "Br"  , SMLSIZE+INVERS)  




---- touche bascule entre ecran -----------------
 if event == EVT_VIRTUAL_NEXT_PAGE then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(10)
  end
   if event == EVT_VIRTUAL_PREV_PAGE then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(14)
  end
  
 if event == EVT_VIRTUAL_MENU_LONG then -- bouton menu 
 playTone(1200, 120,5) -- play tone
    shared.changeScreen(1)
  end

  


  
  
  

	  
	  
	
  
  -- page:
lcd.drawNumber(123, 56,"8", 0+INVERS) -- texte numero page

end