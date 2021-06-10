import java.lang.Math;

class Player{
  private Float[] position;
  private Float radius;
  private Float direction;

  Player(Float x, Float y, Float radius,Float direction){
    this.position = new Float[2];
    this.position[0] = x;
    this.position[1] = y;
    this.radius = radius;
    this.direction = direction;
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
    color c = color(0,0,255);
    fill(c);
    circle(this.position[0],this.position[1],radius*2);
    stroke(color(255,255,255));
    line(this.position[0],this.position[1],this.position[0] + cos(this.direction)*this.radius, this.position[1] + sin(this.direction)*this.radius);
  }
}
