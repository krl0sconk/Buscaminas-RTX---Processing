int cols, rows;
int rez = 50;
int mineamount = 21;
int flagamount = mineamount;
PVector mines[] = new PVector[mineamount];
PVector cellclicked;
int cellstate[][];
PVector minesnumber;
boolean gameOver = false;
boolean win = false;

PImage spriteSheet;
int spriteFrameWidth = 102;
int spriteFrameHeight = 102;
int spriteSheetCols = 4;
int totalFrames = 20;

PImage background;
int gameAreaX = 45;
int gameAreaY = 200;
int gameAreaWidth = 550;
int gameAreaHeight = 555;

PImage timesprites;
int timespriteFrameWidth = 38;
int timespriteFrameHeight = 66;
int timespriteSheetCols = 5;
int timetotalFrames = 10;
int time;
int deltatime = 0;
boolean countTime = true;

PImage smileysprites;
int smileyspriteFrameWidth = 17;
int smileyspriteFrameHeight = 17;
int smileyspriteSheetCols = 1;
int smileytotalFrames = 4;
int smileystate = 3;
void setup() {
  size(642, 794);
  spriteSheet = loadImage("minesweepersprites.png");
  background = loadImage("background.png");
  timesprites = loadImage("timesprites.png");
  smileysprites = loadImage("smileysprites.png");
  cols = gameAreaWidth / rez;
  rows = gameAreaHeight / rez;
  placeMines();
  cellstate = new int[cols][rows];
  noSmooth();
}

void draw() {
  background(51);
  image(background, 0, 0);
  if(countTime){
   time = int(millis()/1000) - deltatime;
  }
  else {
    deltatime = int(millis()/1000);
  }
  drawFlagAmount();
  drawTimer();
  drawSmiley(smileystate);
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {

      int drawX = gameAreaX + i * rez;
      int drawY = gameAreaY + j * rez;

      switch(cellstate[i][j]) {
      case 0:
        drawSpriteFrame(0, drawX, drawY);
        break;
      case 1:
        drawSpriteFrame(calculateNumbers(i, j) + 11, drawX, drawY);
        break;
      case 3:
        drawSpriteFrame(5, drawX, drawY);
        break;
      case 2:
        if (gameOver) {
          boolean wasMine = false;
          PVector flagCell = new PVector(i, j);
          for (int m = 0; m < mines.length; m++) {
            if (flagCell.equals(mines[m])) {
              wasMine = true;
              break;
            }
          }
          if (!wasMine){
            drawSpriteFrame(9, drawX, drawY);
          }
         }
         else {
           drawSpriteFrame(4, drawX, drawY);
         }
        break;
      }
    }
  }
  fill(255, 0, 0);
  if (gameOver) {
    for (int m = 0; m < mines.length; m++) {
      int mineDrawX = gameAreaX + int(mines[m].x) * rez;
      int mineDrawY = gameAreaY + int(mines[m].y) * rez;
      switch(cellstate[int(mines[m].x)][int(mines[m].y)]) {
      default:
        drawSpriteFrame(8, mineDrawX, mineDrawY);
        break;
      case 1:
        drawSpriteFrame(10, mineDrawX, mineDrawY);
        break;
      }
    }
    smileystate = 1;
    println("GAME OVER");
    countTime = false;
  }

  if (win) {
    smileystate = 0;
    println("WIN");
    countTime = false;
  }
}

void placeMines() {
  for (int i = 0; i < mineamount; i++) {
    PVector p;
    boolean ok;
    do {
      p = new PVector(int(random(cols)), int(random(rows)));
      ok = true;
      for (int j = 0; j < i; j++) {
        if (p.equals(mines[j])) {
          ok = false;
          break;
        }
      }
    } while (!ok);
    mines[i] = p;
  }
}

void mouseReleased() {
  if (gameOver || win) {
    resetGame();
  }
  smileystate = 3;

  int mouseGameX = mouseX - gameAreaX;
  int mouseGameY = mouseY - gameAreaY;

  int x = mouseGameX / rez;
  int y = mouseGameY / rez;
  if (x < 0 || x >= cols || y < 0 || y >= rows) {
    return;
  }
  if (mouseButton == LEFT) {
    if (cellstate[x][y] == 1) {
      return;
    }
    boolean clickedOnMine = false;
    PVector clickedCell = new PVector(x, y);
    for (int i = 0; i < mines.length; i++) {
      if (clickedCell.equals(mines[i])) {
        clickedOnMine = true;
        break;
      }
    }

    if (clickedOnMine) {
      gameOver = true;
    }
    cellstate[x][y] = 1;
  } else if (mouseButton == RIGHT) {
    if (cellstate[x][y] == 0 && flagamount > 0) {
      cellstate[x][y] = 2;
      flagamount--;
    } else if (cellstate[x][y] == 2) {
      flagamount++;
      cellstate[x][y] = 3;
    } else {
      cellstate[x][y] = 0;
    }
  }
}

