Client c;
PFont f;
MainMenu mainMenu;
ClientMenu clientMenu;

void setup(){
  size(1000,600);
  c = new Client("localhost",1229);
  f = createFont("Arial",32);
  
  mainMenu = new MainMenu(c);
  clientMenu = new ClientMenu(c);
  //c.send("create frango assado\n");
  //c.receive();
  //c.send("login frango assado\n");
  //c.receive();
  //c.send("join\n");
  //c.receive();
  //c.send("update\n");
  //c.startGameReader();
}

void draw(){
  //System.out.println(c.menu);
    if(c.menu == 0){
      background(255);
      textFont(f);
       mainMenu.draw();
    }
    
    else if(c.menu == 2){
       background(255);
       textFont(f);
       clientMenu.draw();
    }
    
    else if(c.menu == 1){
    c.receiveState();
    c.gameArea.draw();
    c.send("update\n");
    }
    
    
 }
 
 void keyPressed(){
    if(c.menu == 1){
      if(key == BACKSPACE) c.menu = 2;
    }
    else if (c.menu == 0 ) {
      mainMenu.keyPressed(key); 
    }
}

void mouseClicked(){
 if(c.menu == 0){
   mainMenu.mouseClicked(mouseX,mouseY);
 }
 else if(c.menu == 2){
   clientMenu.mouseClicked(mouseX,mouseY);
 }
}
