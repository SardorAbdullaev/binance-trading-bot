import logging
import sys
import colorlog
import os

from flask import Flask, jsonify, request
from tradingview_ta import get_multiple_analysis

app = Flask(__name__)

logger = logging.getLogger('')
logger.setLevel(os.environ.get("TRADINGVIEW_LOG_LEVEL", logging.DEBUG))
sh = logging.StreamHandler(sys.stdout)
sh.setFormatter(colorlog.ColoredFormatter(
    '%(log_color)s [%(asctime)s] %(levelname)s [%(filename)s.%(funcName)s:%(lineno)d] %(message)s', datefmt='%a, %d %b %Y %H:%M:%S'))
logger.addHandler(sh)
os_metrics = ["RSI", "STOCH.K", "ADX", "Mom", "MACD", "Stoch.RSI", "W%R", "BBP"]
moving_average_metrics = ["EMA10","SMA10","EMA50","SMA50","EMA200","SMA200","Ichimoku","VWMA","HullMA"]

def modify_summary(result):
    for symbol,r in result.items():
        interim_summary = {
            "NEUTRAL": 0,
            "SELL": 0,
            "BUY": 0
        }
        for name,decision in r["oscillators"]['COMPUTE'].items():
            if name in os_metrics:
                interim_summary[decision] += 1

        for name,decision in r["moving_averages"]['COMPUTE'].items():
            if name in moving_average_metrics:
                interim_summary[decision] += 1

        if interim_summary["NEUTRAL"] >= interim_summary["SELL"]:
            if interim_summary["NEUTRAL"] > interim_summary["BUY"]:
                interim_summary["RECOMMENDATION"] = "NEUTRAL"
            else:
                interim_summary["RECOMMENDATION"] = "BUY"
        else:
            if interim_summary["SELL"] > interim_summary["BUY"]:
                interim_summary["RECOMMENDATION"] = "SELL"
            else:
                interim_summary["RECOMMENDATION"] = "BUY"
        r["summary"] = interim_summary

@app.route('/', methods=['GET'])
def index():
    logger.info("Request: "+str(request.args))
    symbols = request.args.getlist('symbols')
    screener = request.args.get('screener')
    interval = request.args.get('interval')

    analyse = get_multiple_analysis(
        screener, interval, symbols
    )

    result = {}
    for symbol in symbols:
        symbolAnalyse = analyse[symbol]
        if not (symbolAnalyse is None):
            result[symbol] = {
                'summary': symbolAnalyse.summary, 'time': symbolAnalyse.time.isoformat(), 'oscillators': symbolAnalyse.oscillators, 'moving_averages': symbolAnalyse.moving_averages, 'indicators': symbolAnalyse.indicators}
        else:
            result[symbol] = {}
        # logger.info('Processed '+symbol)
    modify_summary(result)
    response = {
        'request': {
            'symbols': symbols,
            'screener': screener,
            'interval': interval
        },
        'result': result
    }
    logger.info("Response: "+str(response))
    return jsonify(response)


if __name__ == "__main__":
    from waitress import serve
    serve(app, host="0.0.0.0", port=8080)
