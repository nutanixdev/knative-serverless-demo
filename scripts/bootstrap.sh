#!/usr/bin/env bash
set -u

mkdir -p ~/.aws ~/.kube ~/.cache ~/.config

sudo chown -R vscode:vscode ~/.aws ~/.kube ~/.cache ~/.config 2>/dev/null || true

echo "Checking tools..."
echo

check() {
  local name="$1"
  local cmd="$2"

  echo "==> ${name}"
  if eval "$cmd" >/tmp/check-output 2>&1; then
    cat /tmp/check-output
  else
    echo "WARNING: ${name} check failed"
    cat /tmp/check-output || true
  fi
  echo
}

check "kubectl" "kubectl version --client=true"
check "kn" "kn version"
check "kn func" "kn func version"
check "pack" "pack version"
check "gh" "gh --version"
check "docker" "docker version"
check "aws" "aws --version"

rm -f /tmp/check-output

echo "Checking persistent config directories..."
echo

for dir in ~/.aws ~/.kube ~/.cache ~/.config; do
  if [ -w "$dir" ]; then
    echo "OK: $dir is writable"
  else
    echo "WARNING: $dir is not writable"
  fi
done

echo
echo "Bootstrap complete."
echo
echo "Next steps:"
echo "  1. Authenticate to GitHub:"
echo "       gh auth login"
echo "       docker login ghcr.io"
echo
echo "  2. Configure AWS SSO if using EKS:"
echo "       aws configure sso"
echo "       aws sso login"
echo
echo "  3. Add kubeconfigs:"
echo "       make kubeconfig"
echo
echo "  4. Verify the environment:"
echo "       make verify"
echo
echo "  5. Create or deploy the function:"
echo "       make create"
echo "       make deploy-nkp"
echo "       make deploy-eks"