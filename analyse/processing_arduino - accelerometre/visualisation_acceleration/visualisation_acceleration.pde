import processing.serial.*;

// Serial
Serial myPort;  // créer l'objet sérial 
String inString ="";  // Input string from serial port:
int lf = 36;      // ASCII dollar 

String[] items = new String[2];
float[] valeur_recu_temporaire = {0,0,0};

float save_x = 123456;
float save_y = 123456;
float[] liste_init_x = new float[0];
int compte_init_x = 0;
float[] liste_init_y = new float[0];
int compte_init_y = 0;
int bo = 2; //booléen 
float moyenne_x = 0;
float moyenne_y = 0;
int entree_permise;

//float[] liste_position_obstacle = new float[0]; 
//int nb_elem_liste_position_obstacle = 0; 


float position_robot_x = 400;
float position_robot_y = 400;


// =======================================================
void setup() {
  size(800,800);
  background(0);
  //1 cm = 1 pixel
  
  // Serial Port
  String portName = "COM6";  //Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil(lf);
  
}


void draw() {
  background(255);
  //line(x1_ligne,x2_ligne,y1_ligne,y2_ligne);
  conversion_serial_en_float();
  //regression_lineaire();
  affiche_robot();
  //ajoute_nouveau_obstacles();
  //affiche_obstacles();
}



// =============== EVENTS ==================
void serialEvent(Serial p){
  try {
    inString = p.readString(); 
    //items = parseString(inString); // want to split String?  
  }
  catch (Exception e) {}
}

// ================= UTILS ========================
String[] parseString(String serialString){
  if (serialString != null)
  {
    serialString = serialString.replaceAll("(\\r|\\n)", "");
    String items[] = splitTokens(serialString, " =");
    return(items);
  }
  else return(null);  
}

void conversion_serial_en_float(){
  String[] tmp_tableau = split(inString,',');
  try{
    valeur_recu_temporaire[0] = float(tmp_tableau[0]); //x
    valeur_recu_temporaire[1] = float(tmp_tableau[1]); //y
    valeur_recu_temporaire[2] = float(tmp_tableau[2]); //z
  }catch (Exception e) {}
  //print("\nx = "+valeur_recu_temporaire[0]+"  y = "+valeur_recu_temporaire[1]+"  z = "+valeur_recu_temporaire[2]);
  
  //print("\n AVANT :"+valeur_recu_temporaire[0]+" et "+save_x);
  entree_permise=0;
  if(valeur_recu_temporaire[0] != save_x && valeur_recu_temporaire[0]>0){ //valeur_recu_temporaire[0]>0 permet de filtrer les première valeurs d'initialisation qui sont fausses
    if(save_x != 123456.0 &&(valeur_recu_temporaire[0]-100 > save_x || valeur_recu_temporaire[0]+100 < save_x)){ //eviter les valeurs trop loin
      ; //mauvaise valeur à éliminer.
    }
    else{ //bonne valeur
      save_x = valeur_recu_temporaire[0];
      if(compte_init_x<20){
        liste_init_x = splice(liste_init_x,valeur_recu_temporaire[0],compte_init_x); 
        compte_init_x++;
      }  
      entree_permise=1;      
      //print("\n x"+compte_init_x+" "+valeur_recu_temporaire[0]);
    }
  }
  if(valeur_recu_temporaire[1] != save_y && valeur_recu_temporaire[1]>0){
    if(save_y != 123456.0 &&(valeur_recu_temporaire[1]-100 > save_y || valeur_recu_temporaire[0]+100 < save_y)){ //eviter les valeurs trop loin
      ; //mauvaise valeur à éliminer.
    }
    else{ //bonne valeur
      save_y = valeur_recu_temporaire[1];
      if(compte_init_y<20){
        liste_init_y = splice(liste_init_y,valeur_recu_temporaire[1],compte_init_y); 
        compte_init_y++;
      }
      entree_permise=1;
      //print("\n y"+compte_init_y);
    }
  }
  if(bo==1){ //pour remettre les valeurs à zéro
    compte_init_y=0;
    compte_init_x=0;
  }
  //print("\n",compte_init_x +" "+ compte_init_y+" "+bo);
  if(compte_init_x==20 && compte_init_y==20 && bo==2){
    moyenne_x = 0;
    moyenne_y = 0;
    for(int i=0;i<20;i++){
      moyenne_x += liste_init_x[i];
      moyenne_y += liste_init_y[i];
    }
    moyenne_x = moyenne_x / 20.0;
    moyenne_y = moyenne_y / 20.0;
    print(" \n Moyenne x = "+moyenne_x+"    Moyenne y = "+moyenne_y);
    bo=1; // cette variable passe à 1 quand on a fini de calculer les moyennes pour l'initialisation. 
  }
  
  
  
  /*
  if(valeur_recu_temporaire[0]<512.0 && valeur_recu_temporaire[0]>502.0){
    valeur_recu_temporaire[0]=0;
    //print("\nstop"+valeur_recu_temporaire[0]);
  }*/
  //si robot bouge on met robot_immobile à 0. On remet compte teta à 0. 
}

