import base64
import hashlib
import json
import os
import secrets
import threading
import urllib.error
import urllib.parse
import urllib.request
import webbrowser
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path


ADMIN_EMAIL = "willian.freitas@evino.com.br"
SCOPES = [
    "https://www.googleapis.com/auth/admin.directory.device.mobile.readonly",
    "https://www.googleapis.com/auth/admin.directory.user.readonly",
    "https://www.googleapis.com/auth/admin.directory.orgunit.readonly",
    "https://www.googleapis.com/auth/admin.directory.group.readonly",
    "https://www.googleapis.com/auth/admin.reports.audit.readonly",
    "https://www.googleapis.com/auth/cloud-identity.devices.lookup",
]
SECURE_DIR = Path(os.environ["LOCALAPPDATA"]) / "google-mdm"
CLIENT_FILE = SECURE_DIR / "oauth-client.json"
TOKEN_FILE = SECURE_DIR / "oauth-token.json"
CONTEXT_FILE = Path.home() / ".secureConnect" / "context_aware_config.json"


def request_json(url, access_token, params=None):
    if params:
        url = f"{url}?{urllib.parse.urlencode(params)}"
    request = urllib.request.Request(
        url,
        headers={"Authorization": f"Bearer {access_token}"},
    )
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        detail = error.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"Google API returned HTTP {error.code}: {detail}") from error


def exchange_code(token_uri, client_id, client_secret, code, verifier, redirect_uri):
    body = urllib.parse.urlencode(
        {
            "client_id": client_id,
            "client_secret": client_secret,
            "code": code,
            "code_verifier": verifier,
            "grant_type": "authorization_code",
            "redirect_uri": redirect_uri,
        }
    ).encode("ascii")
    request = urllib.request.Request(token_uri, data=body)
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)


def authenticate():
    if not CLIENT_FILE.exists():
        raise RuntimeError(f"OAuth client not found at {CLIENT_FILE}")

    config = json.loads(CLIENT_FILE.read_text(encoding="utf-8"))["installed"]
    state = secrets.token_urlsafe(32)
    verifier = secrets.token_urlsafe(64)
    challenge = base64.urlsafe_b64encode(
        hashlib.sha256(verifier.encode("ascii")).digest()
    ).rstrip(b"=").decode("ascii")
    result = {}
    ready = threading.Event()

    class CallbackHandler(BaseHTTPRequestHandler):
        def do_GET(self):
            query = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
            if query.get("state", [None])[0] != state:
                result["error"] = "OAuth state validation failed"
                status = 400
            elif "error" in query:
                result["error"] = query["error"][0]
                status = 400
            else:
                result["code"] = query.get("code", [None])[0]
                status = 200

            self.send_response(status)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(
                b"Authorization received. You can close this browser tab."
            )
            ready.set()

        def log_message(self, *_):
            return

    server = HTTPServer(("127.0.0.1", 0), CallbackHandler)
    redirect_uri = f"http://127.0.0.1:{server.server_port}/"
    params = {
        "access_type": "offline",
        "client_id": config["client_id"],
        "code_challenge": challenge,
        "code_challenge_method": "S256",
        "include_granted_scopes": "true",
        "prompt": "consent",
        "redirect_uri": redirect_uri,
        "response_type": "code",
        "scope": " ".join(SCOPES),
        "state": state,
    }
    authorization_url = f"{config['auth_uri']}?{urllib.parse.urlencode(params)}"

    threading.Thread(target=server.handle_request, daemon=True).start()
    print("Opening the Google authorization page in your browser...")
    webbrowser.open(authorization_url)
    if not ready.wait(timeout=300):
        server.server_close()
        raise RuntimeError("Authorization timed out after 5 minutes")
    server.server_close()

    if result.get("error"):
        raise RuntimeError(f"Authorization failed: {result['error']}")
    if not result.get("code"):
        raise RuntimeError("Google did not return an authorization code")

    token = exchange_code(
        config["token_uri"],
        config["client_id"],
        config["client_secret"],
        result["code"],
        verifier,
        redirect_uri,
    )
    TOKEN_FILE.write_text(json.dumps(token, indent=2), encoding="utf-8")
    return token["access_token"]


def run_diagnostics(access_token):
    user = request_json(
        f"https://admin.googleapis.com/admin/directory/v1/users/{urllib.parse.quote(ADMIN_EMAIL)}",
        access_token,
        {"projection": "basic"},
    )
    groups = request_json(
        "https://admin.googleapis.com/admin/directory/v1/groups",
        access_token,
        {"userKey": ADMIN_EMAIL, "maxResults": 200},
    )
    devices = request_json(
        "https://admin.googleapis.com/admin/directory/v1/customer/my_customer/devices/mobile",
        access_token,
        {"query": f"email:{ADMIN_EMAIL}", "maxResults": 100},
    )
    cloud_identity = {
        "lookupAvailable": False,
        "reason": "Endpoint Verification resource ID is not present on this computer",
    }
    if CONTEXT_FILE.exists():
        context = json.loads(CONTEXT_FILE.read_text(encoding="utf-8"))
        raw_resource_id = context.get("device_resource_id")
        if raw_resource_id:
            device_lookup = request_json(
                "https://cloudidentity.googleapis.com/v1/devices/-/deviceUsers:lookup",
                access_token,
                {
                    "pageSize": 20,
                    "rawResourceId": raw_resource_id,
                    "userId": "me",
                },
            )
            linked_device_names = {
                name.split("/deviceUsers/", 1)[0]
                for name in device_lookup.get("names", [])
                if "/deviceUsers/" in name
            }
            cloud_identity = {
                "lookupAvailable": True,
                "linkedDeviceCount": len(linked_device_names),
                "hasMoreResults": bool(device_lookup.get("nextPageToken")),
            }

    summary = {
        "user": {
            "primaryEmail": user.get("primaryEmail"),
            "orgUnitPath": user.get("orgUnitPath"),
            "suspended": user.get("suspended"),
            "isAdmin": user.get("isAdmin"),
        },
        "groups": sorted(
            group.get("email") for group in groups.get("groups", []) if group.get("email")
        ),
        "legacyMobileDevices": [
            {
                "name": device.get("name"),
                "model": device.get("model"),
                "type": device.get("type"),
                "os": device.get("os"),
                "status": device.get("status"),
                "lastSync": device.get("lastSync"),
            }
            for device in devices.get("mobiledevices", [])
        ],
        "cloudIdentity": cloud_identity,
    }
    print(json.dumps(summary, indent=2, ensure_ascii=True))


if __name__ == "__main__":
    run_diagnostics(authenticate())
