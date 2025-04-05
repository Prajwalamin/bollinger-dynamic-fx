//+------------------------------------------------------------------+
//| Expert Advisor based on Bollinger Bands and RSI (H4 Chart)      |
//| No Stop Loss, Take Profit in Pips                               |
//| Added Drawdown Protection & Dynamic Lot Sizing                 |
//| Now uses Initial Balance for Drawdown Calculation              |
//+------------------------------------------------------------------+
#property strict

// Input Parameters
input int RSI_Period = 14;
input int BB_Period = 20;
input double BB_Deviation = 2.0;
input int RSI_Overbought = 70;
input int RSI_Oversold = 30;
input double DefaultLotSize = 0.5;
input double MaxDrawdownPercent = 10.0; // Maximum Drawdown before reducing lot size
input int TakeProfitPips = 50; // Take Profit in pips
input double LotReductionFactor = 0.5; // Factor to reduce lot size when drawdown is hit

// Indicator Handles
int rsiHandle;
int bbHandle;

double rsiValue, upperBB, lowerBB, middleBB;
double bid, ask;

double rsiBuffer[1], upperBBBuffer[1], lowerBBBuffer[1], middleBBBuffer[1];
double CurrentLotSize;
bool DrawdownTriggered = false;
double InitialBalance;

//+------------------------------------------------------------------+
//| Initialization function                                         |
//+------------------------------------------------------------------+
int OnInit()
{
    rsiHandle = iRSI(_Symbol, PERIOD_H4, RSI_Period, PRICE_CLOSE);
    bbHandle = iBands(_Symbol, PERIOD_H4, BB_Period, BB_Deviation, 0, PRICE_CLOSE);
    CurrentLotSize = DefaultLotSize;
    InitialBalance = AccountInfoDouble(ACCOUNT_BALANCE); // Store initial balance
    
    if (rsiHandle == INVALID_HANDLE || bbHandle == INVALID_HANDLE)
    {
        Print("Error creating indicator handles");
        return INIT_FAILED;
    }
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| OnTick Function - Trading Logic                                 |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check for Drawdown Exceeding Limit (based on Initial Balance)
    
    double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    double maxAllowedEquity = InitialBalance  * (1.0 - MaxDrawdownPercent / 100.0);
    
    if (accountEquity < maxAllowedEquity && !DrawdownTriggered)
    {
        CurrentLotSize *= LotReductionFactor;
        if (CurrentLotSize < 0.01) CurrentLotSize = 0.01; // Prevent too small lot sizes
        DrawdownTriggered = true;
        Print("Max Drawdown Reached! Reducing lot size to ", DoubleToString(CurrentLotSize, 2));
    }
    
    // Get latest market prices
    bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    
    // Copy latest RSI value
    if (CopyBuffer(rsiHandle, 0, 0, 1, rsiBuffer) <= 0)
    {
        Print("Error copying RSI buffer");
        return;
    }
    rsiValue = rsiBuffer[0];
    
    // Copy latest Bollinger Bands values
    if (CopyBuffer(bbHandle, 0, 0, 1, middleBBBuffer) <= 0 ||
        CopyBuffer(bbHandle, 1, 0, 1, lowerBBBuffer) <= 0 ||
        CopyBuffer(bbHandle, 2, 0, 1, upperBBBuffer) <= 0)
    {
        Print("Error copying Bollinger Bands buffer");
        return;
    }
    middleBB = middleBBBuffer[0];
    lowerBB = lowerBBBuffer[0];
    upperBB = upperBBBuffer[0];
    
    // Prevent multiple trades in the same direction
    bool buyExists = CheckIfTradeExists(POSITION_TYPE_BUY);
    bool sellExists = CheckIfTradeExists(POSITION_TYPE_SELL);
    
    // Trading Conditions
    if (bid >= upperBB && rsiValue > RSI_Overbought && !sellExists)
    {
        OpenSellOrder();
    }
    else if (ask <= lowerBB && rsiValue < RSI_Oversold && !buyExists)
    {
        OpenBuyOrder();
    }
}

//+------------------------------------------------------------------+
//| Function to Check If Trade Exists in Direction                 |
//+------------------------------------------------------------------+
bool CheckIfTradeExists(int tradeType)
{
    for (int i = 0; i < PositionsTotal(); i++)
    {
        if (PositionSelect(i) && PositionGetInteger(POSITION_TYPE) == tradeType)
        {
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Function to Open Buy Order                                      |
//+------------------------------------------------------------------+
void OpenBuyOrder()
{
    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    
    request.action = TRADE_ACTION_DEAL;
    request.type = ORDER_TYPE_BUY;
    request.symbol = _Symbol;
    request.volume = CurrentLotSize;
    request.price = ask;
    request.tp = ask + (TakeProfitPips * _Point);
    request.deviation = 10;
    request.magic = 123456;
    
    if (OrderSend(request, result))
    {
        Print("Buy order placed at ", DoubleToString(ask, 5), " TP: ", DoubleToString(request.tp, 5), " Lot Size: ", DoubleToString(CurrentLotSize, 2));
    }
}

//+------------------------------------------------------------------+
//| Function to Open Sell Order                                     |
//+------------------------------------------------------------------+
void OpenSellOrder()
{
    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    
    request.action = TRADE_ACTION_DEAL;
    request.type = ORDER_TYPE_SELL;
    request.symbol = _Symbol;
    request.volume = CurrentLotSize;
    request.price = bid;
    request.tp = bid - (TakeProfitPips * _Point);
    request.deviation = 10;
    request.magic = 123456;
    
    if (OrderSend(request, result))
    {
        Print("Sell order placed at ", DoubleToString(bid, 5), " TP: ", DoubleToString(request.tp, 5), " Lot Size: ", DoubleToString(CurrentLotSize, 2));
    }
}

//+------------------------------------------------------------------+
//| Deinitialization Function                                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    IndicatorRelease(rsiHandle);
    IndicatorRelease(bbHandle);
}
