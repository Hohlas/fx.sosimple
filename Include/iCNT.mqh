#define MAGIC_GEN    1  // виды 
#define LABEL_WRITE  2  // обработки
#define READ_FILE    3  // входных 
#define READ_ARR     4  // данных 
#define WRITE_HEAD   5  // 
#define WRITE_PARAM  6

int LotDigits, BarCount;
bool Prn;
string ttt, StartDate;
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
int OnInit(){// при загрузке эксперта, смене инструмента/периода/счета/входных параметров, компиляции
   if (!IsTesting() && !IsOptimization()) Real=true; 
   if (IsOptimization()) Real=false; 
   InitDeposit=short(AccountBalance()); DayMinEquity=InitDeposit;
   StartDate=TimeToStr(TimeCurrent(),TIME_DATE); // дата начала оптимизации/тестированиЯ
   MARKET_INFO();// обновление Spred и StopLevel
   MarginRequired=short(MarketInfo(Symbol(),MODE_MARGINREQUIRED)) * 2; // Размер свободных средств, необходимых для открытия 1 лота на покупку
   if (MarketInfo(Symbol(),MODE_LOTSTEP)<0.1) LotDigits=2; else LotDigits=1;
   Lot=float(0.1);
   if (Real){
      if (Risk>0){
         Aggress=Risk; 
         MaxRisk*=Aggress; 
         Alert(" WARNING, Risk x ",Aggress,"  MaxRisk=",MaxRisk, " !!!");} // Если в настройках выставить риск>0, то риск, считанный из #.csv будет увеличен в данное количество раз.
      GlobalVariableSet("CanTrade",0); // сбрасываем Magic
      ERROR_CHECK("OnInit-1");}
   if (BackTest==0) MAGIC_GENERATOR(); 
   else{// Загрузка параметров эксперта из файла отчета *.csv.
      if (!INPUT_FILE_READ()){ 
         Alert("OnInit(): отключение эксперта из-за ошибка загрузки данных из файла");
         return(INIT_FAILED); // ненулевой возврат означает неудачную инициализацию и генерирует событие Deinit с кодом причины деинициализации REASON_INITFAILED
      }  } 
   LOAD_GLOBALS(); // ВОССТАНОВЛЕНИЕ НА РЕАЛЕ ГЛОБАЛЬНЫХ ПЕРЕМЕННЫХ: BarTime, RevBUY, RevSELL, ExpMemory      
   BarsInDay=short(60*24/Period()); // кол-во бар в дне
   TimeOn=ushort(Tin*60/Period()); // начало торговли в барах от начала сессии, где Tin-часы от начала сессии
   TimeOff=ushort(TimeOn+(Tper+1)*60/Period()); // период торговли в барах от начала торговли, где Tper-часы от начала торговли Tin
   if (TimeOff>BarsInDay) TimeOff-=BarsInDay; // переход через полночь
   BarCount=1; // счетчик бар с начала работы эксперта для контроля кол-ва сделок
   //bool bb=true; int ii=-1; bool UP=bool(ii); Print("UP=",UP, " ii=",ii);
   bar=1;
   
   if (ATR_INIT()==INIT_FAILED) {Alert("OnInit(): ATR_INIT()=INIT_FAILED"); return(INIT_FAILED);}  // НЕнулевой код возврата означает неудачную инициализацию и генерирует
   if (PIC_INIT()==INIT_FAILED) {Alert("OnInit(): PIC_INIT()=INIT_FAILED"); return(INIT_FAILED);}  // событие Deinit с кодомпричины деинициализации REASON_INITFAILED
   //for (bar=Bars-1; bar>1; bar--){// прогоняем индикаторы на доступной истории, чтобы к началу работы все значения были готовы 
   //   PIC();  // ОСНОВНОЙ ЦИКЛ ПОИСКА УРОВНЕЙ 
   //   if (Atr.Slow==0) continue;  // функция ATR() не набрала достаточного кол-ва бар
   //   }
   if (Real) ERROR_CHECK("OnInit-2");   
   LastBarTime=Time[bar];     // для подсчета пропущенных бар
   INPUT_PARAMETERS_PRINT();  // ПЕЧАТЬ В ЛЕВОЙ ЧАСТИ ГРАФИКА ВХОДНЫХ ПАРАМЕТРОВ ЭКСПЕРТА
   Print(" "); Print(" ");
   Print(" OnInit(): MarginRequired=",MarginRequired," TickVal=",MarketInfo(Symbol(),MODE_TICKVALUE)," StopLevel=",StopLevel," Point=",MarketInfo(Symbol(),MODE_POINT)," Margin=",AccountFreeMargin());
   Print(" OnInit(): "," bar=",bar,"  Bars=",Bars," Time[bar]=",DTIME(Time[bar])," Time[Bars]=",DTIME(Time[Bars-1]));
   Print(" OnInit(): BarsInDay=",BarsInDay," Atr.Fast=",S5(Atr.Fast)," Atr.Slow=",S5(Atr.Slow)); 
   ERROR_CHECK("OnInit-3");
   return (INIT_SUCCEEDED); // Успешная инициализация. Результат выполнения функции OnInit() анализируется терминалом только если программа скомпилирована с использованием #property strict.
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool COUNT(){// Общие расчеты для всего эксперта 
   //TRADES_ENOUGH();
   if (Real){
      if (Risk==0) return(false); // отключение торгов на реале при выставлении в файле параметров риска=0
      str="";} 
   Modify=false; // флаг необходимости модификации (удаления) ордеров  
   if (AccountFreeMargin()<MarginRequired) {Report("COUNT(): Недостаточно маржи!!! FreeMargin="+S0(AccountFreeMargin())+" MarginRequired="+S0(MarginRequired)); ExpertRemove();}
   MARKET_INFO();
   if (!PIC()) return (false);   // ОСНОВНОЙ ЦИКЛ ПОИСКА УРОВНЕЙ 
   POC();  // ОПРЕДЕЛЕНИЕ ПЛОТНОГО СКОПЛЕНИЯ БАР БЕЗ ПРОПУСКОВ 
   //if (StopLevel+Spred>Atr.Max/2)  {Report("WARNING! StopLevel+Spred > Atr.Max/2:  StopLevel="+S5(StopLevel)+" Spred="+S4(Spred)+" Atr.Max="+S4(Atr.Max)+" Atr.Fast="+S4(Atr.Fast)+" Atr.Slow="+S4(Atr.Slow));} // слишком большой спред
   // МАКСИМАЛЬНЫЕ/МИНИМАЛЬНЫЕ ЦЕНЫ С МОМЕНТА ОТКРЫТИЯ ПОЗ 
   if (BUY>0){
      int Shift=SHIFT(BuyTime);
      MinFromBuy=(float)Low [iLowest (NULL,0,MODE_LOW ,Shift,0)]; 
      MaxFromBuy=(float)High[iHighest(NULL,0,MODE_HIGH,Shift,0)];} //  Print("BUY=",BUY," BuyTime=",BuyTime," Shift=",Shift," MinFromBuy=",MinFromBuy," MaxFromBuy=",MaxFromBuy);    
   if (SELL>0){
      int Shift=SHIFT(SellTime);
      MinFromSell=(float)Low [iLowest (NULL,0,MODE_LOW ,Shift,0)];
      MaxFromSell=(float)High[iHighest(NULL,0,MODE_HIGH,Shift,0)];}//  Print("SELL=",SELL," SellTime=",SellTime," Shift=",Shift," MinFromSell=",MinFromSell," MaxFromSell=",MaxFromSell);      
   
   FILTERS (iDblTop, iImp, iFltBrk, UP, DN); // ФИЛЬТРЫ ГЛОБАЛЬНОГО НАПРАВЛЕНИЯ формируют сигналы UP, DN        
   TARGET_ZONE_CHECK(BUYLIMIT, SELLLIMIT); // ЗАКРЫТИЕ ОРДЕРОВ, ПОПАДАЮЩИХ В ЗОНУ ЦЕЛЕВОГО ДВИЖЕНИЯ / iINPUT()      
   POC_CLOSE_TO_ORDER();// удаление отложника если перед ним формируется флэт(пик) / iOUTPUT()  
   //LINE("HI["+S0(HI)+"] Back="+S4(F[HI].Back)+" Glb"+S0(Trnd.LevBrk), bar+1, F[HI].P, bar, F[HI].P,  clrPink,2);       // LINE("F[HI].Tr", bar+1, F[HI].Tr, bar, F[HI].Tr,  clrPink,0); 
   //LINE("LO["+S0(LO)+"] Back="+S4(F[LO].Back)+" Glb"+S0(Trnd.LevBrk), bar+1, F[LO].P, bar, F[LO].P,  clrLightBlue,2);  // LINE("F[HI].Tr", bar+1, F[HI].Tr, bar, F[HI].Tr,  clrLightBlue,0);  
   // if (BUY){  A("BUY="+S4(BUY)+" Shift="+S0(SHIFT(BuyTime))+" MaxFromBuy="+S4(MaxFromBuy -BUY),  H-ATR*3, 0,  clrGray);
   //if (SELL) V("SELL="+S4(SELL)+" DN="+S0(DN),  L+ATR*3, 0,  clrGray);// " Shift="+S0(SHIFT(SellTime))+" MinFromSell="+S4(SELL-MinFromSell)
   if (Real) ERROR_CHECK("COUNT");
   return (true);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void TESTER_FILE_CREATE(string Inf, string TesterFileName){ // создание файла отчета со всеми характеристиками  //////////////////////////////////////////////////////////////////////////////////////////////////
   ResetLastError(); TesterFile=FileOpen(TesterFileName, FILE_READ|FILE_WRITE | FILE_SHARE_READ | FILE_SHARE_WRITE, ';'); 
   if (TesterFile<0) {Report("ERROR! TesterFileCreate()  Не могу создать файл "+TesterFileName); return;}
   string SymPer=Symbol()+DoubleToStr(Period(),0);
   //MAGIC_GENERATOR();
   if (FileReadString(TesterFile)==""){
      FileWrite(TesterFile,"INFO","SymPer",Str1,Str2,Str3,Str4,Str5,Str6,Str7,Str8,Str9,Str10,Str11,Str12,Str13,"Magic"); 
      DATA_PROCESSING(TesterFile, WRITE_HEAD);
      }
   FileSeek (TesterFile, 0,SEEK_END); // перемещаемся в конец   
   FileWrite(TesterFile,    Inf  , SymPer ,Prm1,Prm2,Prm3,Prm4,Prm5,Prm6,Prm7,Prm8,Prm9,Prm10,Prm11,Prm12,Prm13, Magic); 
   DATA_PROCESSING(TesterFile, WRITE_PARAM);
   FileSeek (TesterFile,-2,SEEK_END); FileWrite(TesterFile,"",0,0,0);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void MAGIC_GENERATOR(){
   MagicLong=0;
   DATA_PROCESSING(0, MAGIC_GEN);   // генерит огромное чило MagicLong типа ulong складыая побитно все входные параметры
   ExpID=CODE(MagicLong);  // Уникальное 70-ти разрядное строковое имя из символов, сгенерированных на основе числа MagicLong 
   Magic=int(MagicLong);   // обрезаем до размеров, используемых в функциях OrderSend(), OrderModify()...
   if (Magic<0) Magic*=-1; // Отрицательный не нужен
   //Print (" MagicLong=",MagicLong," Magic=",Magic," ExpId=",ExpID);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void INPUT_PARAMETERS_PRINT(){ // ПЕЧАТЬ В ЛЕВОЙ ЧАСТИ ГРАФИКА ВХОДНЫХ ПАРАМЕТРОВ ЭКСПЕРТА и создание файла настроек magic.set 
   if (IsOptimization()) return;
   string FileName=ExpertName+"_"+S0(Magic)+".set";   // TerminalInfoString(TERMINAL_DATA_PATH)+"\\tester\\files\\"+ExpertName+DoubleToString(Magic,0)+".txt";
   int file=FileOpen(FileName,FILE_WRITE|FILE_TXT);
   if (file<0){   Print("INPUT_PARAMETERS_PRINT: Can't write setter file ", FileName);  return;}
   LABEL("                  "+ExpertName+" Back="+S0(BackTest)+" Risk="+S1(Risk)+" MaxRisk="+S0(MaxRisk));
   LABEL("                  Magic="+S0(Magic)); LABEL(" "); 
   DATA_PROCESSING(file, LABEL_WRITE);
   FileClose(file); 
   ERROR_CHECK("INPUT_PARAMETERS_PRINT"); 
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void DATA_PROCESSING(int source, char ProcessingType){// универсальная ф-ция для записи/чтения парамеров, их печати на графике и генерации MagicLong   
   if (ProcessingType==LABEL_WRITE)   LABEL(" - P I C   L E V E L S - ");///////////
   DATA("FltLen", FltLen,     source,ProcessingType);
   DATA("PicCnt", PicCnt,     source,ProcessingType);
   DATA("Target", Target,     source,ProcessingType);
   DATA("Front",   Front,     source,ProcessingType);
   DATA("Trd",    Trd,        source,ProcessingType);
   DATA("Pot",    Pot,        source,ProcessingType);
   DATA("Rev",    Rev,        source,ProcessingType);
   if (ProcessingType==LABEL_WRITE)   LABEL(" -  T R E N D   S I G N A L S  - ");////////////////
   DATA("TrGlb",   TrGlb,     source,ProcessingType);
   DATA("TrDblPic",TrDblPic,  source,ProcessingType);
   DATA("TrImp",   TrImp,     source,ProcessingType);
   DATA("iDblTop",iDblTop,    source,ProcessingType);
   DATA("iFltBrk",iFltBrk,    source,ProcessingType);
   DATA("iImp",   iImp,       source,ProcessingType);
   if (ProcessingType==LABEL_WRITE)   LABEL(" - A  T  R -");////////////////
   DATA("A",         A,       source,ProcessingType);
   DATA("a",         a,       source,ProcessingType);
   DATA("dAtr",      dAtr,    source,ProcessingType);
   DATA("Ak",        Ak,      source,ProcessingType);
   DATA("PicVal",    PicVal,  source,ProcessingType);
   if (ProcessingType==LABEL_WRITE)   LABEL(" -  I N P U T S -");////////////////
//   DATA("iFrstLev",iFrstLev,  source,ProcessingType);
   DATA("iSignal",iSignal,    source,ProcessingType);
   DATA("iParam", iParam,     source,ProcessingType);
   DATA("Iprice", Iprice,     source,ProcessingType);
   DATA("D",      D,          source,ProcessingType);
   if (ProcessingType==LABEL_WRITE)   LABEL(" -  S T O P -");////////////////
   DATA("sMin",   sMin,       source,ProcessingType);
   DATA("sMax",   sMax,       source,ProcessingType);
   DATA("Stp",    Stp,        source,ProcessingType);
   if (ProcessingType==LABEL_WRITE)   LABEL(" -  P R O F I T -");////////////////
   DATA("pType",  pType,      source,ProcessingType);
   DATA("pVal",   pVal,       source,ProcessingType);
   DATA("minPL",  minPL,      source,ProcessingType);
   if (ProcessingType==LABEL_WRITE)   LABEL(" -  O U T P U T  -");////////////////
   DATA("oImp",   oImp,       source,ProcessingType);
   DATA("oSig",   oSig,       source,ProcessingType);
   DATA("oFlt",   oFlt,       source,ProcessingType);
   DATA("oPrice", oPrice,     source,ProcessingType);
   DATA("Trl",    Trl,        source,ProcessingType);
   if (ProcessingType==LABEL_WRITE)   LABEL(" -  T I M E  -");////////////////
   DATA("ExpirBars", ExpirBars,source,ProcessingType);
   DATA("Tper",   Tper,       source,ProcessingType);
   DATA("Tin",    Tin,        source,ProcessingType);
   DATA("tPrice", tPrice,     source,ProcessingType);
   }   
    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void DATA(string name, char& param, int& source, char ProcessingType){// выбор типа обработки входных данных в DATA_PROCESSING
   char i=2; 
   switch (ProcessingType){// тип обработки входных данных
   case LABEL_WRITE: LABEL(name+"="+S0(param));  FileWrite(source,name+"=",S0(param));  break;
   case READ_FILE:   param=char(StrToDouble(FileReadString(source)));            break; 
   case READ_ARR:    param=CSV[BackTest].PRM[source];    source++;               break;  
   case WRITE_HEAD:  FileSeek (source,-2,SEEK_END); FileWrite(source,"",name);   break;   
   case WRITE_PARAM: FileSeek (source,-2,SEEK_END); FileWrite(source,"",param);  break;    
   case MAGIC_GEN:   // формирование длинного числа из всех параметров эксперта
      while (i<param) {i*=2; if (i>4) break;} // кол-во зарзрядов (бит), необходимое для добавления нового параметра, но не более 3, чтобы не сильно растягивать число
      MagicLong*=i; // сдвиг MagicLong на i кол-во зарзрядов  
      MagicLong+=param; // Добавление очередного параметра
      break;
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
//void TRADES_ENOUGH(){// СБРОС ОПТИМИЗАЦИИ ТЕСТЕРА ПРИ ОТСУТСТВИИ СДЕЛОК на 1500 первых барах
//   if (BarCount==0) return;  // сделки были, больше нет необходимости проверять 
//   BarCount++; 
//   if (BarCount<=1500) return;// не набралось достаточное кол-во бар чтобы считать сделки
//   for(int Ord=0; Ord<OrdersHistoryTotal(); Ord++){ 
//      if (OrderSelect(Ord, SELECT_BY_POS, MODE_HISTORY)==true && (OrderType()==OP_BUY || OrderType()==OP_SELL)){ // хоть одна сделка в истории
//         BarCount=0; // флаг достаточности 
//         return;
//      }  }
//   Print("COUNT(): ни одной сделки за 1500 бар, прекращение работы ");   
//   ExpertRemove();
//   }
// 
   

