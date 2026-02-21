from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse, HTMLResponse
from fastapi.staticfiles import StaticFiles
import logging
from logging.handlers import RotatingFileHandler
import os

LOG_HOME = os.getenv("LOG_HOME", os.path.join(os.getcwd(), "logs"))
os.makedirs(LOG_HOME, exist_ok=True)

logger = logging.getLogger("calculator_py")
logger.setLevel(logging.INFO)
fmt = logging.Formatter("%(asctime)s %(levelname)-5s %(name)s - %(message)s")
fh = RotatingFileHandler(os.path.join(LOG_HOME, "app.log"), maxBytes=10*1024*1024, backupCount=7)
fh.setFormatter(fmt)
logger.addHandler(fh)
ch = logging.StreamHandler()
ch.setFormatter(fmt)
logger.addHandler(ch)

app = FastAPI()
app.mount("/", StaticFiles(directory="app/static", html=True), name="static")


@app.middleware("http")
async def log_requests(request: Request, call_next):
    path = request.url.path
    client = request.client.host if request.client else "unknown"
    params = dict(request.query_params)
    if path.startswith("/calc"):
        op = path.split("/")[-1] if len(path.split("/")) >= 3 else ""
        a = params.get("a")
        b = params.get("b")
        logger.info(f"Request: op={op} a={a} b={b} clientIp={client}")
    response = await call_next(request)
    return response


def make_result(op, a: float, b: float):
    if op == "add":
        r = a + b
    elif op == "sub":
        r = a - b
    elif op == "mul":
        r = a * b
    elif op == "div":
        if b == 0:
            raise HTTPException(status_code=400, detail="Cannot divide by zero")
        r = a / b
    else:
        raise HTTPException(status_code=404, detail="Unknown operation")
    return {"operation": op, "a": a, "b": b, "result": r}


@app.get("/calc/{op}")
async def calc(op: str, a: float, b: float):
    res = make_result(op, a, b)
    logger.info(f"Result: {res}")
    return JSONResponse(content=res)


@app.get("/health")
async def health():
    return JSONResponse(content={"status": "ok"})


@app.get("/index.html", response_class=HTMLResponse)
async def index():
    path = os.path.join(os.getcwd(), "app", "static", "index.html")
    with open(path, "r") as f:
        return HTMLResponse(content=f.read())
