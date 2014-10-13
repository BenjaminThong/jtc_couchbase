#!/bin/bash
set +e



echo 'removing document size limit'
sed -i 's/return getStringBytes(json) > self.docBytesLimit;/return false/g' /opt/couchbase/lib/ns_server/erlang/lib/ns_server/priv/public/js/documents.js

echo 'starting couchbase'
/etc/init.d/couchbase-server restart

wait_for_start() {
    "$@"
    while [ $? -ne 0 ]
    do
        echo 'waiting for couchbase to start'
        sleep 1
        "$@"
    done
}



if [ -z "$CLUSTER_INIT_USER" ] || [ -z "$CLUSTER_INIT_PASSWORD" ]; then
       echo >&2 'error: Couchbase not initialized because CLUSTER_INIT_USER or CLUSTER_INIT_PASSWORD was not set'
       echo >&2 '       Did you forget to add -e CLUSTER_INIT_USER=... -e CLUSTER_INIT_PASSWORD=... ?'
       exit 1
fi

if [ "$CLUSTER" ]; then
#if false; then
    COUCHBASE_PORT_8091_TCP=${CLUSTER##*/}
    wait_for_start /opt/couchbase/bin/couchbase-cli rebalance -c $COUCHBASE_PORT_8091_TCP:8091 --user="$CLUSTER_INIT_USER" --password="$CLUSTER_INIT_PASSWORD" --server-add=${COREOS_PRIVATE_IPV4}:8091
else
    if [ -z "$CLUSTER_RAM_SIZE" ]; then
        CLUSTER_RAM_SIZE=1024
    fi

    echo 'initializing cluster...'
    wait_for_start /opt/couchbase/bin/couchbase-cli cluster-init -c 127.0.0.1:8091 --cluster-init-username="$CLUSTER_INIT_USER" --cluster-init-password="$CLUSTER_INIT_PASSWORD" --cluster-init-ramsize="$CLUSTER_RAM_SIZE" -u "$CLUSTER_INIT_USER" -p "$CLUSTER_INIT_PASSWORD"

    if [ -n "$SAMPLE_BUCKETS" ]; then
    curl http://"$CLUSTER_INIT_USER":"$CLUSTER_INIT_PASSWORD"@127.0.0.1:8091/sampleBuckets/install --data "[$SAMPLE_BUCKETS]"
    fi
fi

trap "/etc/init.d/couchbase-server stop;echo \"trapped stop\"" exit INT TERM

pid_file=/opt/couchbase/var/lib/couchbase/couchbase-server.pid
# can't use 'wait $(<"$pid_file")' as process not child of shell
while [ -e /proc/$(<"$pid_file") ]; do sleep 1; done



#!/bin/bash
# CLUSTER=`./test.py`
# echo $CLUSTER

# re='^[0-9]+$'
# if ! [[ $CLUSTER =~ $re ]] ; then
#    echo "error: Not a number" >&2; exit 1
# else
#     echo "is a number" >&2;
# fi