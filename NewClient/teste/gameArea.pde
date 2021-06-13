import java.util.Random;
import java.util.HashMap;
import java.lang.Math;

class GameArea implements Displayable{
  private int height;
  private int width;
  private HashMap<String,Player> players;
  private HashMap<String,Integer> leaderboard;
  private HashMap<String,Integer> scoreboard;
  private Obstacle[] obstacles;
  private Creature[] creatures;
  private Client c;

  GameArea(int width, int height, Client c){
    try{
    this.height = height;
    this.width = width;
    this.leaderboard = new HashMap<String,Integer>();
    this.scoreboard = new HashMap<String,Integer>();
    this.players = new HashMap<String,Player>();
    this.obstacles = new Obstacle[0];
    this.creatures = new Creature[0];
    this.c = c;
    }
    catch(Exception e){}
  }

  public void setMessages(String message){}

  public void receiveState(BufferedReader b){
    this.players = new HashMap<String,Player>();
    try{
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
         
         for(Map.Entry<String,Player> e : this.players.entrySet()){
            Player player = e.getValue();
            this.scoreboard.put(player.username,player.points);
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
      boolean isSelf = (Integer.parseInt(b.readLine()) == 1);
      Float posX = Float.parseFloat(b.readLine());
      Float posY = Float.parseFloat(b.readLine());
      Float radius = Float.parseFloat(b.readLine());
      Float direction = Float.parseFloat(b.readLine());
      int points = Integer.parseInt(b.readLine());
      String username = b.readLine();
      Float energy = Float.parseFloat(b.readLine());

      return new Player(posX,posY,radius,direction, points, isSelf, username,energy);
    }
    catch(Exception e){}
    return new Player( 0.0f,  0.0f,  0.0f, 0.0f, 0, false,"",0.0f);
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
    boolean cond;
    synchronized(c){
      cond = c.showScores;
    }
    color col = color(255,255,255);
    fill(col);
    rect(0,0,width,height); // Desenha a tela do jogo
    for(Player p : this.players.values()) p.draw();
    for(Creature c : this.creatures) c.draw();
    for(Obstacle o : this.obstacles) o.draw();

    if (cond){
      this.drawPoints();
    }
  }

  public void mouseClicked(int mouseX, int mouseY){
  }


  public void drawPoints(){
    fill(120);
    rect(500-width/8,0,width/4,height/2);
    fill(0);
    textAlign(CENTER);
    text("Leaderboard", 500, 25);
    int spacing = 47;
    int i = 1;
    for(Map.Entry<String,Integer> e : this.leaderboard.entrySet()){
      if (i < 6){
        textAlign(CENTER);
        text(e.getKey() + " : " + e.getValue(), 500, i*spacing);
        i++;
      }
   }
    fill(0);
    rect(500-width/8,height/2,width/4,height/2);
    fill(255);
    textAlign(CENTER);
    text("Scoreboard", 500, height/2 + 25);
    i = 1;
    for(Map.Entry<String,Integer> e : this.scoreboard.entrySet()){
      if (i < 6){
        textAlign(CENTER);
        text(e.getKey() + " : " + e.getValue(), 500, height/2 + i*spacing);
        i++;
      }
   }  


  }

  public void keyPressed(char key){
    switch (key){
      case 'a':
      c.setCMD("a_p");
      c.communicate();
      break;

      case 'w':
      c.setCMD("w_p");
      c.communicate();
      break;

      case 'd':
      c.setCMD("d_p");
      c.communicate();
      break;

      case BACKSPACE:
      c.setCMD("leave");
      c.communicate();
      break;

      case TAB:
      System.out.println("kappa");
      synchronized(c){
        c.showScores = true;
      }
      break;


      default:
      break;
    }
  }

  public void keyReleased(char key){
    switch (key){
      case 'a':
      c.setCMD("a_r");
      c.communicate();
      break;

      case 'w':
      c.setCMD("w_r");
      c.communicate();
      break;

      case 'd':
      c.setCMD("d_r");
      c.communicate();
      break;

      case TAB:
      synchronized(c){
        c.showScores = false;
      }
      break;      

      default:
      break;
    }
  }
}






class Player{
  private Float[] position;
  private Float radius;
  private Float direction;
  private Float energy;
  public int points;
  public String username;
  public boolean isSelf;

  Player(Float x, Float y, Float radius,Float direction, int points, boolean isSelf, String username, Float energy){
    this.position = new Float[2];
    this.position[0] = x;
    this.position[1] = y;
    this.radius = radius;
    this.direction = direction;
    this.username = username;
    this.points = points;
    this.isSelf = isSelf;
    this.energy = energy;
  }

  public String toString(){
    StringBuilder sb = new StringBuilder();
    sb.append("PLAYER:\n");
    sb.append("POS_X: ");
    sb.append(this.position[0]);
    sb.append("\nPOS_Y: ");
    sb.append(this.position[1]);
    sb.append("\nRADIUS: ");
    sb.append(this.radius);
    sb.append("\nDIRECTION: ");
    sb.append(this.direction);
    return sb.toString();
  }
  
  
  public void draw(){
    color k = color(0,0,255);
    if (this.isSelf){
        k = color(0,200,255);
    }

    fill(k);
    circle(this.position[0],this.position[1],radius*2);
    
    if(this.isSelf){
      k = color(233, 132, 255);
      fill(k);
      circle(this.position[0],this.position[1],radius*2*(this.energy)/100);
    }
    
    stroke(color(255,255,255));
    line(this.position[0],this.position[1],this.position[0] + cos(this.direction)*this.radius, this.position[1] + sin(this.direction)*this.radius);
  

  }
}









class Creature{
  private Float[] position;
  private Float radius;
  private Float direction;
  private int poisonous;

  Creature(int poisonous,Float x, Float y, Float radius,Float direction){
    this.position = new Float[2];
    this.position[0] = x;
    this.position[1] = y;
    this.radius = radius;
    this.poisonous = poisonous;
    this.direction = direction;
  }

  public String toString(){
    StringBuilder sb = new StringBuilder();
    sb.append("CREATURE:\n");
    sb.append("POS_X: ");
    sb.append(this.position[0]);
    sb.append("\nPOS_Y: ");
    sb.append(this.position[1]);
    sb.append("\nRADIUS: ");
    sb.append(this.radius);
    sb.append("\nDIRECTION: ");
    sb.append(this.direction);
    sb.append("\nPOISONOUS: ");
    sb.append(this.poisonous);
    return sb.toString();
  }


  
  public void draw(){
    color c = color(this.poisonous*255,(1-this.poisonous)*255,0);
    fill(c);
    circle(this.position[0],this.position[1],radius*2);
  }
}



class Obstacle{
  private Float[] position;
  private Float radius;

  Obstacle(Float x, Float y, Float radius){
    this.position = new Float[2];
    this.position[0] = x;
    this.position[1] = y;
    this.radius = radius;
  }

  public String toString(){
    StringBuilder sb = new StringBuilder();
    sb.append("OBSTACLE:\n");
    sb.append("POS_X: ");
    sb.append(this.position[0]);
    sb.append("\nPOS_Y: ");
    sb.append(this.position[1]);
    sb.append("\nRADIUS: ");
    sb.append(this.radius);
    return sb.toString();
  }
  
  public void draw(){
    color c = color(0,0,0);
    fill(c);
    circle(this.position[0],this.position[1],radius*2);
  } 
}
