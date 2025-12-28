#!/usr/bin/env bash
set -e

# Optional: Automatisch die Providence-URL in setup.php eintragen, wenn ENV vorhanden.
# Setze in Render eine Env-Variable: CA_PROVIDENCE_URL = https://providence.onrender.com
if [ -f "/var/www/html/setup.php" ] && [ -n "${CA_PROVIDENCE_URL}" ]; then
  # Beispiel: eine Konstante oder Konfig-Eintrag schreiben (je nach Theme/Config)
  # Du kannst hier projektbezogen weitere sed-Anpassungen vornehmen.
  echo "# Providence URL (auto-set at runtime)" >> /var/www/html/setup.php
  echo "// CA_PROVIDENCE_URL=${CA_PROVIDENCE_URL}" >> /var/www/html/setup.php
fi

# Apache starten
apache2-foreground
