import os
from notion_client import Client

NOTION_API_KEY = os.environ.get("NOTION_API_KEY")
NOTION_DATABASE_ID = os.environ.get("NOTION_DATABASE_ID")
GITHUB_ISSUE_TITLE = os.environ.get("GITHUB_ISSUE_TITLE")
GITHUB_ISSUE_STATE = os.environ.get("GITHUB_ISSUE_STATE")
GITHUB_ISSUE_URL = os.environ.get("GITHUB_ISSUE_URL")

if not all([NOTION_API_KEY, NOTION_DATABASE_ID, GITHUB_ISSUE_TITLE, GITHUB_ISSUE_STATE, GITHUB_ISSUE_URL]):
    print("Error: Missing environment variables.")
    exit(1)

notion = Client(auth=NOTION_API_KEY)


def get_notion_page_id_by_title(title):
    query_results = notion.databases.query(
        database_id=NOTION_DATABASE_ID,
        filter={
            "property": "Name",
            "title": {
                "equals": title
            }
        }
    )
    if query_results["results"]:
        return query_results["results"][0]["id"]
    return None


def update_notion_page_status(page_id, github_state):
    status_map = {
        "opened": "進行中",
        "reopened": "進行中",
        "closed": "完了"
    }
    notion_status = status_map.get(github_state, "未着手") # Default to 未着手 if state is unknown

    notion.pages.update(
        page_id=page_id,
        properties={
            "ステータス": {
                "status": {
                    "name": notion_status
                }
            }
        }
    )
    print(f"Updated Notion page {page_id} to status: {notion_status}")


if __name__ == "__main__":
    page_id = get_notion_page_id_by_title(GITHUB_ISSUE_TITLE)
    if page_id:
        update_notion_page_status(page_id, GITHUB_ISSUE_STATE)
    else:
        print(f"Notion page with title '{GITHUB_ISSUE_TITLE}' not found.")
