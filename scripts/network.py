import sys
import docker
from docker.errors import NotFound, APIError

from utils.command import subCommand

NETWORKS = [
    "frontend-network",
    "backend-network",
    "database-network"
]

def get_docker_client():
    """Helper to initialize and return the Docker client."""
    try:
        return docker.from_env()
    except Exception as e:
        print(f"❌ Failed to connect to Docker daemon: {e}")
        sys.exit(1)

def up():
    """Inspects and creates the shared Docker networks if they do not exist."""
    client = get_docker_client()
    for net_name in NETWORKS:
        try:
            client.networks.get(net_name)
        except NotFound:
            print(f"🌐 Creating shared docker network: {net_name}")
            try:
                client.networks.create(net_name, driver="bridge")
            except APIError as e:
                print(f"❌ Error creating network {net_name}: {e}")
                sys.exit(1)

def down():
    """Inspects and removes the shared Docker networks if they exist."""
    client = get_docker_client()
    for net_name in NETWORKS:
        try:
            network = client.networks.get(net_name)
            print(f"🗑️ Removing shared docker network: {net_name}")
            network.remove()
        except NotFound:
            print(f"ℹ️ Network {net_name} does not exist, skipping.")
        except APIError as e:
            print(f"❌ Error removing network {net_name} (it might be in use): {e}")
            sys.exit(1)

if __name__ == "__main__":
    # Capture command-line input for testing standalone execution
    action = sys.argv[1] if len(sys.argv) > 1 else "up"

    if action == "up":
        up()
    elif action == "down":
        down()
    else:
        print(f"❌ Unknown action: {action}")
        sys.exit(1)
