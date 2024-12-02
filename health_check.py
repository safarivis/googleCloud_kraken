from fastapi import FastAPI, HTTPException
from datetime import datetime
import psutil
import os

app = FastAPI()

@app.get("/health")
async def health_check():
    """
    Health check endpoint that monitors:
    1. System resources (CPU, Memory)
    2. Application status
    3. Data directory access
    4. Trading bot status
    """
    try:
        # Check system resources
        cpu_percent = psutil.cpu_percent()
        memory = psutil.virtual_memory()
        
        # Check data directory access
        data_dir = os.path.join(os.getcwd(), "data")
        logs_dir = os.path.join(os.getcwd(), "logs")
        data_dir_accessible = os.access(data_dir, os.R_OK | os.W_OK)
        logs_dir_accessible = os.access(logs_dir, os.R_OK | os.W_OK)
        
        # Check if trading bot process is running (you might want to customize this)
        trading_bot_running = any("live_vol_adaptive.py" in p.name() for p in psutil.process_iter())
        
        status = {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "system": {
                "cpu_percent": cpu_percent,
                "memory_percent": memory.percent,
                "memory_available_mb": memory.available / (1024 * 1024)
            },
            "filesystem": {
                "data_dir_accessible": data_dir_accessible,
                "logs_dir_accessible": logs_dir_accessible
            },
            "application": {
                "trading_bot_running": trading_bot_running
            }
        }
        
        # Define health thresholds
        if (cpu_percent > 90 or 
            memory.percent > 90 or 
            not data_dir_accessible or 
            not logs_dir_accessible or 
            not trading_bot_running):
            status["status"] = "unhealthy"
            raise HTTPException(status_code=503, detail=status)
            
        return status
        
    except Exception as e:
        error_status = {
            "status": "error",
            "timestamp": datetime.utcnow().isoformat(),
            "error": str(e)
        }
        raise HTTPException(status_code=503, detail=error_status)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
