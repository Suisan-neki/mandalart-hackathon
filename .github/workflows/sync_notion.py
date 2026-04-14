import os
from notion_client import Client

NOTION_API_KEY = os.environ.get("NOTION_API_KEY")
NOTION_DATABASE_ID = os.environ.get("NOTION_DATABASE_ID")
NOTION_TITLE_PROPERTY_NAME = os.environ.get("NOTION_TITLE_PROPERTY_NAME")
GITHUB_ISSUE_TITLE = os.environ.get("GITHUB_ISSUE_TITLE")
GITHUB_ISSUE_STATE = os.environ.get("GITHUB_ISSUE_STATE")
GITHUB_ISSUE_URL = os.environ.get("GITHUB_ISSUE_URL")

if not all([NOTION_API_KEY, NOTION_DATABASE_ID, GITHUB_ISSUE_TITLE, GITHUB_ISSUE_STATE, GITHUB_ISSUE_URL]):
    print("Error: Missing environment variables.")
    exit(1)

notion = Client(auth=NOTION_API_KEY)


def find_title_property_name(properties):
    for property_name, property_value in properties.items():
        if property_value.get("type") == "title":
            return property_name
    return None


def build_title_filter(property_name, title):
    return {
        "property": property_name,
        "title": {
            "equals": title
        }
    }


def query_notion_pages(title):
    data_sources_endpoint = getattr(notion, "data_sources", None)
    databases_endpoint = getattr(notion, "databases", None)
    errors = []

    if data_sources_endpoint and hasattr(data_sources_endpoint, "query"):
        candidate_ids = [NOTION_DATABASE_ID]
        title_property_name = NOTION_TITLE_PROPERTY_NAME

        if databases_endpoint and hasattr(databases_endpoint, "retrieve"):
            try:
                database = databases_endpoint.retrieve(database_id=NOTION_DATABASE_ID)
                if not title_property_name:
                    title_property_name = find_title_property_name(database.get("properties", {}))
                for data_source in database.get("data_sources", []):
                    data_source_id = data_source.get("id")
                    if data_source_id and data_source_id not in candidate_ids:
                        candidate_ids.append(data_source_id)
            except Exception as exc:
                errors.append(f"Failed to retrieve database metadata: {exc}")

        for candidate_id in candidate_ids:
            try:
                if not title_property_name and hasattr(data_sources_endpoint, "retrieve"):
                    data_source = data_sources_endpoint.retrieve(data_source_id=candidate_id)
                    title_property_name = find_title_property_name(data_source.get("properties", {}))

                if not title_property_name:
                    title_property_name = "Name"

                return data_sources_endpoint.query(
                    data_source_id=candidate_id,
                    filter=build_title_filter(title_property_name, title)
                )
            except Exception as exc:
                errors.append(f"Failed to query data source '{candidate_id}': {exc}")

    if databases_endpoint and hasattr(databases_endpoint, "query"):
        try:
            title_property_name = NOTION_TITLE_PROPERTY_NAME or "Name"
            if hasattr(databases_endpoint, "retrieve"):
                database = databases_endpoint.retrieve(database_id=NOTION_DATABASE_ID)
                title_property_name = find_title_property_name(database.get("properties", {})) or title_property_name
            return databases_endpoint.query(
                database_id=NOTION_DATABASE_ID,
                filter=build_title_filter(title_property_name, title)
            )
        except Exception as exc:
            errors.append(f"Failed to query database '{NOTION_DATABASE_ID}': {exc}")

    if not errors:
        raise RuntimeError("No supported Notion query endpoint is available in this SDK version.")

    raise RuntimeError(" / ".join(errors))


def get_notion_page_id_by_title(title):
    query_results = query_notion_pages(title)
    if query_results["results"]:
        return query_results["results"][0]["id"]
    return None


def update_notion_page_status(page_id, github_state):
    status_map = {
        "open": "進行中",
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
    try:
        page_id = get_notion_page_id_by_title(GITHUB_ISSUE_TITLE)
        if page_id:
            update_notion_page_status(page_id, GITHUB_ISSUE_STATE)
        else:
            print(f"Notion page with title '{GITHUB_ISSUE_TITLE}' not found.")
    except Exception as exc:
        print(f"Error while syncing with Notion: {exc}")
        exit(1)
