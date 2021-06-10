class GameReader extends Thread{
  private Socket s;
  private Client c;
  private BufferedReader b;

  GameReader(Socket s, BufferedReader b, Client c){
    this.s = s;
    this.c = c;
    this.b = b;
  }

  public void receiveState(){
    while(true){
      GameArea buffer = new GameArea(1000,600);
      try{
       c.l.lock();
       while(c.okDraw)c.okDrawCond.await();
       if(this.c.keyPressed == 'w' || this.c.keyPressed == 'a' || this.c.keyPressed == 'd'){ this.c.send(this.c.keyPressed + "_press\n");
       this.c.keyPressed = 'T';}
       if(this.c.keyReleased == 'w' || this.c.keyReleased == 'a' || this.c.keyReleased == 'd'){this.c.send(this.c.keyReleased + "_release\n");
       this.c.keyReleased = 'T';}
       
       this.c.send("update\n");
       buffer.receiveState(this.b);
       //buffer.printState();
       c.gameArea = buffer;
       c.okDraw = true;
      }catch(Exception e){}
      finally{
        c.okDrawCond.signal();
        c.l.unlock();
      }
    }
  }

  public void run(){
    this.receiveState();
  }
}
