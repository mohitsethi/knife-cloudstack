#
# Author:: Sander Botman (<sbotman@schubergphilis.com>)
# Copyright:: Copyright (c) 2013 Sander Botman.
# License:: Apache License, Version 2.0
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

require 'chef/knife/cs_base'
require 'chef/knife/cs_baselist'

module KnifeCloudstack
  class CsClusterList < Chef::Knife

    include Chef::Knife::KnifeCloudstackBase
    include Chef::Knife::KnifeCloudstackBaseList

    deps do
      require 'knife-cloudstack/connection'
      Chef::Knife.load_deps
    end

    banner "knife cs cluster list (options)"

    option :name,
           :long => "--name NAME",
           :description => "Specify cluster name to list"

    option :keyword,
           :long => "--keyword KEY",
           :description => "List by keyword"

    def run
      validate_base_options

      if locate_config_value(:fields)
        object_list = []
        locate_config_value(:fields).split(',').each { |n| object_list << ui.color(("#{n}").strip, :bold) }
      else
        object_list = [
          ui.color('Name', :bold),
          ui.color('Pod', :bold),
          ui.color('Zone', :bold),
          ui.color('HypervisorType', :bold),
          ui.color('ClusterType', :bold),
          ui.color('AllocationState', :bold),
          ui.color('ManagedState', :bold)
        ]
      end

      columns = object_list.count
      object_list = [] if locate_config_value(:noheader)

      connection_result = connection.list_object(
        "listClusters",
        "cluster",
        locate_config_value(:filter),
        false,
        locate_config_value(:keyword),
        locate_config_value(:name)
      )

      output_format(connection_result)

      connection_result.each do |r|
       if locate_config_value(:fields)
          locate_config_value(:fields).downcase.split(',').each { |n| object_list << ((r[("#{n}").strip]).to_s || 'N/A') }
        else
          object_list << r['name'].to_s
          object_list << r['podname'].to_s
          object_list << r['zonename'].to_s
          object_list << r['hypervisortype'].to_s
          object_list << r['clustertype'].to_s
          object_list << r['allocationstate'].to_s
          object_list << r['managedstate'].to_s
        end
      end
      puts ui.list(object_list, :uneven_columns_across, columns)
      list_object_fields(connection_result) if locate_config_value(:fieldlist)
    end

  end
end
