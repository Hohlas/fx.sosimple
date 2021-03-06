#define  PicPer   1 // период фракталов (самый ухкий)

#define  TRND  1  // признак пробоя трендового уровня
#define  BRK   2  // признак пробоя пика
#define  LevelsAmount   100 
#define  Movements      5 // размерность MovUp, MovDn  (должнa быть не меньше 3)
// СТАДИИ ФОРМИРОВАНИЯ СИГНАЛОВ
#define BLOCK    -1  // блокировка 
#define NONE      0
#define WAIT      1  // ожидание
#define START     2  // начало 
#define CONFIRM   3  // подтверждение
#define GOGO      4  // сигнал на открытие позы
#define BREAK     5  // отмена
#define DONE      6  // поза открыта
// ВИДЫ ФЛЭТА
#define  DBLPIC   1  // просто два отскока с подтвержденным трендовым уровнем
#define  FLAT     2  // широкий и протяженный флэт
// NEW EXTERNAL 
// LEVELS PROPERTIES
color    UPCLR=clrPink, DNCLR=clrLightBlue;
float    ATR, H, L,
         Impulse,    // величина последнего импульса, превысившего порог Atr.Slow*TrImp
         New,        // новый (последний) фрактал
         HiBack, LoBack, // 
         MidMovUp, MidMovDn, LastMovUp, LastMovDn,    // среднее значение нескольких пследних движений
         MovUp[1], MovDn[1], MovUpSrt[1], MovDnSrt[1],// массивы безоткатных движений для определения целевого движения, инициализируюстя в init() на Movements членов
         TargetHi, TargetLo;  // целевые движения и их предварительные значения    
datetime FlatLength, // минимальная продолжительность флэта, либо время от пробиваемой вершины до ложняка.  FlatLength=FltLen*Period()*60 (сек)  
         BarSeconds; // кол-во секунд в баре         
ushort   BarsInDay; // период поиска первых уровней (сек). На нем ищем пики, развернувшие самые большие движения         
char     TrlStp=3,   // трейлинг должен иметь Back=TrlStp*0.5*ATR  
         Back,       // задний фронт импульса Back=Front*Max(1,Pot)
         Dir;        // направление последнего пика
// Индексы уровней
uchar n,          // номер последнего пика
      BrokenPic,  // последний из пробитых
      hi,lo,      // последний Hi/Lo
      hi2,lo2,    // предпоследний
      stpH, stpL,     // уровни стопов
      HI,LO,Hi2,Lo2, // Первый, предпоследний Первый
      midHI, midLO,  // Уровень чуть дальше серединки с максимальным фронтом
      jmpHI, jmpLO,  // Уровень чуть дальше серединки с максимальным кол-вом отскоков
      RevHi,RevLo,RevHi2,RevLo2,// Разворотный,
      FlsUp,FlsDn,// ложняки подтвержденные
      uFsUp,uFsDn,// ложняки неподтвержденные
      TrgHi,TrgLo;// целевой
bool  Update;     // признак обновления пика

struct FLS_BRK{// вложенная структура ложных пробоев
   datetime BT;   // время базы, из которой выстрелил ложняк
   datetime T;    // время пика ложняка
   float    Base; // база, из которой выстрелил ложняк
   float    P;    // пик ложняка
   char     Phase;// стадия NONE, START, CONFIRM, BREAK 
   }; 
struct FLT_LEV{// вложенная структуа флэта, сформированного пиком
  float  Lev;  // усредненное значение сформированной границы флэта
  float  Frnt; // фронт первого пика флэта (движение предшествующее флэту) (пока ХЗ зачем)
  datetime T;  // время начала флэта
  uint  Len;   // длина флэта 
  };     
struct PICS{  //  C Т Р У К Т У Р А   P I C
   float P;       // price
   float Tr;      // трендовые уровни пиков
   char  TrBrk;   // статус трендового -1 не сформирован,  0 сформирован,  1 пробит 
   float Mid;     // чуть дальше серединки движения
   float PocPrice;// Цена с макс поком движения
   float Mir;     // зеркальный уровень движения
   float Frnt;    // передний фронт пика 
   float Back;    // задний фронт пика
   datetime T;       // время возникновения последнего пика 
   datetime ExT;     // время начала движения, которое развернул уровень.
   datetime Per;     // кол-во бар до пробоя пика
   char  Dir;     // направление фрактала: 1=ВЕРШИНА, -1=ВПАДИНА
   char  Rev;     // признак разворотной вершины, повышающегося пика. Только из них выбираются Первые Уровни 
   char  Brk;     // Признак пробитости: 0-нет, 1-пробой не более Lim = касание, 2-глубокий пробой, 3-обратный пробой (зеркальный), 4-пробой зеркального (некчемный)
   char  Str;     // Сила уровня 0-негодный, 1-сильный, 2-первый
   char  Cnt;     // кол-во совпадений c сонаправленными пиками для простоения флэта
   uchar Pics;    // кол-во совпадений c любыми пиками для нахождения зоны с максимальным кол-вом отскоков
   uchar Poc;     // Ширина пика в барах
   FLT_LEV    Flt;  // вложенная структуа флэта, сформированного пиком
   FLS_BRK Fls;  // вложенная структура ложных пробоев
   } F[LevelsAmount]; 
                 
struct TREND_SIGNALS{  //  C Т Р У К Т У Р А   T R E N D
   char  FltBrk;    // пробой флэта
   char  PicBrk;    // пробитии подряд PicBrk пиков
   char  Global;    // пробитие уровня противоположным пиком
   float Imp;       // импульс
   char  Up;       
   char  Dn;
   char  DblTop;    // сигнал "Двойная вершина" 
   }Trnd;      // 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
