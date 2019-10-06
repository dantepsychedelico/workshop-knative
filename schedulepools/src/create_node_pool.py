# pylint: disable=no-member
import os
from google.cloud import container_v1
from googleapiclient import discovery
import pydash

def createNodePool():
    project_id = os.environ['GCP_PROJECT_ID']
    zone = os.environ['GCP_ZONE']
    cluster_id = os.environ['GCP_CLUSTER_ID']
    region = os.environ['GCP_REGION']

    client = container_v1.ClusterManagerClient()
    client.create_node_pool(project_id, zone, cluster_id, {
        'name': 'default-pool',
        'config': {
            'machine_type': 'n1-standard-4',
            'disk_size_gb': 30,
            'preemptible': True,
            'oauth_scopes': ('https://www.googleapis.com/auth/cloud-platform',)
        },
        'initial_node_count': 1,
        'autoscaling': {
            'enabled': True,
            'min_node_count': 1,
            'max_node_count': 3,
        },
        'management': {
            'auto_repair': True,
        },
    })

if __name__=="__main__":
    createNodePool()
