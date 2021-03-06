float MM(float Stop){
   float   MinLot =(float)MarketInfo(Symbol(),MODE_MINLOT), // CurDD - глобальная, т.к. передается в ф. TradeHistoryWrite() 
           MaxLot =(float)MarketInfo(Symbol(),MODE_MAXLOT);        
   if (Risk>MaxRisk) Risk=float(MaxRisk*0.95);// проверка на ошибочное значение риска
   int CurDD=CURRENT_DD(); // последняя незакрытая просадка эксперта (не максимальной) 
   if (Stop<=0)                                 {Report("MM: Stop<=0!");    return (-MinLot);}
   if (MarketInfo(Symbol(),MODE_POINT)<=0)      {Report("MM: POINT<=0!");   return (-MinLot);}
   if (MarketInfo(Symbol(),MODE_TICKVALUE)<=0)  {Report("MM: TICKVAL<0!");  return (-MinLot);}
   if (CurDD>HistDD)                            {Report("MM: CurDD>HistDD!: "+DoubleToStr(CurDD,0)+">"+DoubleToStr(HistDD,0));return (-MinLot);}
   // см.Расчет залога http://www.alpari.ru/ru/help/forex/?tab=1&slider=margins#margin1
   // Margin = Contract*Lot/Leverage = 100000*Lot/100  
   // MaxLotForMargin=NormalizeDouble(AccountFreeMargin()/MarketInfo(Symbol(),MODE_MARGINREQUIRED),LotDigits) // Макс. кол-во лотов для текущей маржи
   Lot = float(NormalizeDouble(Depo(MM)*Risk*0.01 / (Stop/MarketInfo(Symbol(),MODE_POINT)*MarketInfo(Symbol(),MODE_TICKVALUE)), LotDigits)); // размер стопа через Стоимость пункта. См. калькулятор трейдера http://www.alpari.ru/ru/calculator/
   if (Lot<MinLot) Lot=MinLot;   // Проверка на соответствие условиям ДЦ
   if (Lot>MaxLot) Lot=MaxLot; //Print("Risk=",Risk," RiskChecker=",RiskChecker(Lot,Stop));
   if (RiskChecker(Lot,Stop,Symbol())>MaxRisk) {Report("MM: RiskChecker="+DoubleToStr(RiskChecker(Lot,Stop,Symbol()),2)+"% - Trade Disable!"); return (-MinLot);}// Не позволяем превышать риск MaxRisk%! 
   if (Risk<0.1) return(MinLot);
   return (Lot);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
float RiskChecker(float lot, float Stop, string SYMBOL){// Проверим, какому риску будет соответствовать расчитанный Лот:  
   if (MarketInfo(SYMBOL,MODE_TICKVALUE)<=0) {Report("RiskChecker(): "+SYMBOL+" TickValue<0"); return (100);}
   if (MarketInfo(SYMBOL,MODE_POINT)<=0)     {Report("RiskChecker(): POINT<=0!"); return (-1);}
   return (float(NormalizeDouble(lot * (Stop/MarketInfo(SYMBOL,MODE_POINT)*MarketInfo(SYMBOL,MODE_TICKVALUE)) / AccountBalance()*100,2)));
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
int CURRENT_DD(){// расчет последней незакрытой просадки эксперта (не максимальной)  
   int  Ord;
   double MaxExpertProfit=LastTestDD, ExpertProfit=0, profit=0;
   for(Ord=0; Ord<OrdersHistoryTotal(); Ord++){// находим среди всей истории сделок эксперта ПОСЛЕДНЮЮ просадку и измеряем ее от макушки баланса до текущего значения (Не до минимального!)
      if (OrderSelect(Ord,SELECT_BY_POS,MODE_HISTORY)==true && OrderMagicNumber()==Magic && OrderCloseTime()>TestEndTime){
         profit=OrderProfit()+OrderSwap()+OrderCommission(); // прибыль от выбранного ордера в пунктах
         if (profit!=0){ 
            profit=profit/OrderLots()/MarketInfo(Symbol(),MODE_TICKVALUE)*0.1;
            ExpertProfit+=profit; // текущая прибыль эксперта
            if (ExpertProfit>MaxExpertProfit) MaxExpertProfit=ExpertProfit; // Print(" CurDD(): magic=",Magic," profit=",profit," MaxExpertProfit=",MaxExpertProfit," ExpertProfit=",ExpertProfit," OrderCloseTime()=",TimeToStr(OrderCloseTime(),TIME_SECONDS));// максимальная прибыль эксперта                  
      }  }  } 
   return (int(MaxExpertProfit-ExpertProfit)); // значение последней незакрытой просадки эксперта (не максимальной)
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
int Depo(int TypeMM){ // Расчет части депозита, от которой берется процент для совершения сделки 
   double Deposite=0, ExpMaxBalance=AccountBalance(); // индивидуальная переменная, должна храниться в файле с временными параметрами
   switch (TypeMM){
      case 1: // Классический Антимартингейл
         Deposite=AccountBalance();   //Print("ExpMaxDD=",ExpMaxDD," CarrentDD=",cDD," Balance=",AccountBalance()," Deposite=",Deposite, " K=",100*(ExpMaxDD-cDD)/ExpMaxDD,"%");// Дополнительно уменьшаем риск эксперта пропорционально глубине его текущей просадки      
      break; 
      case 2: // Индивидуальный баланс. Фиксируется начало индивидуальной просадки и риск начинает увеличиваться до выхода из нее за счет прироста баланса от прибыльных систем. 
         // Но не превышает установленного риска для данной системы, если баланс продолжает снижаться.  
         if (CURRENT_DD()==0 && AccountBalance()>ExpMaxBalance) ExpMaxBalance=AccountBalance(); // Лот увеличивается только если система в плюсе и общий баланс растет. Т.е. если другие системы не сливают. 
         Deposite=MathMin(ExpMaxBalance,AccountBalance()); // Не превышаем установленного риска
      break; 
      case 3: // Процент от общего максимально достигнутого баланса.
         // При просадке экспертов лот не понижается (риск растет вплоть до 10%). 
         // Выход из просадки осуществляется с большей скоростью за счет растущего баланса от друхих систем. 
         // При этом оказывается значителььное влияние убыточных систем на общий баланс. 
         Deposite=GlobalVariableGet("MaxBalance");
         if (AccountBalance()>Deposite) Deposite=AccountBalance();
         GlobalVariableSet("MaxBalance",Deposite);
      break;
      case 4: // Общий баланс с дополнительным сокращением риска при индивидуальной просадке
         Deposite=AccountBalance()-CURRENT_DD();  // Дополнительно уменьшаем риск эксперта пропорционально глубине его текущей просадки      
      break; 
      //case 5: // Общий баланс с дополнительным сокращением риска при индивидуальной просадке
      //   Deposite=AccountBalance()*(HistDD-CurDD)/HistDD;   //Print("ExpMaxDD=",ExpMaxDD," CarrentDD=",cDD," Balance=",AccountBalance()," Deposite=",Deposite, " K=",100*(ExpMaxDD-cDD)/ExpMaxDD,"%");// Дополнительно уменьшаем риск эксперта пропорционально глубине его текущей просадки      
      //break; 
      default: Deposite=AccountBalance(); //Deposite=AccountBalance(); // Классический Антимартингейл
      }
   return (int(Deposite));
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
