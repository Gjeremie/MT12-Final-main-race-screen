//  Arduino board   Seeed XIAO ESP32 S3

// https://github.com/AlfredoSystems/AlfredoCRSF/tree/main

//  https://github.com/RobTillaart/RunningMedian

// HWTelemetry : librairie perso modifié pour non bloquante.  basé sur https://github.com/PotatoNukeMk1/HWTelemetry

// https://github.com/sparkfun/SparkFun_u-blox_GNSS_Arduino_Library


#include <Preferences.h> // AJOUT : Pour la sauvegarde en mémoire flash

#include <SparkFun_u-blox_GNSS_Arduino_Library.h>  //    gps

#include <HardwareSerial.h>

#include <AlfredoCRSF.h> // lib csrf

#include <RunningMedian.h> // lib mediane mobile

#include "esp_task_wdt.h" //   watchdog

#include <HWTelemetry.h> // telem ESC  Hobbywing																				  


Preferences preferences; // AJOUT : Objet pour gérer la sauvegarde


// def des variable pour faire mediane des relevés

int tailleEchantillonTension = 50; // Valeur par défaut
RunningMedian *MOYtension;         // MODIFIÉ : Déclaration en pointeur
   
RunningMedian MOYcourant = RunningMedian(3); // moyenne glissante de 3 - Courant  
RunningMedian MOYtemperature1 = RunningMedian(10); // mediane glissante de 10 - Temperature
RunningMedian MOYtemperature2 = RunningMedian(10); // mediane glissante de 10 - Temperature
RunningMedian MOYrpm = RunningMedian(5); // moyenne glissante de 5 - RPM
RunningMedian MOYlat = RunningMedian(8); // moyenne glissante de 8 - latitude
RunningMedian MOYlon = RunningMedian(8); // moyenne glissante de 8 - longitude

// recup valeur channel 11 et 12 en us
int ch11_val = 1500;
int ch12_val = 1500;
int retour = 0; // retour info valeur modifiable

// pour frequenece verif valeur
unsigned long datedebut2 = 0;
unsigned long pulsedebut = 0;
unsigned long pulsecapa = 0;

// coeff courant  1000 represente 100.0%, valeur non modifiée
int coeff=1000;

  // tension courant et temperature
  float tension = 36.0; // init a 6000 Mv par cellule (36 V totale)
  float courant = 0;
  
  // capacité
 float capa = 0;

// temperature
float temperature1 = 0;
float temperature2 = 0;

// RPM
float rpm = 0; // rpm moteur  ( t/ min)

// distance
float dist = 0;



// Variables de temporisation
static unsigned long lastSend = 0;
static bool sendBatt = true;

// UART1 pour envoie CSRF
HardwareSerial crsfSerial(1);  
AlfredoCRSF crsf; 

  
// UART0 pour récup telem hobbywing
HardwareSerial Hobbywing(0);  

// UART2 pour le GPS   // 
SFE_UBLOX_GNSS myGPS;
HardwareSerial GPS_Serial(2); // 



// pour detection erreur telemetrie hobbywing
volatile unsigned long lastTelemetryTime = 0;       // temps du derniere trame recue



// --- DEBUT BLOC MULTI-CORE GPS ---

// Variables pour partager les données GPS entre les cœurs
volatile int32_t shared_lat = 450000000;
volatile int32_t shared_lon = 50000000;
volatile bool gpsIsConnected = false;

// Tâche dédiée au GPS qui s'exécutera sur le Cœur 0
void gpsTask(void *pvParameters) {
  // Initialisation de la librairie GPS sur ce cœur
  if (myGPS.begin(GPS_Serial)) {
    gpsIsConnected = true;
  }

  // Boucle infinie de la tâche
  for (;;) {
    if (gpsIsConnected) {
      // On vérifie les données. Même si c'est bloquant, ça ne gêne que ce cœur.
      if (myGPS.checkUblox() && myGPS.getPVT()) {





        int fixType = myGPS.getFixType();
        uint8_t sats = myGPS.getSIV();
        if (fixType >= 3 && sats >= 6) {
          shared_lat = myGPS.getLatitude();
          shared_lon = myGPS.getLongitude();
        }
        else {
          shared_lat = 450000000;
          shared_lon = 50000000;
        }


      }
    }
    // Petite pause pour être un bon citoyen du système
    vTaskDelay(10 / portTICK_PERIOD_MS);
  }
}
// --- FIN BLOC MULTI-CORE GPS ---


