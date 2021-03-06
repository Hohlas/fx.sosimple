void ORDERS_SET(){
   bool repeat;   int ticket;   float TradeRisk=0; 
   if (ExpirBars>0)  Expiration=Time[0]+ExpirBars*Period()*60; else Expiration=0;// уменьшаем период на 30сек, чтоб совпадало с реалом 
   if (Buy.Inp>0){
      repeat=true;   uchar try=0; 
      Buy.Inp = N5(Buy.Inp);
      Buy.Stp = N5(Buy.Stp);
      Buy.Prf = N5(Buy.Prf);
      if (MathAbs(Buy.Inp-Ask) <=StopLevel)     Buy.Inp=(float)Ask; 
      if (Buy.Inp-Buy.Stp <= StopLevel+Spred)   {X("WrongBuyStop="  +S4(Buy.Inp-Buy.Stp), Buy.Inp, bar, clrRed); return;}  // слишком близкий/неправильный стоп
      if (Buy.Prf-Buy.Inp <= StopLevel+Spred)   {X("WrongBuyProfit="+S4(Buy.Prf-Buy.Inp), Buy.Inp, bar, clrRed); return;}  // слишком близкий/неправильный тейк
      if (Real){
         str="";
         ERROR_CHECK("ORDERS_SET/PreBuy");// сброс буфера ошибок
         MARKET_INFO();
         float Stop=Buy.Inp-Buy.Stp;
         if (Stop<=0) {Report("StopBuy<=0"); return;}
         Lot=MM(Stop); if (Lot<0) {Report("Lot<0"); return;} 
         TradeRisk=RiskChecker(Lot,Stop,Symbol());   //   Print("Lot=",Lot," StopBuy=",StopBuy," TradeRisk=",TradeRisk," Buy.Inp=",Buy.Inp," Buy.Stp=",Buy.Stp," Buy.Prf=",Buy.Prf);
         if (TradeRisk>MaxRisk) {Report("RiskChecker="+S1(TradeRisk)+"% too BIG!!! Lot="+S2(Lot)+" Balance="+S0(AccountBalance())+" Stop="+S4(Stop)+" Buy.Inp="+S4(Buy.Inp)+" Buy.Stp="+S4(Buy.Stp)); return;}
         TerminalHold(60); // ждем 60сек освобождения терминала
         }
      while (repeat && BUY==0 && BUYSTOP==0 && BUYLIMIT==0){ // чтобы исключить повторное выставление при ошибке 128
         if (Buy.Inp-Ask>StopLevel)  {if (Real) str="SetBuyStp";   ticket=OrderSend(Symbol(),OP_BUYSTOP, Lot, Buy.Inp, 3, Buy.Stp, Buy.Prf, ExpID, Magic, Expiration,clrBlue);}   else
         if (Ask-Buy.Inp>StopLevel)  {if (Real) str="SetBuyLim";   ticket=OrderSend(Symbol(),OP_BUYLIMIT,Lot, Buy.Inp, 3, Buy.Stp, Buy.Prf, ExpID, Magic, Expiration,clrBlue);}   else
               {Buy.Inp=(float)Ask;   if (Real) str="SetBuy";      ticket=OrderSend(Symbol(),OP_BUY,     Lot, Buy.Inp, 3, Buy.Stp, Buy.Prf, ExpID, Magic,    0      ,clrBlue);}
         if (ticket<0){
            ERROR_CHECK("ORDERS_SET/Buy");
            repeat=true; 
            try++; if (try>3) repeat=false;}
         else repeat=false;
         if (Real){
            Report(str+S4(Buy.Inp)+"/"+S4(Buy.Stp)+"/"+S4(Buy.Prf)+"/"+S2(Lot)+"x"+S1(TradeRisk)+"% Expir="+DTIME(Expiration)); str="";
            ORDER_CHECK();
      }  }  }
   if (Sel.Inp>0){ 
      repeat=true;   uchar try=0; 
      Sel.Inp = N5(Sel.Inp); 
      Sel.Stp = N5(Sel.Stp);   
      Sel.Prf = N5(Sel.Prf); 
      if (MathAbs(Sel.Inp-Bid) <=  StopLevel)  Sel.Inp=(float)Bid;// немного отодвигаем стоп от расчетной точки
      if (Sel.Stp-Sel.Inp <= StopLevel+Spred) {X("WrongSellStop="  +S4(Sel.Stp-Sel.Inp),    Sel.Inp, bar, clrRed); return;}  // слишком близкий/неправильный стоп
      if (Sel.Inp-Sel.Prf <= StopLevel+Spred) {X("WrongSellProfit="+S4(Sel.Inp-Sel.Prf),  Sel.Inp, bar, clrRed); return;}  // слишком близкий/неправильный тейк
      if (Real){
         str="";
         ERROR_CHECK("ORDERS_SET/PreSell");// сброс буфера ошибок
         MARKET_INFO();
         float Stop=Sel.Stp-Sel.Inp;
         if (Stop<=0) {Report("StopSell<=0"); return;}
         Lot=MM(Stop); if (Lot<0) {Report("Lot<0"); return;}
         TradeRisk=RiskChecker(Lot,Stop,Symbol());
         if (TradeRisk>MaxRisk) {Report("RiskChecker="+S1(TradeRisk)+"% too BIG!!! Lot="+S2(Lot)+" Balance="+S0(AccountBalance())+" Stop="+S4(Sel.Stp-Sel.Inp)+" Sel.Inp="+S4(Sel.Inp)+" Sel.Stp="+S4(Sel.Stp)); return;}
         TerminalHold(60); // ждем 60сек освобождения терминала
         }
      while (repeat &&  SELL==0 && SELLSTOP==0 && SELLLIMIT==0){   //  V("SELL "+S4(Sel.Inp)+"/"+S4(Sel.Stp)+"/"+S4(Sel.Prf), Sel.Inp, bar, clrSilver);
         if (Bid-Sel.Inp>StopLevel) {if (Real) str="SetSellStp";   ticket=OrderSend(Symbol(),OP_SELLSTOP, Lot, Sel.Inp, 3, Sel.Stp, Sel.Prf, ExpID, Magic, Expiration,clrRed);}   else
         if (Sel.Inp-Bid>StopLevel) {if (Real) str="SetSellLim";   ticket=OrderSend(Symbol(),OP_SELLLIMIT,Lot, Sel.Inp, 3, Sel.Stp, Sel.Prf, ExpID, Magic, Expiration,clrRed);}   else
               {Sel.Inp=(float)Bid;  if (Real) str="SetSell";      ticket=OrderSend(Symbol(),OP_SELL,     Lot, Sel.Inp, 3, Sel.Stp, Sel.Prf, ExpID, Magic,      0    ,clrRed);}
         if (ticket<0){
            ERROR_CHECK("ORDERS_SET/Sell");
            repeat=true; 
            try++; if (try>3) repeat=false;}
         else repeat=false;
         if (Real){
            Report(str+S4(Sel.Inp)+"/"+S4(Sel.Stp)+"/"+S4(Sel.Prf)+"/"+S2(Lot)+"x"+S1(TradeRisk)+"% Expir="+DTIME(Expiration)); str="";    
            ORDER_CHECK();
      }  }  }
   TerminalFree();
   if (Real) ERROR_CHECK("ORDERS_SET");
   }  
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void ORDERS_MODIFY(){   // Похерим необходимые стоп/лимит ордера: удаление если Buy/Sell=0       
   if (!Modify) return;
   bool ReSelect=true, make;      // если похерили какой-то ордер, надо повторить перебор сначала, т.к. OrdersTotal изменилось, т.е. они все перенумеровались 
   while (ReSelect){        // и переменная ReSelect вызовет их повторный перебор        
      ReSelect=false; int Orders=OrdersTotal(); //Print("ORDERS_MODIFY()/ReSelect=",ReSelect,"  Orders=",Orders);
      for (int i=0; i<Orders; i++){ //Print("for:  i=",i);
         if (ReSelect) break; // при ошибках перебор ордеров начинается заново
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true && OrderMagicNumber()==Magic){
            int Order=OrderType();  make=false;  uchar try=0;  //Print("for: Order=",ORDER_TO_STR(Order));
            if (Real){
               str="";
               MARKET_INFO();
               ERROR_CHECK("PreModify");}
            while (!make){// повторяем операции над ордером, пока не достигнем результата
               make=true; //Print("Begin: Order=",ORDER_TO_STR(Order)," i=",i," Orders=",Orders);
               switch(Order){
                  case OP_SELL:        
                     if (SELL==0){     //  C L O S E     S E L L  
                        if (Real) str="CloseSELL-"+S4(OrderOpenPrice());
                        TerminalHold(60); make=OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);       
                        break;} 
                                       //  M O D I F Y     S E L L  
                     STOP_SELL  =N5(STOP_SELL);    // нормализация до
                     PROFIT_SELL=N5(PROFIT_SELL);  // пятого знака
                     if (EQUAL(STOP_SELL,OrderStopLoss()) && EQUAL(PROFIT_SELL,OrderTakeProfit())) break; // новые значения должны отличаться от текущих охтябы на 10 пунктов
                     if (STOP_SELL-Ask<=Spred || Ask-PROFIT_SELL<=Spred) break; // корректность новых значений 
                     if (Real){
                        if (!EQUAL(STOP_SELL,   OrderStopLoss()))    str="ModifySellStp-"+S4(OrderStopLoss())+"/"+S4(STOP_SELL);
                        if (!EQUAL(PROFIT_SELL, OrderTakeProfit()))  str="ModifySellPrf-"+S4(OrderTakeProfit())+"/"+S4(PROFIT_SELL);}
                     TerminalHold(60);    make=OrderModify(OrderTicket(), OrderOpenPrice(), STOP_SELL, PROFIT_SELL,OrderExpiration(),clrRed);   //Print(" ord=",ord," STOP_SELL=",STOP_SELL," OrderStopLoss=",OrderStopLoss()," PROFIT_SELL=",PROFIT_SELL," OrderTakeProfit=",OrderTakeProfit());    
                  break;     
                  case OP_SELLSTOP:    //  D E L   S E L L S T O P  //
                     if (SELLSTOP==0){ 
                        if (Real) str="DelSellStop-"+S4(OrderOpenPrice());
                        TerminalHold(60); make=OrderDelete(OrderTicket(),clrRed);}                      
                  break;
                  case OP_SELLLIMIT:   //  D E L   S E L L L I M I T  //
                     if (SELLLIMIT==0){
                        if (Real) str="DelSellLimit-"+S4(OrderOpenPrice());
                        TerminalHold(60); make=OrderDelete(OrderTicket(),clrRed);}    
                  break;   
                  case OP_BUY: //  C L O S E     B U Y 
                     if (BUY==0){
                        if (Real) str="CloseBUY-"+S4(OrderOpenPrice());
                        TerminalHold(60); make=OrderClose(OrderTicket(),OrderLots(),Bid,3,clrBlue);       
                        break;}    
                              //   M O D I F Y    B U Y  
                     STOP_BUY  =N5(STOP_BUY);   // нормализация до
                     PROFIT_BUY=N5(PROFIT_BUY); // пятого знака
                     if (EQUAL(STOP_BUY,OrderStopLoss()) && EQUAL(PROFIT_BUY,OrderTakeProfit()))   break; // новые значения должны отличаться от текущих охтябы на 10 пунктов
                     if (Bid-STOP_BUY<=Spred || PROFIT_BUY-Bid<=Spred) break; // корректность новых значений 
                     if (Real){ 
                        if (!EQUAL(STOP_BUY,    OrderStopLoss()))    str="ModifyBuyStp-"+S4(OrderStopLoss())+"/"+S4(STOP_BUY);
                        if (!EQUAL(PROFIT_BUY,  OrderTakeProfit()))  str="ModifyBuyPrf-"+S4(OrderTakeProfit())+"/"+S4(PROFIT_BUY);}
                     TerminalHold(60);    make=OrderModify(OrderTicket(), OrderOpenPrice(), STOP_BUY, PROFIT_BUY,OrderExpiration(),clrBlue);   //Print(" ord=",ord," STOP_BUY=",STOP_BUY," OrderStopLoss=",OrderStopLoss()," PROFIT_BUY=",PROFIT_BUY," OrderTakeProfit=",OrderTakeProfit());      
                  break;
                  case OP_BUYSTOP:  //  D E L  B U Y S T O P  
                     if (BUYSTOP==0){
                        if (Real) str="DelBuyStop-"+S4(OrderOpenPrice());
                        TerminalHold(60); make=OrderDelete(OrderTicket(),clrBlue);}                      
                  break;
                  case OP_BUYLIMIT: //  D E L  B U Y L I M I T  
                     if (BUYLIMIT==0){
                        if (Real) str="DelBuyLimit-"+S4(OrderOpenPrice());
                        TerminalHold(60); make=OrderDelete(OrderTicket(),clrBlue);}                      
                  break;
                  }  //Print("End: Order=",ORDER_TO_STR(Order)," i=",i," Orders=",Orders," make=",make);      
               if (Real && str!="") {Report(str);  str="";}
               if (!make){
                  Print("ERROR1 in Modyfy",ORDER_TO_STR(Order)," Ticket=",OrderTicket());
                  ERROR_CHECK("Modify");
                  try++;  if (try>3) {Print("ERROR2 in Modyfy try=",try); return;}             
            }  }  }//while(repeat)
         if (Orders!=OrdersTotal()) {ReSelect=true; break;} // при ошибках или изменении кол-ва ордеров надо заново перебирать ордера (выходим из цикла "for"), т.к. номера ордеров поменялись
         }//if (OrderSelect      
      }//while(ReSelect)     
   TerminalFree();
   Modify=false; // флаг необходимости модификации (удаления) ордеров
   if (Real) ERROR_CHECK("ORDERS_MODIFY");  
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool EQUAL(double One, double Two){// совпадение значений с точностью до 10 тиков
   if (MathAbs(One-Two)<10*Point) return true; else return false;
   }        
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void ORDER_CHECK(){   // ПАРАМЕТРЫ ОТКРЫТЫХ И ОТЛОЖЕННЫХ ПОЗ
   BUY=0; BUYSTOP=0; BUYLIMIT=0; SELL=0; SELLSTOP=0; SELLLIMIT=0;  STOP_BUY=0; PROFIT_BUY=0; STOP_SELL=0; PROFIT_SELL=0;
   for (int i=0; i<OrdersTotal(); i++){ 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true && OrderMagicNumber()==Magic){
         if (OrderType()==6) continue; // ролловеры не записываем
         switch(OrderType()){
            case OP_BUYSTOP:  BUYSTOP=(float)OrderOpenPrice();  STOP_BUY=(float)OrderStopLoss();  PROFIT_BUY=(float)OrderTakeProfit();   BuyTime=OrderOpenTime();    break;
            case OP_BUYLIMIT: BUYLIMIT=(float)OrderOpenPrice(); STOP_BUY=(float)OrderStopLoss();  PROFIT_BUY=(float)OrderTakeProfit();   BuyTime=OrderOpenTime();    break;
            case OP_BUY:      BUY=(float)OrderOpenPrice();      STOP_BUY=(float)OrderStopLoss();  PROFIT_BUY=(float)OrderTakeProfit();   BuyTime=OrderOpenTime();    break;
            case OP_SELLSTOP: SELLSTOP=(float)OrderOpenPrice(); STOP_SELL=(float)OrderStopLoss(); PROFIT_SELL=(float)OrderTakeProfit();  SellTime=OrderOpenTime();   break;
            case OP_SELLLIMIT:SELLLIMIT=(float)OrderOpenPrice();STOP_SELL=(float)OrderStopLoss(); PROFIT_SELL=(float)OrderTakeProfit();  SellTime=OrderOpenTime();   break;
            case OP_SELL:     SELL=(float)OrderOpenPrice();     STOP_SELL=(float)OrderStopLoss(); PROFIT_SELL=(float)OrderTakeProfit();  SellTime=OrderOpenTime();   break;
   }  }  }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void MARKET_INFO(){// обновление Spred и StopLevel
   RefreshRates();
   Spred    =float((MarketInfo(Symbol(),MODE_SPREAD))*Point);
   StopLevel=float((MarketInfo(Symbol(),MODE_STOPLEVEL)+1)*Point); // 
   }      
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void BALANCE_CHECK(){// Проверка  состояния баланса для изменения лота текущих отложников  (При инвестировании или после крупных сделок)
   if (!Real) return; 
   Sleep(Magic*100);
   if (!GlobalVariableSetOnCondition("CanTrade",Magic,0)) return; // попытка захватат флага доступа к терминалу 
   //if (TimeCurrent()-GlobalVariableGet("LastOrdersCheckTime")<600) return;
   double BalanceChange=(GlobalVariableGet("LastBalance")-AccountBalance())*100/AccountBalance();
   if (MathAbs(BalanceChange)<10 || AccountBalance()<1) return; // баланс изменился свыше 10%
   if (BalanceChange>0) str="increase"; else str="decrease";
   Report("Balance "+str+" on "+ S0(MathAbs(BalanceChange)) +"%, recount orders");
   GlobalVariableSet("LastBalance",AccountBalance()); 
   
   GlobalVariableSet("CanTrade",0); // сбрасываем глобал
   ERROR_CHECK("BALANCE_CHECK");  
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
string ORDER_TO_STR(int Type){ 
   switch(Type){
      case 0:  return ("BUY"); 
      case 1:  return ("SELL");
      case 2:  return ("BUYLIMIT"); 
      case 3:  return ("SELLLIMIT");
      case 4:  return ("BUYSTOP");
      case 5:  return ("SELLSTOP");
      case 10: return ("SetBUY");
      case 11: return ("SetSELL");
      default: return ("---");
   }  }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   

