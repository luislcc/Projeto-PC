Client c;

void setup(){
  c = new Client(800,600);
  size(800,600);
}

void draw(){
  c.gameArea.draw();
}


/*
PFont f;
    
// Variable to store text currently being typed
String typing = "";
// Variable to store saved text when return is hit
String saved = "";
    
void setup() {  
  size(300, 200);  
  f = createFont("Arial", 16);
}
    
void draw() {  
  background(255);  
  int indent = 25;  

  // Set the font and fill for text  
  textFont(f);  
  fill(0);  

  // Display everything  
  text("Click in this sketch and type. \nHit return to save what you typed.", indent, 40);  
  text(typing, indent, 90);  
  text(saved, indent, 130);
}
    
void keyPressed() {  
  // If the return key is pressed, save the String and clear it  
  if (key == '\n') {    
    saved = typing;    
    typing = "";  
    // Otherwise, concatenate the String  
  } else {    
    typing = typing + key;   
  }
}*/