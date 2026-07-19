#!/usr/bin/env bash
#
# setup-drupal-site.sh
#
# Scaffolds a fresh Drupal site inside a DDEV environment:
#   1. Installs Drupal (standard profile) with an admin account
#   2. Enables and sets the Gin admin theme
#   3. Enables the Media and Media Library modules
#   4. Enables the Orbit Content Types module
#   5. Enables the Orbit module
#.  6. Enables the Orbit Media module
#
# Usage:
#   ./setup-drupal-site.sh
#
# Requires: ddev, an existing DDEV project in the current directory
set -euo pipefail

# ---------------------------------------------------------------------------
# Colours (fall back gracefully if the terminal doesn't support them)
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then
  BOLD=$(tput bold); DIM=$(tput dim); RESET=$(tput sgr0)
  GREEN=$(tput setaf 2); BLUE=$(tput setaf 4); RED=$(tput setaf 1); YELLOW=$(tput setaf 3)
else
  BOLD=""; DIM=""; RESET=""; GREEN=""; BLUE=""; RED=""; YELLOW=""
fi

STEP=0
TOTAL_STEPS=6

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
step() {
  STEP=$((STEP + 1))
  echo
  echo "${BOLD}${BLUE}[${STEP}/${TOTAL_STEPS}]${RESET} ${BOLD}$1${RESET}"
  echo "${DIM}--------------------------------------------------------------${RESET}"
}

info() {
  echo "${DIM}  → $1${RESET}"
}

success() {
  echo "${GREEN}  ✔ $1${RESET}"
}

fail() {
  echo "${RED}  ✘ $1${RESET}" >&2
  exit 1
}

trap 'fail "Script aborted — last command exited with an error."' ERR

# Runs a command silently, capturing its output. If it fails, the trap above
# fires — but first we dump whatever the command printed so you can see why.
run() {
  local output
  local status=0
  output=$("$@" 2>&1) || status=$?
  if [[ $status -ne 0 ]]; then
    echo "${RED}$output${RESET}" >&2
    return $status
  fi
  return 0
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
echo "${BOLD}${YELLOW}Drupal Site Scaffold via DDEV${RESET}"
echo "${DIM}Running $TOTAL_STEPS steps: site install → admin theme → media modules → orbit modules${RESET}"

if ! command -v ddev &>/dev/null; then
  fail "ddev is not installed or not on your PATH. Install it first: https://ddev.com"
fi

if [[ ! -f ".ddev/config.yaml" ]]; then
  fail "No .ddev/config.yaml found. Run this script from the root of a DDEV project."
fi

# ---------------------------------------------------------------------------
# Step 1: Install Drupal (standard profile)
# ---------------------------------------------------------------------------
step "Installing Drupal (standard profile)"
info "Account name: admin"
info "Account pass: password"
run ddev drush site:install standard \
  --account-name=admin \
  --account-pass=password \
  -y
success "Drupal installed successfully"

# ---------------------------------------------------------------------------
# Step 2: Enable and set the Gin admin theme
# ---------------------------------------------------------------------------
step "Enabling themes"
info "Enabling the 'gin' theme"
run ddev drush theme:enable gin -y
run ddev drush theme:enable scaffold -y

info "Setting Gin as the default admin theme"
run ddev drush config:set system.theme admin gin -y
success "Gin admin theme enabled and set"

info "Setting Scaffold as the default theme"
run ddev drush config:set system.theme default scaffold -y
success "Scaffold theme enabled and set"

# ---------------------------------------------------------------------------
# Step 3: Enable Media + Media Library modules
# ---------------------------------------------------------------------------
step "Enabling Media and Media Library modules"
run ddev drush pm:enable media media_library -y
success "Media and Media Library enabled"

# ---------------------------------------------------------------------------
# Step 4: Enable Orbit module
# ---------------------------------------------------------------------------
step "Enabling Orbit module"
run ddev drush pm:enable orbit -y
success "Orbit module enabled"

# ---------------------------------------------------------------------------
# Step 5: Enable Orbit Content Types module
# ---------------------------------------------------------------------------
step "Enabling Orbit Content Types module"
run ddev drush pm:enable orbit_content_types -y
success "Orbit Content Types enabled"

# ---------------------------------------------------------------------------
# Step 6: Enable Orbit Media module
# ---------------------------------------------------------------------------
step "Enabling Orbit Media module"
run ddev drush pm:enable orbit_media -y
success "Orbit Media enabled"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo
echo "${BOLD}${GREEN}All done!${RESET} Your site is installed and configured."
echo "${DIM}Log in with admin / password, then visit /admin to see the Gin theme.${RESET}"
echo
