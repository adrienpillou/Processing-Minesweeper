final int cell_size = 30;
final int board_width = 600/cell_size;
final int board_height = 600/cell_size;
Grid board = new Grid(board_width, board_height);
ArrayList<Vector> flags = new ArrayList<Vector>(0);
ArrayList<Cell> bombs = new ArrayList<Cell>(0);
boolean isRunning = false;


void setup(){
  size(600,600);
  frameRate(15);
  println("\n\n*** Minesweeper ***");
  textAlign(CENTER, CENTER);
  board.drawInstance();
  startGame();
}

void draw(){
  update();
}

void update(){
  if(isRunning){
    background(0);
    board.drawInstance();
    drawFlags();
  }
}

void mousePressed(){
  if(isRunning){
    if(mouseButton == LEFT){
      selectCell(new Vector((int)mouseX/cell_size, (int)mouseY/cell_size));
    }else if(mouseButton == RIGHT){
      placeFlag(new Vector((int)mouseX/cell_size, (int)mouseY/cell_size));
    }
  }
}

void keyPressed(){
  if(key =='r'){
    startGame();
  }
}

void selectCell(Vector cell_position){
  Cell selected_cell = board.getCell(cell_position);
  if(board.getCell(cell_position).is_bombed){
    showBombs();
    isRunning = false;
    displayMessage("YOU LOSE !", 64);
    println("BOOM !!!\nYou lose !");
  }else{
    floodFill(selected_cell);
    if (checkWin()){
      board.drawInstance();
      drawFlags();
      isRunning = false;
      displayMessage("YOU WIN !", 64);
      println("You win !");
    }
  }
}

void floodFill(Cell cell){
  if(cell.is_revealed)return;
  cell.reveal();
  if (cell.bombs_around == 0){
    for(int j=-1 ; j<=1 ; j++){
      for(int i=-1 ; i<=1 ; i++){
        if(i!=0 || j!=0){
          int x= cell.position.x + i;
          int y= cell.position.y + j;
          if((x>=0 && x<board.columns) && (y>=0 && y<board.rows)){
            floodFill(board.getCell(x,y));
          }
        }
      }
    }
  }else return;
}

void placeFlag(Vector flag_position){
  int flag_exists = getFlagIndex(flag_position);
  if(flag_exists!=-1){
    flags.remove(flag_exists);
    drawFlags();
  }else if (flags.size()<bombs.size() && !board.getCell(flag_position).is_revealed){
    flags.add(flag_position);
    drawFlags();
  }
}

int getFlagIndex(Vector position){
  for(int i=0 ; i<flags.size() ; i++){
    Vector checked_flag = flags.get(i);
    if(checked_flag.x == position.x && checked_flag.y == position.y){
      return i;
    }
  }
  return -1;
}

void drawFlags(){
  fill(255,0,0);
  for(Vector flag : flags){
    square(flag.x*cell_size, flag.y*cell_size, cell_size);
  }
}

void showBombs(){
  stroke(0);
  fill(0);
  for(Cell bomb:bombs){
    circle(bomb.position.x*cell_size + cell_size/2, bomb.position.y*cell_size + cell_size/2, cell_size/3);
  }
}

void startGame(){
  board= new Grid(board_width, board_height);
  flags.clear();
  bombs.clear();
  board.feed(.99, 40);
  isRunning = true;
}

boolean checkWin(){
  for(int j=0 ; j<board.rows ; j++){
      for(int i=0 ; i<board.columns ; i++){
        Cell checked_cell = board.getCell(i, j);
        if(!checked_cell.is_revealed && !checked_cell.is_bombed )
          return false;
      }
  }
  return true;
}

void displayMessage(String message, int size){
  fill(0);
  stroke(255);
  textSize(size);
  text(message, width/2, height/2);
}

class Grid{
  Cell [][] content;
  int columns;
  int rows;
  
  public Grid(int columns, int rows){
    this.rows = rows;
    this.columns = columns;
    this.content = new Cell[columns][rows];
    this.create();
  }
  
  Cell getCell(Vector position){
    return (this.content[position.x][position.y]);
  }
  
