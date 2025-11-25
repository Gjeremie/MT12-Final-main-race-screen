local shared = ...

  local num = model.getInfo().name
  
  

  
function shared.run(event)
  lcd.clear()



---- touche bascule entre ecran -----------------
 if event == EVT_VIRTUAL_MENU then -- bouton menu 
    shared.changeScreen(6)
  end
  

lcd.drawText(1, 24, "     CONFIG             " , DBLSIZE+INVERS) -- TITRE
lcd.drawText(48, 51, num , MIDSIZE) -- model

-- icone voiture
  lcd.drawLine(20, 52, 26, 52, SOLID, FORCE)
  lcd.drawLine(17, 53, 20, 53, SOLID, FORCE)
  lcd.drawLine(24, 53, 30, 53, SOLID, FORCE)
  lcd.drawLine(37, 53, 40, 53, SOLID, FORCE)
  lcd.drawLine(15, 54, 17, 54, SOLID, FORCE)
  lcd.drawLine(24, 54, 33, 54, SOLID, FORCE)
  lcd.drawLine(36, 54, 40, 54, SOLID, FORCE)
  lcd.drawLine(5, 55, 15, 55, SOLID, FORCE)
  lcd.drawLine(24, 55, 37, 55, SOLID, FORCE)
  lcd.drawLine(3, 56, 13, 56, SOLID, FORCE)
  lcd.drawLine(21, 56, 38, 56, SOLID, FORCE)
  lcd.drawLine(2, 57, 5, 57, SOLID, FORCE)
  lcd.drawLine(7, 57, 9, 57, SOLID, FORCE)
  lcd.drawLine(11, 57, 28, 57, SOLID, FORCE)
  lcd.drawLine(30, 57, 32, 57, SOLID, FORCE)
  lcd.drawLine(34, 57, 38, 57, SOLID, FORCE)
  lcd.drawLine(1, 58, 4, 58, SOLID, FORCE)
  lcd.drawLine(6, 58, 10, 58, SOLID, FORCE)
  lcd.drawLine(12, 58, 27, 58, SOLID, FORCE)
  lcd.drawLine(29, 58, 33, 58, SOLID, FORCE)
  lcd.drawLine(35, 58, 37, 58, SOLID, FORCE)
  lcd.drawLine(1, 59, 3, 59, SOLID, FORCE)
  lcd.drawLine(5, 59, 11, 59, SOLID, FORCE)
  lcd.drawLine(13, 59, 26, 59, SOLID, FORCE)
  lcd.drawLine(28, 59, 34, 59, SOLID, FORCE)
  lcd.drawLine(36, 59, 37, 59, SOLID, FORCE)
  lcd.drawLine(1, 60, 3, 60, SOLID, FORCE)
  lcd.drawLine(5, 60, 7, 60, SOLID, FORCE)
  lcd.drawLine(9, 60, 11, 60, SOLID, FORCE)
  lcd.drawLine(13, 60, 26, 60, SOLID, FORCE)
  lcd.drawLine(28, 60, 30, 60, SOLID, FORCE)
  lcd.drawLine(32, 60, 34, 60, SOLID, FORCE)
  lcd.drawPoint(36, 60)
  lcd.drawLine(1, 61, 3, 61, SOLID, FORCE)
  lcd.drawLine(5, 61, 11, 61, SOLID, FORCE)
  lcd.drawLine(13, 61, 26, 61, SOLID, FORCE)
  lcd.drawLine(28, 61, 34, 61, SOLID, FORCE)
  lcd.drawLine(6, 62, 10, 62, SOLID, FORCE)
  lcd.drawLine(29, 62, 33, 62, SOLID, FORCE)
  lcd.drawLine(7, 63, 9, 63, SOLID, FORCE)
  lcd.drawLine(30, 63, 32, 63, SOLID, FORCE)



end