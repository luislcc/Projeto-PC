class Login implements Clickable{
  public float posx(){
    return 125;
  }

  public float posy(){
    return 350;
  }
  public float extent(){
    return 250;
  }
  public String displayText(){
    return "Login";
  } 
  public void clicked(int mouseX, int mouseY, Client c){
    if ((mouseX > this.posx() && mouseX < this.posx()+this.extent()) && (mouseY > this.posy() && mouseY < this.posy()+this.extent())){
      c.setCMD( "login");
      c.ativo = loginUs;
    }
  } 
}

class Create implements Clickable{
  public float posx(){
    return 375;
  }

  public float posy(){
    return 350;
  }
  public float extent(){
    return 250;
  }
  public String displayText(){
    return "Create Acc";
  } 
  public void clicked(int mouseX, int mouseY, Client c){
    if ((mouseX > this.posx() && mouseX < this.posx()+this.extent()) && (mouseY > this.posy() && mouseY < this.posy()+this.extent())){
      c.setCMD( "create");
      c.ativo = loginUs;
    }
  } 
}


class Close implements Clickable{
  public float posx(){
    return 625;
  }

  public float posy(){
    return 350;
  }
  public float extent(){
    return 250;
  }
  public String displayText(){
    return "Close Acc";
  } 
  public void clicked(int mouseX, int mouseY, Client c){
    if ((mouseX > this.posx() && mouseX < this.posx()+this.extent()) && (mouseY > this.posy() && mouseY < this.posy()+this.extent())){
      c.setCMD( "close");
      c.ativo = loginUs;
    }
  } 
}



class Online implements Clickable{
  public float posx(){
    return 750;
  }

  public float posy(){
    return 0;
  }
  public float extent(){
    return 250;
  }
  public String displayText(){
    return "Online now";
  } 
  public void clicked(int mouseX, int mouseY, Client c){
    if ((mouseX > this.posx() && mouseX < this.posx()+this.extent()) && (mouseY > this.posy() && mouseY < this.posy()+this.extent())){
      c.setCMD( "online");
      c.ativo = loadingData;
      c.communicate();
    }
  } 
}




class SubmitUsername implements ClickableType{
  public float posx(){
    return 750;
  }

  public float posy(){
    return 0;
  }
  public float extent(){
    return 250;
  }
  public String displayText(){
    return "OK!";
  } 
  public void clicked(int mouseX, int mouseY, Client c, String typing){
    if ((mouseX > this.posx() && mouseX < this.posx()+this.extent()) && (mouseY > this.posy() && mouseY < this.posy()+this.extent())){
       if (typing.length()>0){       
       c.username = typing;
       c.ativo = loginPas;
      }
    }
  } 
}



class SubmitPassword implements ClickableType{
  public float posx(){
    return 750;
  }

  public float posy(){
    return 0;
  }
  public float extent(){
    return 250;
  }
  public String displayText(){
    return "Ok!";
  } 
  public void clicked(int mouseX, int mouseY, Client c, String typing){
    if ((mouseX > this.posx() && mouseX < this.posx()+this.extent()) && (mouseY > this.posy() && mouseY < this.posy()+this.extent())){      
      if (typing.length()>0){
       c.password = typing;
       c.ativo = loadingData;
       c.communicate();
        loginUs.typing = "";
        loginPas.typing = "";
      }
    }
  } 
}


class Cancel implements Clickable{
  public float posx(){
    return 0;
  }

  public float posy(){
    return 0;
  }
  public float extent(){
    return 250;
  }
  public String displayText(){
    return "Cancel";
  } 
  public void clicked(int mouseX, int mouseY, Client c){
    if ((mouseX > this.posx() && mouseX < this.posx()+this.extent()) && (mouseY > this.posy() && mouseY < this.posy()+this.extent())){
      c.username = "";
      c.password = "";
      c.setCMD( "");
      c.ativo = inicial;
    }
  } 
}


class Logout implements Clickable{
  public float posx(){
    return 250;
  }

  public float posy(){
    return 350;
  }
  public float extent(){
    return 250;
  }
  public String displayText(){
    return "Logout";
  } 
  public void clicked(int mouseX, int mouseY, Client c){
    if ((mouseX > this.posx() && mouseX < this.posx()+this.extent()) && (mouseY > this.posy() && mouseY < this.posy()+this.extent())){
      c.setCMD( "logout");
      c.ativo = loadingData;
      c.communicate();
    }
  } 
}


class Play implements Clickable{
  public float posx(){
    return 500;
  }

  public float posy(){
    return 350;
  }
  public float extent(){
    return 250;
  }
  public String displayText(){
    return "Match Make";
  } 
  public void clicked(int mouseX, int mouseY, Client c){
    if ((mouseX > this.posx() && mouseX < this.posx()+this.extent()) && (mouseY > this.posy() && mouseY < this.posy()+this.extent())){
      c.setCMD("join");
      c.ativo = loadingData;
      c.communicate();
    }
  } 
}


class Leave implements Clickable{
  public float posx(){
    return 375;
  }

  public float posy(){
    return 350;
  }
  public float extent(){
    return 250;
  }
  public String displayText(){
    return "Leave Queue";
  } 
  public void clicked(int mouseX, int mouseY, Client c){
    if ((mouseX > this.posx() && mouseX < this.posx()+this.extent()) && (mouseY > this.posy() && mouseY < this.posy()+this.extent())){
      c.ativo = loadingData;
      c.setCMD("leave");
      c.ativo = loadingData;
      c.communicate();    
    }
  } 
}






//class Test implements Clickable{
//  public float posx(){
//    return 100;
//  }
//
//  public float posy(){
//    return 100;
//  }
//  public float extent(){
//    return 100;
//  }
//  public String displayText(){
//    return "Bruh";
//  } 
//  public void clicked(int mouseX, int mouseY, Client c){
//    if ((mouseX > this.posx() && mouseX < this.posx()+this.extent()) && (mouseY > this.posy() && mouseY < this.posy()+this.extent())){
//      c.bruh();
//    }
//  } 
//}