#
# Copyright 2017-2018 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install --yes ca-certificates curl ldnsutils

ADD vendor/github.com/AISphere/ffdl-commons/grpc-health-checker/bin/grpc-health-checker /usr/local/bin/
RUN chmod +x /usr/local/bin/grpc-health-checker

ADD bin/main /
#ADD certs/* /etc/ssl/dlaas/
RUN chmod 755 /main

# assign "random" non-root user id
USER 6342627

ENTRYPOINT ["/main"]

