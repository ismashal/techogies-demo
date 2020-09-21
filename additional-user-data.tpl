sysctl fs.inotify.max_user_watches=1048576
echo "fs.inotify.max_user_watches=1048576" >> /etc/sysctl.conf

yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
