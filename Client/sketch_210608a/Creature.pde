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
    circle(this.position[0],this.position[1],radius);
  }
}
