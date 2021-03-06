double minHi,maxLo; // самая нижняя впадина сверху и самая высокая снизу в формирующемся диапазоне
int PocSum; // кол-во совпавших бар диапазона
int dPoc;   // инкремент РОС для формирования массива распределения 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
int POC_INIT(){
   Comment( "Начало истории минуток         ",  TimeToString(iTime(NULL,PERIOD_M1, iBars(NULL,PERIOD_M1)-1)), ", в окне  ",iBars(NULL,PERIOD_M1)," бар"+"\n"+
            "Начало истории текущего ТФ ",      TimeToString(Time[Bars-1]),                                   ", в окне  ",Bars,                 " бар");
   dPoc=PERIOD_D1/Period(); // чтобы на разных ТФ значения РОС были примерно одинаковыми
   CLEAR_CHART();// удаляем все свои линии
   return (INIT_SUCCEEDED); // Успешная инициализация. Результат выполнения функции OnInit() анализируется терминалом только если программа скомпилирована с использованием #property strict.
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void POC_INDICATOR(int PocPer){
   int      maxpoc;        // максимальное значение POC
   double   maxpocPrice;   // уровень с максимальным значением POC
   minHi=MathMin(High[bar],minHi); // С каждым новым баром края диапазона minHi и maxLo с учетом новых High и Low
   maxLo=MathMax(Low [bar],maxLo); // обрезаются, стремясь к его середине. 
   if (minHi > maxLo) PocSum++;// диапазон пересечения последних нескольких бар положителен, т.е. ни один бар не "выскочил" за него: считаем кол-во идущих подряд бар с общим ценовым диапазоном 
   else{// диапазон схлопнулся
      if (PocSum>PocPer){// совпало достаточное кол-во бар
         POC_COUNT(Time[bar+PocSum], Time[bar], maxpoc, maxpocPrice); // расчет уровня и значения РОС в сформированном диапазоне
         }
      PocSum=2; // кол-во совпавших бар = текущий и предыдущий
      minHi=MathMin(High[bar],High[bar+1]);   // для дальнейшего
      maxLo=MathMax(Low [bar],Low [bar+1]);   // отслеживания           
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
int POC_COUNT(datetime TimeFrom, datetime TimeTo, int& maxpoc, double& maxpocPrice){// расчет уровня и значения РОС за последние PocBars бар
   double   point=Point*10.0; // шаг сканирования диапазона (снизу вверх)
   int shift=0;
   if (TimeTo<TimeFrom) {datetime tmp=TimeFrom; TimeFrom=TimeTo; TimeTo=tmp;} // для последующих расчетов TimeTo должен быть больше TimeFrom
   int m1BarFrom=iBarShift(NULL,PERIOD_M1,TimeFrom, false);  // края диапазона на минутном ТФ. При exact=false, iBarShift возвращает ближайший бар,     
	int m1BarTo = iBarShift(NULL,PERIOD_M1,TimeTo,   false);	// при exact=true,  iBarShift возвращает -1          
   int BarFrom=iBarShift(NULL,0,TimeFrom, false);  // края диапазона на минутном ТФ. При exact=false, iBarShift возвращает ближайший бар,     
	int BarTo = iBarShift(NULL,0,TimeTo,   false);	// при exact=true,  iBarShift возвращает -1   
   int PocLow  = (int)MathRound(iLow (NULL, 0, iLowest (NULL, 0, MODE_LOW,  BarFrom-BarTo+1, BarTo))/point);   // нижняя и верхняя границы
   int PocHigh = (int)MathRound(iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, BarFrom-BarTo+1, BarTo))/point);   // диапазона на минутном ТФ в целых числах
	int PocArr[];// массив распределения POC 
	int PocHL=GET_POC(m1BarFrom, m1BarTo, PocArr, PocLow, PocHigh, maxpoc, maxpocPrice, point);
	if (PocHL==0) return(0); // PocHL - размер диапазона в пунктах от нижней до верхней его границы
	if (PocAllocation)  // показывать гистограмму POC
	   shift=iBarShift(NULL,0,TimeTo,false);
	   for (int p=0; p<PocHL; p++){ // от нижней до верхней границы гистограммы POC 
	      if (PocArr[p]==maxpoc)  LINE("POC",shift,(PocLow+p)*point, shift+PocArr[p]*PocScale/1000,(PocLow+p)*point, MaxPocColor,0);   // максимум гистограммы выделяем красным
	      else                    LINE("POC",shift,(PocLow+p)*point, shift+PocArr[p]*PocScale/1000,(PocLow+p)*point, PocColor,0);      // остальные линии серенькие
	      }
   return(0);   
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
int GET_POC(int m1BarFrom, int m1BarTo, int& PocArr[], int& PocLow, int& PocHigh, int& maxpoc, double& maxpocPrice, double point){// Получить гистограмму распределения цен
	int PocHL = PocHigh-PocLow+1; // размер диапазона в пунктах от нижней до верхней его границы = коло-во членов массива PocArr
	ArrayResize(PocArr, PocHL);
	ArrayInitialize(PocArr, 0);
	for (int i=0; i<=(m1BarFrom-m1BarTo); i++){// перебор диапазона по барам справа налево
		int Hi=(int)MathRound(iHigh(NULL,PERIOD_M1,i+m1BarTo)/point); // H свечи
		int Lo=(int)MathRound(iLow (NULL,PERIOD_M1,i+m1BarTo)/point); // L свечи (в целых числах)
		for (int p=Lo; p<=Hi; p++){// перебор свечи от L к H с шагом point=Point*10
		   if (p<PocLow || p>PocHigh) continue; // свечи только из границ заданного диапазона HL
		   PocArr[p-PocLow]+=dPoc;    // заполняем массив на каждом уровне, где попадается свеча
		   if (PocArr[p-PocLow]>maxpoc) {maxpoc=PocArr[p-PocLow]; maxpocPrice=p*point;} // сразу ищем максимальное значение POC и запоминаем цену с этим значением 
	   }  } 
	return(PocHL);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
float POC_SIMPLE(float UpBorder, float DnBorder, int BarFrom, int BarTo, ushort& MaxPoc, float& MaxPocPrice){// расчет уровня и значения РОС за последние PocBars бар
   float   point=float(Point*10.0); // шаг сканирования диапазона (снизу вверх)
   if (BarFrom<BarTo) {int tmp=BarTo; BarTo=BarFrom; BarFrom=tmp;}
   if (UpBorder<DnBorder) {float tmp=UpBorder; UpBorder=DnBorder; DnBorder=tmp;} 
   int bars=BarFrom-BarTo;
   int shift=0, maxp=0;
   if (UpBorder==0) UpBorder=999999; // если границы сверху и снизу не 
   //if (DnBorder==0) DnBorder=0;    // заданы, расширяем их до бесконечности  
   float lim=Atr.Lim; // чуть увеличим бары совпадали немного недотягивающиеся друг до друга 
   ushort PocLow  = (ushort)MathRound((MathMax(Low [iLowest (NULL,0,MODE_LOW, bars+1,BarTo)], DnBorder) - lim)/point);   // целые значения нижней и верхней границ
   ushort PocHigh = (ushort)MathRound((MathMin(High[iHighest(NULL,0,MODE_HIGH,bars+1,BarTo)], UpBorder) + lim)/point);   // диапазона, ограниченные границами поиска
	ushort PocArr[];// массив распределения POC 
	ushort PocHL = PocHigh-PocLow+1; // размер диапазона в пунктах от нижней до верхней его границы = коло-во членов массива PocArr
	ArrayResize(PocArr, PocHL);
	ArrayInitialize(PocArr, 0);
	MaxPoc=0;
	for (int i=0; i<=bars; i++){// перебор диапазона по барам справа налево
		int Hi=(int)MathRound((High[i+BarTo]+lim)/point); // H свечи
		int Lo=(int)MathRound((Low [i+BarTo]-lim)/point); // L свечи (в целых числах)
		for (int p=Lo; p<=Hi; p++){// перебор свечи от L к H с шагом point=Point*10
		   if (p<PocLow || p>PocHigh) continue; // свечи только из границ заданного диапазона HL
		   PocArr[p-PocLow]+=1;    // заполняем массив на каждом уровне, где попадается свеча
		   if (PocArr[p-PocLow]>MaxPoc) {MaxPoc=PocArr[p-PocLow]; maxp=p-PocLow; MaxPocPrice=p*point;} // сразу ищем максимальное значение POC и запоминаем цену с этим значением 
	   }  } 
	for (int p=maxp; p<PocHL; p++)// шарим массив в обратном направлении
	   if (PocArr[p]<MaxPoc) {MaxPocPrice=(int(maxp+p-1)/2+PocLow)*point; break;} // в поисках центра POC   
	return (MaxPocPrice);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
