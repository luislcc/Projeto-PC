import java.util.*;
import java.net.*;
import java.io.*;
import java.util.concurrent.locks.ReentrantLock;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.locks.*;

class Client{

	private Socket s;
	public boolean connected = true;
	public Menu ativo;
	public String username;
	public String password;
	public String cmd = "";
	public boolean logged = false;
	public GameArea gameA;

	Client(String ipAdress,int portNumber){
		try{
    		this.s = new Socket(ipAdress,portNumber);
    		(new SocketReader(this)).start();
    		(new SocketWriter(this)).start();

    	}
    	catch(Exception e){}
	}


	public synchronized void setCMD(String cmd){
		this.cmd = cmd;
	}

	public synchronized void communicate(){
		notifyAll();
	}

	
	public boolean updateFromSocket(Socket s){
		String receive = "";
		try{
			BufferedReader b = new BufferedReader(new InputStreamReader(s.getInputStream()));
			receive = b.readLine();
    		
    		System.out.println(receive);
    		synchronized(this){
    			switch(receive.split(" : ")[0]){
    				case "valid login":
    					this.logged = true;
    					this.ativo = play;
    					this.ativo.messages = "\n" + receive;
    				break;
	
    				case "logged out":
    					this.logged = false;
    					this.ativo = inicial;
    					this.ativo.messages = "\n" + receive;
    				break;

    				case "enqueued in":
    					this.ativo = queued;
    					this.ativo.messages = "\n" + receive;
    				break;

    				case "game Started":
    				break;

    				case "update":
    				break;
    				


    				default:
    					this.ativo = inicial;
    					if (this.logged) {
    						this.ativo = play;
    					}
    					this.ativo.messages = "\n" + receive;
    					break;
    			}
    		}
    	}
    	catch(Exception e){
    		this.ativo = loadingData;this.ativo.messages = "\n" + "Lost Server Conection..."; 
    		synchronized(this){
    			this.connected = false;
    		} 
    	}
    	synchronized(this){
    		return this.connected;
    	}
	}		


	
	public synchronized boolean updateOnSocket(){
		while(cmd.length() == 0){

			try{
				wait();
			}
			catch(Exception e){System.out.println(e.toString());}
		}
		String message = this.cmd;
    	switch(cmd){
    		
    		case "online":
    		break;

    		case "join":
    		break;

    		case "logout":
    		break;

    		case "leave":
    		break;

    		default:
				message += " " + this.username + " " + this.password;
    		break;
    	}
		
		message += "\n";
    	try{
    		System.out.println(message);
    		DataOutputStream dout = new DataOutputStream(this.s.getOutputStream());
    		dout.writeBytes(message);
    		dout.flush();
    		this.cmd = "";
    	}
    	catch(Exception e){}

    	return this.connected;	
    }

}




class SocketReader extends Thread{
	Client c;

	SocketReader(Client c){
		this.c = c;
	}

	public void run(){
		System.out.println("Started Reader");
		boolean con = true;
		while(con){
			con = c.updateFromSocket(c.s);
		}
	}
}

class SocketWriter extends Thread{
	Client c;

	SocketWriter(Client c){
		this.c = c;
	}

	public void run(){
		System.out.println("Started Writer");
		boolean con = true;
		while(con){
			con = c.updateOnSocket();
		}
	}
}