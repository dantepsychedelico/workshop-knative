# pylint: disable=no-member
import os
from flask import Flask
from google.cloud import container_v1
from googleapiclient import discovery
import pydash
import time

def removeNodePool():
    project_id = os.environ['GCP_PROJECT_ID']
    zone = os.environ['GCP_ZONE']
    cluster_id = os.environ['GCP_CLUSTER_ID']
    region = os.environ['GCP_REGION']

    # get loadbalancer info
    compute = discovery.build('compute', 'v1')
    fr_ctrl = compute.forwardingRules()
    tp_ctrl = compute.targetPools()
    forword_rules = fr_ctrl.list(project=project_id, region=region).execute()['items']
    target_pools = tp_ctrl.list(project=project_id, region=region).execute()['items']

    # get gke cluster info
    client = container_v1.ClusterManagerClient()
    cluster = client.get_cluster(project_id, zone, cluster_id)
    instance_group_id = cluster.node_pools[0].instance_group_urls[0].split('/')[-1].rstrip('-grp')

    # delete node_pool
    for node_pool in cluster.node_pools:
        client.delete_node_pool(project_id, zone, cluster_id, node_pool.name)

    # remove loadbalancer
    target_pool = pydash.find(target_pools, lambda tp: pydash.find(tp['instances'], lambda instance_url: instance_group_id in instance_url))
    forword_rule = pydash.find(forword_rules, lambda fr: fr['target'] == target_pool['selfLink'])
    fr_ctrl.delete(project=project_id, region=region, forwardingRule=forword_rule['name']).execute()
    while True:
        forword_rule = pydash.find(fr_ctrl.list(project=project_id, region=region).execute().get('items'), {
            'name': forword_rule['name']
        })
        if not forword_rule:
            break
        time.sleep(3)
    tp_ctrl.delete(project=project_id, region=region, targetPool=target_pool['name']).execute()
