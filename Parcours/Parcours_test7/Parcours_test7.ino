#include <Servo.h>
#define ir A0
#define model 1080
Servo myServoD, myServoG;

/* CONSTANTES GLOBALES */
int vitesse = 0;
int BORNE_MAX_SUIVI = 350;
int BORNE_MIN_SUIVI = 320;

/* Vitesse du son dans l'air en mm/us */
const float SOUND_SPEED = 340.0 / 1000;

/*CONSTANTE ULTRASON AVANT*/
/**************************/
/* Constantes pour les broches */
const byte TRIGGER_PIN_ULTRASON_AVANT = 2; // Broche TRIGGER
const byte ECHO_PIN_ULTRASON_AVANT = 3;    // Broche ECHO
/* Constantes pour le timeout */
const unsigned long MEASURE_TIMEOUT = 25000UL; // 25ms = ~8m à 340m/s
/**************************/

/*FONCTION ULTRASON AVANT*/
/**************************/
void initUltrasonAvant() {
  /* Initialise les broches */
  pinMode(TRIGGER_PIN_ULTRASON_AVANT, OUTPUT);
  digitalWrite(TRIGGER_PIN_ULTRASON_AVANT, LOW); // La broche TRIGGER doit être à LOW au repos
  pinMode(ECHO_PIN_ULTRASON_AVANT, INPUT);
}

float getDistanceUltrasonAvant() {
  /* 1. Lance une mesure de distance en envoyant une impulsion HIGH de 10µs sur la broche TRIGGER */
  digitalWrite(TRIGGER_PIN_ULTRASON_AVANT, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIGGER_PIN_ULTRASON_AVANT, LOW);
  /* 2. Mesure le temps entre l'envoi de l'impulsion ultrasonique et son écho (si il existe) */
  long measure = pulseIn(ECHO_PIN_ULTRASON_AVANT, HIGH, MEASURE_TIMEOUT);
  /* 3. Calcul la distance à partir du temps mesuré */
  int distance_mm = measure / 2.0 * SOUND_SPEED;
  return distance_mm;
}
/**************************/

/*CONSTANTE ULTRASON ROUGE*/
/**************************/
/* Constantes pour les broches */
const byte TRIGGER_PIN_ULTRASON_DROIT = 4; // Broche TRIGGER
const byte ECHO_PIN_ULTRASON_DROIT = 7;    // Broche ECHO
/**************************/

/*FONCTION ULTRASON DROIT*/
/**************************/
void initUltrasonDroit() {
  /* Initialise les broches */
  pinMode(TRIGGER_PIN_ULTRASON_DROIT, OUTPUT);
  digitalWrite(TRIGGER_PIN_ULTRASON_DROIT, LOW); // La broche TRIGGER doit être à LOW au repos
  pinMode(ECHO_PIN_ULTRASON_DROIT, INPUT);
}

float getDistanceUltrasonDroit() {
  /* 1. Lance une mesure de distance en envoyant une impulsion HIGH de 10µs sur la broche TRIGGER */
  digitalWrite(TRIGGER_PIN_ULTRASON_DROIT, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIGGER_PIN_ULTRASON_DROIT, LOW);
  /* 2. Mesure le temps entre l'envoi de l'impulsion ultrasonique et son écho (si il existe) */
  long measure = pulseIn(ECHO_PIN_ULTRASON_DROIT, HIGH, MEASURE_TIMEOUT);
  /* 3. Calcul la distance à partir du temps mesuré */
  int distance_mm = measure / 2.0 * SOUND_SPEED;
  return distance_mm;
}
/**************************/

/*FONCTION MOTEUR*/
/**************************/
void initMoteur() {
  myServoD.attach(5);
  myServoG.attach(6);
}

void rotationGauche(){
  myServoG.write(133);
  myServoD.write(50);
}

void rotationDroite(){
  myServoG.write(1);
  myServoD.write(135);
}

void trajectoireGauche(int vitesse){
  myServoG.write(vitesse);
  myServoD.write(vitesse - 15);
}

void trajectoireDroite(int vitesse){
  myServoG.write(vitesse - 15);
  myServoD.write(vitesse);
}

void avancer(int vitesse){
  myServoG.write(vitesse);
  myServoD.write(vitesse);
}

void reculer(int vitesse){
  myServoG.write(vitesse);
  myServoD.write(vitesse);
}

void arreter(){
  myServoG.write(90);
  myServoD.write(90);
}
/**************************/


/********MAIN*********/
/*********************/
unsigned int ETAT_PRESENT = 1;
unsigned int ETAT_SUIVANT = 0;
int DISTANCE_MM_AVANT = 0;
int DISTANCE_MM_DROIT = 0;

/*
 * 0 = arreter()
 * 1 = avancer()
 * 2 = reculer()
 * 3 = trajectoireDroite()
 * 4 = rotationGauche()
 * 5 = trajectoireGauche()
 * 6 = rotationDroite()
 */ 
void setup() {
  initMoteur();
  initUltrasonAvant();
  initUltrasonDroit();
  Serial.begin(9600);
  Serial1.begin(9600);
}


