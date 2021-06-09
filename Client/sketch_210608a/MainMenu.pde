class MainMenu{
   public String typing;
   public Client c;
   public int state;
   
   MainMenu(Client c){
   this.typing = "";
   this.state = 0;
   this.c = c;
   }
   
   public void draw(){
     //System.out.println("Hello");
     fill(120);
     rect(0,400,250,200);
     rect(250,400,250,200);
     rect(500,400,250,200);
     rect(750,400,250,200);
     
     textFont(f);
  
  // Display everything
    fill(0);
    if(this.state == 1){
      text("Insira o seu username e password\n",200,300);
      text(this.typing,25,230);
    }
    
    else if(this.state == 2){
      text("Insira o seu username e password\n",200,300);
      text(this.typing,25,230);
    }
    
    else if(this.state == 3){
      text("Insira o seu username e password\n",200,300);
      text(this.typing,25,230);
    }
    
    else if(this.state == 4){
      text("Quem está online:\n",200,300);
      //text(this.typing,25,230);
    }
    
    text("Bem vindo ao Choque De Glutões\n ", 250, 150);
    fill(255);
    text("Criar\nConta",75,475);
    text("Login\n",340,475);
    text("Fechar\nConta",575,475);
    text("Online\n",825,475);
   }
   
   public void keyPressed(char key){
     if(key == '\n' && this.c.username.length() == 0){
         this.c.username = this.typing;
         System.out.println(this.c.username);
         this.typing = "";
     }
     
      else if(key == '\n' && this.c.username.length() > 0 && this.state == 1){
         this.c.password = this.typing;
         this.typing = "";
         this.c.send("create " + this.c.username + " " + this.c.password + "\n");
         this.c.receive();
     }
     
     else if(key == '\n' && this.c.username.length() > 0 && this.state == 2){
         this.c.password = this.typing;
         this.c.send("login " + this.c.username + " " + this.c.password + "\n");
         this.c.receive();
         this.c.setClientMenu();
     }
     
     else if(key == BACKSPACE && this.typing.length() > 0){
       this.typing = this.typing.substring(0,this.typing.length()-1);
     }
     else{
       this.typing += key;
     }
  }
  
  public void mouseClicked(int mouseX, int mouseY){
    if(mouseX > 0 && mouseX < 250 && mouseY > 400 && mouseY < 600){
      this.state = 1;
      this.c.username = "";
      this.c.password = "";
    }
    else if(mouseX > 250 && mouseX < 500 && mouseY > 400 && mouseY < 600){
      this.state = 2;
      this.c.username = "";
      this.c.password = "";
    }
    else if(mouseX > 500 && mouseX < 750 && mouseY > 400 && mouseY < 600){
      this.state = 3;
      this.c.username = "";
      this.c.password = "";
    }
    else if(mouseX > 750 && mouseX < 1000 && mouseY > 400 && mouseY < 600){
      this.state = 4;
      this.c.username = "";
      this.c.password = "";
    }
  }
}