int PIC_INIT(){
   if (A<1) {Print("PIC_INIT(): PicPer=",PicPer,". Must be >0"); return(INIT_FAILED);}
   ArrayResize(MovDn,Movements); // массив безоткатных движений
   ArrayResize(MovUp,Movements); // массив безоткатных движений
   ArrayResize(MovUpSrt,Movements); // массивы для сортировки
   ArrayResize(MovDnSrt,Movements); // безоткатных движений
   Back=Front*MathMax(char(1),Pot); // задний фронт импульса 
   BarSeconds=ushort(Period()*60);  // кол-во секунд в баре
   BarsInDay=ushort(24*60/Period());// Кол-во бар в сутках
   FlatLength=datetime(FltLen*BarSeconds);   // продолжительность флэта (сек), меньше которой он не защитывается (сек)
   CHART_SETTINGS(); // настройки вненшего вида графика  
   for (uchar f=0; f<LevelsAmount; f++) F[f].P=0;  
   //POC_SIMPLE(1.2488, 1.2426, t1, t2, MaxPoc, MaxPocPrice);
   //LINE("MaxPoc="+S0(MaxPoc), t1, MaxPocPrice,  t2, MaxPocPrice, clrRed);
   return (INIT_SUCCEEDED); // "0"-Успешная инициализация. Результат выполнения функции OnInit() анализируется терминалом только если программа скомпилирована с использованием #property strict.
   }          
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool PIC(){// ОСНОВНОЙ ЦИКЛ ПОИСКА УРОВНЕЙ
   if (!ATR_COUNT())  {return(false);}   // Print(DTIME(Time[bar]),": ATR don't ready");
   H=(float)High[bar];
   L=(float)Low [bar];
   Update=0;
   if (High[bar+PicPer]==High[iHighest(NULL,0,MODE_HIGH,PicPer*2+1,bar)]){ // Новый hi  ///////////////////////////////////////////////////////    
      NEW_LEVEL( 1, (float)High[bar+PicPer]); // ФОРМИРОВАНИЕ И УДАЛЕНИЕ УРОВНЕЙ
      }
   if (Low [bar+PicPer]==Low [iLowest (NULL,0,MODE_LOW ,PicPer*2+1,bar)]){ // Новый lo  /////////////////////////////////////////////////////////     
      NEW_LEVEL(-1, (float)Low[bar+PicPer]); // ФОРМИРОВАНИЕ И УДАЛЕНИЕ УРОВНЕЙ
      }
   //NEW_W();             // Сигнал "Голова/Плечи" (стоит до TREND_DETECT(), т.к. проверяется пробитие Первых Уровней
   TREND_DETECT();      // ОПРЕДЕЛЕНИЕ ТРЕНДА (стоит до LEVELS_FIND_AROUND(), т.к. пробой уровней проверяется до их обновления    
   LEVELS_FIND_AROUND();// ПОИСК СИЛЬНЫХ УРОВНЕЙ      
   //LINE(" F/Fi="+S0(Atr.Fast/Point)+"/"+S0(fst/Point)+" S/Si="+S0(Atr.Slow/Point)+"/"+S0(slw/Point), bar+1, Close[bar], bar, Close[bar],  clrDarkSeaGreen,3);
   //if (ArrFull) {V("A R R  F U L L   P0="+S4(F[0].P), Close[bar],bar+PicPer, clrRed);} 
   return(true);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
void NEW_LEVEL(char dir, float NewFractal){// ФОРМИРОВАНИЕ И УДАЛЕНИЕ УРОВНЕЙ
   Update=True;// признак появления нового пика
   Dir=dir;    // направление последнего пика
   New=NewFractal;
   int Shift; 
   datetime ExPicTime=Time[Bars-1];// время ближайшшего превосходящего пика из массива...
   char  Cnt=1;         // кол-во совпадений c флэтовыми непробитыми пиками
   uchar Pics=0;          // кол-во совпадений со всеми пиками
   uchar FlatBegin=0;   // номер пика начала флэта
   float LevMiddle=New; // средний уровень совпавших пиков
   uchar LowestPowerCell=0;   // номер ячейки и 
   ushort LowestPower=65535;  // сила самого слабого уровня для удаления на случай, если не найдется свободной ячейки
   datetime StartSearchTime=Time[MathMin(bar+BarsInDay*2, Bars-1)];  // время начала поиска самого слабого уровня на удаление  = два дня назад
   n=0;           // новая свободная ячейка для заполнения
   for (uchar f=1; f<LevelsAmount; f++){// перебираем весь массив фракталов от большего к меньшему
      if (F[f].P==0) {n=f; continue;} // 
      Shift=iBarShift(NULL,0,F[f].T,false); // сдвиг фрактала из массива относительно текущего (нулевого) бара 
      float FrntVal=MathAbs(F[f].P-F[f].Frnt);
      float BackVal=MathAbs(F[f].P-F[f].Back);
      ushort check=ushort(MathMin(FrntVal, BackVal)/Point/(1+F[f].Brk)); // критерий удаления = минимальный фронт, деленный на степень пробоя
      if (F[f].T<StartSearchTime && F[f].Fls.Phase<START && check<LowestPower){// самый слабый уровень для удаления. Должен быть старше двух дней и не не стадии ложного пробития. 
         LowestPower=check; LowestPowerCell=f;}     
      if (MathAbs(New-F[f].P)<Atr.Lim) {F[f].Pics++; Pics++;} // кол-во совпадений со всеми пиками (пробитыми и зеркальными) для поиска уровня с максимальным количеством отскоков
      if (F[f].Brk<2){   // не пробитый, либо с касанием
         if (F[f].TrBrk==0){
            if (F[f].Dir>0)   {if (H>F[f].Mid) F[f].TrBrk=1;} // пробитие трендового уровня    
            else              {if (L<F[f].Mid) F[f].TrBrk=1;} // пробитие трендового уровня        
            }
         if (Dir==F[f].Dir && MathAbs(New-F[f].P)<Atr.Lim){// сравниваемые фракталы в пределах Lim и это не пробитый пик, т.е. между отобранным и новым пиками ничего не выступает  
            F[f].Brk=1;       // касание в пределах Lim
            F[f].Cnt++; Cnt++;// поиск совпадающих уровней, увеличиваем кол-во совпадений
            LevMiddle+=F[f].P; // и их сумма для усреднения LINE(S0(f)+" Lim="+S5(Atr.Lim)+" a="+S4(Atr.Fast)+" A="+S4(Atr.Slow), bar+PicPer,New,  SHIFT(F[f].T),F[f].P,clrLightBlue,0);
            if (FlatBegin==0 || F[f].T<F[FlatBegin].T) FlatBegin=f;// самый старый пик флэта, для противоположной границы
         }  }     
      if (F[f].Brk==0){    //  Н Е   П Р О Б И Т Ы Й  ни на один тик (Признак пробитости: 0-нет, 1- касание в пределах Lim, 2-глубокий пробой, 3-обратный пробой (зеркальный), 4-пробой зеркального (некчемный)
         if (Dir==F[f].Dir)   {if (F[f].T>ExPicTime) ExPicTime=F[f].T;} // время ближайшего превосходящего пика для поиска фронта
         else if (F[f].Dir>0) {if (New<F[f].Back) {F[f].Back=New;    if (F[f].Str==1 && F[f].P-F[f].Back>Atr.Max*Back)   F[f].Str=2;}}  // задний фронт увеличился, если пик с достаточно большим
         else if (F[f].Dir<0) {if (New>F[f].Back) {F[f].Back=New;    if (F[f].Str==1 && F[f].Back-F[f].P>Atr.Max*Back)   F[f].Str=2;}}  // передним фронтом (F[f].Str=1) и задний тож ничего, ставим флаг первого уровня = 2    
         }
      if (F[f].Brk==2){  // подтверждение зеркального уровня - достаточно глубокий пробой пробитого (2) уровня
         if (F[f].Dir>0 && Dir>0 && New>F[f].P+Atr.Max) {F[f].Brk=3;} // пробой зеркального пика V(DTIME(Time[bar+PicPer])+"/"+S4(FrntVal), F[f].P, SHIFT(F[f].T), clrBlue);
         if (F[f].Dir<0 && Dir<0 && New<F[f].P-Atr.Max) {F[f].Brk=3;} // сонаправленным  
         }    
      if (F[f].Brk==2 || F[f].Brk==3){  // отмена зеркального уровня - касание, либо обратный пробой
         if (F[f].Dir>0 && New<F[f].P+Atr.Lim) {F[f].Brk=4;} // пробой, либо касание противоположным пиком,  X(DTIME(Time[bar+PicPer]), F[f].P, SHIFT(F[f].T), clrRed);
         if (F[f].Dir<0 && New>F[f].P-Atr.Lim) {F[f].Brk=4;} // маркируем отработавшим   
         }         
      //if (F[f].T==StringToTime("2001.01.08 08:00")) Print(Time[bar]," Brk=",F[f].Brk," Frnt=",F[f].Frnt," Back=",F[f].Back);
      FALSE_BREAK(f,iSignal);// проверка ложного пробоя при iSignal=1 (iINPUT.mqh)
      }
   if (n==0) {n=LowestPowerCell;} // X("n-"+DTIME(F[n].T)+" LowestPower="+S0(LowestPower), New,bar+PicPer, clrBlue);// если пустых ячеек нет, берем самую слабую  
   //PRN("n="+S0(n)+" "+DTIME(F[n].T)+" LowestPower="+S0(LowestPower));
   Shift=iBarShift(NULL,0,ExPicTime,false); // сдвиг превосходящего пика относительно нового пика
   F[n].P=New;            // пишем в свободную ячейку значение фрактала
   F[n].T=Time[bar+PicPer];    // время возникновения фрактала
   F[n].Cnt=Cnt;  // кол-во совпадений с предыдущими непробитыми уровнями
   F[n].Pics=Pics;// кол-во совпадений со всеми уровнями  
   F[n].Dir=Dir;   // направление фрактала: 1=ВЕРШИНА, -1=ВПАДИНА
   F[n].ExT=ExPicTime; // время превосходящего пика (начала движения, которое развернул уровень).
   F[n].Per=PicPer-1; // кол-во бар до пробоя пика
   F[n].Brk=0;   // Признак пробитости: 0-нет, 1-пробой не более Lim = касание, 2-глубокий пробой
   F[n].Poc=0;    // POC_DETECT(); 
   F[n].Rev=0; // признак повышающегося пика, только из них выбираются Первые Уровни 
   F[n].TrBrk=-1; // статус трендового уровня: -1~не сформирован, 0~сформирован,  1~пробит. Пока хай не опустится под трендовый, он будет не действителен.
   F[n].Fls.Phase=NONE;
   if (Dir>0){ // вершина  
      F[n].Tr=float(Low [iHighest(NULL,0,MODE_LOW ,PicPer*2+1,bar)]);// для вершины трендовый уровень не продажу (пока хай не опустится под трендовый, он будет не действителен)     LINE("PicHi="+S4(F[hi].P)+" F[hi].Trd="+S4(F[hi].Trd), bar+PicPer*2, F[hi].Trd,  bar, F[hi].Trd, clrRed);
      if (F[n].Tr<F[n].P-Atr.Min*2) {F[n].Tr=F[n].P-Atr.Min*2;}// трендовый оч далеко, формируем заново  A(S4(Atr.Min), F[n].Tr, bar+PicPer, clrRed);
      F[n].Mid=(F[n].P+F[n].Tr)/2;     // серединка на пробой  F[n].Mid=F[n].P-(F[n].P-F[n].Tr)/3;
      F[n].Frnt=float(Low [iLowest (NULL,0,MODE_LOW ,Shift-(bar+PicPer),bar+PicPer)]);   // Передний Фронт уровня (величина развернутого им движения) = расстояние от нового пика до минимума, лежащего между новым пиком и превосходящим его баром.    
      F[n].Back=float(Low [iLowest (NULL,0,MODE_LOW ,PicPer,bar)]);// задний фронт = кол-во пунктов от текущего до следующего противоположного фрактала. Будет постепенно увеличиваться по мере удаления цены от уровня       
      if (F[n].P-F[n].Frnt>Atr.Max*Front) F[n].Str=1; else F[n].Str=0; // Сила уровня 0-негодный, 1-большой передний фронт=кандидат на первый, 2-задний фронт тоже большой, точно первый
      if (New>F[hi].P)    {F[n].Rev=1;   RevHi=n;}  // "повышающийся пик"  нужен для формирования измеренных движений X("RevHi="+DoubleToString(Rev.F[hi].P,4), Rev.F[hi].P, bar+PicPer, clrRed);    
      hi2=hi; hi=n; // if (F[n].Frnt>Atr.Max) V("Frnt="+S4(F[n].Frnt)+" Ex="+DTIME(F[n].ExT), New, bar+PicPer, clrRed); //
   }else{      // впадина                                                             
      F[n].Tr=float(High[iLowest (NULL,0,MODE_HIGH,PicPer*2+1,bar)]);// для впадины трендовый уровень на покупку (пока лоу не поднимется над трендовым, он будет недействительным)
      if (F[n].Tr>F[n].P+Atr.Min*2) {F[n].Tr=F[n].P+Atr.Min*2;}// трендовый оч далеко, формируем заново   V(S4(Atr.Min), F[n].Tr, bar+PicPer, clrGreen);   
      F[n].Mid=(F[n].P+F[n].Tr)/2;    // серединка на пробой    F[n].Mid=F[n].P+(F[n].Tr-F[n].P)/3;
      F[n].Frnt=float(High[iHighest(NULL,0,MODE_HIGH,Shift-(bar+PicPer),bar+PicPer)]);   // Передний Фронт уровня (величина развернутого им движения) = расстояние от нового пика до максимума, лежащего между новым пиком и превосходящим его баром. 
      F[n].Back=float(High[iHighest(NULL,0,MODE_HIGH,PicPer,bar)]);// задний фронт = кол-во пунктов от текущего до следующего противоположного фрактала. Будет постепенно увеличиваться по мере удаления цены от уровня        
      if (F[n].Frnt-F[n].P>Atr.Max*Front) F[n].Str=1; else F[n].Str=0; // Сила уровня 0-негодный, 1-большой передний фронт=кандидат на первый, 2-задний фронт тоже большой, точно первый
      if (New<F[lo].P)    {F[n].Rev=1;   RevLo=n;} // "понижающаяся впадина"  нужен для формирования измеренных движений X("RevLo="+DoubleToString(F[RevLo].P,4), F[RevLo].P, bar+PicPer, clrGreen);
      lo2=lo; lo=n;  // if (F[n].Frnt>Atr.Max) A(" Pics="+S0(F[n].Pics), New, bar+PicPer, clrBlue); // DTIME(Time[bar])+" Shift="+S0(Shift)+" bar="+S0(bar)+
      }  
   TARGET_COUNT();// РАСЧЕТ ЦЕЛЕВЫХ УРОВНЕЙ ОКОНЧАНИЯ ДВИЖЕНИЯ НА ОСНОВАНИИ ИЗМЕРЕНИЯ ПРЕДЫДУЩИХ ДВИЖЕНИЙ                                                                               
   FLAT_DETECT(LevMiddle, FlatBegin, Cnt);
   //if (F[n].T==StringToTime("2000.04.19 11:00")) V(" Frnt="+S4(F[n].Frnt)+" Pics="+S0(F[n].Pics), New, bar+PicPer, clrBlue);
   }         
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ       
void LOWEST_HI(float BaseLev, float& Delta, uchar f, uchar& Nearest){// ближайший к BaseLev уровень CheckLev, возвращается его номер NearestNum и расстояние между ними
   if (F[f].P+Atr.Lim>BaseLev && F[f].P-BaseLev<Delta)  {Delta=F[f].P-BaseLev;  Nearest=f;}
   }   
void HIGHEST_LO(float BaseLev, float& Delta, uchar f, uchar& Nearest){// ближайший к BaseLev уровень CheckLev, возвращается его номер NearestNum и расстояние между ними
   if (F[f].P-Atr.Lim<BaseLev && BaseLev-F[f].P<Delta)  {Delta=BaseLev-F[f].P;  Nearest=f;}  
   }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void LEVELS_FIND_AROUND(){ // П О И С К   Б Л И З Л Е Ж А Щ И Х   У Р О В Н Е Й 
   uchar fHI=0, fLO=0, fH=0, fL=0; // номера уровней в массиве
   float minTrgHi=99999, minTrgLo=99999, minHI=999999, minLO=999999, minH=999999, minL=999999; 
   TrgHi=0; TrgLo=0; stpH=0; stpL=0;
   for (uchar f=1; f<LevelsAmount; f++){// в нулевом хранится последнее значение, оно же записывается в массив вместо самого слабого пика 
      if (F[f].Brk>1) continue; // 2-4 глубоко пробитые более чем на Lim пунктов
      if (F[f].P==0) continue; // пустые значения
      PIC_BREAK(f);
      if (F[f].Brk>0) continue; // 1-пробитые менее чем на Lim пунктов (касание)
      if (F[f].Dir>0){ // вершина
         if (F[f].TrBrk <0){// трендовый уровень еще не сформирован
            if (H<F[f].Tr) {F[f].TrBrk=0;  if (F[f].Flt.Len>0) Trnd.DblTop=-1;} // окончательнрое формирование трендового, когда хоть один хай опустился ниже его уровня. Шортовый сигнал "Двойная вершина"
            else F[f].Poc++;// увеличение РОС пика до тех пор, пока не сформировался его трендовый уровень    
            }
         if (Target!=0) LOWEST_HI(TargetHi, minTrgHi, f, TrgHi);   // ближайший пик к расчитанному целевому уровню 
      }else{   // впадина
         if (F[f].TrBrk <0){// трендовый уровень еще не сформирован
            if (L>F[f].Tr) {F[f].TrBrk=0; if (F[f].Flt.Len>0) Trnd.DblTop= 1;}  // окончательнрое формирование трендового, когда хоть один лоу поднялся выше его уровня. Шортовый сигнал "Двойная вершина"
            else F[f].Poc++;// увеличение РОС пика до тех пор, пока не сформировался его трендовый уровень 
            }
         if (Target!=0) HIGHEST_LO(TargetLo, minTrgLo, f, TrgLo);  // ближайший пик к расчитанному целевому уровню 
         }
      F[f].Per++;  // увеличение периода уровня до момента пробития     
      float FrntVal=MathAbs(F[f].P-F[f].Frnt);
      float BackVal=MathAbs(F[f].P-F[f].Back);
      if (Pot>0  && BackVal<FrntVal) continue; // задний фронт д.б. больше переднего  
      if (Trd>1  && F[f].TrBrk!=0)   continue; // только с непробитым cформированным трендовым (TrBrk=0)
      if (Rev>0  && F[f].Rev==0)     continue; // уровень должен пробить хотябы один пик (REV=1)  
      if (BackVal>TrlStp*ATR){
         if (F[f].Dir>0)   LOWEST_HI (H, minH, f, stpH);  // ближайший пик к текущей цене, инициировавший движение в Atr.Int*2*(1+FirstLev)   
         else              HIGHEST_LO(L, minL, f, stpL);  // ближайший пик к текущей цене, инициировавший движение в Atr.Int*2*(1+FirstLev)     
         }
      if (F[f].Str!=2) continue;// ФИЛЬТРАЦИЯ СИЛЬНЫХ УРОВНЕЙ 0-негодный; 1-большой передний фронт; 2-Первый уровень, т.е. большой передний и задний фронты 
      if (F[f].Dir>0)   LOWEST_HI (H, minHI, f, fHI);  // ближайший первый  уровень к текущей цене, 
      else              HIGHEST_LO(L, minLO, f, fLO);  // ближайший первый  уровень к текущей цене, 
      } 
   // формирование ПЕРВЫХ УРОВНЕЙ   if (Time[bar]<StringToTime("1999.11.26 08:00")  || Time[bar]>StringToTime("1999.11.27 00:00"))   return;    
   
   bool UpdateHI=false, UpdateLO=false;
   if (fHI>0 && HI!=fHI){// ПЕРВЫЙ ТРЕНДОВЫЙ НА ПРОДАЖУ 
      HI=fHI;     LINE("HI="+S0(HI), SHIFT(F[HI].T),F[HI].P, bar+PicPer, F[HI].Back,clrLightPink,0);
      UpdateHI=true; 
      if (TrGlb==3) Trnd.Global=-1;}        
   if (fLO>0 && LO!=fLO){// ПЕРВЫЙ ТРЕНДОВЫЙ НА ПРОКУПКУ
      LO=fLO;     LINE("LO="+S0(LO), SHIFT(F[LO].T),F[LO].P, bar+PicPer, F[LO].Back,clrLightGreen,0);
      UpdateLO=true; 
      if (TrGlb==3) Trnd.Global= 1;}          
   // обновление уровней серединки
   if (UpdateHI || HiBack!=F[HI].Back){ // Вершина обновилась, либо ее Back (цена отошла нижее от Первого Уровня),
      HiBack=F[HI].Back; jmpHI=0; midHI=0;
      float MaxHiFront=0, Range=F[HI].P-F[HI].Back, UpBorder=F[HI].P-Range/4, DnBorder=F[HI].P-Range/2;    // F[HI].PocPrice=POC_SIMPLE(UpBorder, DnBorder, SHIFT(F[fHI].T), bar, MaxPoc, MaxPocPrice);   пересчитываем PocPrice серединки   
      ushort MaxPicsHi=PicCnt;
      for (uchar f=1; f<LevelsAmount; f++){// в нулевом хранится последнее значение, оно же записывается в массив вместо самого слабого пика 
         if (F[f].T<F[HI].T || F[f].P>UpBorder || F[f].P<DnBorder || F[f].P<H || F[f].P==0) continue; // только пики образованные после первого уровня и в диапазоне от трендового до серединки движения
         if (F[f].Pics>MaxPicsHi)    {MaxPicsHi=F[f].Pics;   jmpHI=f;}   // поиск пиков с максимальным количеством отскоков
         if (F[f].Dir>0 && F[f].Brk==0 && F[f].P-F[f].Frnt>MaxHiFront)  {MaxHiFront=F[f].P-F[f].Frnt; midHI=f;}   // поиск пиков чуть дальше серединки с максимальным фронтом  
         }  
      //if (midHI>0) LINE(" HI="+S0(HI),   SHIFT(F[HI].T),F[midHI].P,       bar,F[midHI].P,     clrBlue,0);  
      if (jmpHI>0){
         LINE("HI="+S0(HI)+" Pics="+S0(F[jmpHI].Pics),   SHIFT(F[HI].T),F[jmpHI].P,       bar,F[jmpHI].P, clrRed,0);  // DTIME(Time[bar])+DTIME(F[HI].T)+"-"+DTIME(Time[bar])+"/"+DTIME(F[jmpHI].T)
         A("Pics="+S0(F[jmpHI].Pics), F[jmpHI].P, SHIFT(F[jmpHI].T), clrRed);}
      }  
   if (UpdateLO || LoBack!=F[LO].Back){ // Обновился Back (цена отошла дальше от Первого Уровня),
      LoBack=F[LO].Back; jmpLO=0; midLO=0;  
      float MaxLoFront=0, Range=F[LO].Back-F[LO].P, UpBorder=F[LO].P+Range/2, DnBorder=F[LO].P+Range/4;    // F[LO].PocPrice=POC_SIMPLE(UpBorder, F[LO].Tr, SHIFT(F[fLO].T), bar, MaxPoc, MaxPocPrice);  // пересчитываем PocPrice серединки
      ushort MaxPicsLo=PicCnt;
      for (uchar f=1; f<LevelsAmount; f++){// в нулевом хранится последнее значение, оно же записывается в массив вместо самого слабого пика 
         if (F[f].T<F[LO].T || F[f].P>UpBorder || F[f].P<DnBorder || F[f].P>L || F[f].P==0) continue; // только пики образованные после первого уровня и в диапазоне от трендового до серединки движения
         if (F[f].Pics>MaxPicsLo)    {MaxPicsLo=F[f].Pics;   jmpLO=f;}   // поиск пиков с максимальным количеством отскоков
         if (F[f].Dir<0 && F[f].Brk==0 && F[f].Frnt-F[f].P>MaxLoFront)  {MaxLoFront=F[f].Frnt-F[f].P; midLO=f;}
         }  
      //if (midHI>0) LINE(" HI="+S0(HI),   SHIFT(F[HI].T),F[midHI].P,       bar,F[midHI].P,     clrBlue,0);  
      if (jmpLO>0){
         LINE("LO="+S0(LO)+" Pics="+S0(F[jmpLO].Pics),   SHIFT(F[LO].T),F[jmpLO].P,       bar,F[jmpLO].P, clrGreen,0);  // DTIME(Time[bar])+DTIME(F[HI].T)+"-"+DTIME(Time[bar])+"/"+DTIME(F[jmpHI].T)
         A("Pics="+S0(F[jmpLO].Pics), F[jmpLO].P, SHIFT(F[jmpLO].T), clrGreen);}    
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void PIC_BREAK(uchar f){ // ПРОБИТИЕ 
   if (F[f].Dir>0)   {if (H>F[f].P+Atr.Lim)   F[f].Brk=2;}  // глубокое   
   else              {if (L<F[f].P-Atr.Lim)   F[f].Brk=2;}  // пробитие    
   if (F[f].Brk<2)   return; // далее обработка глубоких пробоев
   //if (F[f].Str!=0 && F[f].Brk==0) V(S0(f)+" B"+S4(F[f].Back)+" F"+S4(F[f].Frnt)+" "+DTIME(F[f].ExT), F[f].P, SHIFT(F[f].T), clrBlack); 
   if (F[f].Str>0){  // был пробит сильный уровень
      F[f].Fls.Phase=WAIT;} // его ложняк будет интересен: ставим начальный флаг. Флаг сбрасывается на "BREAK"  при формировании уровня в FLAT_DETECT()
   if (F[f].Flt.Len>0){// если это был флэт шириной более FltLen бар,
      if (F[f].Dir>0) Trnd.FltBrk= 1; else Trnd.FltBrk=-1;//  генерится сигнал "пробой флэта"
   }  }     
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void TREND_DETECT(){ // О П Р Е Д Е Л Е Н И Е   Т Р Е Н Д А  
    // отмена сигналов "Пробой флэта" и "формирование флэта" противоположным пробоем любого пика   
   if (H-F[hi].P>Atr.Lim){
      if (Trnd.DblTop<0)   {Trnd.DblTop=0;   }  // X("BREAK DblTop", High[bar],bar,clrRed);
      if (Trnd.FltBrk<0)   {Trnd.FltBrk=0;   }  // прекращение шортового сигнала X("BREAK Flat",   High[bar],bar,clrRed);
      }
   if (F[lo].P-L>Atr.Lim){
      if (Trnd.DblTop>0)   {Trnd.DblTop=0;   }  // X("BREAK DblTop", Low [bar],bar,clrGreen);
      if (Trnd.FltBrk>0)   {Trnd.FltBrk=0;   }  // прекращение лонгового сигнала X("BREAK Flat", Low [bar],bar,clrGreen);
      }
   // Cмена глоб. тренда при пробитии Первых Уровней.
   if (HI>0 && H-F[HI].P>Atr.Lim)   {Hi2=HI; HI=0;  if (TrGlb==2) Trnd.Global= 1;}  // V(" HI="+S4(H), F[Hi2].P, bar, clrOrange);   
   if (LO>0 && F[LO].P-L>Atr.Lim)   {Lo2=LO; LO=0;  if (TrGlb==2) Trnd.Global=-1;}  // A(" LO="+S4(H), F[Lo2].P, bar, clrOrange); 
   
   if (TrGlb==1){ // Cмена глоб. тренда при пробитии "Уровней серединки", определяемого максимальным скоплением бар
      if (Trnd.Global!= 1 && High[bar]>F[HI].PocPrice && High[bar+1]<F[HI].PocPrice)  {Trnd.Global= 1;}  //  LINE("HI PocPrice",   bar+3,F[HI].PocPrice, bar, F[HI].PocPrice,clrRed,0);
      if (Trnd.Global!=-1 && Low [bar]<F[LO].PocPrice && Low [bar+1]>F[LO].PocPrice)  {Trnd.Global=-1;}  //  LINE("LO PocPrice",   bar+3,F[LO].PocPrice, bar, F[LO].PocPrice,clrGreen,0);  
      }
   // значительный ИМПУЛЬС из последнего пика /(SHIFT(F[hi].T)-bar)
   if ((F[hi].P-F[hi].Back)>Atr.Slow*TrImp) {Trnd.Imp=F[hi].Back-F[hi].P; }  // ИМПУЛЬС ВНИЗ V(S0(lo)+" "+S4(Trnd.Imp)+" Back="+S4(F[lo].Back), High[bar], bar, clrGreen);
   if ((F[lo].Back-F[lo].P)>Atr.Slow*TrImp) {Trnd.Imp=F[lo].Back-F[lo].P; }  // ИМПУЛЬС ВВЕРХ  A(S0(lo)+" "+S4(Trnd.Imp)+" Back="+S4(F[lo].Back), Low [bar], bar, clrGreen);
   if (Atr.Fast<Atr.Slow) Trnd.Imp=0;  // отмена сигнала импульса при спадании АТР    
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void FILTERS(char DblTop, char Imp, char FltBrk, char& Up, char& Dn){// суммирование входных сигналов  
   bool Chk=false; // факт проверки хотябы одного сигнала
   if (TrGlb==0)        {Up=1; Dn=1;}  else  // сигналы
   if (Trnd.Global== 1) {Up=1; Dn=0;}  else  // глобального 
   if (Trnd.Global==-1) {Up=0; Dn=1;}        // тренда
   SIG_SUM(Chk, DblTop, Trnd.DblTop,   Up, Dn); // двойной отскок
   SIG_SUM(Chk, FltBrk, Trnd.FltBrk,   Up, Dn); // пробой флэта
   SIG_SUM(Chk, Imp,    Trnd.Imp,      Up, Dn); // резкий импульс
   if (TrGlb  && Trnd.Global>0)   LINE("Up="+S0(Up)+" Global="  +S0(Trnd.Global), bar+1, Low [bar+1]-Atr.Lim*6, bar, Low [bar]-Atr.Lim*6, clrBlack,0);
   if (TrGlb  && Trnd.Global<0)   LINE("Dn="+S0(Dn)+" Global="  +S0(Trnd.Global), bar+1, High[bar+1]+Atr.Lim*6, bar, High[bar]+Atr.Lim*6, clrBlack,0); 
   if (DblTop && Trnd.DblTop>0)   LINE("Up="+S0(Up)+" DblTop", bar+1, Low [bar+1]-Atr.Lim*8, bar, Low [bar]-Atr.Lim*8, clrRed,0);
   if (DblTop && Trnd.DblTop<0)   LINE("Dn="+S0(Dn)+" DblTop", bar+1, High[bar+1]+Atr.Lim*8, bar, High[bar]+Atr.Lim*8, clrRed,0); 
   if (FltBrk && Trnd.FltBrk>0)   LINE("Up="+S0(Up)+" BrkFlat",   bar+1, Low [bar+1]-Atr.Lim*4, bar, Low [bar]-Atr.Lim*4, clrGreen,0);
   if (FltBrk && Trnd.FltBrk<0)   LINE("Dn="+S0(Dn)+" BrkFlat",   bar+1, High[bar+1]+Atr.Lim*4, bar, High[bar]+Atr.Lim*4, clrGreen,0); 
   
   if (Imp    && Trnd.Imp>0)      LINE("Up="+S0(Up)+" Imp="     +S0(Trnd.Imp),    bar+1, Low [bar+1]-Atr.Lim*2, bar, Low [bar]-Atr.Lim*2, clrMagenta,0);
   if (Imp    && Trnd.Imp<0)      LINE("Dn="+S0(Dn)+" Imp="     +S0(Trnd.Imp),    bar+1, High[bar+1]+Atr.Lim*2, bar, High[bar]+Atr.Lim*2, clrMagenta,0); 
   }    // if (Prn) X("Flt="+DoubleToString(Trnd.Flt,0)+" Global="+DoubleToString(Trnd.Global,0)+" Trnd.Dn="+DoubleToString(1,0), Close[bar], bar, clrGray);
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void SIG_SUM(bool& Chk, char Logic, float Sig, char& Up, char& Dn){// СЛОЖЕНИЕ СИГНАЛОВ ТРЕНДА по "ИЛИ", "И"
   if (Logic==0) return;
   if (!Chk){// ни один сигнал еще не проверялся
      Chk=true;   // проверка первого сигнала
      if (Sig>0) Up=1; else Up=0; 
      if (Sig<0) Dn=1; else Dn=0;  // X("Sig="+S0(Sig)+" Up="+S0(Up)+" Dn="+S0(Dn), Close[bar], bar, clrGreen);
      }
   switch (MathAbs(Logic)){   
   case 1: // "AND" - сложение сигналов
      if (Sig<=0 && Up<2) Up=0; // отмена тренда, если не было сигнала, но при отстутствии 
      if (Sig>=0 && Dn<2) Dn=0; // доминирующего сигнала "OR"
   break;
   case 2:  // "OR" доминирующий над "AND" сигнал c отменой противоположного
      if (Sig>0)  {Dn=-1;  if (Up!=-1) Up=2;}   // блокировка противоположного,  
      if (Sig<0)  {Up=-1;  if (Dn!=-1) Dn=2;}   // если не было аналогичной блокировки, ставим флаг "2"
   break;
   case 3:  // "NO" отмена противоположного
      if (Sig>0)  {Dn=-1;}   // 
      if (Sig<0)  {Up=-1;}  //
   break;        
      }
   if (Logic<0){
      char tmp=Up; Up=Dn; Dn=tmp;      
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
void TARGET_COUNT(){// расчет целевых уровней окончания движения на основании измерения предыдущих безоткатных движений
   if (Target==0) return; // 
   if (Dir>0){// вершина
     if (RevLo2!=RevLo){// пересортировка, если были понижающиеся Lo, иначе обновляется лишь последнее движение LastMovUp
         RevLo2=RevLo;
         for (uchar i=Movements-1; i>0; i--) {MovUp[i]=MovUp[i-1];}   // пересортировка массива движений    if (Prn) Print("MovUp[",i,"]=",S4(MovUp[i]));
         MovUp[0]=LastMovUp; // последнее движение = последний пик - разворотная впадина  if (Prn) Print("MovUP[0]=",S4(MovUp[0]));
         ArrayCopy(MovUpSrt,MovUp,0,0,WHOLE_ARRAY); // копируем во временный массив для сортировки
         ArraySort(MovUpSrt,WHOLE_ARRAY,0,MODE_DESCEND); // сортировка в порядке убывания 
         if (Target<0)  MidMovUp=(MovUpSrt[1]+MovUpSrt[2])/2; // среднее движение: отбрасываем самый большой (0) и два самых маленьких (4)(3) движения
         LastMovUp=0;      
         }
      if (F[hi].P-F[RevLo].P>LastMovUp) {LastMovUp=F[hi].P-F[RevLo].P;}// обновляем последнее движение, если новый пик дальше от разворотной впадины, чем предыдущий   LINE("LastMovUp="+S4(LastMovUp)+" F[RevLo].P="+S4(F[RevLo].P), SHIFT(F[RevLo].T), F[RevLo].P,  bar+PicPer, F[hi].P, clrRed);
      if (Target>0) MidMovUp=(MovUpSrt[0]+MathMax(MovUpSrt[1],LastMovUp))/2;  // среднее максимальных значений прошлых и последнего движения
      if (MathAbs(Target)==1 || (MathAbs(Target)==2 && hi==RevHi)){ // отмеряем целевое движение вниз от последнего пика, или только от разворотного пика
         TargetLo=F[hi].P-MidMovDn;} //LINE("MidMovDn="+S4(MidMovDn), SHIFT(F[hi].T), F[hi].P,  SHIFT(F[hi].T), PreTargetLo, clrOrange);
   }else{// впадина
      if (RevHi2!=RevHi){// пересортировка, если были повышающиеся Hi, иначе обновляется лишь последнее движение LastMovDn
         RevHi2=RevHi;   
         for (uchar i=Movements-1; i>0; i--) {MovDn[i]=MovDn[i-1];}//пересортировка массива движений    if (Prn) Print("MovDn[",i,"]=",S4(MovDn[i]));
         MovDn[0]=LastMovDn;  // последнее движение = разворотный пик - последняя впадина    if (Prn) Print("MovDn[0]=",S4(MovDn[0]));
         ArrayCopy(MovDnSrt,MovDn,0,0,WHOLE_ARRAY); // копируем во временный массив для сортировки
         ArraySort(MovDnSrt,WHOLE_ARRAY,0,MODE_DESCEND); // сортировка в порядке убывания 
         if (Target<0)  MidMovDn=(MovDnSrt[1]+MovDnSrt[2])/2; // среднее движение: отбрасываем самый большой (0) и два самых маленьких (4)(3) движения
         LastMovDn=0;
         }    
      if (F[RevHi].P-F[lo].P>LastMovDn)  {LastMovDn=F[RevHi].P-F[lo].P;}// обновляем последнее движение, если новый пик дальше от разворотной впадины, чем предыдущий   LINE("LastMovDn="+S4(LastMovDn)+" MidMovDn="+S4(MidMovDn), SHIFT(F[RevHi].T), F[RevHi].P,  bar+PicPer, F[lo].P, clrGreen);  
      if (Target>0) MidMovDn=(MovDnSrt[0]+MathMax(MovDnSrt[1],LastMovDn))/2;  // среднее максимальных значений прошлых и последнего движения
      if (MathAbs(Target)==1 || (MathAbs(Target)==2 && lo==RevLo)){ // отмеряем целевое движение вверх от последнего пика, или только от разворотного пика
         TargetHi=F[lo].P+MidMovUp; //LINE("MidMovUp="+S4(MidMovUp), SHIFT(F[lo].T), F[lo].P,  SHIFT(F[lo].T), PreTargetHi, clrCornflowerBlue); 
   }  }  }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
double HiZone, DnZone; 
float PocCenter; 
uchar PocCnt;  // кол-во пересекающихся друг за другом бар
void POC(){    // определение плотного скопления бар без пропусков
   HiZone=MathMin(High[bar],HiZone); // С каждым новым баром края диапазона h и l
   DnZone=MathMax(Low [bar],DnZone); // обрезаются с учетом новых High и Low
   if (HiZone>DnZone) {PocCnt++; PocCenter=float((HiZone+DnZone)/2);} // считаем длину сформированного диапазона и его серединку
   else{// Диапазон прервался (сузился до нуля)
      PocCnt=1;    
      HiZone=High[bar]; 
      DnZone=Low[bar]; 
   }  } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
   

//int POC_DETECT(){// кол-во бар, образующих объем пика
//   double UpZone=P.New, DnZone=P.New-ATR, Zone=P.New-ATR/2;  // верхняя и нижняя границы поиска бар, формирующих POC
//   int BarOut=0, PocBars=0;
//   if (Dir<0) {UpZone=P.New+ATR; DnZone=P.New; Zone=P.New+ATR/2;} // при нижнем пике границы меняются местами
//   for (int p=bar; p<Bars; p++){// поиск назад от текущего бара
//      if (High[p]<DnZone || Low[p]>UpZone) BarOut++; else {PocBars++; } // бар или не попадает, или попадает в границы РОС   if (Prn) X(" PocBars="+DoubleToString(PocBars,0)+" p="+DoubleToString(p,0), (UpZone+DnZone)/2, p, clrRed);
//      if (p-bar>PicPer && BarOut>PocBars) break;}  // if (Prn) Print("p=",p," High[p]=",High[p]," Low[p]=",Low[p]," UpZone=",UpZone," DnZone=",DnZone);
//   //if (PocBars>PocPer){ 
//   //   LINE("Up: POC="+DoubleToString(PocBars,0), bar+PocBars, UpZone,  bar, UpZone, clrGreen); //+BarOut
//   //   LINE("Dn: POC="+DoubleToString(PocBars,0), bar+PocBars, DnZone,  bar, DnZone, clrGreen); //+BarOut
//   //   }
//   return (PocBars);
//   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
   
   
   //void DAY_ATR(){// Д Н Е В Н О Й   Д И А П А З О Н   З А   П О С Л Е Д Н И Е   П Я Т Ь   Д Н Е Й 
//   if (TimeHour(Time[bar])>TimeHour(Time[bar+1])) return; // новый день     
//   double DayHigh=High[iHighest(NULL,0,MODE_HIGH,BarsInDay,bar)], DayLow=Low[iLowest(NULL,0,MODE_LOW ,BarsInDay,bar)];
//   DayMov[DaysCnt]=DayHigh-DayLow; DaysCnt++; if (DaysCnt>=5) DaysCnt=0;
//   DayAtr=0; for (int i=0; i<5; i++) DayAtr+=DayMov[i]; DayAtr/=5; 
//   } //Print(ttt,"NewDay ","  ",DTIME(Time[bar])," DayHigh-DayLow=",DayHigh-DayLow,"   ",NormalizeDouble(DayMov[0],Digits-1)," ",NormalizeDouble(DayMov[1],Digits-1)," ",NormalizeDouble(DayMov[2],Digits-1)," ",NormalizeDouble(DayMov[3],Digits-1)," ",NormalizeDouble(DayMov[4],Digits-1),"      DayAtr=",NormalizeDouble(DayAtr,Digits-1));    

   
           