int calculateNumbers(int i, int j) {
  int amount = 0;
  for (int k = i-1; k <= i+1; k++) {
    for (int l = j-1; l <= j+1; l++) {
      if (k >= 0 && k < cols && l >= 0 && l < rows && !(k == i && l == j)) {
        minesnumber = new PVector(k, l);
        for (int m = 0; m < mines.length; m++) {
          if (minesnumber.equals(mines[m])) {
            amount++;
          }
        }
      }
    }
  }
  if (amount == 0) {
    for (int k = i-1; k <= i+1; k++) {
      for (int l = j-1; l <= j+1; l++) {
        if (k >= 0 && k < cols && l >= 0 && l < rows) {
          if (cellstate[k][l] == 0) {
            cellstate[k][l] = 1;
          }
        }
      }
    }
  }
  if (!gameOver && !win) {
    boolean allSafeCellsRevealed = true;
    for (int cell_i = 0; cell_i < cols; cell_i++) {
      for (int cell_j = 0; cell_j < rows; cell_j++) {
        boolean isMine = false;
        PVector currentCell = new PVector(cell_i, cell_j);
        for (int m = 0; m < mines.length; m++) {
          if (currentCell.equals(mines[m])) {
            isMine = true;
            break;
          }
        }
        if (!isMine && cellstate[cell_i][cell_j] == 0) {
          allSafeCellsRevealed = false;
          break;
        }
      }
      if (!allSafeCellsRevealed) {
        break;
      }
    }

    if (allSafeCellsRevealed) {
      win = true;
    }
  }
  return amount;
}
void mousePressed(){
  smileystate = 2;
}
void resetGame() {
  countTime = true;
  gameOver = false;
  win = false;
  placeMines();
  flagamount=mineamount;
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      cellstate[i][j] = 0;
    }
  }
}

void keyPressed() {
  if ((gameOver || win) && keyCode == 'R') {
    resetGame();
  }
}

void drawSpriteFrame(int frameIndex, int gridX, int gridY) {
  if (spriteSheet == null) {
    println("Error: La spritesheet no ha sido cargada.");
    return;
  }

  int spriteCol = frameIndex % spriteSheetCols;
  int spriteRow = frameIndex / spriteSheetCols;

  int sx = spriteCol * spriteFrameWidth;
  int sy = spriteRow * spriteFrameHeight;

  int dx = gridX;
  int dy = gridY;

  copy(spriteSheet, sx, sy, spriteFrameWidth, spriteFrameHeight,
    dx, dy, rez, rez);
}
void drawtimeSpriteFrame(int frameIndex,int x, int y, int sizex, int sizey) {
  if (timesprites == null) {
    println("Error: La spritesheet no ha sido cargada.");
    return;
  }

  int timespriteCol = frameIndex % timespriteSheetCols;
  int timespriteRow = frameIndex / timespriteSheetCols;

  int sx = timespriteCol * timespriteFrameWidth;
  int sy = timespriteRow * timespriteFrameHeight;

  copy(timesprites, sx, sy, timespriteFrameWidth, timespriteFrameHeight,
    x, y, sizex, sizey);
}

void drawTimer(){
  int digit1x = 530;
  int digitsy = 70;
  int digit1 = time%10;
  int digit2 = (time /10)%10;
  int digit3 = (time /100)%10;
  drawtimeSpriteFrame(digit1,digit1x,digitsy,35,70);
  drawtimeSpriteFrame(digit2,digit1x - 35,digitsy,35,70);
  drawtimeSpriteFrame(digit3,digit1x - 70,digitsy,35,70);
}

void drawFlagAmount(){
  int digit1x = 150;
  int digitsy = 70;
  int digit1 = flagamount%10;
  int digit2 = (flagamount /10)%10;
  int digit3 = (flagamount /100)%10;
  drawtimeSpriteFrame(digit1,digit1x,digitsy,35,70);
  drawtimeSpriteFrame(digit2,digit1x - 35,digitsy,35,70);
  drawtimeSpriteFrame(digit3,digit1x - 70,digitsy,35,70);
}

void drawsmileySpriteFrame(int frameIndex,int x, int y, int sizex, int sizey) {
  if (smileysprites == null) {
    println("Error: La spritesheet no ha sido cargada.");
    return;
  }

  int smileyspriteCol = frameIndex % smileyspriteSheetCols;
  int smileyspriteRow = frameIndex / smileyspriteSheetCols;

  int sx = smileyspriteCol * smileyspriteFrameWidth;
  int sy = smileyspriteRow * smileyspriteFrameHeight;

  copy(smileysprites, sx, sy, smileyspriteFrameWidth, smileyspriteFrameHeight,
    x, y, sizex, sizey);
}
 void drawSmiley(int state){
  drawsmileySpriteFrame(state,280,60,90,90);
 }
