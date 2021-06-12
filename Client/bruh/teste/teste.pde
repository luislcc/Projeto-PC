
Client c = new Client("localhost",1229);


Menu inicial = new Menu("Bem vindo ao choque de glutões",c, new ArrayList<Clickable>(Arrays.asList(new Login(), new Create(), new Close(), new Online())) );

MenuType loginUs = new MenuType("Insira o Username",c, new ArrayList<Clickable>(Arrays.asList(new Cancel())),new ArrayList<ClickableType>(Arrays.asList(new SubmitUsername())));
MenuType loginPas = new MenuType("Insira a Password",c, new ArrayList<Clickable>(Arrays.asList(new Cancel())),new ArrayList<ClickableType>(Arrays.asList(new SubmitPassword())));

Menu play = new Menu("Logged in",c,new ArrayList<Clickable>(Arrays.asList(new Logout(), new Play(), new Online())) );
Menu queued = new Menu("Enqueued",c,new ArrayList<Clickable>(Arrays.asList(new Leave())));
Menu dead = new Menu("Died",c,new ArrayList<Clickable>(Arrays.asList(new Back())));

Menu playersOnline = new Menu("Users Online",c,new ArrayList<Clickable>(Arrays.asList(new Cancel())));

Menu loadingData = new Menu("Retrieving Data from server wait...",c,new ArrayList<Clickable>());




void setup(){
  size(1000,600);
  synchronized(c){
    c.ativo = inicial;
  }
}


void draw(){
  clear();
  background(255);
  synchronized(c){
    c.ativo.draw();
  }
  fill(255);
}

void mouseClicked(){
  synchronized(c){
	 c.ativo.mouseClicked(mouseX,mouseY);
  }
}


void keyPressed(){
  synchronized(c){
    c.ativo.keyPressed(key);
  }
}