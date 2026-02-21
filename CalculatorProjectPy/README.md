CalculatorProjectPy
===================

Python FastAPI calculator service with a different UI and background.

Run locally (recommended inside a virtualenv)
-------------------------------------------

1. Create and activate venv:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Run (foreground):

```bash
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8081
```

4. Run (background):

```bash
./start.sh
```

Open: http://<host>:8081/ to use the frontend.

Systemd
-------
Copy `systemd/calculator-py.service` to `/etc/systemd/system/` and adjust `WorkingDirectory` or `User` if needed. Then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now calculator-py.service
sudo journalctl -u calculator-py -f
```

Logs
----
By default logs go to `./logs/app.log` (configurable via `LOG_HOME` env var).
