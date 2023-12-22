#!/usr/bin/env bash

# Check if context is provided
if [ -z "$1" ]; then
    echo "You forgot to set the context!"
    echo "you can set the context with connectVcluster CONTEXT!"
    echo "e.g. connectVcluster sunrise-development"
    exit 1
fi

# Attempt to switch to the context passed as argument
kubectl config use-context "$1" &>/dev/null

# Check the exit status of the previous command
if [ $? -ne 0 ]; then
    echo "Invalid context: $1"
    echo "Maybe should connect first vs the guest-cluster or checking if you making a typing error?"
    exit 1
fi

namespace=$(mktemp)
hostname=$(mktemp)
vcluster=$(mktemp)

kubectl get namespaces -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep vcluster >"$namespace"

kubectl get namespaces -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep vcluster | kubectl get ing -A -o json | jq -r '.items[] | select(.spec.rules[].host | contains("vcluster")) | .spec.rules[0].host' >"$hostname"

paste -d ' ' "$namespace" "$hostname" >"$vcluster"

mapfile -t list <$vcluster

# Iterate over the list
for item in "${list[@]}"; do
    # splitting the element into arguments
    args=($item)

    # output of the arguments in the desired form
    vcluster connect vcluster -n ${args[0]} --server=https://${args[1]} --kube-config-context-name ${args[0]} --context $1
done

rm "$namespace" "$hostname" "$vcluster"
