import java.util.*;
import java.net.*;
import java.io.*;
import java.nio.charset.StandardCharsets;

class Client{
	Socket s;

	Client(String ipAdress,int portNumber){
		try{
		this.s = new Socket(ipAdress,portNumber);
		}
		catch(Exception e){}
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
			BufferedReader b = new BufferedReader( new InputStreamReader(this.s.getInputStream()));

			String s = b.readLine();
			System.out.println(s);
		}
		catch(Exception e){System.out.println(e.toString());}
	}
}

class Main{
	public static void main(String[] args) {
		Client c = new Client("localhost",123);
		System.out.println("hello");
		c.send("create frango assado\n");
		c.receive();
		c.send("login frango assado\n");
		c.receive();
	}
}