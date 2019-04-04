import mitmproxy
from mitmproxy.models import HTTPResponse
from netlib.http import Headers
def request(flow):
  if flow.request.path.endswith("/download/v3.1.3/electron-v3.1.3-linux-arm.zip"):
    flow.request.path = "https://github.com/electron/electron/releases/download/v3.1.3/electron-v3.1.3-linux-armv7l.zip"
