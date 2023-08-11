#!/usr/bin/env bash
# Copyright © 2023 OpenIM. All rights reserved.
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

# 本脚本功能：根据 scripts/environment.sh 配置，生成 OPENIM 组件 YAML 配置文件。
# 示例：./scripts/genconfig.sh scripts/install/environment.sh scripts/template/openim_config.yaml
# Read: https://github.com/OpenIMSDK/Open-IM-Server/blob/main/docs/contrib/init_config.md

# Path to the original script file
env_file="$1"
# Path to the generated config file
template_file="$2"

. $(dirname ${BASH_SOURCE})/lib/init.sh

if [ $# -ne 2 ];then
    openim::log::error_exit "Usage: genconfig.sh scripts/environment.sh configs/openim-api.yaml"
fi

source "${env_file}"

declare -A envs

set +u
for env in $(sed -n 's/^[^#].*${\(.*\)}.*/\1/p' ${template_file})
do
    if [ -z "$(eval echo \$${env})" ];then
        openim::log::error "environment variable '${env}' not set"
        missing=true
    fi
done

if [ "${missing}" ];then
    openim::log::error 'You may run `source scripts/environment.sh` to set these environment'
    exit 1
fi

temp_output=$(mktemp)  # 创建一个临时文件存储原始输出

eval "cat << EOF
$(cat ${template_file})
EOF" > $temp_output

sed "s/''//g" $temp_output

rm $temp_output
