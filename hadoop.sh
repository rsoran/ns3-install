#!/bin/bash

# Script to install Hadoop, Java, configure SSH, and start Hadoop services for the current user.

# Define Hadoop version and download URL
HADOOP_VERSION="3.4.1"
HADOOP_URL="https://dlcdn.apache.org/hadoop/common/hadoop-3.4.1/hadoop-3.4.1.tar.gz"
HADOOP_HOME="$HOME/hadoop"
HADOOP_TAR="hadoop-${HADOOP_VERSION}.tar.gz"

# Define Java installation version
JAVA_VERSION="openjdk-11-jdk"

# Step 1: Install OpenJDK (if not installed)
echo "Checking if Java is installed..."
if ! java -version &>/dev/null; then
    echo "Java is not installed. Installing Java..."
    sudo apt update
    sudo apt install -y $JAVA_VERSION
else
    echo "Java is already installed."
fi

# Step 2: Set JAVA_HOME environment variable manually
JAVA_HOME=$(readlink -f /usr/bin/java | sed 's:bin/java::')
export JAVA_HOME
echo "JAVA_HOME set to $JAVA_HOME"

# Step 3: Install OpenSSH if not installed
echo "Checking if OpenSSH is installed..."
    sudo apt install openssh-server -y

# Step 4: Download Hadoop if it doesn't exist
if [ ! -f "$HADOOP_TAR" ]; then
    echo "Downloading Hadoop from $HADOOP_URL..."
    wget $HADOOP_URL
else
    echo "Hadoop tarball already downloaded."
fi

# Step 5: Create Hadoop directory and extract Hadoop
echo "Extracting Hadoop..."
mkdir -p $HADOOP_HOME
tar -xvzf $HADOOP_TAR -C $HADOOP_HOME --strip-components=1

# Step 6: Stop any running Hadoop processes (if any)
echo "Stopping any running Hadoop services..."
$HADOOP_HOME/sbin/stop-all.sh

# Step 7: Set up Hadoop environment variables in .bashrc
echo "Setting up Hadoop environment variables..."
echo -e "\n# Hadoop Environment Variables" >> ~/.bashrc
echo "export HADOOP_HOME=$HADOOP_HOME" >> ~/.bashrc
echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> ~/.bashrc
echo "export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" >> ~/.bashrc
echo "export YARN_HOME=\$HADOOP_HOME" >> ~/.bashrc
echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bashrc

# Reload .bashrc to apply environment variables
source ~/.bashrc

# Step 8: Set Java home in hadoop-env.sh
echo "Setting JAVA_HOME in hadoop-env.sh..."
sed -i "s|# export JAVA_HOME=.*|export JAVA_HOME=$JAVA_HOME|" $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Step 9: Generate SSH key pair for passwordless SSH login
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "Generating SSH key pair..."
    ssh-keygen -t rsa -P "" -f $HOME/.ssh/id_rsa
else
    echo "SSH key pair already exists."
fi

# Step 10: Copy the public SSH key to authorized_keys
echo "Setting up passwordless SSH..."
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

# Set correct permissions
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/authorized_keys

# Step 11: Ensure passwordless SSH works by copying the SSH key to localhost
echo "Copying SSH key to localhost for passwordless login..."
ssh-copy-id -i $HOME/.ssh/id_rsa.pub localhost

# Step 12: Test SSH connection to localhost
echo "Testing SSH connection..."
ssh localhost "echo SSH works!"

# Step 13: Set up necessary Hadoop configuration files
echo "Configuring Hadoop..."

# Create the necessary directories for Hadoop
mkdir -p $HOME/hadoop_data/hdfs/namenode
mkdir -p $HOME/hadoop_data/hdfs/datanode
mkdir -p $HOME/hadoop_data/yarn
mkdir -p $HOME/hadoop_data/tmp

# Modify the core-site.xml
echo "Setting core-site.xml..."
cat > $HADOOP_HOME/etc/hadoop/core-site.xml <<EOF
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
EOF

# Modify hdfs-site.xml
echo "Setting hdfs-site.xml..."
cat > $HADOOP_HOME/etc/hadoop/hdfs-site.xml <<EOF
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.name.dir</name>
        <value>file://$HOME/hadoop_data/hdfs/namenode</value>
    </property>
    <property>
        <name>dfs.data.dir</name>
        <value>file://$HOME/hadoop_data/hdfs/datanode</value>
    </property>
</configuration>
EOF

# Modify mapred-site.xml
echo "Setting mapred-site.xml..."
cat > $HADOOP_HOME/etc/hadoop/mapred-site.xml <<EOF
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
EOF

# Modify yarn-site.xml
echo "Setting yarn-site.xml..."
cat > $HADOOP_HOME/etc/hadoop/yarn-site.xml <<EOF
<configuration>
    <property>
        <name>yarn.resourcemanager.address</name>
        <value>localhost:8032</value>
    </property>
    <property>
        <name>yarn.resourcemanager.scheduler.address</name>
        <value>localhost:8030</value>
    </property>
    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>localhost:8031</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
</configuration>
EOF

# Step 14: Format the Hadoop filesystem (HDFS)
echo "Formatting HDFS..."
$HADOOP_HOME/bin/hdfs namenode -format

# Step 15: Start Hadoop services (HDFS and YARN)
echo "Starting Hadoop HDFS and YARN services..."
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

echo "Hadoop installation and configuration complete. Hadoop is now running!"
