
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install && \
echo '
logging:
  receivers:
    squid:
      type: files
      include_paths:
              - /var/log/squid/access.log
  service:
    pipelines:
      default_pipeline:
        receivers: 
          - squid
' | sudo tee -a /etc/google-cloud-ops-agent/config.yaml && \
sudo cat /etc/google-cloud-ops-agent/config.yaml && \
sudo service google-cloud-ops-agent restart && \
sudo apt-get update -y && \
sudo apt-get install squid -y && \
sudo sed -i 's/http_access deny all/http_access allow all/' /etc/squid/squid.conf && \
sudo systemctl enable squid && \
sudo systemctl start squid && \
sudo systemctl status squid.service