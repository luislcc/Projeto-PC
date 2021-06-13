import java.util.*; 

interface Displayable{
	public void setMessages(String message);
	public void mouseClicked(int mouseX, int mouseY);
	public void draw();
	public void keyPressed(char key);
	public void keyReleased(char key);
}


class Menu implements Displayable{
	public String displayText, messages;
   	public Client c;
   	public List<Clickable> buttons;

   	Menu(String displayText, Client c, List<Clickable> buttons){
   		this.displayText = displayText;
   		this.messages = "";
   		this.c = c;
   		this.buttons = new ArrayList<Clickable>(buttons);
   	}

   	public void mouseClicked(int mouseX, int mouseY){
        for (int i = 0; i < this.buttons.size(); i++) {
            Clickable x = this.buttons.get(i);
            x.clicked(mouseX,mouseY,c);
        }
   	}

   	public void setMessages(String message){
   		this.messages = message;
   	}

   	public void keyReleased(char key){}

   	public void draw(){
   		fill(0);
   		text(this.displayText + messages, 250, 150);
        for (int i = 0; i < this.buttons.size(); i++) {
            Clickable x = this.buttons.get(i);
            fill(120);
            rect(x.posx(),x.posy(),x.extent(),x.extent());
            fill(0);
            textAlign(LEFT);
            text(x.displayText(),x.posx()+x.extent()/2,x.posy()+x.extent()/2);
        }   		
   	}
	
	public void keyPressed(char key){}
}



interface Clickable{
	public float posx();
	public float posy();
	public float extent();
	public String displayText(); 
	public void clicked(int mouseX, int mouseY, Client c); 
}


interface ClickableType{
	public float posx();
	public float posy();
	public float extent();
	public String displayText();
	public void clicked(int mouseX, int mouseY, Client c, String typing); 
}



class MenuType extends Menu implements Displayable{
	public String baseDisplay;
	public String typing;
	public List<ClickableType> buttonsType;

	MenuType(String displayText, Client c, List<Clickable> buttons, List<ClickableType> buttonsType){
		super("",c,buttons);
		this.baseDisplay = displayText;
		this.typing = "";
		this.buttonsType = new ArrayList<ClickableType>(buttonsType);	
	}

	public void mouseClicked(int mouseX, int mouseY){
		super.mouseClicked(mouseX,mouseY);
        for (int i = 0; i < this.buttonsType.size(); i++) {
            ClickableType x = this.buttonsType.get(i);
            x.clicked(mouseX,mouseY,this.c,this.typing);
        }		
	}

	public void draw(){
		this.displayText = baseDisplay + "\n\n" + this.typing;
		super.draw();
        for (int i = 0; i < this.buttonsType.size(); i++) {
            ClickableType x = this.buttonsType.get(i);
            fill(120);
            rect(x.posx(),x.posy(),x.extent(),x.extent());
            fill(0);
            textAlign(LEFT);
            text(x.displayText(),x.posx()+x.extent()/2,x.posy()+x.extent()/2);
        } 		
	}


	public void keyPressed(char key){        
    	if(key == BACKSPACE && this.typing.length() > 0){
    		this.typing = this.typing.substring(0,this.typing.length()-1);
    		}
    	
    	else if( (key>47 && key<57) || (key>64 && key<91) || (key>96 && key<123) ){
    		this.typing += key;
    	}
	}

	public void keyReleased(char key){}
}