// =========================================== FONCTIONs ===================================  
					 

void hwtCallback() {

  rpm = HWTelemetry.getRPM();
  tension = HWTelemetry.getVoltage();  
  courant = HWTelemetry.getCurrent() ; // additione courant moteur (6s) + courant bec (2s) ramener a conso courant sur batterie 6s en /3 = + HWTelemetry.getBECCurrent()/3.0
  temperature2 = HWTelemetry.getESCTemperature();
  temperature1 = HWTelemetry.getMotorTemperature();
  
  	
lastTelemetryTime = millis();       // temps du dernier calcul de fréquence

	
 // Assigner  courant 
	MOYcourant.add(courant*coeff); // ajoute derniere valeur relevé courant a mediane en mA
	
// assigner rpm
	MOYrpm.add(rpm/2.0); // ajoute derniere valeur relevé rpm a mediane
// rpm en t/min et diviser par 2 pour ne pas depasser limite chiffre donc coeff 510 sur coeff telco edgeTX pour recup bon nombre

  
  
}









//============================================   SETUP  ====================================  

void setup() {
	
	
	// AJOUT : Chargement des préférences depuis la mémoire flash
  preferences.begin("settings", true); // Ouvre les préférences en mode lecture seule ("settings" est un nom que vous choisissez)
  coeff = preferences.getInt("coeff", 1000); // Charge 'coeff', si non trouvée, utilise 1000
  tailleEchantillonTension = preferences.getInt("tailleTens", 50); // Charge 'tailleTens', si non trouvée, utilise 50
  preferences.end(); // Ferme les préférences

  // Initialisation de l'objet MOYtension avec la taille chargée ou par défaut
  MOYtension = new RunningMedian(tailleEchantillonTension);
	
	
	
	
	
 //  UART0
Hobbywing.begin(115200, SERIAL_8N1, 7, -1);    
 // RX actif sur pin 7 et TX desactivé avec -1    
 HWTelemetry.begin(Hobbywing);
HWTelemetry.attach(hwtCallback);
HWTelemetry.setMotorPoles(4); // moteur 4 poles
  
  // UART 1
crsfSerial.begin(CRSF_BAUDRATE, SERIAL_8N1, 5, 6); 
 // X2=5=RX ESP32 (vers TX du recepteur ELRS Er6G )  puis   X1=6=TX ESP32 (vers RX  du recepteur ELRS Er6G )		  
crsf.begin(crsfSerial);
  
  
  
  //  UART2
  GPS_Serial.begin(115200, SERIAL_8N1, 8, 4); // <- ON GARDE CETTE LIGNE
  // BAUD selon la config du GPS
  // 8=RX ESP32 (vers TX du GPS)  puis   4=TX ESP32 (vers RX du GPS)
  delay(200);
  // myGPS.begin(GPS_Serial); // <- ON SUPPRIME CETTE LIGNE, elle est maintenant dans gpsTask

  
  
  
  
  
  

  

   // AJOUT : Lancement de la tâche GPS sur le Cœur 0
  xTaskCreatePinnedToCore(
    gpsTask,    // La fonction à exécuter
    "GPSTask",  // Un nom pour la tâche
    4096,       // La taille de la pile
    NULL,       // Pas de paramètres
    1,          // Priorité 1
    NULL,       // Pas de handle
    0           // Épingler au Cœur 0
  );




datedebut2 = millis();
pulsedebut = millis();
pulsecapa = millis();


MOYtemperature1.add(temperature1); // ajoute derniere valeur relevé temperature  a mediane
MOYtemperature2.add(temperature2); // ajoute derniere valeur relevé temperature  a mediane
MOYtension->add(6000); // MODIFIÉ: Utilisation de -> au lieu de .      ajoute derniere valeur relevé tension a mediane en mv
MOYcourant.add(courant*coeff); // ajoute derniere valeur relevé courant a mediane en mA
MOYrpm.add(rpm/2); // ajoute derniere valeur relevé rpm a mediane
MOYlat.add(450000000); // ajoute 0 a lat
MOYlon.add(50000000); // ajoute 0 a lon

lastTelemetryTime = millis();       // temps du dernier calcul de fréquence


// Config du Watchdog (nouvelle API ESP-IDF 5.x+)
  esp_task_wdt_config_t wdt_config = {
    .timeout_ms = 2000,  // timeout de 2 secondes
    .idle_core_mask = (1 << portNUM_PROCESSORS) - 1, // Sur ESP32-C3 = 1
    .trigger_panic = true
  };

  esp_task_wdt_init(&wdt_config);
  esp_task_wdt_add(NULL);  // Ajouter la tâche loop() au Watchdog

   






 
}