  Cell getCell(int x, int y){
    return (this.content[x][y]);
  }
  
  void create(){
    for(int j = 0 ; j<this.rows ; j++){
      for(int i = 0 ; i<this.columns ; i++){
        this.content[i][j] = new Cell(new Vector(i, j), false, this);
      }
    }
  }
  
  void feed(float proba, int max_bomb_amount){
    int current_bomb_amount = 0;
    while(current_bomb_amount != max_bomb_amount){
      for(int j = 0 ; j<this.rows ; j++){
        for(int i = 0 ; i<this.columns ; i++){
          float rng = random(1);
          if(rng > proba && current_bomb_amount < max_bomb_amount && !this.getCell(i, j).is_bombed){
            this.getCell(i, j).is_bombed = true;
            bombs.add(this.getCell(i, j));
            current_bomb_amount ++;
          }
        }
      }
    }
    println("You need to find "+ current_bomb_amount + " bombs in this board.");
  }
  
  void drawInstance(){
    for(int j = 0 ; j<board.rows ; j++){
      for(int i = 0 ; i<board.columns ; i++){
         this.getCell(i, j).drawInstance();
      }
    }
  }
}

class Cell{
  int bombs_around = 0;
  boolean is_bombed = false;
  boolean is_revealed = false;
  Vector position;
  Grid grid;
  
  public Cell(Vector position, boolean is_bombed, Grid grid){
    this.position = position;
    this.is_bombed = is_bombed;
    this.is_revealed = false;
    this.grid = grid;
  }
  
  int getNeighboors(){  
    int bombs_around = 0;
    for(int j = -1 ; j<=1 ; j++){
      for(int i = -1 ; i<=1 ; i++){
        int x = this.position.x+i;
        int y = this.position.y+j;
        if((i!=0 || j!=0) && (x >= 0 && x < grid.columns) && (y >= 0 && y < grid.rows)){
          if(grid.getCell(this.position.x+i, this.position.y+j).is_bombed){
            bombs_around++;
          }
        }
      }
    }
    return bombs_around;
  }
  
  void reveal(){
    if(!this.is_revealed){
      if(!this.is_bombed)this.bombs_around = this.getNeighboors();
      if(getFlagIndex(this.position)!=-1)flags.remove(getFlagIndex(this.position));
      this.is_revealed = true;
    }
  }
  

  
  void drawInstance(){
    stroke(125);
    if(this.is_revealed){
      if(isOdd(this.position.x+this.position.y))
        fill(175);
      else
        fill(200);
      square(this.position.x*cell_size, this.position.y*cell_size, cell_size);
      if(bombs_around>0){
        color text_color;
        switch(bombs_around){
          case 1:
            text_color = color(70, 130, 180);
            break;
          case 2:
            text_color = color(34, 139, 34);
            break;
          case 3:
            text_color = color(178, 34, 34);
            break;
          case 4:
            text_color = color(128, 0, 128);
            break;
          case 5:
            text_color = color(128, 0, 0);
            break;
          case 6:
            text_color = color(0, 206, 209);
            break;
          case 7:
            text_color = color(0, 0, 0);
            break;
          case 8:
            text_color = color(128, 128, 128);
            break;
          default:
            text_color = color(0, 0, 0);
            break;
        }
        fill(text_color);
        textSize(cell_size/1.5);
        text(this.bombs_around, this.position.x*cell_size+cell_size/2, this.position.y*cell_size+cell_size/2);
      }
    }else if(!this.is_revealed){
      fill(100);
      square(this.position.x*cell_size, this.position.y*cell_size, cell_size);
    }
    if(grid.getCell(this.position).is_bombed && this.is_revealed){
      fill(200);
      square(this.position.x*cell_size, this.position.y*cell_size, cell_size);
    }
  }
  
}

class Vector{
  int x;
  int y;
  
  public Vector(){
    this.x = 0;
    this.y = 0;
  }
  
  public Vector(int x, int y){
    this.x = x;
    this.y = y;
  }
}

boolean isOdd(int n){
  if(n%2 == 0)
    return false;
  else return true;
}
