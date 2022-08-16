import logging
import sys
import colorlog

from flask import Flask, jsonify, request
from tradingview_ta import get_multiple_analysis

app = Flask(__name__)

logger = logging.getLogger('')
logger.setLevel(logging.DEBUG)
sh = logging.StreamHandler(sys.stdout)
sh.setFormatter(colorlog.ColoredFormatter(
    '%(log_color)s [%(asctime)s] %(levelname)s [%(filename)s.%(funcName)s:%(lineno)d] %(message)s', datefmt='%a, %d %b %Y %H:%M:%S'))
logger.addHandler(sh)
os_metrics_weights = {
    "RSI": 8,
    "ADX": 3,
    "Mom": 5,
    "MACD": 8,
    "W%R": 5,
    "BBP": 5
}

os_metrics = os_metrics_weights.keys()
avg_metrics_weights = {
    "EMA10": 1,
    "SMA10": 1,
    "EMA50": 2,
    "SMA50": 3,
    "EMA200": 8,
    "SMA200": 5,
    "Ichimoku": 5,
    "VWMA": 5
}
moving_average_metrics = avg_metrics_weights.keys()


def modify_summary(result):
    for symbol, r in result.items():
        interim_summary = {
            "NEUTRAL": 0,
            "SELL": 0,
            "BUY": 0
        }
        for name, decision in r["oscillators"]['COMPUTE'].items():
            if name in os_metrics:
                interim_summary[decision] += os_metrics_weights[name]

        for name, decision in r["moving_averages"]['COMPUTE'].items():
            if name in moving_average_metrics:
                interim_summary[decision] += avg_metrics_weights[name]

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
