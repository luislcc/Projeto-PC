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
      buffer.receiveState(this.b);
        if(this.c.l.tryLock()){
          try{
            this.c.gameArea = buffer;
            this.c.okDraw = true;
            this.c.okDrawCond.signalAll();
          }
          finally{
          this.c.l.unlock();
          }     
      }
    }
  }

  public void run(){
    this.receiveState();
  }
}
