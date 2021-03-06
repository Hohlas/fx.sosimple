void SIG_FIRST_LEVELS_CONFIRM(){  // работа от первых уровней с подтверждением
   // ПРОДАЖА ОТ ПИКА ПЕРВОГО УРОВНЯ
   if (Sel.T!=F[HI].T){// при смене первых уровней
      Sel.T=F[HI].T;      // запоминаем время формирования первых уровней 
      Sel.Pattern=1;          // сигнал переходит на стадию ожидания,
      SELLSTOP=0; SELLLIMIT=0;// установленные ордера отменяются
      V("BEGIN", F[HI].P, bar, clrSlateBlue);
      }  
   if (SELL) {Sel.Pattern=0;} // X(" ", Close[bar], bar, clrBlue);
   if (F[hi].P>Sel.Sig1.P)   {Sel.Pattern=1;} // при обновлении пика перезаход    X("XXX Step="+S0(Sel.Pattern), Close[bar], bar, clrBlue);
   //if (Sel.Pattern>WAIT && High[bar]>Sel.Sig1.P) {Sel.Pattern=BLOCK; X(" ", High[bar], bar, clrBlue);} // при обновлении пика блокировка сигнала до формирования следующей зоны продажи 
   
   float delta=(MathAbs(iParam)+1)*ATR;
   // ПООЧЕРЕДНОЕ ОТСЛЕЖИВАНИЕ ПАТТЕРНОВ
   switch (Sel.Pattern){
   case 1:  // ОЖИДАНИЕ КАСАНИЯ ЗОНЫ ПРОДАЖИ
      //X("F[hi].P="+S4(F[hi].P), F[hi].P, bar, clrGray);
      if (F[hi].P<F[HI].P && F[hi].P>F[HI].P-delta && F[hi].T>F[HI].T){ // последний пик в зоне продажи и возник после ее формирования
         Sel.Pattern=2;// переключение на следующий шаг - "откат"
         Sel.Sig1=F[hi];      // копирование структуры пиков в структуру сигналов (все уровни и времена)
         V("WAIT", Sel.Sig1.P, SHIFT(Sel.Sig1.T), clrRed);
         }
   break;
   case 2: // ОТКАТ = формирование уровня, пробой которого даст подтверждение
      // I вариант
      if (F[lo].T>Sel.Sig1.T){// после верхнего пика возникла впадина  && F[lo].P>Sel.Zone.Dn   и она в зоне продажи
         Sel.Pattern=3;    // подтверждение пробоем ближайшего трендового
         Sel.Sig2=F[lo];            //  копирование структуры пиков в структуру сигналов (все уровни и времена)
         A("START-1", Sel.Sig2.P, bar, clrYellow);
         LINE("Sel.Sig2.Mid="+S4(Sel.Sig2.Mid), bar+1, Sel.Sig2.Mid, bar, Sel.Sig2.Mid,  clrBlue,0);
         }
      //// II вариант
      if (High[bar]>High[bar+1] && High[bar]<Sel.Sig1.P){// из хаев образовалась впадина (трендовый уровень на покупку)
         Sel.Pattern=3;    // подтверждение пробоем ближайшего трендового
         Sel.Sig2.P=float(Low[bar+1]);// значение самого пика и 
         Sel.Sig2.Mid=float(Low[bar+1]+(High[bar+1]-Low[bar+1])/3); // его серединки
         Sel.Sig2.T=Time[bar+1]; // момент отката
         A("START-2", Sel.Sig2.P, bar, clrBlue);
         LINE("Sel.Sig2.Mid="+S4(Sel.Sig2.Mid), bar+1, Sel.Sig2.Mid, bar, Sel.Sig2.Mid,  clrBlue,0);
         }     
   break;
   case 3:// ПОДТВЕРЖДЕНИЕ
      if (Low[bar]<Sel.Sig2.Mid && Time[bar]-Sel.Sig2.T<BarSeconds*10){   // противоположный пик подтверждения пробит не позже 10бар
         Sel.Pattern=GOGO;    // сигнал на открытие позы
         Sel.Inp=Sel.Sig1.Tr;// трендовый уровень первого пика
         Sel.Inp=Sel.Sig2.Mid;// серединка второго пика (подтверждающего)
         Sel.Stp=Sel.Sig1.P; // за первый пик
         Sel.Prf=Sel.Sig1.Frnt; // треть движения, коснувшегося зоны продажи
         A("GOGO", Sel.Inp, bar,  clrBlack);
         }
   break;
   case GOGO:  break;//Sel.Pattern=WAIT;      
      }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   // ПОКУПКА ОТ ВПАДИНЫ ПЕРВОГО УРОВНЯ
   if (Buy.T!=F[LO].T){// при смене первых уровней
      Buy.Pattern=WAIT;          // сигнал сбрасывается на стадию ожидания,
      BUYSTOP=0; BUYLIMIT=0;}    // установленные ордера отменяются
   Buy.T=F[LO].T;      // запоминаем время формирования первых уровней
   if (F[lo].P<Buy.Sig1.P) {Buy.Pattern=WAIT;} // при обновлении пика перезаход
   if (BUY) {Buy.Pattern=BLOCK;} // X(" ", Close[bar], bar, clrBlue);
   // ПООЧЕРЕДНОЕ ОТСЛЕЖИВАНИЕ ПАТТЕРНОВ
   switch (Buy.Pattern){
   case WAIT:  // ОЖИДАНИЕ КАСАНИЯ ЗОНЫ ПОКУПКИ
      X("F[lo].P="+S4(F[lo].P), F[lo].P, bar, clrGray);
      if (F[lo].P<F[LO].P+delta && F[lo].P>F[LO].P && F[lo].T>F[LO].T){ // последний пик в зоне продажи и возник после ее формирования
         Buy.Pattern=START;   // переключение на следующий паттерн - "откат"
         Buy.Sig1=F[lo];         // копирование структуры пиков в структуру сигналов (все уровни и времена)
         X("WAIT Frnt="+S4(Buy.Sig1.Frnt), Buy.Sig1.P, SHIFT(Buy.Sig1.T), clrOrangeRed);
         }
   break;
   case START: // ОТКАТ = формирование уровня, пробой которого даст подтверждение
      // I вариант
      if (F[hi].T>Buy.Sig1.T){// после нижнего пика возник пик и он в зоне покупки    && F[lo].P>Buy.Zone.Dn
         Buy.Pattern=CONFIRM;    // подтверждение пробоем ближайшего трендового
         Buy.Sig2=F[hi];    //  копирование структуры пиков в структуру сигналов (все уровни и времена)
         X("START P="+S4(Buy.Sig1.P), Buy.Sig2.P, bar, clrYellow);
         }
      // II вариант
      if (Low[bar]<Low[bar+1]){ // из хаев образовалась впадина (трендовый уровень на покупку)
         Buy.Pattern=CONFIRM;      // подтверждение пробоем ближайшего трендового
         Buy.Sig2.P=float(High[bar+1]); // значение самого пика и 
         Buy.Sig2.Mid=float(High[bar+1]-(High[bar+1]-Low[bar+1])/3); // его серединки
         Buy.Sig2.T=Time[bar+1];// момент отката
         X("START P="+S4(Buy.Sig1.P), Buy.Sig2.P, bar, clrYellow);
         }     
   break;
   case CONFIRM:// ПОДТВЕРЖДЕНИЕ
      if (High[bar]>Buy.Sig2.Mid && Time[bar]-Buy.Sig2.T<BarSeconds*10){   // противоположный пик подтверждения пробит не позже 10бар
         Buy.Pattern=GOGO;         // сигнал на открытие позы
         Buy.Inp=Buy.Sig1.Tr;   // трендовый уровень первого пика
         Buy.Inp=Buy.Sig2.Mid;   // серединка второго пика (подтверждающего)
         Buy.Stp=F[LO].P;       // за первый пик (уровень) 
         Buy.Prf=Buy.Sig1.Frnt; // треть движения, коснувшегося зоны покупки
         X("CONF P.Front="+S4(F[lo].P+Buy.Sig1.Frnt)+"Stp="+S4(Buy.Stp), Buy.Inp, bar,  clrWhite);
         }
   break;
   case GOGO:  break;//Buy.Pattern=WAIT;      
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   

