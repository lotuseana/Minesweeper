import de.bezier.guido.*;
int NUM_ROWS =16;
int NUM_COLS =16;
int clickAmt=0;
boolean alive = true;
private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> mines = new ArrayList <MSButton>(); //ArrayList of just the minesweeper buttons that are mined
private ArrayList <MSButton> posStart = new ArrayList <MSButton>();
private MSButton startButton;

void setup ()
{
  size(595, 595);
  textSize(25);
  textAlign(CENTER, CENTER);
  strokeWeight(5);
  stroke(50);

  // make the manager
  Interactive.make( this );
  buttons = new MSButton[NUM_ROWS][NUM_COLS];
  for (int i =0; i <buttons.length; i++) {
    for (int j=0; j<buttons[i].length; j++) {
      buttons[i][j]=new MSButton(i, j);
    }
  }

  setMines();
  getStart();
}
public void setMines()
{
  int numMines = 40;
  for (int i =0; i <numMines; i++) {
    int r = (int)(Math.random()* NUM_ROWS);
    int c = (int)(Math.random()* NUM_COLS);
    if (!(mines.contains(buttons[r][c]))) {
      mines.add(buttons[r][c]);
    }
  }
}

public void draw ()
{
  background(0);
}
public boolean isWon()
{
  if (NUM_ROWS*NUM_COLS-clickAmt==mines.size()) {
    return true;
  }
  return false;
}
public void displayLosingMessage()
{
  strokeWeight(2);
  fill(255, 2);
  rect(200, 200, 200, 150);
  textSize(50);
  fill(255, 0, 0);
  text("u lose", 300, 250);
  textSize(15);
  text("(refresh page to retry)", 300, 300);
}
public void displayWinningMessage()
{
  strokeWeight(2);
  fill(255, 2);
  rect(200, 200, 200, 150);
  textSize(50);
  fill(5, 173, 44);
  text("u win", 300, 250);
  textSize(15);
  text("(refresh page to retry)", 300, 300);
}
public boolean isValid(int r, int c)
{
  if (r>=0 && r<NUM_ROWS && c>=0 && c<NUM_COLS) {
    return true;
  }
  return false;
}
public int countMines(int row, int col)
{
  int numMines = 0;
  for (int i = row-1; i <= row+1; i++) {
    for (int j= col-1; j<=col+1; j++) {
      if (!(i==row && j==col)) {
        if (isValid(i, j) && mines.contains(buttons[i][j])) {
          numMines++;
        }
      }
    }
  }
  return numMines;
}
public void getStart() {
  for (int i =0; i<NUM_ROWS; i++) {
    for (int j = 0; j<NUM_COLS; j++) {
      if (countMines(i, j)==0&&!(mines.contains(buttons[i][j]))) {
        posStart.add(buttons[i][j]);
      }
    }
  }
  int rand = (int)(Math.random()*posStart.size());
  startButton = posStart.get(rand);
}
public class MSButton
{
  private int myRow, myCol;
  private float x, y, width, height;
  private boolean clicked, flagged;
  private String myLabel;

  public MSButton ( int row, int col )
  {
    width = 600/NUM_COLS;
    height = 600/NUM_ROWS;
    myRow = row;
    myCol = col; 
    x = myCol*width;
    y = myRow*height;
    myLabel = "";
    flagged = clicked = false;
    Interactive.add( this ); // register it with the manager
  }

  // called by manager
  public void mouseReleased() {
    if (clicked&&!flagged&&countMines(myRow, myCol)>0) {
      int countFlagged =0;
      for (int i =myRow-1; i<=myRow+1; i++) {
        for (int j=myCol-1; j<=myCol+1; j++) {
          if (isValid (i,j) && buttons[i][j].flagged) {
            countFlagged++;
          }
        }
      }
      if (countFlagged==countMines(myRow, myCol)) {
        for (int i = myRow-1; i<=myRow+1; i++) {
          for (int j = myCol-1; j<=myCol+1; j++) {
            if (!(myRow==i&&myCol==j)) {
              if (isValid(i, j)&& buttons[i][j].clicked==false&&!(buttons[i][j].flagged)){
                buttons[i][j].mousePressed();
              }
            }
          }
        }
      }
    }
  }
  public void mousePressed () 
  {
    clickAmt=0;
    if (!flagged && mouseButton!=RIGHT) {
      clicked = true;
      for (int i =0; i<NUM_ROWS;i++){
    for (int j=0; j<NUM_COLS; j++){
      if (buttons[i][j].clicked){
        clickAmt++;
      }
    }
  }
    }

    if (mouseButton ==RIGHT&&!clicked) {
      flagged = !flagged;
    } else if (!flagged && mines.contains(this)) {
      displayLosingMessage();
      alive = false;
      System.out.print(alive);
    } else if (countMines(myRow, myCol)>0) {
      setLabel(countMines(myRow, myCol));
    } else {
      for (int i = myRow-1; i<=myRow+1; i++) {
        for (int j = myCol-1; j<=myCol+1; j++) {
          if (!(myRow==i&&myCol==j)) {
            if (isValid(i, j)&& buttons[i][j].clicked==false) {
              buttons[i][j].mousePressed();
            }
          }
        }
      }
    }
  }
  public void draw () 
  { 
    if (flagged) {
      fill(100);
    } else if ( clicked && mines.contains(this) ) 
      fill(255, 0, 0);
    else if (clicked)
      fill(200);
    else 
    fill(100);
    strokeWeight(5);
    stroke(50);
    rect(x, y, width, height);
    fill(0);
    textSize(25);
    text(myLabel, x+width/2, y+height/2);
    if (startButton==this&& !clicked) {
      strokeCap(ROUND);
      strokeWeight(6);
      stroke(43, 150, 23);
      line(x+12, y+12, x+width-12, y+height-12);
      line(x+12, y+height-12, x+width-12, y+12);
    }
    if ( (clicked|| !alive) && mines.contains(this) &&!flagged) {
      fill(0);
      strokeWeight(0);
      ellipse(x+width/2, y+(3*height/5), 20, 20);
      rect(x+width/3, y+(2*height/7), width/3, height/3);
      stroke(107, 55, 22);
      strokeWeight(2);
      noFill();
      curve(x+width, y+height/2, x+25, y+5, x+width/2, y+10, x+width, y+height);
    }
    if (!alive&&mines.contains(this)&&flagged&&clicked) {
      fill(255, 0, 0, 50);
      strokeWeight(5);
      stroke(50);
      rect(x, y, width, height);
    }
    if (flagged) {
      fill(171, 5, 5);
      strokeWeight(0);
      triangle(x+(2*width/5), y+height/5, x+(2*width/5), y+(3*height/5), x+(4*width/5), y+(2*height/5));
      strokeWeight(4);
      stroke(255);
      strokeCap(BEVEL);
      line(x+(2*width/5), y+height/5, x+(2*width/5), y+(4*height/5));
      strokeWeight(3);
      fill(255);
      ellipse(x+(2*width/5), y+(2*height/7), 5, 5);
    }
    if (!alive) {
      displayLosingMessage();
    }
    if (isWon()) {
      displayWinningMessage();
    }
  }
  public void setLabel(String newLabel)
  {
    myLabel = newLabel;
  }
  public void setLabel(int newLabel)
  {
    myLabel = ""+ newLabel;
  }
  public boolean isFlagged()
  {
    return flagged;
  }
}
