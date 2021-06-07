class Obstacle{
  private Float[] position;
  private Float radius;

  Obstacle(Float x, Float y, Float radius){
    this.position = new Float[2];
    this.position[0] = x;
    this.position[1] = y;
    this.radius = radius;
  }
  /*
  public void draw(){
    color c = color(0,0,0);
    fill(c);
    circle(this.position[0],this.position[1],radius);
  } */
}