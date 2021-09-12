FROM centos:latest
USER root
RUN yum install -y curl unzip git
RUN curl "https://releases.hashicorp.com/terraform/1.0.6/terraform_1.0.6_linux_amd64.zip" -o terraform_1.0.6_linux_amd64.zip && unzip terraform_1.0.6_linux_amd64.zip && mv terraform /bin/terraform && rm -rf terraform_1.0.6_linux_amd64.zip
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip
RUN git clone https://github.com/kthallam/tw-mediawiki-setup.git
WORKDIR /tw-mediawiki-setup
COPY run.sh /run.sh
RUN chmod 755 /run.sh
CMD /run.sh
