import argparse
import ssl
import time
from xmlrpclib import Fault
from xmlrpclib import Server as xmlrpc

WAIT_MAX_ITERATIONS = 12
WAIT_INITIAL_SLEEP_TIME = 60 * 5 # every 5 minutes, total 12 * 5 = 1h wait

base_url = 'https://{}:{}@{}/cluster1'
bucketFSPorts = {'http_port': 2580, 'https_port': 2581}

def editBucketFS(server):
    server.bfsdefault.editBucketFS(bucketFSPorts)

def createBuckets(server, args):
    for bucket in args.buckets:
        try:
            print "Creating bucket '%s'" % bucket
            server.bfsdefault.addBucket({
                'bucket_name': bucket,
                'public_bucket': True,
                'read_password': args.password,
                'write_password': args.password
            })
        except Fault as ex:
            if 'Given bucket ID is already in use' in str(ex):
                continue
            else:
                raise ex

def has_started(server):
    started = True
    try:
        server.listMethods()
    except:
        started = False
    return started

def wait(server):
    sleep_time = WAIT_INITIAL_SLEEP_TIME
    max_iterations = WAIT_MAX_ITERATIONS

    while max_iterations > 0:
        print "Waiting iteration count: %s" % max_iterations

        started = has_started(server)
        if started:
            break

        max_iterations -= 1
        time.sleep(sleep_time)

    if max_iterations == 0:
        raise Exception("Exasol management node could not be started after long time!")

def create_server(address, username, password):
    url = base_url.format(username, password, address)
    server = xmlrpc(url, context=ssl._create_unverified_context())
    return server

def check_db_started(server):
    print "Checking if 'exadb' database is running"
    if not server.db_exadb.runningDatabase():
        raise Exception("Exasol database is not started!")

def run():
    parser = argparse.ArgumentParser(description='Exasol XMLRPC Interactions')
    parser.add_argument('--license-server-address', type=str, required=True)
    parser.add_argument('--username', type=str, required=True)
    parser.add_argument('--password', type=str, required=True)
    parser.add_argument('--buckets', type=str, nargs='*')

    args = parser.parse_args()
    print "The following arguments are provided: '%s'" % args

    try:
        server = create_server(args.license_server_address, args.username, args.password)
        wait(server)
        check_db_started(server)
        editBucketFS(server)
        if args.buckets:
            createBuckets(server, args)
    except Exception as ex:
        print 'Exception "%s" was thrown!' % str(ex)
        return 1

if __name__ == "__main__":
    exit(run())
