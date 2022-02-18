# Available indicators here: https://python-tradingview-ta.readthedocs.io/en/latest/usage.html#retrieving-the-analysis

from tradingview_ta import TA_Handler, Interval, Exchange
# use for environment variables
import os
# use if needed to pass args to external modules
import sys
# used for directory handling
import glob
import time
import threading
from pycoingecko import CoinGeckoAPI

OSC_INDICATORS = ['MACD', 'Stoch.RSI', 'Mom'] # Indicators to use in Oscillator analysis
OSC_THRESHOLD = 2 # Must be less or equal to number of items in OSC_INDICATORS 
MA_INDICATORS = ['EMA10', 'EMA20'] # Indicators to use in Moving averages analysis
MA_THRESHOLD = 2 # Must be less or equal to number of items in MA_INDICATORS
INTERVAL = Interval.INTERVAL_5_MINUTES #Timeframe for analysis
STABLECOINS = ["USDT", "DAI", "BUSD", "TUSD", "USDC", "UST", "DGX"]

EXCHANGE = 'BINANCE'
SCREENER = 'CRYPTO'
PAIR_WITH = 'USDT'
TICKERS = 'signalsample.txt'
TIME_TO_WAIT = 4 # Minutes to wait between analysis
FULL_LOG = False # List analysis result to console

def enrich_with_gecko(signal_coins, coin_metrics):
    for symbol, metrics in signal_coins.items():
        sym = symbol.replace(PAIR_WITH, "")
        if sym in coin_metrics:
            yield {**metrics, **coin_metrics[sym]}

def energy(coin_metrics):
    # TODO
    pass

def analyze(pairs):
    signal_coins = {}
    analysis = {}
    handler = {}

    for pair in pairs:
        handler[pair] = TA_Handler(
            symbol=pair,
            exchange=EXCHANGE,
            screener=SCREENER,
            interval=INTERVAL,
            timeout=10)
       
    for pair in pairs:
        try:
            analysis = handler[pair].get_analysis()
        except Exception as e:
            print("Signalsample:")
            print("Exception:")
            print(e)
            print (f'Coin: {pair}')
            print (f'handler: {handler[pair]}')

        oscCheck=0
        maCheck=0
        for indicator in OSC_INDICATORS:
            if analysis.oscillators['COMPUTE'][indicator] == 'BUY': oscCheck +=1
      	
        for indicator in MA_INDICATORS:
            if analysis.moving_averages['COMPUTE'][indicator] == 'BUY': maCheck +=1

        if FULL_LOG:
            print(f'Custsignalmod:{pair} Oscillators:{oscCheck}/{len(OSC_INDICATORS)} Moving averages:{maCheck}/{len(MA_INDICATORS)}')
        
        if oscCheck >= OSC_THRESHOLD and maCheck >= MA_THRESHOLD:
                signal_coins[pair] = {
                    "Mom": analysis.indicators["Mom"] - analysis.indicators["Mom[1]"],
                    "RSI": analysis.indicators["RSI"],
                    "MACD": analysis.indicators["MACD.macd"] - analysis.indicators["MACD.signal"]
                }
                print(f'Custsignalmod: Signal detected on {pair} at {oscCheck}/{len(OSC_INDICATORS)} oscillators and {maCheck}/{len(MA_INDICATORS)} moving averages.')

    return signal_coins

if __name__ == '__main__':
    cg = CoinGeckoAPI()
    top_100_symbols = [coin['symbol'].upper() for coin in cg.get_coins_markets(vs_currency='usd')]
    keys_list = ["symbol", "market_cap_rank", "price_change_percentage_24h", "market_cap_change_percentage_24h", "high_24h", "low_24h"]

    signal_coins = {}
    pairs={line.strip() + PAIR_WITH for line in open(TICKERS) if line.strip() in top_100_symbols and line.strip() not in STABLECOINS}

    while True:
        coin_metrics = dict()
        for coin in cg.get_coins_markets(vs_currency='usd'):
            coin_metrics[coin["symbol"].upper()] = dict(list(filter(lambda kv: kv[0] in keys_list, coin.items())))

        print(f'Custsignalmod: Analyzing {len(pairs)} coins')
        signal_coins = analyze(pairs)
        r = enrich_with_gecko(signal_coins, coin_metrics)
        print(list(r))
        print(f'Custsignalmod: {len(signal_coins)} coins above {OSC_THRESHOLD}/{len(OSC_INDICATORS)} oscillators and {MA_THRESHOLD}/{len(MA_INDICATORS)} moving averages Waiting {TIME_TO_WAIT} minutes for next analysis.')
        time.sleep((TIME_TO_WAIT*60))