void loop() {
  DISTANCE_MM_DROIT = getDistanceUltrasonDroit();
  DISTANCE_MM_AVANT = getDistanceUltrasonAvant();

  /*Serial.print("Distance Droite: ");
  Serial.print(DISTANCE_MM_DROIT);
  Serial.print(" | Distance Avant: ");
  Serial.print(DISTANCE_MM_AVANT);*/ 
  
  if (DISTANCE_MM_AVANT <= 1) {
    DISTANCE_MM_AVANT = 8000;
  }
  if (DISTANCE_MM_DROIT <= 1) {
    DISTANCE_MM_DROIT = 8000;
  }

  if (DISTANCE_MM_AVANT > 1500) {
    vitesse = 125;
  } else if (DISTANCE_MM_AVANT > 600 && DISTANCE_MM_AVANT < 1500) {
    vitesse = 120;
  }

   int c;
  if(Serial.available()) {
    c = Serial.read();
    Serial1.print(c);
  }
  if (Serial1.available()) {
    c = Serial1.read();
    Serial.println(c);    
  }
  if(c==48){
  switch(ETAT_PRESENT) {
    
    case 0: 
      arreter();

      if (DISTANCE_MM_AVANT > 600 && DISTANCE_MM_DROIT > 1500) {
        ETAT_SUIVANT = 6;
      } else if (DISTANCE_MM_AVANT > 600 && DISTANCE_MM_DROIT > 400) {
        ETAT_SUIVANT = 3;
      } else if (DISTANCE_MM_AVANT > 600 && DISTANCE_MM_DROIT < 300){
        ETAT_SUIVANT = 5;
      } else if (DISTANCE_MM_AVANT > 1500 ) {
        ETAT_SUIVANT = 1;
      } else {
        ETAT_SUIVANT = 0;
      }
      
      Serial.println(" | Etat arreter");
      break;
      
    case 1: 
      avancer(vitesse);
      
      if (DISTANCE_MM_AVANT > 300 && DISTANCE_MM_DROIT > 1500) {
        ETAT_SUIVANT = 6;
      } else if (DISTANCE_MM_AVANT < 600){
        ETAT_SUIVANT = 4;
      } else if (DISTANCE_MM_DROIT > BORNE_MAX_SUIVI) {
        ETAT_SUIVANT = 3; // trajectoire droite
      } else if (DISTANCE_MM_DROIT < BORNE_MIN_SUIVI) {
        ETAT_SUIVANT = 5; // trajectoire gauche
      } else {
        ETAT_SUIVANT = 1;
      }
      
      Serial.println(" | Etat avancer");
      break;
      
    case 2 : 
      reculer(vitesse);
      Serial.println(" | Etat reculer");
      break;
      
    case 3: 
      trajectoireDroite(vitesse);
      
      if (DISTANCE_MM_AVANT > 300 && DISTANCE_MM_DROIT > 1500) {
        ETAT_SUIVANT = 6;
      } else if (DISTANCE_MM_AVANT < 600) {
        ETAT_SUIVANT = 4;
      } else if (DISTANCE_MM_DROIT < BORNE_MAX_SUIVI) {
        ETAT_SUIVANT = 5;
      } else {
        ETAT_SUIVANT = 3;
      }
      Serial.println(" | Etat trajectoireDroite");
      break;
      
    case 4: // Rotation Gauche
      rotationGauche();
      
      if (DISTANCE_MM_AVANT > 600) {
        ETAT_SUIVANT = 1;
      } else {
        ETAT_SUIVANT = 4;
      }
      
      Serial.println(" | Etat rotationGauche");
      break;
      
    case 5:
      trajectoireGauche(vitesse);

      if (DISTANCE_MM_AVANT > 300 && DISTANCE_MM_DROIT > 1500) {
        ETAT_SUIVANT = 6;
      } else if (DISTANCE_MM_AVANT < 600){
        ETAT_SUIVANT = 4; 
      } else if (DISTANCE_MM_DROIT > BORNE_MIN_SUIVI){
        ETAT_SUIVANT = 1;
      } else {
        ETAT_SUIVANT = 5;
      }
      
      Serial.println(" | Etat trajectoireGauche");
      break;

    case 6:
      rotationDroite();

      if (DISTANCE_MM_AVANT < 600) {
        ETAT_SUIVANT = 4;
      } else if (DISTANCE_MM_AVANT < 4000 || DISTANCE_MM_DROIT < 1000) {
        ETAT_SUIVANT = 1;
      } else {
        ETAT_SUIVANT = 6;
      }
      
      Serial.println(" | Etat rotation Droite ");
      break;
  }} else if(c==49){
    avancer(118);
  } else if(c==50){
    avancer(127);
  } else if(c==54){
    reculer(118);
  } else if(c==51){
    rotationGauche();
  } else if(c==52){
   rotationDroite();
  }else if(c==53){
    arreter();
  }else if(c==55){
    trajectoireGauche(130);
  } else if (c==56){
    trajectoireDroite(130);
  }
  

  
  
  ETAT_PRESENT = ETAT_SUIVANT;
  delay(100);
}
