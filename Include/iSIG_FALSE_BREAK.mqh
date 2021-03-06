
void FALSE_BREAK_SIG(){// при iSignal=1  
   // iParam=0..3 - Максимальный вылет ложняка = ATR*(iParam+1). /lib_flat.mqh
   // П Р О Б О Й   В Е Р Ш И Н Ы  =  Ш О Р Т    ////////////////////////////////////////////////////////////////////////////
   Print("FALSE_BREAK_SIG");
   if (Sel.Mem!=FlsUp && F[FlsUp].Fls.Phase==CONFIRM && Sel.Pattern!=GOGO){// образовался новый ложняк, он подтвердился, нет сигнала от прошлого ложняка
      Sel.Mem=FlsUp;  // фиксим номер ложняка
      Sel.Pattern=GOGO;    // сигнал на открытие позы
      Sel.T=Time[bar];// время формирования сигнала
      /*    D   */   // цена входа (c подтверждением)
      /*  5.. 3 */   if (D> 2)   Sel.Inp = F[FlsUp].P       +float((D-4)*ATR/2); else  // лимитник от пробитой вершины  -0.5 .. +0.5 ATR
      /*  2.. 0 */   if (D>=0)   Sel.Inp = F[FlsUp].Fls.Base+float((D-1)*ATR/2); else  // лимитник от базы ложняка      -0.5 .. +0.5 ATR
      // без подтверждения - сразу ставим ордер на пробой при D<0
      /* -1..-2 */   if (D>-3)   Sel.Inp = F[FlsUp].P       +float((D+1)*ATR/2); else  // обратный пробой пробитой вершины  -0.5 .. +0 ATR
      /* -3..-5 */               Sel.Inp = F[FlsUp].Fls.Base+float((D+4)*ATR/2);       // пробой базы ложняка           -0.5 .. +0.5 ATR
      Sel.Stp=F[FlsUp].Fls.P+DELTA(Stp);// за пик ложняка
      Sel.Prf=F[FlsUp].Back;// тейк на величину движения, которое дал уровень
      V("GOGO "+S0(FlsUp), Sel.Inp, bar,  clrGreen);
      }  
   if (Sel.Pattern==GOGO && F[FlsUp].Fls.Phase==NONE){// отмена сигнала при отмене ложняка 
      Sel.Pattern=NONE;
      }       
      
   // П Р О Б О Й   В П А Д И Н Ы  =  Л О Н Г   ////////////////////////////////////////////////////////////////////////////
   if (Buy.Mem!=FlsDn && F[FlsDn].Fls.Phase==CONFIRM && Buy.Pattern!=GOGO){// образовался новый ложняк, он подтвердился, нет сигнала от прошлого ложняка 
      Buy.Mem=FlsDn;  // фиксим номер ложняка
      Buy.Pattern=GOGO;    // сигнал на открытие позы
      Buy.T=Time[bar];// время формирования сигнала
      /*    D   */   // цена входа (c подтверждением)
      /*  5.. 3 */   if (D> 2)   Buy.Inp = F[FlsDn].P       -float((D-4)*ATR/2); else  // лимитник от пробитой впадины  -0.5 .. +0.5 ATR
      /*  2.. 0 */   if (D>=0)   Buy.Inp = F[FlsDn].Fls.Base-float((D-1)*ATR/2); else  // лимитник от базы ложняка      -0.5 .. +0.5 ATR
      // без подтверждения - сразу ставим ордер на пробой при D<0
      /* -1..-2 */   if (D>-3)   Buy.Inp = F[FlsDn].P       -float((D+1)*ATR/2); else  // обратный пробой пробитой впадины  -0.5 .. +0 ATR
      /* -3..-5 */               Buy.Inp = F[FlsDn].Fls.Base-float((D+4)*ATR/2);       // пробой базы ложняка           -0.5 .. +0.5 ATR
      Buy.Stp=F[FlsDn].Fls.P-DELTA(Stp);  // за первый пик
      Buy.Prf=F[FlsDn].Back;// тейк на величину движения, которое дал уровень
      A("GOGO "+S0(FlsDn), Buy.Inp, bar,  clrGreen);
      }
   if (Buy.Pattern==GOGO && F[FlsDn].Fls.Phase==NONE){     // отмена ложняка
      Buy.Pattern=NONE;
      }
   if (Real) ERROR_CHECK("FALSE_BREAK_SIG");
   }
   
   
   