void loop() {
	
	





// appel fonction dès que donnée telem recu de hobbywing
HWTelemetry.processInput();
// rq= quand gaz pas au neutre hobbywing transmet a 50Hz (sinon a 10 Hz)													 

 // Must call crsf.update() in loop() to process data
 crsf.update();
// rq= avec ELRS en 500HZ et telemetry ratio sur 1/2 : transmission toute les 4 ms theorique possible





























  if ((millis()-pulsecapa)>25) { // a faire tous les 25 ms  


	  // Calcul fréquence réception Hobbywing

  if (millis() - lastTelemetryTime > 1000) { // si rien recu depuis plus de 1 s

  rpm = 0;
  tension = 30.0;  // met a 5000 mv
  courant = 0;
  temperature2 = 0;
  temperature1 = 0;
  
 MOYtension->clear();   // Vide l'historique des 40 dernières valeurs
    MOYtension->add(5000); // On la remplit immédiatement avec la valeur cible
	
 // Assigner  courant 
	MOYcourant.add(0); // ajoute 0
	
// assigner rpm
	MOYrpm.add(0); // ajoute 0
	
  }
else{
	  	  esp_task_wdt_reset(); // reset watchdog regulierement    
	
	
	
	
		 // calcul capa consommée
capa = capa + MOYcourant.getAverage() /144000.0 ; // 0.025 = 25ms            * 0.025/3600 = /144000
	

// Assigner tension  
	
	if (tension > 6 ) {  // vérif si envoie pas 0 V (if superieur a 1V par cellule 6S)
	MOYtension->add(tension*1000.0/6.0); // ajoute derniere valeur relevé tension a mediane en mv, /6 pour 6S
	}

	
}









	
MOYlat.add(shared_lat); // ajoute derniere valeur relevé ;  latitude*10000000  exemple: 474569876 = 47.4569876
     
      MOYlon.add(shared_lon); // ajoute derniere valeur relevé ; longitude*10000000  exemple: 44569876 = 4.4569876
	
	
	
	
		
	 
	 
  // **** NOUVEAU BLOC DE RÉGLAGE ET SAUVEGARDE VIA RADIO ****
   ch11_val = crsf.getChannel(11);
   ch12_val = crsf.getChannel(12);

	
	
	
	
	
	
	pulsecapa=millis();
}












if ((millis()-datedebut2)>250) { // a faire tous les 250 ms

	 retour = 0; // met retour variable a zero

	MOYtemperature1.add(temperature1); // ajoute derniere valeur relevé temperature  a mediane
	 MOYtemperature2.add(temperature2); // ajoute derniere valeur relevé temperature  a mediane
	 
	 // calcul distance
	 dist = dist + MOYrpm.getAverage() * 7.0 / 1058.0 * 551.0 / 900000.0 ;
	 // dist = dist + (MOYrpm.getAverage()* 2.0 / 240.0) * 4408.0 / 60000.0 * 14.0 / 46.0 * 1.0 / 46.0;   // distance qui une fois multiplié par (nb de dent pinion moteur) * 10 = distance en m
	 // 14/46 = rapport pinion attaque             .../46= rapport couronne moteur
	 // MOYrpm.getAverage() /240 car /60 puis /4 pour nb de tour en 250 ms
	 // MOYrpm.getAverage() * 2 car MOY rpm est égale a rpm /2
	 
	 
	 
	 
  // **** NOUVEAU BLOC DE RÉGLAGE ET SAUVEGARDE VIA RADIO ****
  // --- Mode 1: Modification du coefficient du courant (CH11 ~ 1000µs) ---
  if (ch11_val >= 1040-20 && ch11_val <= 1040+20) { // offset 10
	  retour = coeff/2-450; // assigne variable retour a coeff
    long nouveau_coeff = floor(ch12_val/5.12-192.9688+0.5)+900; // Map pour offset sur mixage CH12 telco 1 a 200 == coeff de 902 a 1100
    if (nouveau_coeff != coeff) {
      coeff = nouveau_coeff;
      preferences.begin("settings", false); // Ouvre en mode écriture
      preferences.putInt("coeff", coeff);   // Sauvegarde la nouvelle valeur
      preferences.end();                    // Ferme et écrit en flash
    }
  }
  // --- Mode 2: Modification de la taille de l'échantillon tension (CH11 ~ 1100µs) ---
  else if (ch11_val >= 1090-20 && ch11_val <= 1090+20) { // offset 20
	  retour = tailleEchantillonTension/2; // assigne variable retour a tailleEchantillonTension
    int nouvelleTaille = floor(ch12_val/5.12-192.9688+0.5); // Map pour offset sur mixage CH12 telco 1 a 200 == tailleEchantillonTension de 2 a 200
    if (nouvelleTaille != tailleEchantillonTension) {
      tailleEchantillonTension = nouvelleTaille;
      
      delete MOYtension; // Libère l'ancienne mémoire
      MOYtension = new RunningMedian(tailleEchantillonTension); // Crée le nouvel objet
      MOYtension->add(6000); // Pré-remplit avec une valeur
      
      preferences.begin("settings", false); // Ouvre en mode écriture
      preferences.putInt("tailleTens", tailleEchantillonTension); // Sauvegarde la nouvelle taille
      preferences.end(); // Ferme et écrit en flash
    }
  }
	 
	 else if (ch11_val >= 1140-20 && ch11_val <= 1140+20) { // offset 30
		 retour = coeff/2-450; // assigne variable retour a coeff
	 }
	 
	 else if (ch11_val >= 1190-20 && ch11_val <= 1190+20) { // offset 40
		 retour = tailleEchantillonTension/2; // assigne variable retour a tailleEchantillonTension
	 }
	
	  
	  
	  
	  
	  // ****  lit valeur channel 11 =
		  else if( ch11_val > 1600) { // si ch11 sup a pos milieu (1500)
	// crsf.getChannel(11);   // pour recup position channel 11 (en micro second)

	capa = 0; // reset capa consommée
	dist = 0; // reset distance (nb tour moteur)
	}




 datedebut2=millis();


} 












  

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // *************  Envoi alterné entre batterie et GPS toutes les 33 ms (30 Hz au total donc envoie sendGps a 15Hz et sendRxBattery a 15Hz)  ***************
if (millis() - lastSend >= 33) {
        if (sendBatt) {
		// ********* envoie packet RX BATTERY
		















				if (millis()<30000) { // a faire au debut pendant 30 sec
					if ((millis()-pulsedebut)>5000) { // a faire tous les 5000 ms et pendant 200ms
					  sendRxBattery(6000, MOYcourant.getAverage()/10.0, MOYtemperature1.getMedian(), retour);   // envoie valeur avec tension fake a 6V 
					  					 
					}
					else { // sinon envoie valeur normale
					  sendRxBattery(MOYtension->getAverage(), MOYcourant.getAverage()/10.0, MOYtemperature1.getMedian(), retour);  
					  
					  // tension en Mv     -    Courant en Centi A (4523 = 45230 mA)   -    Temperature  en degree - retour valeur modifiable 
					}
					if ((millis()-pulsedebut)>5200) { // reset 200 ms apres
					pulsedebut=millis();
					}
				}

				else { // apres 30 sec
					   sendRxBattery(MOYtension->getAverage(), MOYcourant.getAverage()/10.0, MOYtemperature1.getMedian(), retour);  
					  // tension en Mv     -    Courant en Centi A (4523 =   45 230 mA)   -    Temperature  en degree - retour valeur modifiable 
				}
            
			
        } else {
		// ********** envoie packet GPS / ALT

// IMPORTANT !!!!!!!!   : latitude et longitude codé par rapport a la position relative lat/long = 45°/5°

			if (millis()<3000) { // faire seulement apres 3 seconde de démarrage de ESP32 afin que dist et capa soit a 0 apres restart pour recup ancienne valeur par lua EdgeTx
				sendGps(MOYlat.getAverage()-450000000, MOYlon.getAverage()-50000000, MOYrpm.getAverage(), MOYtemperature2.getMedian(), 0 , 0);
			}
			else { // faire ensuite
			sendGps(MOYlat.getAverage()-450000000, MOYlon.getAverage()-50000000, MOYrpm.getAverage(), MOYtemperature2.getMedian(), capa , dist);   
				//   rpm en t/min dans champ groundspeed    temperature ESC dans heading      capacité en  mA/H   dans champ Alt          distance  dans champ satellite (46 donne 46 *16 *10 *3/2 =  7360 m parcouru)
			}
			
        }
        
        // Basculer l'envoi pour le prochain cycle
        sendBatt = !sendBatt;
        lastSend = millis();
}
  
  
  
  
  
  
  
  

  
  
  
  
  
  
  
  
}     //   FIN LOOP




