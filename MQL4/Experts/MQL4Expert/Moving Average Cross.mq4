//+------------------------------------------------------------------+
//|                                         Moving Average Cross.mq4 |
//+------------------------------------------------------------------+

#property copyright     "MQL4Expert.club"
#property link          "http://www.mql4expert.club"
#property description   ""
#property strict


//+------------------------------------------------------------------+
//| Includes and object initialization                               |
//+------------------------------------------------------------------+

#include <MQL4Expert\Trade.mqh>
CTrade Trade;
CCount Count;

#include <MQL4Expert\Indicators.mqh>

#include <MQL4Expert\Timer.mqh>
CNewBar NewBar;

#include <MQL4Expert\TrailingStop.mqh>

#include <MQL4Expert\MoneyManagement.mqh>


//+------------------------------------------------------------------+
//| Input variables                                                  |
//+------------------------------------------------------------------+

sinput string TradeSettings;    // Trade Settings
input int MagicNumber = 101;
input int Slippage = 10;
input bool TradeOnBarOpen = true;
input ENUM_LINE_STYLE InpStyle = STYLE_SOLID;   // Border line style
input int  InpWidth=6;         // Arrow size

input int MinCrossSpread = 10;

sinput string FastMaSettings;   // Fast Moving Average
input int FastMaPeriod = 5;
input ENUM_MA_METHOD FastMaMethod = MODE_EMA;
input ENUM_APPLIED_PRICE FastMaPrice = PRICE_CLOSE;

sinput string SlowMaSettings;   // Slow Moving Average
input int SlowMaPeriod = 20;
input ENUM_MA_METHOD SlowMaMethod = MODE_EMA;
input ENUM_APPLIED_PRICE SlowMaPrice = PRICE_CLOSE;


//+------------------------------------------------------------------+
//| Global variable and indicators                                   |
//+------------------------------------------------------------------+

CiMA FastMa(_Symbol,_Period,FastMaPeriod,0,FastMaMethod,FastMaPrice);
CiMA SlowMa(_Symbol,_Period,SlowMaPeriod,0,SlowMaMethod,SlowMaPrice);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
{
   // Set magic number
   Trade.SetMagicNumber(MagicNumber);
   Trade.SetSlippage(Slippage);
   
   return(INIT_SUCCEEDED);
}


void DrawArrowUp(string ArrowName,double LinePrice,color LineColor)
{
ObjectCreate(ArrowName, OBJ_ARROW, 0, Time[0], LinePrice); //draw an up arrow
ObjectSet(ArrowName, OBJPROP_STYLE, InpStyle);
ObjectSet(ArrowName, OBJPROP_WIDTH, InpWidth);
ObjectSet(ArrowName, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
ObjectSet(ArrowName, OBJPROP_COLOR,LineColor);
}

void DrawArrowDown(string ArrowName,double LinePrice,color LineColor)
{
ObjectCreate(ArrowName, OBJ_ARROW, 0, Time[0], LinePrice); //draw an up arrow
ObjectSet(ArrowName, OBJPROP_STYLE, InpStyle);
ObjectSet(ArrowName, OBJPROP_WIDTH, InpWidth);
ObjectSet(ArrowName, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
ObjectSet(ArrowName, OBJPROP_COLOR,LineColor);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick() {
   // Check for bar open
   bool newBar = true;
   int barShift = 0;
   
   double minSpread = MinCrossSpread * _Point;
   
   if(TradeOnBarOpen == true) {
      newBar = NewBar.CheckNewBar(_Symbol,_Period);
      barShift = 0;
      Print(_Point);
      Print(minSpread);
   }
   
   /*ตรวจสอบว่าเป็นการเริ่มแท่งเทียนใหม่รึปล่าว */
   if(newBar == true) {

      // ตรวจสอบว่าเป็น MA Cross Over รึปล่าว
      if( FastMa.Main(barShift) > SlowMa.Main(barShift) + minSpread 
      && FastMa.Main(barShift + 1) <= SlowMa.Main(barShift + 1)+ minSpread) {
         // Open Order Buy
         DrawArrowUp("Buy",Open[0],clrWhite); 

         
      }
      
      // ตรวจสอบว่าเป็น MA Cross Under รึปล่าว
      else if( FastMa.Main(barShift) < SlowMa.Main(barShift) - minSpread 
      && FastMa.Main(barShift + 1) >= SlowMa.Main(barShift + 1) - minSpread) {
         // Open Order Sell
        DrawArrowDown("Sell",Open[0],clrRed); 
         
      }
   }  
    
}
  
//+------------------------------------------------------------------+
