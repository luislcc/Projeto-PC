Client c;

void setup(){
  c = new Client("localhost",1229);
  size(1000,600);
  c.send("create frango assado\n");
  c.receive();
  c.send("login frango assado\n");
  c.receive();
  c.send("join\n");
  c.receive();
  c.send("update\n");
  //c.startGameReader();
}

void draw(){
    c.receiveState();
    c.gameArea.draw();
    c.send("update\n");
 }
 
 void keyPressed(){
   
 }