// Fonction pour envoie 4 valeur dans la telem tension
static void sendRxBattery(float voltage, float current, float capacity, float remaining)
{
  crsf_sensor_battery_t crsfBatt = { 0 };

  // Values are MSB first (BigEndian)
  crsfBatt.voltage = htobe16((uint16_t)(voltage));   // -  pour récup valeur identique faire x10 dans config sensor EDGETX (Ratio 255)  - MAX 65535
  crsfBatt.current = htobe16((uint16_t)(current));   //  -  pour récup valeur identique faire x10 dans config sensor EDGETX (Ratio 255)  - MAX 65535
  crsfBatt.capacity = htobe16((uint16_t)(capacity)) << 8;   // -  récup valeur identique faire x10 dans config sensor EDGETX (Ratio 255) - MAX 65535
  crsfBatt.remaining = (uint8_t)(remaining);                //  -  récup valeur identique   - MAX 100
  crsf.queuePacket(CRSF_SYNC_BYTE, CRSF_FRAMETYPE_BATTERY_SENSOR, &crsfBatt, sizeof(crsfBatt));
}




void sendGps(int32_t latitude, int32_t longitude, float groundspeed, float heading, float altitude, float satellites)
{
  crsf_sensor_gps_t crsfGps = { 0 };

  // Values are MSB first (BigEndian)
  crsfGps.latitude = htobe32((int32_t)(latitude));  // -  pour récup valeur identique
  crsfGps.longitude = htobe32((int32_t)(longitude));  // -  pour récup valeur identique 
  crsfGps.groundspeed = htobe16((uint16_t)(groundspeed));  //  -  pour récup valeur identique faire x10 dans config sensor EDGETX (Ratio 255)  - MAX 65535
  crsfGps.heading = htobe16((int16_t)(heading)); // -  pour récup valeur identique faire x1000 dans config sensor EDGETX (Ratio 25500) utiliser que pour temperature (tester jusqua 200)
  crsfGps.altitude = htobe16((uint16_t)(altitude + 1000.0)); // -  récup valeur identique  - MAX 64535
  crsfGps.satellites = (uint8_t)(satellites);   // -  récup valeur identique  - MAX 100
  crsf.queuePacket(CRSF_SYNC_BYTE, CRSF_FRAMETYPE_GPS, &crsfGps, sizeof(crsfGps));
}









