#property copyright "Hohla"
#property link      "mail@hohla.ru"
#property version    "180.207" // yym.mdd
#property description "При совпадении PowerCheck вершин начинается верхний флэтовый уровень" 
#property description "Нижний флэтовый уровень чертится по мимимуму между ними." 
#property description "При пробитии одного из этих уровней на LevAccuracy*atr фиксируется начало импульса ложняка и чертится соответствующпй уровень." 
#property strict // Указание компилятору на применение особого строгого режима проверки ошибок 
#property indicator_chart_window 
#property indicator_buffers 20
#property indicator_color1 clrCadetBlue      // Flt.Hi.P: Флэтовые уровни с кол-вом    
#property indicator_color2 clrCadetBlue      // Flt.Lo.P: отскоков больше PowerCheck  
#property indicator_color3 clrLightSlateGray // F[StrHi].P: Хотябы один
#property indicator_color4 clrLightSlateGray // F[StrLo].P: отскок
#property indicator_color5 clrLightCoral     // UP3: Уровни покупки
#property indicator_color6 clrCornflowerBlue // DN3: и продажи

#property indicator_color7 clrOrange      // Fls.Max: максимум ложняка (для постановки стопа)
#property indicator_color8 clrOrange      // Fls.Min: минимум ложняка (для постановки стопа)
#property indicator_color9 clrOrange      // Fls.Buy: уровень покупки для ложняка вверх
#property indicator_color10 clrOrange     // Fls.Sel: уровень продажи для ложняка вниз
#property indicator_color11 clrSilver     // Fls.UpEnd: противоположный (нижний) уровень канала ложняка вверх
#property indicator_color12 clrSilver     // Fls.DnEnd: противоположный (верхний) уровень канала ложняка вниз
#property indicator_color13 clrSilver     // Fls.UpStart: пробитая ложняком верхняя граница
#property indicator_color14 clrSilver     // Fls.DnStart: пробитая ложняком нижняя граница

#property indicator_color15 clrLightCoral    // FirstUp: первый трендовый уровень не продажу
#property indicator_color16 clrCornflowerBlue// FirstDn: первый трендовый уровень не покупку
#property indicator_color17 clrLightCoral    // F[StrLo].P: уровень поддержки при восходящем тренде, или граница флэта при двойном пике
#property indicator_color18 clrCornflowerBlue// F[StrHi].P: уровень сопротивления при нисходящем тренде, или граница флэта при двойном пике
#property indicator_color19 clrRed     // TargetUp: целевой уровень окончания движения вверх на основании измерения предыдущих безоткатных движений
#property indicator_color20 clrGreen    // TargetDn: целевой уровень окончания движения вниз  на основании измерения предыдущих безоткатных движений

//#property indicator_width1 5
//#property indicator_width2 5
////#property indicator_width7 2
////#property indicator_width8 2
#property indicator_width15 3
#property indicator_width16 3
#property indicator_width17 2 // тренд вверх (жирная поддержка АпТренда)
#property indicator_width18 2 // тренд вниз (жирное сопротивление ДаунТренда)
      sinput string  z2="          -  P I C    L E V E L S  - ";
extern char FltLen=10;  // FltLen=5..15/5 минимальная длина флэта; и бары от пробиваемого пика до его ложняка в SIG_MIRROR_LEVELS()
extern char PicCnt=2;   // PicCnt=1..3 кол-во отскоков для флэтa и ложняка
extern char Target=1;   // Target=-2..2 целевой уровень: >0~макс. <0~средн движение от 1-последнего, 2-разворотного пика  
extern char  Front=9;   // Front=0..3 передний фронт АТР*Front
extern char Trd=0;      // Trd=0..1 С непробитым трендовым должны быть
extern char Pot=1;      // Pot=0..1 Потенциал пика: Back д.б. больше Front; Back=Front*Max(1,Pot) 0~не учитывается
extern char Rev=0;      // Rev=0..1  Пробивший охтябы одну вершину.
      sinput string  z3="          -  T R E N D   S I G N A L S  - ";
extern char  TrGlb=0;   // TrGlb=0..3 всегда "И" Глобальный тренд после пробоя: 1-Серединки; 2-Первых Уровней; 3-Образования первого уровня; 0-без Глобала       
extern char  TrDblPic=2;// TrDblPic=2..3 Двойная/тройная вершинка 
extern char  TrImp=4;   // TrImp=2..8/2 порог срабатывания (*ATR) импульса из пика.
extern char iDblTop=0; // iDblTop=0..3   сложение сигналов тренда при входе:  1(AND) суммирование с остальными; 0 без данного сигнала; 
extern char iFltBrk=0; // iFltBrk=0..3   2(OR) достаточно одного сигнала, противоположные отменяются;  
extern char iImp=0;    // iImp=0..3      3(NO) противоположные отменяются.         
      sinput string  z5="          -  A  T  R  - ";       
