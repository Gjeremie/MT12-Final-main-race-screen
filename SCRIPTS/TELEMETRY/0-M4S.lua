local shared = ...

  local num = model.getInfo().name
  
  

  
function shared.run(event)
  lcd.clear()



---- touche bascule entre ecran -----------------
 if event == EVT_VIRTUAL_MENU then -- bouton menu 
    shared.changeScreen(6)
  end
  

lcd.drawText(1, 24, "     CONFIG             " , DBLSIZE+INVERS) -- TITRE
lcd.drawText(42, 51, num , MIDSIZE) -- model

-- icone voiture
  lcd.drawLine(28, 50, 35, 50, SOLID, FORCE)
  lcd.drawLine(28, 51, 34, 51, SOLID, FORCE)
  lcd.drawLine(13, 52, 18, 52, SOLID, FORCE)
  lcd.drawLine(28, 52, 33, 52, SOLID, FORCE)
  lcd.drawLine(5, 53, 6, 53, SOLID, FORCE)
  lcd.drawLine(12, 53, 13, 53, SOLID, FORCE)
  lcd.drawLine(18, 53, 20, 53, SOLID, FORCE)
  lcd.drawLine(27, 53, 32, 53, SOLID, FORCE)
  lcd.drawLine(5, 54, 6, 54, SOLID, FORCE)
  lcd.drawLine(11, 54, 12, 54, SOLID, FORCE)
  lcd.drawLine(18, 54, 21, 54, SOLID, FORCE)
  lcd.drawLine(27, 54, 29, 54, SOLID, FORCE)
  lcd.drawLine(4, 55, 6, 55, SOLID, FORCE)
  lcd.drawLine(10, 55, 11, 55, SOLID, FORCE)
  lcd.drawLine(18, 55, 30, 55, SOLID, FORCE)
  lcd.drawLine(3, 56, 10, 56, SOLID, FORCE)
  lcd.drawLine(15, 56, 31, 56, SOLID, FORCE)
  lcd.drawLine(2, 57, 3, 57, SOLID, FORCE)
  lcd.drawLine(7, 57, 27, 57, SOLID, FORCE)
  lcd.drawLine(31, 57, 32, 57, SOLID, FORCE)
  lcd.drawLine(1, 58, 2, 58, SOLID, FORCE)
  lcd.drawLine(8, 58, 26, 58, SOLID, FORCE)
  lcd.drawLine(32, 58, 33, 58, SOLID, FORCE)
  lcd.drawLine(1, 59, 2, 59, SOLID, FORCE)
  lcd.drawPoint(5, 59)
  lcd.drawLine(8, 59, 26, 59, SOLID, FORCE)
  lcd.drawPoint(29, 59)
  lcd.drawLine(32, 59, 33, 59, SOLID, FORCE)
  lcd.drawLine(1, 60, 2, 60, SOLID, FORCE)
  lcd.drawLine(8, 60, 9, 60, SOLID, FORCE)
  lcd.drawLine(25, 60, 26, 60, SOLID, FORCE)
  lcd.drawLine(32, 60, 33, 60, SOLID, FORCE)
  lcd.drawLine(2, 61, 3, 61, SOLID, FORCE)
  lcd.drawLine(7, 61, 8, 61, SOLID, FORCE)
  lcd.drawLine(26, 61, 27, 61, SOLID, FORCE)
  lcd.drawLine(31, 61, 32, 61, SOLID, FORCE)
  lcd.drawLine(3, 62, 7, 62, SOLID, FORCE)
  lcd.drawLine(27, 62, 31, 62, SOLID, FORCE)
  lcd.drawLine(4, 63, 6, 63, SOLID, FORCE)
  lcd.drawLine(28, 63, 30, 63, SOLID, FORCE)



end