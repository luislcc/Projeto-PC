import java.util.Random;

class GameArea{
  private int height;
  private int width;
  private Player[] players;
  private Obstacle[] obstacles;
  private Creature[] creatures;

  GameArea(int width, int height){
    this.height = height;
    this.width = width;
    this.players = new Player[3];
    this.obstacles = new Obstacle[10];
    this.creatures = new Creature[5];
    Random rand = new Random();
    
    for(int i = 0; i < 3; i++) this.players[i] = new Player(rand.nextFloat()*this.width,rand.nextFloat()*this.height,rand.nextFloat()*100);
    for(int i = 0; i < 5; i++) this.creatures[i] = new Creature(rand.nextFloat()*this.width,rand.nextFloat()*this.height,rand.nextFloat()*100,false);
    for(int i = 0; i < 10; i++) this.obstacles[i] = new Obstacle(rand.nextFloat()*this.width,rand.nextFloat()*this.height,rand.nextFloat()*100);
  }

  public void draw(){
    color col = color(255,255,255);
    fill(col);
    rect(0,0,width,height); // Desenha a tela do jogo
    for(Player p : this.players) p.draw();
    for(Creature c : this.creatures) c.draw();
    for(Obstacle o : this.obstacles) o.draw();
  }
}