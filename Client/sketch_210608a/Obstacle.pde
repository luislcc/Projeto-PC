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
    circle(this.position[0],this.position[1],radius);
  } 
}
