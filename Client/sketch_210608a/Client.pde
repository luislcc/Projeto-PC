import java.util.*;
import java.net.*;
import java.io.*;
import java.util.concurrent.locks.ReentrantLock;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.locks.*;

class Client{
  private Socket s;
  public ReentrantLock l = new ReentrantLock();
  public boolean okDraw;
  final Condition okDrawCond = l.newCondition();
  private BufferedReader b;
  private GameReader gameReader;
  private GameArea gameArea;

  Client(String ipAdress,int portNumber){
    try{
      this.okDraw = false;
    this.s = new Socket(ipAdress,portNumber);
    this.b = new BufferedReader( new InputStreamReader(this.s.getInputStream())); // JAVA <3
    this.gameArea = new GameArea(1000,600);
    }
    catch(Exception e){}
  }

  public void startGameReader(){
    this.gameReader = new GameReader(this.s,this.b,this);
    this.gameReader.start();
  }
  
  public void receiveState(){
    this.gameArea.receiveState(this.b);
  }

  public void send(String message){
    try{
    DataOutputStream dout = new DataOutputStream(this.s.getOutputStream());
    dout.writeBytes(message);
    dout.flush();
    }
    catch(Exception e){}
  }

  public void receive(){
    try{

      String s = this.b.readLine();
      System.out.println(s);
    }
    catch(Exception e){System.out.println(e.toString());}
  }

  
}
