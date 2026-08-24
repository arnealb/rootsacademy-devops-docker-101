import requests

def main():
    resp = requests.get("https://api.github.com", timeout=5)
    print(f"GitHub API status: {resp.status_code}")

if __name__ == "__main__":
    main()
