void OUTPUT(){
   if (!BUY  && !SELL) return;
   Buy.Prf=0;  Sel.Prf=0; // значения тейков для обновления ордеров 
      
   if (BUY){  // A("BUY="+S4(BUY)+" Shift="+S0(SHIFT(BuyTime))+" MaxFromBuy="+S4(MaxFromBuy -BUY),  H-ATR*3, 0,  clrGray);
      if (oImp>0 && !IMP_UP())                        {CLOSE_BUY(oPrice);   V("CloseBuy: NoImp",H, bar,  clrBlue);}        // отсутствие резкого отскока на первом баре после входа
      if (oSig>0 && (UP<1 || Buy.Pattern==NONE))      {CLOSE_BUY(oPrice);   V("CloseBuy: NoSig UP<1", H, bar,  clrBlue);}  // отсутвствие лонгового сигнала
      if (oSig<0 && DN>0 && UP<1)                     {CLOSE_BUY(oPrice);   V("CloseBuy: OppSig DN>0", H, bar,  clrBlue);} // появление шортового сигнала
      if (Tper>0 && Tin==0 && SHIFT(BuyTime)>=Tper)   {CLOSE_BUY(tPrice);   V("CloseBuy: HoldOverTime", H, bar,  clrBlue);}//  если не задан период работы Tin, то Tper определяет HoldTime
      }  
   if (SELL){ //V("SELL="+S4(SELL)+" DN="+S0(DN),  L+ATR*3, 0,  clrGray);// " Shift="+S0(SHIFT(SellTime))+" MinFromSell="+S4(SELL-MinFromSell)
      if (oImp>0 && !IMP_DN())                        {CLOSE_SELL(oPrice);  A("CloseSELL: NoImp", L, bar,  clrRed);}       // отсутствие резкого отскока на первом баре после входа
      if (oSig>0 && (DN<1 || Sel.Pattern==NONE))      {CLOSE_SELL(oPrice);  A("CloseSELL: NoSig DN<1", L, bar,  clrRed);}  // отсутствие шортового сигнала
      if (oSig<0 && UP>0 && DN<1)                     {CLOSE_SELL(oPrice);  A("CloseSELL: OppSig UP>0", L, bar,  clrRed);} // появление лонгового сигнала
      if (Tper>0 && Tin==0 && SHIFT(SellTime)>=Tper)  {CLOSE_SELL(tPrice);  A("CloseSELL: HoldOverTime", L, bar,  clrRed);}// если не задан период работы Tin, то Tper определяет HoldTime
      }
   if (Real) ERROR_CHECK("OUTPUT");   
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
char IMP_UP(){// Проверка резкого отскока на первом баре лонга
   if (SHIFT(BuyTime) >1 && MaxFromBuy -BUY <ATR*oImp)   return (false); else return (true); // Shift=1 бар входа, Shift=2 следующий
   }  
char IMP_DN(){// Проверка резкого отскока на первом баре шорта
   if (SHIFT(SellTime)>1 && SELL-MinFromSell<ATR*oImp)   return (false); else return (true); // *SHIFT(SellTime)
   }    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void CLOSE_BUY(char CloseType){// подтягиваем тейк на
   float NewProfit;
   if (CloseType<0)  NewProfit=MaxFromBuy; // максимальную цену с момента открытия позы
   else              NewProfit=MAX(BUY,(float)Bid) + CloseType*ATR/2; // максимальную из текущей и цены входа плюс жадность
   if (NewProfit-Bid<StopLevel) {BUY=0;   Modify=true; return;} // тейк недопустимо близко к цене, просто закрываемся
   if (NewProfit>0 && (NewProfit<PROFIT_BUY || PROFIT_BUY==0)) {PROFIT_BUY=NewProfit;     Modify=true;}  V("CLOSE: PROFIT_BUY="+S4(PROFIT_BUY), PROFIT_BUY, bar,  clrGray);
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void CLOSE_SELL(char CloseType){
   float NewProfit;
   if (CloseType<0)  NewProfit=MinFromSell; // минимальную цену с момента открытия позы
   else              NewProfit=MIN(SELL,(float)Ask) - CloseType*ATR/2; // минимальную из текущей и цены входа плюс жадность   
   if (Ask-NewProfit<StopLevel) {SELL=0; Modify=true; return;} // тейк недопустимо близко к цене, просто закрываемся  
   if (NewProfit>0 && (NewProfit>PROFIT_SELL || PROFIT_SELL==0)) {PROFIT_SELL=NewProfit;   Modify=true;}   
   }     
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ          
void TRAILING(){//    - T R A I L I N G   S T O P -
   if (Trl==0) return;
   float StpBuy=0, StpSel=0, minHI=999999, minLO=999999, MinBack=ATR*MathAbs(Trl);    // и заднего фронтов; 
   uchar TrlHi=0, TrlLo=0; 
   
   for (uchar f=1; f<LevelsAmount; f++){ 
      if (F[f].P==0)    continue; // пустые значения пропускаем
      if (F[f].Brk>0)  continue; // только непробитые,        
      if (MathAbs(F[f].P-F[f].Back)<MinBack) continue; // уровень должен быть с достаточным отскоком 
      if (F[f].Dir>0 && F[f].T>SellTime)  LOWEST_HI (H, minHI, f, TrlHi);  // пик, образовавшийся после продажи
      if (F[f].Dir<0 && F[f].T>BuyTime)   HIGHEST_LO(L, minLO, f, TrlLo);  // впадина, образовавшаяся после покупки
      }
   if (TrlLo>0)   StpBuy=F[TrlLo].P-DELTA(Stp);    
   if (TrlHi>0)   StpSel=F[TrlHi].P+DELTA(Stp);      
   
   if (BUY  && StpBuy>0 && StpBuy-STOP_BUY>ATR  && (StpBuy>BUY  || Trl<0)){ // 
      A("TRAILING_BUY="+S4(StpBuy), StpBuy, SHIFT(F[TrlLo].T), clrGreen);
      STOP_BUY=StpBuy; Modify=true;}            
   if (SELL && StpSel>0 && STOP_SELL-StpSel>ATR && (StpSel<SELL || Trl<0)){//
      V("TRAILING_SELL="+S4(StpSel), StpSel, SHIFT(F[TrlHi].T), clrGreen);
      STOP_SELL=StpSel; Modify=true;} 
   if (Real) ERROR_CHECK("TRAILING");     
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void POC_CLOSE_TO_ORDER(){// УДАЛЕНИЕ ОТЛОЖНИКА ЕСЛИ ПЕРЕД НИМ ФОРМИРУЕТСЯ ФЛЭТ. Проверяется в COUNT()
   if (oFlt==0) return;   // 
   float Near=float(ATR*0.5*oFlt);
   if (SELLLIMIT>0){ // пик (poc) перед зоной продажи = цена "отдохнула"
      if (PocCnt>2 && SELLLIMIT-PocCenter<Near)       {Sel.Pattern=0; SELLLIMIT=0; Modify=true; X("PocNearSel",PocCenter, bar, clrRed);}         // перед лимиткой cформировалось уплотнение из нескольких бар
      if (SELLLIMIT-F[hi].P<Near && F[hi].T>SellTime) {Sel.Pattern=0; SELLLIMIT=0; Modify=true; X("HiNearSel", F[hi].P, SHIFT(F[hi].T), clrRed);}  // или вершина
      if (SELLLIMIT-F[lo].P<Near && F[lo].T>SellTime) {Sel.Pattern=0; SELLLIMIT=0; Modify=true; X("LoNearSel", F[lo].P, SHIFT(F[lo].T), clrRed);}  // или впадина
      }   
   if (BUYLIMIT>0){  // пик перед зоной продажи = цена "отдохнула"
      if (PocCnt>2 && PocCenter-BUYLIMIT<Near)        {Buy.Pattern=0; BUYLIMIT=0;  Modify=true; X("PocNearBuy",PocCenter, bar, clrRed);}
      if (F[lo].P-BUYLIMIT<Near && F[lo].T>BuyTime)   {Buy.Pattern=0; BUYLIMIT=0;  Modify=true; X("LoNearBuy", F[lo].P, SHIFT(F[lo].T), clrRed);} 
      if (F[hi].P-BUYLIMIT<Near && F[hi].T>BuyTime)   {Buy.Pattern=0; BUYLIMIT=0;  Modify=true; X("HiNearBuy", F[hi].P, SHIFT(F[hi].T), clrRed);}
   }  } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ            



   