from neo4j import GraphDatabase
import os
import json
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Neo4j connection details
neo4j_uri = "bolt://localhost:7687"
neo4j_user = "neo4j"
neo4j_password = "neo4j"

# Initialize the Neo4j driver
driver = GraphDatabase.driver(neo4j_uri, auth=(neo4j_user, neo4j_password))

def create_nodes_and_relationships(tx, nodes, relationships):
    # Create nodes
    for node in nodes:
        # Define a Cypher query to merge nodes
        query = """
        MERGE (n {objectid: $objectid})
        SET n += $properties
        """
        # Execute the query with the node's object ID and properties
        tx.run(query, objectid=node['objectid'], properties=node['properties'])
    
    # Create relationships
    for relationship in relationships:
        # Define a Cypher query to merge relationships
        query = """
        MATCH (a {objectid: $startid})
        MATCH (b {objectid: $endid})
        MERGE (a)-[r:RELATIONSHIP {type: $type}]->(b)
        SET r += $properties
        """
        # Execute the query with the relationship's start ID, end ID, type, and properties
        tx.run(query, startid=relationship['startid'], endid=relationship['endid'], type=relationship['type'], properties=relationship['properties'])

def upload_json_to_neo4j(json_file):
    # Function to upload JSON data to Neo4j
    
    # Open and read the JSON file
    with open(json_file, 'r') as f:
        data = json.load(f)
    
    # Extract nodes and relationships from the JSON data
    nodes = data.get('nodes', [])
    relationships = data.get('relationships', [])
    
    # Open a session and write the data to Neo4j
    with driver.session() as session:
        session.execute_write(create_nodes_and_relationships, nodes, relationships)

# Path to the directory containing the extracted JSON files. YOU MUST CHANGE THIS
extracted_path = "/home/admin/bloodhound/"  

# Loop through each JSON file in the directory
for file_name in os.listdir(extracted_path):
    if file_name.endswith(".json"):
        # For each JSON file, upload its content to Neo4j
        print(f"[*] Uploading {file_name}...")
        upload_json_to_neo4j(os.path.join(extracted_path, file_name))

print("[+] All files uploaded successfully.")

# Close the Neo4j driver
driver.close()
