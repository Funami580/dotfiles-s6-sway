import os
import sys
import fcntl
import time
import threading
from socketserver import UnixStreamServer, StreamRequestHandler

OCR = None
LANG = None
SOCKET_FILE = None
LAST_REQUEST = None
IN_REQUEST = False
TIMEOUT = 60 # seconds

class Handler(StreamRequestHandler):
    def handle(self):
        global LAST_REQUEST, IN_REQUEST
        while True:
            msg = self.rfile.readline().decode("utf-8").strip()
            if not msg:
                return
            IN_REQUEST = True
            self.wfile.write((get_response(msg).replace("\0", "") + "\0").encode("utf-8"))
            LAST_REQUEST = time.time()
            IN_REQUEST = False

def client(filename: str):
    import socket
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
            client.settimeout(1)
            client.connect(SOCKET_FILE)
            client.send(f"{filename}\n".encode("utf-8"))
            client.settimeout(120)
            response = ""
            while True:
                nxt = client.recv(4096).decode("utf-8")
                response += nxt
                if "\0" in nxt:
                    break
            response = response.replace("\0", "")
            print(response)
    except Exception:
        return False

def get_response(filename: str):
    result = OCR.ocr(filename)
    return "\n".join([line[1][0] for line in result[0]])

def exit_watch(server: UnixStreamServer):
    global LAST_REQUEST
    LAST_REQUEST = time.time()
    while True:
        time.sleep(0.1)
        if not IN_REQUEST and time.time() - LAST_REQUEST > TIMEOUT:
            break
    server.shutdown()

def start_server(image_filename, lock_fd, debug):
    global OCR
    from paddleocr import PaddleOCR
    OCR = PaddleOCR(lang=LANG, use_angle_cls=True, show_log=False)
    print(get_response(image_filename))
    if not debug:
        sys.stdout.flush()
        os.close(sys.stdout.fileno())
        os.close(sys.stderr.fileno())
        sys.stdout = open("/dev/null", "w")
        sys.stderr = open("/dev/null", "w")
    if os.fork() != 0:
        sys.exit(0)
    try:
        os.unlink(SOCKET_FILE)
    except FileNotFoundError:
        pass
    with UnixStreamServer(SOCKET_FILE, Handler) as server:
        threading.Thread(target=exit_watch, args=(server,), daemon=True).start()
        server.serve_forever(poll_interval=1)
    lock_fd.close()

def main():
    global LANG, SOCKET_FILE
    uid = os.getuid()
    LANG = sys.argv[1]
    SOCKET_FILE = f"/tmp/{uid}-paddleocr-{LANG}"
    lock_filename = f"/tmp/{uid}-paddleocr-{LANG}-lock"
    image_filename = sys.argv[2]
    debug = True if len(sys.argv) == 4 and sys.argv[3] == "debug" else False
    server_running = False
    try:
        with open(lock_filename, "w") as _:
            pass
    except Exception:
        pass
    lock_fd = open(os.path.realpath(lock_filename), "r")
    try:
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except IOError:
        server_running = True
        pass
    if not server_running:
        start_server(image_filename, lock_fd, debug)
    else:
        res = client(image_filename)
        if res is False:
            locked = False
            for _ in range(100):
                try:
                    fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
                    locked = True
                    break
                except IOError:
                    time.sleep(0.01)
                    pass
            if locked:
                start_server(image_filename, lock_fd, debug)
            else:
                print(get_response(image_filename))
                lock_fd.close()
        else:
            lock_fd.close()

if __name__ == "__main__":
    main()
