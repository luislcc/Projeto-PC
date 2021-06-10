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
  c.startGameReader();
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
    
    else if(c.menu == 1){  //game draw
    try{
      c.l.lock();
    while(!c.okDraw) c.okDrawCond.await();
    c.gameArea.draw();
    c.okDraw = false;
    }catch(Exception e) {}
    finally{
      c.okDrawCond.signal();
      c.l.unlock();
    }
    }
 }
 
 void keyPressed(){
    if(c.menu == 1){
      switch(key){
        case (BACKSPACE):
          c.menu = 2;
          break;
        
        case ('w'):
          try{
            c.l.lock();
            c.keyPressed = 'w';
          }finally{
            c.l.unlock();
          }
          break;
        
        case ('a'):
          try{
            c.l.lock();
            c.keyPressed = 'a';
          }finally{
            c.l.unlock();
          }
          break;
        
        case ('d'):
          try{
            c.l.lock();
            c.keyPressed = 'd';
          }finally{
            c.l.unlock();
          }
          break;
        
      }
      
    }
    
    else if (c.menu == 0 ) {
      mainMenu.keyPressed(key); 
    }
}

void keyReleased(){
  
  switch(key){
  case ('w'):
          try{
            c.l.lock();
            c.keyReleased = 'w';
          }finally{
            c.l.unlock();
          }
          break;
        
        case ('a'):
          try{
            c.l.lock();
            c.keyReleased = 'a';
          }finally{
            c.l.unlock();
          }
          break;
        
        case ('d'):
          try{
            c.l.lock();
            c.keyReleased = 'd';
          }finally{
            c.l.unlock();
          }
          break;
        
      }
  
}

void mouseClicked(){
 if(c.menu == 0){
   mainMenu.mouseClicked(mouseX,mouseY);
 }
 else if(c.menu == 1){
 }
 else if(c.menu == 2){
   clientMenu.mouseClicked(mouseX,mouseY);
 }
}
