
void updateMessage() {
  
  if (cycleTimer < frameCount-cycleEndTime && !timerFinished) {
    
    timerFinished = true;
    if(wordsTyping){
            println("FINISHED TYPING");
      wordsTyping = false;
       nextWord(thisTwit);
    }
  }
   if(timerFinished && generateWord && stopTwitCount < 10){
     if(moonPositionX > width*0.5){
     messagePositionX = int(messageWidth/1.5); 
      }
            newColor = QColor[QColorInt];  
            QColorInt+=1;
            thisTwit = Tlines[currentTweet];
            messageHeight = 280;
            messageHeight -= map(thisTwit.length(), 270, 60, 0, 200);
            println("Retrieved " + thisTwit);
            currentTweet ++;
            stringCount = 0;
            wordsTyping = true;
            generateWord = false;
            particlesFly = false;
           stopTwitCount +=1;
    }
  
  if (wordsTyping && timerFinished) { 
    boolean areWordsPrinted;   
    areWordsPrinted = printMessage();
    if(areWordsPrinted){
    
      cycleTimer = frameCount;
      if(moonPositionX > width*0.5){
     cycleEndTime = 600; 
      }
      else{
      cycleEndTime = 650;
      }
      timerFinished = false;
      particlesFly = true;
      generateWord = false;
      //wordsTyping = false;
    }
  }
}


boolean printMessage() {
  if (stringCount < thisTwit.length()) {
   if(frameCount % 5 == 0){ 
    stringCount ++; 
   }
    String typeTwit = thisTwit.substring(0, stringCount);
    message = typeTwit;
  } else if (stringCount >= thisTwit.length()) {
    return true;
  }
  //delay(40);
  return false;
}