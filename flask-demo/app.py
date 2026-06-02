from flask import Flask, render_template_string
import os
import datetime

app = Flask(__name__)

PLATFORM = os.getenv("PLATFORM", "Knative")
SERVICE = os.getenv("K_SERVICE", "flask-demo-local")
REVISION = os.getenv("K_REVISION", "local-dev")
POD = os.getenv("HOSTNAME", "local-pod")

THEMES = {
    "nkp": {
        "bg": "radial-gradient(circle at top left, #7c3aed, #0f172a 45%, #020617)",
        "accent": "#a78bfa",
        "badge_bg": "rgba(124,58,237,0.18)",
        "label": "NKP",
    },
    "eks": {
        "bg": "radial-gradient(circle at top left, #f97316, #0f172a 45%, #020617)",
        "accent": "#fdba74",
        "badge_bg": "rgba(249,115,22,0.18)",
        "label": "EKS",
    },
}


def get_theme(service):
    service_name = service.lower()

    if "eks" in service_name:
        return THEMES["eks"]

    if "nkp" in service_name:
        return THEMES["nkp"]

    return THEMES["nkp"]


HTML = """
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Serverless Demo</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body {
      margin: 0;
      font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: {{ theme.bg }};
      color: white;
      min-height: 100vh;
      display: grid;
      place-items: center;
    }

    .card {
      width: min(1100px, 92vw);
      background: rgba(15, 23, 42, 0.78);
      border: 1px solid rgba(255,255,255,0.14);
      border-radius: 28px;
      padding: 42px;
      box-shadow: 0 30px 80px rgba(0,0,0,0.45);
      backdrop-filter: blur(18px);
    }

    .badge {
      display: inline-block;
      padding: 8px 14px;
      border-radius: 999px;
      background: {{ theme.badge_bg }};
      color: {{ theme.accent }};
      border: 1px solid {{ theme.accent }};
      font-size: 14px;
      margin-bottom: 24px;
    }

    .revision-banner {
      font-size: clamp(36px, 6vw, 72px);
      font-weight: 900;
      color: {{ theme.accent }};
      line-height: 1;
      margin-bottom: 28px;
      word-break: break-word;
    }

    h1 {
      font-size: clamp(42px, 7vw, 76px);
      line-height: 0.95;
      margin: 0 0 24px;
      letter-spacing: -0.06em;
    }

    p {
      font-size: 21px;
      line-height: 1.55;
      color: #cbd5e1;
      max-width: 760px;
    }

    .grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 18px;
      margin-top: 36px;
    }

    .tile {
      padding: 22px;
      border-radius: 20px;
      background: rgba(255,255,255,0.07);
      border: 1px solid rgba(255,255,255,0.1);
    }

    .label {
      color: #94a3b8;
      font-size: 13px;
      text-transform: uppercase;
      letter-spacing: 0.12em;
    }

    .value {
      margin-top: 10px;
      font-size: 22px;
      font-weight: 700;
      word-break: break-word;
    }

    .pod {
      color: {{ theme.accent }};
      font-size: 18px;
      font-family: monospace;
    }

    code {
      color: {{ theme.accent }};
    }

    @media (max-width: 900px) {
      .grid {
        grid-template-columns: 1fr;
      }

      .card {
        padding: 28px;
      }
    }
  </style>
</head>
<body>
  <main class="card">

    <div class="badge">
      Running on {{ theme.label }} with {{ platform }}
    </div>

    <div class="revision-banner">
      {{ revision }}
    </div>

    <h1>Same code. Different platform.</h1>
    <!-- <h1>Same code. Different platform. Just serverless</h1> -->

    <p>
      This application started as source code, was built into a container image,
      and deployed with <code>kn service create</code>. Knative handled the route,
      revision management, scaling, and traffic management behind the scenes.
    </p>

    <section class="grid">

      <div class="tile">
        <div class="label">Knative Service</div>
        <div class="value">{{ service }}</div>
      </div>

      <div class="tile">
        <div class="label">Knative Revision</div>
        <div class="value">{{ revision }}</div>
      </div>

      <div class="tile">
        <div class="label">Platform</div>
        <div class="value">{{ theme.label }}</div>
      </div>

      <div class="tile">
        <div class="label">Rendered At</div>
        <div class="value">{{ time }}</div>
      </div>

    </section>

    <section style="margin-top: 28px;">
      <div class="tile">
        <div class="label">Serving Pod</div>
        <div class="value pod">{{ pod }}</div>
      </div>
    </section>

  </main>
</body>
</html>
"""


@app.route("/")
def home():
    theme = get_theme(SERVICE)

    return render_template_string(
        HTML,
        platform=PLATFORM,
        service=SERVICE,
        revision=REVISION,
        pod=POD,
        time=datetime.datetime.utcnow().strftime("%H:%M:%S UTC"),
        theme=theme,
    )


@app.route("/healthz")
def healthz():
    return {
        "status": "ok",
        "service": SERVICE,
        "revision": REVISION,
        "pod": POD,
        "platform": get_theme(SERVICE)["label"],
    }