extern char  A=15;    // A=10..30  кол-во бар^2 для медленного АТР
extern char  a=5;     // a=2..6  кол-во бар^2 для быстрого atr
extern char  dAtr=10; // dAtr=6..12  ATR=ATR*dAtr*0.1 - минимальное приращение для расчета стопа, тейка и дельты входа: 
extern char  Ak=1;    // Ak=1..3 ATR: 0-(atr,ATR)/2 1~atr 2~min 3~max
extern char  PicVal=20;  // PicVal=10..50  Допуск  Atr.Lim: АТР%
// переменные из эксперта
char  iFrstLev=1; // iFrstLev=-3..3 вход в районе Первых Уровней: DELTA(|iFrstLev|+1) / <0 уровня серединки
char  iParam=1;   // used in  Максимальный вылет ложняка = ATR*(iParam+1)  /lib_Flat.mqh
char  iSignal=1;  // обработка сигнала ложняка при iSignal=1 (lib_Flat.mqh)
char  D=0;        // (lib_Flat.mqh)

int      bar;
ushort   PocScale = 5;  // PocScale=1..10 множитель длины РОС
double   I0[],I1[],I2[],I3[],I4[],I5[],I6[],I7[],I8[],I9[],I10[],I11[],I12[],I13[],I14[],I15[],I16[],I17[],I18[],I19[]; //  ложняки
double   BUY, SELL, BUYSTOP, SELLSTOP, BUYLIMIT, SELLLIMIT, STOP_BUY, PROFIT_BUY, STOP_SELL, PROFIT_SELL,   
         SetBUY, SetSELL, SetSTOP_BUY, SetPROFIT_BUY, SetSTOP_SELL, SetPROFIT_SELL;          
bool    PocAllocation=1, Real=true, Modify;  // PocAllocation=0..1 показывать/скрыть распределение POC
color   PocColor    = clrBlack;  // цвет гистограммы POC
color   MaxPocColor = clrRed;   // цвет максимального POC
   

string ExpertName="iPIC";  // идентификатор графических объектов для их удаления
#include <lib_ATR.mqh> 
#include <lib_POC.mqh>     // 
#include <lib_PIC.mqh>     // 
#include <lib_Flat.mqh>    // 
#include <iGRAPH.mqh>

int OnInit(){//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   string iName="PIC";
   IndicatorBuffers(20);  IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);   SetIndexBuffer(0,I0);   // UP2: сильные уровни с кол-вом 
   SetIndexStyle(1,DRAW_LINE);   SetIndexBuffer(1,I1);   // DN2: отскоков больше PowerCheck
   
   SetIndexStyle(2,DRAW_LINE);   SetIndexBuffer(2,I2);   // F[StrHi].P: хотябы один 
   SetIndexStyle(3,DRAW_LINE);   SetIndexBuffer(3,I3);   // F[StrLo].P: отскок
   
   SetIndexStyle(4,DRAW_LINE);   SetIndexBuffer(4,I4);   // UP3: уровни покупки
   SetIndexStyle(5,DRAW_LINE);   SetIndexBuffer(5,I5);   // DN3: и продажи
   
   SetIndexStyle(6,DRAW_LINE);   SetIndexBuffer(6,I6);   // Fls.Max: максимум ложняка (для постановки стопа)
   SetIndexStyle(7,DRAW_LINE);   SetIndexBuffer(7,I7);   // Fls.Min: минимум ложняка (для постановки стопа)
    
   SetIndexStyle(8,DRAW_LINE);   SetIndexBuffer(8,I8);   // Fls.Buy: уровень покупки для ложняка вверх
   SetIndexStyle(9,DRAW_LINE);   SetIndexBuffer(9,I9);   // Fls.Sel: уровень продажи для ложняка вниз
   
   SetIndexStyle(10,DRAW_LINE);  SetIndexBuffer(10,I10); // Fls.UpEnd: противоположный (нижний) уровень канала ложняка вверх
   SetIndexStyle(11,DRAW_LINE);  SetIndexBuffer(11,I11); // Fls.DnEnd: противоположный (верхний) уровень канала ложняка вниз
   
   SetIndexStyle(12,DRAW_LINE);  SetIndexBuffer(12,I12); // Fls.UpStart: пробитая ложняком верхняя граница
   SetIndexStyle(13,DRAW_LINE);  SetIndexBuffer(13,I13); // Fls.DnStart: пробитая ложняком нижняя граница
   
   SetIndexStyle(14,DRAW_LINE);  SetIndexBuffer(14,I14); // FirstUp: первый трендовый уровень не продажу
   SetIndexStyle(15,DRAW_LINE);  SetIndexBuffer(15,I15); // FirstDn: первый трендовый уровень не покупку
   
   SetIndexStyle(16,DRAW_LINE);  SetIndexBuffer(16,I16); // F[StrHi].P: уровень сопротивления при нисходящем тренде, или граница флэта при двойном пике
   SetIndexStyle(17,DRAW_LINE);  SetIndexBuffer(17,I17); // F[StrLo].P: уровень поддержки при восходящем тренде, или граница флэта при двойном пике
   
   SetIndexStyle(18,DRAW_LINE);  SetIndexBuffer(18,I18); // TargetUp: целевой уровень окончания движения вверх на основании измерения предыдущих безоткатных движений
   SetIndexStyle(19,DRAW_LINE);  SetIndexBuffer(19,I19); // TargetDn: целевой уровень окончания движения вниз  на основании измерения предыдущих безоткатных движений
   
   // iName=iName+"("+DoubleToStr(A,0)+") ";   
   IndicatorShortName(iName);
   SetIndexLabel(0,iName);
   BarsInDay=short(60*24/Period()); // кол-во бар в дне
   ASCII(45);
   if (ATR_INIT()==INIT_FAILED) {Print("OnInit(): ATR_INIT()=INIT_FAILED"); return(INIT_FAILED);}
   return(PIC_INIT());  // (0)=Успешная инициализация. Результат выполнения функции OnInit() анализируется терминалом только если программа скомпилирована с использованием #property strict      
   }                    // НЕнулевой код возврата означает неудачную инициализацию и генерирует событие Deinit с кодом причины деинициализации REASON_INITFAILED



