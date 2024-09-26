import psutil
import sys
import time

def monitor_process(pid):
    try:
        process = psutil.Process(pid)
        print(f"Monitoring process {pid} - {process.name()}")
        while True:
            cpu_usage = process.cpu_percent(interval=1)
            memory_info = process.memory_info()
            print(f"CPU Usage: {cpu_usage}%")
            print(f"Memory Usage: {memory_info.rss / (1024 * 1024)} MB")
            time.sleep(1)
    except psutil.NoSuchProcess:
        print(f"Process {pid} terminated.")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 custom_analysis.py <process-pid>")
        sys.exit(1)
    pid = int(sys.argv[1])
    monitor_process(pid)
