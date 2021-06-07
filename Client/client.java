import java.util.*;
import java.net.*;
import java.io.*;
import java.nio.charset.StandardCharsets;

class Client{
	Socket s;
	BufferedReader b;
	Obstacle[] obstacles;
	HashMap<String,Player> players;
	Creature[] creatures;
	int width;
	int height;

	Client(String ipAdress,int portNumber){
		try{
		this.s = new Socket(ipAdress,portNumber);
		this.b = new BufferedReader( new InputStreamReader(this.s.getInputStream()));
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

			String s = this.b.readLine();
			System.out.println(s);
		}
		catch(Exception e){System.out.println(e.toString());}
	}

	public void receiveState(){
		try{
			String s = this.b.readLine();
			System.out.println(s);
			if(s.equals("update")){
				this.width = Integer.parseInt(this.b.readLine());
				this.height = Integer.parseInt(this.b.readLine());
				int numberOfObstacles = Integer.parseInt(this.b.readLine());
				for (int i = 0; i < numberOfObstacles ;i++ ) {
					this.obstacles[i] = this.receiveObstacle();
				}
				int numberOfPlayers = Integer.parseInt(this.b.readLine());
				for(int i = 0; i < numberOfPlayers; i++){
					String key = this.b.readLine();
					this.players.put(key,this.receivePlayer());
				}
				int numberOfCreatures = Integer.parseInt(this.b.readLine());
				this.creatures = new Creature[numberOfCreatures];
				for (int i = 0; i < numberOfCreatures ;i++) {
					this.creatures[i] = this.receiveCreature();
				}
			}
		}
		catch(Exception e){}
	}

	public Creature receiveCreature(){
		try{
			int type = Integer.parseInt(this.b.readLine());
			Float posX = Float.parseFloat(this.b.readLine());
			Float posY = Float.parseFloat(this.b.readLine());
			Float radius = Float.parseFloat(this.b.readLine());
			Float direction = Float.parseFloat(this.b.readLine());
			return new Creature(type,posX,posY,radius,direction);
		}
		catch(Exception e){}
		return new Creature(0, 0.0f,  0.0f,  0.0f, 0.0f);
	}

	public Player receivePlayer(){
		try{
			Float posX = Float.parseFloat(this.b.readLine());
			Float posY = Float.parseFloat(this.b.readLine());
			Float radius = Float.parseFloat(this.b.readLine());
			Float direction = Float.parseFloat(this.b.readLine());
			return new Player(posX,posY,radius,direction);
		}
		catch(Exception e){}
		return new Player( 0.0f,  0.0f,  0.0f, 0.0f);
	}


	public Obstacle receiveObstacle(){
		try{
			Float posX = Float.parseFloat(this.b.readLine());
			Float posY = Float.parseFloat(this.b.readLine());
			Float radius = Float.parseFloat(this.b.readLine());
			return new Obstacle(posX,posY,radius);
		}
		catch(Exception e){}
		return new Obstacle( 0.0f,  0.0f,  0.0f);
	}
}

class Main{
	public static void main(String[] args) {
		Client c = new Client("localhost",1230);
		c.send("create frango assado\n");
		c.receive();
		c.send("login frango assado\n");
		c.receive();
		c.send("update\n");
		System.out.println("Enviei");
		c.receiveState();
		System.out.println("Width " + c.width); 
	}
}