#define ExpParams 50 // максимальное количество входных параметров эксперта
struct EXPERTS_DATA{// данные эксперта
   int      Per, HistDD, LastTestDD, Magic,Bar;
   datetime ExpMemory, TestEndTime;
   char     PRM[ExpParams];
   string   Sym, Name, OptPeriod;
   float    Risk, RevBUY, RevSELL;   
   };
EXPERTS_DATA CSV[100];   // массив со всеми параметрами всех экспертов, созданный из файла #.csv 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
bool INPUT_FILE_READ (){// занесение в массив считанных из csv файла входных параметров   ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   ResetLastError();
   string InputFileName="#.csv"; 
   int InputFile=-1, chr;
   uchar line=1;
   datetime WaitingTime=30, StartWaiting=TimeLocal();
   if (IsTesting() || IsOptimization()) StartWaiting=TimeLocal()-WaitingTime-5; // чтобы сразу сработала защита при отсутствии файла
   while (InputFile<0){
      Sleep((BackTest+1)*50); // для разгрузки процессора, чтобы не ломились все разом 
      InputFile=FileOpen(InputFileName, FILE_READ | FILE_SHARE_READ | FILE_SHARE_WRITE); 
      if (InputFile<0 && TimeLocal()-StartWaiting>30) {Alert("INPUT_FILE_READ(): Can't open file "+InputFileName+"!");  return(false);}
      }      
   int Column, StrPosition;  
   bool TrueChart=false; 
   while (!FileIsEnding(InputFile)){ 
      line++;  // номер считываемой строки
      str=FileReadString(InputFile); while (!FileIsLineEnding(InputFile)) str=FileReadString(InputFile); // читаем всю херь, пока не кончилась строка 
      str=FileReadString(InputFile); // считываем первый столбец с именем эксперта, датами оптимизации и спредами 
      if (StringFind(str," ",0)<0 || StringFind(str,"-",0)<0) continue; // если в первом столбце не найдены символы " " и "-" то это левая строка, и параметры из нее не читаем
      StrPosition=StringFind(str," ",0); // ищем в строке пробел
      CSV[line].Name=StringSubstr(str,0,StrPosition); 
      StrPosition=StringFind(str,"-",10); // ищем "-" разелитель между началом и концом теста
      CSV[line].TestEndTime=StrToTime(StringSubstr(str,StrPosition+1,10)); // дату конца теста сразу переводим в секунды  Print("Seconds=",TestEndTime," TestEndTime=",TimeToStr(TestEndTime,TIME_DATE));
      StrPosition=StringFind(str,"OPT-",30); // ищем "OPT-" надпись перед сохраненным периодом оптимизации
      if (StrPosition>0) CSV[line].OptPeriod=StringSubstr(str,StrPosition+4,0); else CSV[line].OptPeriod="UnKnown"; //Print("OptPeriod=",OptPeriod);// период начальной оптимизации, сохраненный при самой первой оптимизации
      str=FileReadString(InputFile);// считываем второй столбец с названием пары и ТФ     
      for (chr=0; chr<StringLen(str); chr++)  // Print("s=",StringSubstr(str,chr,1)," cod=",StringGetChar(str,chr));      
         if (StringGetChar(str,chr)>47 && StringGetChar(str,chr)<58) break; // попалось число с кодом: ("0"-48, "1"-49, "2"-50,..., "9"-57)
      CSV[line].Sym=StringSubstr(str,0,chr); 
      CSV[line].Per=int(StrToDouble(StringSubstr(str,chr,0)));       //Print(" Name=",CSV[line].Name," Sym=",CSV[line].Sym," Per=",CSV[line].Per);
      for (Column=3; Column<15; Column++){ // все столбцы, включая magic
         str=FileReadString(InputFile); // читаем просадки HistDD и LastTestDD
         if (Column==7){
            StrPosition=StringFind(str,"_",0);
            CSV[line].HistDD=int(StrToDouble(StringSubstr(str,0,StrPosition)));         //Print("aHistDD[",line,"]=",CSV[line].HistDD);
            CSV[line].LastTestDD=int(StrToDouble(StringSubstr(str,StrPosition+1,0)));   //Print("aLastTestDD[",line,"]=",CSV[line].LastTestDD);
         }  }   
      CSV[line].Risk =float(StrToDouble(FileReadString(InputFile))*Aggress); // 15-й столбец (Risk)
      CSV[line].Magic=int(StrToDouble(FileReadString(InputFile))); // 16-й столбец (Magic)     
      //REAL_PARAM_RESTORE(CSV[line].Magic, CSV[line].Bar, CSV[line].RevBUY, CSV[line].RevSELL, CSV[line].ExpMemory);// восстанавливаем из файла индивидуальные переменные эксперта Print("Magic[",line,"]=",CSV[line].Magic,": HistDD=",CSV[line].HistDD," Risk=",CSV[line].Risk," RevBUY=",CSV[line].RevBUY," ExpMemory=",CSV[line].ExpMemory);
      if (CSV[line].Risk==0) EMPTY_EXPERTS_DELETE(CSV[line].Magic);
      for (chr=0; chr<ExpParams; chr++) CSV[line].PRM[chr]=char(StrToDouble(FileReadString(InputFile))); // записываем входные параметры эксперта в общий массив
      Print(line,": Magic=",CSV[line].Magic, " Name:",CSV[line].Name," Bar=",CSV[line].Bar," ExpMemory=",CSV[line].ExpMemory," PRM:",CSV[line].PRM[0],",",CSV[line].PRM[1],",",CSV[line].PRM[2],",",CSV[line].PRM[3]);
      }    
   FileClose(InputFile);
   string NameRead = CSV[BackTest].Name+"_" + CSV[BackTest].Sym + S0(CSV[BackTest].Per);
   if (NameRead!=ExpertName+"_"+Symbol()+S0(Period())){
      Alert("Строка №"+S0(BackTest)+": \""+NameRead+"\" файла "+InputFileName+" не соответствует эксперту: "+ExpertName+"_"+Symbol()+S0(Period()));   
      return(false);} 
   DATA_PROCESSING(0, READ_ARR); // считываем значения из этого файла во внешние переменные эксперта
   TestEndTime=CSV[BackTest].TestEndTime;
   OptPeriod=  CSV[BackTest].OptPeriod;
   HistDD=     CSV[BackTest].HistDD;
   LastTestDD= CSV[BackTest].LastTestDD;
   Risk=       CSV[BackTest].Risk;
   Magic=      CSV[BackTest].Magic;
   RevBUY=     CSV[BackTest].RevBUY; 
   RevSELL=    CSV[BackTest].RevSELL; 
   ExpMemory=  CSV[line].ExpMemory;
   ExpertsTotal=line;      
   ERROR_CHECK("INPUT_FILE_READ");
   return(true); // кол-во экспертов в файле 
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void EMPTY_EXPERTS_DELETE(int MagicToDelete){// удаление всех поз экспертов с риском=0.
   if (!Real) return;
   Magic=MagicToDelete;
   ORDER_CHECK();
   if (BUY==0 && BUYSTOP==0 && BUYLIMIT==0 && SELL==0 && SELLSTOP==0 && SELLLIMIT==0) return;          
   BUY=0; BUYSTOP=0; BUYLIMIT=0; SELL=0; SELLSTOP=0; SELLLIMIT=0; 
   Report("Expert "+DoubleToStr(Magic,0)+" remove own orders, as its Risk=0");
   Modify=true;
   ORDERS_MODIFY(); // херим все ордера c этим Мэджиком 
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void END(){// запуск после прохода всех экспертов ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   ERROR_CHECK("END");
   if (IsTesting() || IsOptimization()) return;
   CHECK_RESULT(); // ДОКЛАД О ПОСЛЕДНИХ СДЕЛКАХ
   SAVE_GLOBALS(); // СОХРАНЕНИЕ В ФАЙЛ ГЛОБАЛЬНЫХ ПЕРЕМЕННЫХ: BarTime, RevBUY, RevSELL, ExpMemory  
   SAVE_HISTORY(); // ПИШЕМ СОБРАННЫЕ СООБЩЕНИЯ history в один общий файл Reports.csv 
   MAIL_SEND();
   LastBarTime=BarTime; // для подсчета пропущенных бар
   ERROR_CHECK("END2");
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void TerminalHold(ushort WaitingTime){// ожидание освобождения торгового потока, чтобы в каждый момент времени терминал был занят только одним экспертом из всего портфеля
   if (!Real) return;
   if (GlobalVariableGet("CanTrade")==Magic) {  // если глобал свой,
      GlobalVariableSet("BusyTime",TimeLocal());// обновляем время установки глобала
      return;
      }
   // Print(Magic,": TerminalHold");   
   while (GlobalVariableGet("CanTrade")!=Magic){ // присваиваем глобальной переменной значение Magic когда она станет равна 0.
      Sleep(BackTest); // для разгрузки процессора  
      if (GlobalVariableGet("CanTrade")==0) {
         GlobalVariableSet("CanTrade",Magic);
         GlobalVariableSet("BusyTime",TimeLocal()); // фиксируем время установки глобала 
         continue;}
      if (TimeLocal()-GlobalVariableGet("BusyTime")>WaitingTime){ // прождали, насильно захватываем торговый поток, т.к. что-то значит не в порядке
         Report("Expert "+DoubleToStr(GlobalVariableGet("CanTrade"),0)+" work time exceed "+DoubleToStr((TimeLocal()-GlobalVariableGet("BusyTime")),0)+" seconds!, Set own flag: "+DoubleToStr(Magic,0)); // докладываем о занятом торговом потоке
         GlobalVariableSet("CanTrade",0); // сбрасываем Magic 
   }  }  } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void TerminalFree(){ // освобождение торгового потока
   if (!Real) return;
   if (GlobalVariableGet("CanTrade")==0) return;
   if (GlobalVariableGet("CanTrade")!=Magic) // кто-то уже занял без спроса
      Report("Expert "+DoubleToStr(GlobalVariableGet("CanTrade"),0)+" occupy terminal!"); 
   else{ 
      // Print(Magic,": TerminalFree");
      GlobalVariableSet("CanTrade",0);  // освобождаем торговый поток
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
string EXP_INFO(){
   string RunPeriod=StartDate+"-"+TimeToStr(LastDay,TIME_DATE); // период теста/оптимизации
   if (BackTest==0 && IsOptimization())  OptPeriod=RunPeriod; // фиксируем интервал оптимизации, чтобы потом отразить его на графике матлаба жирным
   return (ExpertName+" "+RunPeriod+", Sprd="+DoubleToStr(Spred/Point,0)+", StpLev="+DoubleToStr(StopLevel/Point,0)+", Swaps="+DoubleToStr((MarketInfo(Symbol(),MODE_SWAPLONG)+MarketInfo(Symbol(),MODE_SWAPSHORT)),2)+", OPT-"+OptPeriod);
   }    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
double OnTester(){////  Ф О Р М И Р О В А Н И Е   Ф А Й Л А    О Т Ч Е Т А   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   float   CustomMax, CountedRisk=1, Years, MO,RF=555, iRF=555, PF=555, Sharp=555;  
   short LossesCnt=0, WinCnt=0;       
   double MinDepo=InitDeposit, profit,  SD=0,  iDD=0, MaxWin[5], MidWin, MidLoss, GrossProfit=0, GrossLoss=0, FullProfit=0, MaxProfit=0; 
   ArrayInitialize(MaxWin,0);
   Years=float(day/260.0); //Print("day=",day," Years=",Years);
   ushort Trades=0;
   //InitDeposit=TesterStatistics(STAT_INITIAL_DEPOSIT);
   //PF=TesterStatistics(STAT_PROFIT_FACTOR);
   for(int Ord=0; Ord<OrdersHistoryTotal(); Ord++){   // поиск MO, PF, iRF, kDD
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_HISTORY)==true && OrderMagicNumber()==Magic){ // выясним текущие бай/селл позы и гарантированную прибыль по ним, закрепленную стопами
         int Order=OrderType();
         if (Order==OP_BUY || Order==OP_SELL){
            Trades++; 
            profit=float((OrderProfit()+OrderSwap()+OrderCommission())/MarketInfo(Symbol(),MODE_TICKVALUE));///MarketInfo(Symbol(),MODE_TICKVALUE); //Print(Symbol(),": Pips profit=",profit," OrderProfit()=",OrderProfit()," OrderSwap()=",OrderSwap()," OrderCommission()=",OrderCommission()," TICKVALUE=",MarketInfo(Symbol(),MODE_TICKVALUE));
            FullProfit+=profit; // Значение депо после очередной сделки
            if (profit>MaxWin[0]){ // ищем пять самых крупных выигрышей, чтобы вычесть их потом из профита, т.к. уверены, что они не повторятся 
               for (uchar i=4; i>0; i--) MaxWin[i]=MaxWin[i-1];
               MaxWin[0]=profit;  // т.е. резы тестера будут отличаться в худшую сторону
               } //Print("profit=",profit," FullProfit=",FullProfit);
            if (profit>0) {GrossProfit+=profit; WinCnt++;}
            if (profit<0) {GrossLoss-=profit;   LossesCnt++;}
            if (FullProfit>=MaxProfit) MaxProfit=FullProfit;// подсчет iRF - прибыль делим на среднюю просадку
            else{// нахождение в очередной просадке  
               //if (MaxProfit-FullProfit>DD) DD=MaxProfit-FullProfit;
               iDD+=MaxProfit-FullProfit; // площадь просадочной части эквити в период просадки (подсчет по сделкам)       
      }  }  }  } 
   if (Trades<1 || day<1) return(0);
   if (WinCnt>0)    MidWin=GrossProfit/WinCnt;   else MidWin=0;
   if (LossesCnt>0) MidLoss=GrossLoss/LossesCnt; else MidLoss=0;
   LastTestDD=short(MaxEquity-Equity); // последняя незакрытая просадка на тесте
   for (uchar i=1; i<5; i++) MaxWin[0]+=MaxWin[i]; // суммируем все члены массива в первый член
   FullProfit-=MaxWin[0]; //Print("MaxWin=",MaxWin[0]," FullProfit=",FullProfit);// вычитаем из полного профита пять максимальных винов 
   GrossProfit-=MaxWin[0];
   MaxProfit-=MaxWin[0];
   MO=float(FullProfit/Trades); // МатОжидание или Наклон Эквити 
   Print("FullProfit=",FullProfit," MO=",MO," Trades=",Trades);      
   if (iDD>0) iRF=float(MaxProfit/iDD*100); //  Своя формула для фактора восстановления 
   iDD=iDD/Trades*10;
   for(int Ord=0; Ord<OrdersHistoryTotal(); Ord++){   // поиск MO, PF, iRF, kDD
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_HISTORY)==true && OrderMagicNumber()==Magic){ // выясним текущие бай/селл позы и гарантированную прибыль по ним, закрепленную стопами
         int Order=OrderType();
         if (Order==OP_BUY || Order==OP_SELL){
            profit=float((OrderProfit()+OrderSwap()+OrderCommission())/MarketInfo(Symbol(),MODE_TICKVALUE));
            SD+=MathAbs(MO-profit); // Суммарное отклонение
      }  }  } 
   SD/=Trades; // Отклонение результата сделки от MO
   MO/=(float)MarketInfo(Symbol(),MODE_SPREAD);
   if (GrossLoss>0)  PF=float(GrossProfit/GrossLoss);  
   if (DrawDown>0)   RF=float(MaxProfit/Years/DrawDown); // Фактор восстановления (% в год!)
   if (SD>0)  Sharp=float(MO*1000/SD); // Своя формула для к.Шарпа
   CustomMax=iRF; // Критерий оптимизации 
   if (IsOptimization()){ // Оптимизация / РеОптимизация
      if (BackTest==0) str="Opt"; else str="ReOpt";
      str=str+"_"+Symbol()+DoubleToStr(Period(),0);
      if (PF<PF_ && PF_>0) return (CustomMax); //return(PF/PF_*CustomMax);  // если при оптимизации резы не катят, 
      if (RF<RF_ && RF_>0) return (CustomMax); //return(RF/RF_*CustomMax);  // не пишем их в файл отчета
      if (MO<MO_ && MO_>0) return (CustomMax); //return(MO/cMO*CustomMax);  // и пропорционально уменьшаем критерий оптимизации
      if (Trades/Years<Opt_Trades)  return(CustomMax);                                                     
      }
   else  {if (BackTest==0) str="Test"; else str="Back";} // тест / бэктест
//// формируем файл со статистикой текущей оптимизации    
   string TesterFileName=str+"_"+ ExpertName+".csv"; 
   Str1="Pip/Y";     Prm1=DoubleToStr(FullProfit/Years,0); // Профит пункты / год 
   Str2="Trades/Y";  Prm2=DoubleToStr(Trades/Years,0); 
   Str3="RF=MaxProfit/Years/DD";        Prm3=DoubleToStr(RF,2);    // Фактор восстановления = профит в месяц / просадку 
   Str4="PF";        Prm4=DoubleToStr(PF,2);    // Профит фактор
   Str5="DD/LastDD"; Prm5=" "+DoubleToStr(DrawDown,0)+"_"+DoubleToStr(LastTestDD,0);  // Максимальная историческая просадка / последняя незакрытая просадка
   Str6="iDD";       Prm6=DoubleToStr(iDD,0);   // Средняя площадь всех просадок
   Str7="MO/Spred";  Prm7=DoubleToStr(MO,2);    // Мат Ожидание
   Str8="SD";        Prm8=DoubleToStr(SD,1);    // Стандартное отклонение SD
   Str9="MO/SD";     Prm9=DoubleToStr(Sharp,1); // 
   Str10="iRF=MaxProfit/iDD";      Prm10=DoubleToStr(iRF,0);  // Модиф. фактора восстановления
   if (MidLoss>0){
      Str11="W/L*W%";  Prm11=" "+DoubleToStr(MidWin/MidLoss,2)+"*"+DoubleToStr((WinCnt/Trades)*100,0); // (Средний профит / Средний лосс ) * процент выигрышных сделок = ...Робастность(см. ниже)
      Str12="PF*RF";    Prm12=DoubleToStr(PF*RF,1); //    DoubleToStr(MidWin/MidLoss*(WinCnt/Trades)*100,0);  // Робастность =  (Средний профит / Средний лосс ) * процент выигрышных сделок либо  FullProfit*260*1000/day/MaxDD/Trades
      }
   else {Prm11=" 555"; Prm12=" 555";}   
   if (DrawDown>0) CountedRisk=float(10*MidLoss/DrawDown);
   Str13="RISK=MidLoss/MaxDD";     Prm13=DoubleToStr(CountedRisk,1);// выравнивает просадки в портфеле  // старый R I S K = 50*day/MaxDD/Trades
   TESTER_FILE_CREATE(EXP_INFO(),TesterFileName); // создание файла отчета со всеми характеристиками  //
   for (ushort i=1; i<=day; i++){ // допишем в конец каждой строки еженедельные балансы  
      FileSeek (TesterFile,-2,SEEK_END); // перемещаемся в конец строки
      FileWrite(TesterFile, "",DailyConfirmation[i]/MarketInfo(Symbol(),MODE_TICKVALUE)/1000);    // пишем ежедневные Эквити из созданного массива
      }
   FileClose(TesterFile); //Print("day=",day," FullProfit=",FullProfit," AccountBalance()=",AccountBalance()," InitDeposit=",InitDeposit," Trades=",Trades);
   if (BackTest>0) MATLAB_LOG();
   if (Real) ERROR_CHECK("OnTester");
   return (CustomMax); // возвращаем критерий оптимизации
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void OnDeinit(const int reason){// 
   return;
   if (IsTesting() || IsOptimization()) return;
   switch (reason){ // вместо reason можно использовать UninitializeReason()
      //case 0: str="Эксперт самостоятельно завершил свою работу"; break;
      case 1: Report("Program "+ExpertName+" removed from chart"); break;
      case 2: Report("Program "+ExpertName+" recompile"); break;
      case 3: Report("Symbol or Period was CHANGED!"); break;
      case 4: Report("Chart closed!"); break;
      case 5: Report("Input Parameters Changed!"); break;
      case 6: Report("Another Account Activate!"); break; 
      case 7: Report("Применен другой шаблон графика!"); break;
      case 8: Report("обработчик OnInit() вернул ненулевое значение !"); break;
      case 9: Report("Terminal closed!"); break;   
      }
   //if (IsTesting() || IsOptimization()) SAVE_GLOBALS(); // (только при тестировании реала) пропишем в конец файла историю совершенных сделок и кривую баланса 
   TerminalFree(); //освобождаем торговый поток, если прерывание программы произошло в момент ее выполнения
   ERROR_CHECK("OnDeinit");
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void DAY_STATISTIC(){ // расчет параметров DD, Trades, массив с резами сделок 
   if (Today!=DayOfYear()){ // начался новый день
      Today=(ushort)DayOfYear(); //Print("DayMinEquity=",DayMinEquity," DayOfYear()=",DayOfYear());
      day++;
      DailyConfirmation[day]=short(DayMinEquity-InitDeposit)*1000; // сперва умножим на 1000, а в OnTester() разделим. Это для более точного отображения на графике.    
      if (LastYear<Year()) {LastYear=(ushort)Year(); day++; DailyConfirmation[day]=0; day++; DailyConfirmation[day]=DailyConfirmation[day-2];}
      DayMinEquity=short(AccountBalance());
      if (TimeCurrent()>LastDay) LastDay=TimeCurrent(); //Print(" LastDay=",ServerTime(LastDay)); // приходится искать максимум, т.к. в конце теста значение почему-то сбрасывается к старому
      }
   if (AccountBalance()<DayMinEquity) DayMinEquity=short(AccountBalance());
   // вычисление DD
   Equity=short(AccountEquity()/MarketInfo(Symbol(),MODE_TICKVALUE)); 
   if (Equity>=MaxEquity) MaxEquity=Equity;  // Новый максимум депо
   else{ 
      FullDD+=MaxEquity-Equity;
      if (MaxEquity-Equity>DrawDown) DrawDown=MaxEquity-Equity;
   }  }  