import java.util.Random;
import java.util.HashMap;

class GameArea{
  private int height;
  private int width;
  private HashMap<String,Player> players;
  private HashMap<String,Integer> leaderboard;
  private Obstacle[] obstacles;
  private Creature[] creatures;

  GameArea(int width, int height){
    try{
    this.height = height;
    this.width = width;
    this.leaderboard = new HashMap<String,Integer>();
    this.players = new HashMap<String,Player>();
    this.obstacles = new Obstacle[0];
    this.creatures = new Creature[0];
    }
    catch(Exception e){}
  }

  public void receiveState(BufferedReader b){
    this.players = new HashMap<String,Player>();
    try{
      String s = b.readLine();
      //System.out.println(s);
      if(s.equals("update")){
        this.width = Integer.parseInt(b.readLine());
        this.height = Integer.parseInt(b.readLine());
        int numberOfObstacles = Integer.parseInt(b.readLine());
        this.obstacles = new Obstacle[numberOfObstacles];
        for (int i = 0; i < numberOfObstacles ;i++ ) {
          this.obstacles[i] = this.receiveObstacle(b);
        }
        int numberOfPlayers = Integer.parseInt(b.readLine());
        for(int i = 0; i < numberOfPlayers; i++){
          String key = b.readLine();
          this.players.put(key,this.receivePlayer(b));
        }
        int numberOfCreatures = Integer.parseInt(b.readLine());
        this.creatures = new Creature[numberOfCreatures];
        for (int i = 0; i < numberOfCreatures ;i++) {
          this.creatures[i] = this.receiveCreature(b);
        }  
        // String st = b.readLine();
         //System.out.println("HELLO " + st);
         int numberOfEntries = Integer.parseInt(b.readLine());
        // System.out.println("NUMBER OF ENTRIES: " + numberOfEntries);
         for(int i = 0; i < numberOfEntries; i++){
             String player = b.readLine();
             Integer points = Integer.parseInt(b.readLine());
            this.leaderboard.put(player,points);
         }
      }
    }
    catch(Exception e){}
   // this.printState();
  }

  public Creature receiveCreature(BufferedReader b){
    try{
      int type = Integer.parseInt(b.readLine());
      Float posX = Float.parseFloat(b.readLine());
      Float posY = Float.parseFloat(b.readLine());
      Float radius = Float.parseFloat(b.readLine());
      Float direction = Float.parseFloat(b.readLine());
      return new Creature(type,posX,posY,radius,direction);
    }
    catch(Exception e){}
    return new Creature(0, 0.0f,  0.0f,  0.0f, 0.0f);
  }

  public Player receivePlayer(BufferedReader b){
    try{
      Float posX = Float.parseFloat(b.readLine());
      Float posY = Float.parseFloat(b.readLine());
      Float radius = Float.parseFloat(b.readLine());
      Float direction = Float.parseFloat(b.readLine());
      return new Player(posX,posY,radius,direction);
    }
    catch(Exception e){}
    return new Player( 0.0f,  0.0f,  0.0f, 0.0f);
  }


  public Obstacle receiveObstacle(BufferedReader b){
    try{
      Float posX = Float.parseFloat(b.readLine());
      Float posY = Float.parseFloat(b.readLine());
      Float radius = Float.parseFloat(b.readLine());
      return new Obstacle(posX,posY,radius);
    }
    catch(Exception e){}
    return new Obstacle( 0.0f,  0.0f,  0.0f);
  }

  public void printState(){
    System.out.println("STATE: ");
    System.out.println("WIDTH: " + this.width);
    System.out.println("HEIGHT: " + this.height);
    for(Obstacle o : this.obstacles) System.out.println(o.toString());
    for(Map.Entry<String,Player> e : this.players.entrySet()){
      System.out.println(e.getValue().toString());
      System.out.println("PID: " + e.getKey());
    }
    for(Creature c : this.creatures) System.out.println(c.toString());
    for(Map.Entry<String,Integer> e : this.leaderboard.entrySet()){
     System.out.println("JOGADOR: " + e.getKey() + " " + "PONTOS: " + e.getValue());  
    }
  }

  public void draw(){
    color col = color(255,255,255);
    fill(col);
    rect(0,0,width,height); // Desenha a tela do jogo
    for(Player p : this.players.values()) p.draw();
    for(Creature c : this.creatures) c.draw();
    for(Obstacle o : this.obstacles) o.draw();
  }
}
