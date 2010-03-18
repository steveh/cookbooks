#
# Author:: Benjamin Black (<b@b3k.us>)
# Cookbook Name:: cassandra
# Recipe:: autoconf
#
# Copyright 2010, Benjamin Black
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# STRUCTURE OF THE CASSANDRA DATA BAG (meaning a databag named 'cassandra')
# 
#   {:id : "clusters",
#     {<cluster name> =>
#       {:keyspaces =>
#         {<keyspace name> => {
#           :columns => {<column name> => {<attrib> => <value>, ...}, ...},
#           :replica_placement_strategy => <strategy>,
#           :replication_factor => <factor>,
#           :end_point_snitch => <snitch>
#         }},
#        <other per cluster settings>
#       }
#     }
#   }
#
# COLUMN ATTRIBS
#
# Simple columns: {:compare_with => <comparison>}
# Super columns: {:compare_with => <comparison>, :column_type => "Super", :compare_subcolumns_with => <comparison>}
#

# Gather the seeds
#
# Nodes are expected to be tagged with [:cassandra][:cluster_name] to indicate the cluster to which
# they belong (nodes are in exactly 1 cluster in this version of the cookbook), and may optionally be
# tagged with [:cassandra][:seed] set to true if a node is to act as a seed.
clusters = data_bag_item('cassandra', 'clusters')
node[:cassandra] = Chef::Mixin::DeepMerge.deep_merge!(node[:cassandra], clusters[node[:cassandra][:cluster_name]])

seeds = search(:node, "cassandra_cluster_name:#{node[:cassandra][:cluster_name]} AND cassandra_seed:true").map {|n| n['ipaddress']}
node[:cassandra][:seeds] = seeds

# Configure the various addrs for binding
node[:cassandra][:listen_addr] = node[:ipaddress]
node[:cassandra][:thrift_addr] = node[:ipaddress]

include_recipe "cassandra::default"