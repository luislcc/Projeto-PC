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
  /*
  public void draw(){
    color c = color(0,0,255);
    fill(c);
    circle(this.position[0],this.position[1],radius);
  }*/
}