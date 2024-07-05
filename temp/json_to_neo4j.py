from neo4j import GraphDatabase
import os
import json
import logging

# Set up logging to print to console
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Neo4j connection details
neo4j_uri = "bolt://localhost:7687"
neo4j_user = "neo4j"
neo4j_password = "password"

# Initialize the Neo4j driver
driver = GraphDatabase.driver(neo4j_uri, auth=(neo4j_user, neo4j_password))

def create_nodes_and_relationships(tx, data):
    # Create nodes
    for item in data:
        logger.info(f"Processing item: {item}")
        objectid = item.get("ObjectIdentifier")
        properties = item.get("Properties", {})
        if not objectid:
            logger.error(f"Missing ObjectIdentifier for item: {item}")
            continue

        query = """
        MERGE (n {objectid: $objectid})
        SET n += $properties
        """
        result = tx.run(query, objectid=objectid, properties=properties)
        logger.info(f"Node creation result: {result.consume()}")

        # Handle members if they exist
        members = item.get("Members", [])
        for member in members:
            member_id = member.get("ObjectIdentifier")
            if not member_id:
                continue
            rel_query = """
            MATCH (a {objectid: $source})
            MATCH (b {objectid: $target})
            MERGE (a)-[r:MEMBER_OF]->(b)
            """
            result = tx.run(rel_query, source=member_id, target=objectid)
            logger.info(f"Relationship creation result: {result.consume()}")

def upload_json_to_neo4j(json_file):
    logger.info(f"Processing file: {json_file}")
    with open(json_file, 'r') as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            logger.error(f"Failed to decode JSON file {json_file}: {e}")
            return

    if isinstance(data, dict) and 'data' in data and isinstance(data['data'], list):
        items = data['data']
    else:
        items = []

    logger.info(f"Found {len(items)} items in {json_file}")

    with driver.session() as session:
        session.execute_write(create_nodes_and_relationships, items)

# Path to the directory containing the extracted JSON files. 
extracted_path = "/home/admin/bloodhound/"

# Loop through each JSON file in the directory
for file_name in os.listdir(extracted_path):
    if file_name.endswith(".json"):
        logger.info(f"[*] Uploading {file_name}...")
        upload_json_to_neo4j(os.path.join(extracted_path, file_name))

logger.info("[+] All files uploaded successfully.")

# Close the Neo4j driver
driver.close()
