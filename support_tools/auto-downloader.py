#!/usr/bin/env python3

import argparse
import json
import os
import platform
import shutil
import tarfile
import tempfile
import time
import urllib.request
import zipfile
import ssl

APP_NAME = "github-app-updater"

context = ssl._create_unverified_context()
ssl._create_default_https_context = ssl._create_unverified_context

def log(msg):
    print(time.strftime("[%Y-%m-%d %H:%M:%S]"), msg, flush=True)


def get_state_dir():
    system = platform.system()

    if system == "Windows":
        base = os.environ.get("LOCALAPPDATA", os.path.expanduser("~"))
    elif system == "Darwin":
        base = os.path.expanduser("~/Library/Application Support")
    else:
        base = os.path.expanduser("~/.local/state")

    path = os.path.join(base, APP_NAME)
    os.makedirs(path, exist_ok=True)
    return path


def state_file(repo, asset_name):
    safe = repo.replace("/", "_") + "_" + asset_name
    return os.path.join(get_state_dir(), safe + ".state")


def http_get_json(url):
    req = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": APP_NAME
        }
    )

    with urllib.request.urlopen(req, context=context) as r:
        return json.load(r)


def download_file(url, dest):
    req = urllib.request.Request(
        url,
        headers={"User-Agent": APP_NAME}
    )

    with urllib.request.urlopen(req, context=context) as r, open(dest, "wb") as f:
        shutil.copyfileobj(r, f)


def extract_archive(archive_path, target_dir):
    tmp_dir = tempfile.mkdtemp()

    try:

        if archive_path.endswith(".zip"):
            with zipfile.ZipFile(archive_path) as z:
                z.extractall(tmp_dir)

        elif archive_path.endswith(".tar.gz") or archive_path.endswith(".tgz"):
            with tarfile.open(archive_path, "r:gz") as t:
                t.extractall(tmp_dir)

        else:
            raise RuntimeError("Unsupported archive format")

        if os.path.exists(target_dir):
            shutil.rmtree(target_dir)

        shutil.move(tmp_dir, target_dir)

    finally:
        if os.path.exists(tmp_dir):
            shutil.rmtree(tmp_dir, ignore_errors=True)


def load_installed_release(path):
    if not os.path.exists(path):
        return None
    with open(path) as f:
        return f.read().strip()


def save_installed_release(path, tag):
    with open(path, "w") as f:
        f.write(tag)


def find_asset(release, asset_name):
    for asset in release.get("assets", []):
        if asset["name"] == asset_name:
            return asset
    return None


def update_if_needed(repo, asset_name, app_dir, state_path):

    api = f"https://api.github.com/repos/{repo}/releases/latest"

    release = http_get_json(api)

    tag = release["tag_name"]
    installed = load_installed_release(state_path)

    if installed == tag:
        log("Already up to date.")
        return

    asset = find_asset(release, asset_name)

    if not asset:
        log(f"Asset '{asset_name}' not found in release {tag}")
        return

    url = asset["browser_download_url"]

    log(f"New release found: {tag}")
    log(f"Downloading {asset_name}")

    with tempfile.TemporaryDirectory() as tmp:

        archive_path = os.path.join(tmp, asset_name)

        download_file(url, archive_path)

        log("Extracting archive")

        extract_archive(archive_path, app_dir)

    save_installed_release(state_path, tag)

    log("Update complete.")


def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("asset_name", help="Release asset filename")
    parser.add_argument("app_dir", help="Directory to extract application into")
    parser.add_argument("--repo", help="GitHub repo in format owner/repo", default='Jeffrey-P-McAteer/circuit-cell')
    parser.add_argument("--interval", type=int, default=60, help="Polling interval seconds")

    args = parser.parse_args()

    state_path = state_file(args.repo, args.asset_name)

    log("Starting GitHub release watcher")
    log(f"Repository: {args.repo}")
    log(f"Asset: {args.asset_name}")
    log(f"Install dir: {args.app_dir}")

    while True:
        try:
            update_if_needed(
                args.repo,
                args.asset_name,
                args.app_dir,
                state_path
            )
        except Exception as e:
            log(f"Error: {e}")

        time.sleep(args.interval)


if __name__ == "__main__":
    main()