void affiche_robot(){
  
  fill(100,0,0); 
  //if(bo==1) print("c'est parti");
  print("\n "+bo+" "+entree_permise+" "+valeur_recu_temporaire[0]);
  if(entree_permise==1 && bo==1){
    print("\n r");
    if(abs(valeur_recu_temporaire[0]-moyenne_x) > 5 && abs(valeur_recu_temporaire[1]-moyenne_y) > 5 ){
      print("\nbouge!   x:" +(valeur_recu_temporaire[0]-moyenne_x)+" y="+(valeur_recu_temporaire[1]-moyenne_y)); 
      position_robot_x = position_robot_x+(((valeur_recu_temporaire[0]-moyenne_x)/2)*0.4);
      position_robot_y = position_robot_y+(((valeur_recu_temporaire[1]-moyenne_y)/2)*0.2);
    }
  }
  //robot_immobile++;
  circle(position_robot_x,position_robot_y,40);
}
/*
void ajoute_nouveau_obstacles(){
  // convertir les valeurs polaires en cartésienne
  if(valeur_recu_temporaire[1] != sauveur){
    sauveur= valeur_recu_temporaire[1];
    position_obstacle_x = position_robot_x + valeur_recu_temporaire[0]*cos(valeur_recu_temporaire[1]*(pi/180));
    position_obstacle_y = position_robot_y - valeur_recu_temporaire[0]*sin(valeur_recu_temporaire[1]*(pi/180));
    //print("\nPostion x :"+position_obstacle_y+" Décalage "+valeur_recu_temporaire[0]*sin(valeur_recu_temporaire[1]*(pi*180)));
    
    liste_position_obstacle = splice(liste_position_obstacle, position_obstacle_x, nb_elem_liste_position_obstacle);
    nb_elem_liste_position_obstacle++;
    liste_position_obstacle = splice(liste_position_obstacle, position_obstacle_y, nb_elem_liste_position_obstacle);
    nb_elem_liste_position_obstacle++;
  }
}

void affiche_obstacles(){
  for(int i=0;i<nb_elem_liste_position_obstacle-1;i+=2){
    fill(0,100,0);
    //point(liste_position_obstacle[i],liste_position_obstacle[i+1]);
    circle(liste_position_obstacle[i],liste_position_obstacle[i+1],4);
  }
}

void regression_lineaire(){
  if( compte_teta%17 == 0 ){ //robot_immobile == 0 && compte_teta%17 == 0
    float[] x = new float[compte_teta];
    float[] y = new float[compte_teta];
    for(int i=0;i<compte_teta-1;i++){
      // y
      y[i]=liste_position_obstacle[(nb_elem_liste_position_obstacle-(2*i)-1)];
      // x 
      x[i]=liste_position_obstacle[nb_elem_liste_position_obstacle-(2*i)-2];
    }
    int nombre_element_x = compte_teta;
    float somme_x = 0;
    for(int i=0;i<nombre_element_x;i++){
      somme_x = somme_x + x[i];
    }

    float somme_y = 0;
    for(int i=0;i<nombre_element_x;i++){
      somme_y = somme_y + y[i];
    }

    float somme_x2 = 0;
    for(int i=0;i<nombre_element_x;i++){
      somme_x2 = somme_x2 + x[i]*x[i];
    }

    float somme_xy = 0;
    for(int i=0;i<nombre_element_x;i++){
      somme_xy = somme_xy + x[i]*y[i];
    }
    // Equation de forme Ax = B donc x = A^-1 + B 
    // A doit être vu comme une matrice 2x2 mais comme c'est un tableau ici c'est plat. A = [a b c d]
    float[] A = {somme_x, nombre_element_x, somme_x2, somme_x};
    float[] A_inverse = {0,0,0,0};
    //inverse de A = 1 /(ad-bc) x [d -b -c a]. Si ad-bc == 0 aucune solution
    if(somme_x * somme_x - nombre_element_x * somme_x2 != 0){
      //inverse A dans chaque composante
      float tmp = 1/((somme_x * somme_x) - (nombre_element_x * somme_x2));
      A_inverse[0]= tmp * A[3]; 
      A_inverse[1]= tmp * (-A[1]);
      A_inverse[2]= tmp * (-A[2]);
      A_inverse[3]= tmp * A[0];
      float[] B = {somme_y,somme_xy}; //a voir comme une matrice colonne
      float solution1 = A_inverse[0]*B[0] + A_inverse[1]*B[1];
      float solution2 = A_inverse[2]*B[0] + A_inverse[3]*B[1];
      //print("\n"+solution1);
      //print("\n"+solution2);
      
      float[] y_droite = new float[0];
      for(int i=0;i<nombre_element_x;i++){
        y_droite = splice(y_droite,(x[i]*solution1+solution2),i);
        //print("\n ici "+y_droite[i]);
      }
      x1_ligne = x[0];
      x2_ligne = y_droite[0];
      y1_ligne = x[nombre_element_x-2];
      y2_ligne = y_droite[nombre_element_x-2];
      for(int i=0;i<nombre_element_x-2;i++){
        //print("\n "+i+": "+x[i]+" "+y_droite[i]);
      }
      print("\nLigne : " + x[0] +"  "+ y_droite[0] +"  "+ x[nombre_element_x-1] +"  "+ y_droite[nombre_element_x-1]);

    }
  }
}*/
