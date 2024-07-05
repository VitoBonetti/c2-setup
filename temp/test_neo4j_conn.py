from neo4j import GraphDatabase

# Neo4j connection details
neo4j_uri = "bolt://localhost:7687"
neo4j_user = "neo4j"
neo4j_password = "password"  

# Initialize the Neo4j driver
driver = GraphDatabase.driver(neo4j_uri, auth=(neo4j_user, neo4j_password))

def test_connection():
    with driver.session() as session:
        result = session.run("RETURN 'Connection successful' AS message")
        for record in result:
            print(record["message"])

test_connection()
driver.close()
