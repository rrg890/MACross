//+------------------------------------------------------------------+
//|                                                      MACross.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//variables input

input double malow = 20;
input double mahigh = 100;
input double stop_loss = 0.001;
input double lot = 0.05;
input double slippage = 0.001;

//variables globales
bool in_operation = false;
double ma_low = 0;
double ma_high = 0;
double ticket_buy = 0;
double ticket_sell = 0; //1: buy , 2: sell
int counter_candle = 0;
datetime lasttime = 0;

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   ma_low = iMA(Symbol(), Period(), malow,0,MODE_SMA,PRICE_CLOSE,0);
   ma_high = iMA(Symbol(), Period(), mahigh,0,MODE_SMA,PRICE_CLOSE,0);
   
   //Print("Inoperation: "+in_operation+" 20: "+ma_low+" 100: "+ma_high);
   
   if (!(in_operation) && ma_low<ma_high && lasttime!=iTime(Symbol(),Period(),0)){
      
      //venta
      ticket_sell = OrderSend(Symbol(),OP_SELL,lot,Bid,slippage,0,0,NULL,0,0,Blue);
      if (ticket_sell>0){
         in_operation = true;
         counter_candle = 0;
      }
      
   }else if (!(in_operation) && ma_low>ma_high && lasttime!=iTime(Symbol(),Period(),0)){
      
      //compra
      ticket_buy = OrderSend(Symbol(),OP_BUY,lot,Ask,slippage,0,0,NULL,0,0,Blue);
      if (ticket_buy>0){
         in_operation = true;
         counter_candle = 0;
      }
      
   }
   trailingStop();
   if (in_operation){
      counter_candle = counter_candle + 1;
   }
   
   if (lasttime!=iTime(Symbol(),Period(),0)){
      lasttime = iTime(Symbol(),Period(),0);
   }
   
  }
  
void trailingStop (){
   int counter = 0;
   for (int i = OrdersTotal()-1; i >= 0; i--){
      if ( OrderSelect(i, SELECT_BY_POS) ){
         if (OrderTicket()==ticket_buy){
            if (ma_low<=ma_high){
               
               OrderClose(OrderTicket(),OrderLots(),Bid,100,Red);
               in_operation = false;
               ticket_buy = 0;
            }
         }else if(OrderTicket()==ticket_sell){
            if (ma_low>=ma_high){
               OrderClose(OrderTicket(),OrderLots(),Ask,100,Red);
               in_operation = false;
               ticket_sell = 0;
            }
         }
      }
   //counter = counter+1;
   }

   
}

//+------------------------------------------------------------------+
