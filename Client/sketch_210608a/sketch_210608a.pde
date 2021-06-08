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
  c.startGameReader();
}

void draw(){
  
   //c.goRead();
   c.l.lock();  
   try{
    while(!c.okDraw) c.okDrawCond.await();
    c.gameArea.draw();
    System.out.println("NAO TOU EM STARVATION");
    c.okDraw = false;
   }catch(Exception e){}
   finally{
     c.l.unlock();
   }
     
   
 }