void start(){
   int UnCounted=Bars-IndicatorCounted()-PicPer-1;
   for (bar=UnCounted; bar>0; bar--){ // Print(" Bars=",Bars," IndicatorCounted=",IndicatorCounted()," UnCounted=",UnCounted, " bar=",bar);
      if (!PIC()) continue; // ОСНОВНОЙ ЦИКЛ ПОИСКА УРОВНЕЙ 
      
      //I0[bar]=F[sH].P;
      //I1[bar]=F[sL].P;
         
      //if (Prn) V(S4(F[14].Flt.Lev)+"/"+S0(F[14].Fls.Phase), High[bar]+0.0010, bar, clrGray);//Print(DTIME(Time[bar])," F[14].Fls.Phase",F[14].Fls.Phase);
      //TRADE_ZONE(2);
      //SIG_SIMPLE();
      //NEW_W();
      //TAPERING_TRIANGLE();
     //I4[bar]=TargetHi; //  LINE("PreTargetHi", bar+1, PreTargetHi,  bar, PreTargetHi, clrOrange,0);
     //I5[bar]=TargetLo; //  LINE("PreTargetLo", bar+1, PreTargetLo,  bar, PreTargetLo, clrOrange,0);
      
      //SIG_TURTLE();   
      //POC(); /* if (PocCnt>2) I3[bar]=PocCenter; */ // ОПРЕДЕЛЕНИЕ ПЛОТНОГО СКОПЛЕНИЯ БАР БЕЗ ПРОПУСКОВ   
         //LINE(" HI", bar+1,F[HI].P,  bar, F[HI].P, clrPink,3);          LINE(" FstCenter", bar+1,F[HI].PocPrice,  bar, F[HI].PocPrice, clrPink,0);
         //LINE(" LO=", bar+1,F[LO].P,  bar, F[LO].P, clrPowderBlue,3);   LINE(" FstCenter", bar+1,F[LO].PocPrice,  bar, F[LO].PocPrice, clrPowderBlue,0);
     //I14[bar]=F[HI].P;
     //I15[bar]=F[LO].P;
      //if (TrGlb>0){   
      //   if (Trnd.Global<0) I16[bar]=High[bar]+Atr.Lim; // флэтовый уровень сверху (не менее двух отскоков)
      //   if (Trnd.Global>0) I17[bar]=Low [bar]-Atr.Lim; // флэтовый уровень снизу  (не менее двух отскоков)
      //   } 
      FILTERS (iDblTop, iImp, iFltBrk, Trnd.Up, Trnd.Dn);   
      //if (Trnd.Up>0) I15[bar]=Low [bar]; 
      //if (Trnd.Dn>0) I16[bar]=High[bar]; 
     
   }  }/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
int deinit(){
	CLEAR_CHART();// удаляем все свои линии
	return(0);
   }

  
