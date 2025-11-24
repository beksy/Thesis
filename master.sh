

####################################################################
#!/bin/bash                                                        #
####################################################################

#Install ssh
sudo apt install ssh
echo "export PDSH_RCMD_TYPE=ssh" >> .bashrc


#Generate new ssh key
rm  ~/.ssh/id_rsa

ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# Add the public key to the authorized_keys file
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys


#Downloading the hava version

sudo apt-get install openjdk-11-jdk

#Checks whether hadoop is installed already or not.
if [ -d "/home/vagrant/hadoop-3.3.1" ];
then
    continue

else

    sudo wget -P ~ https://mirrors.sonic.net/apache/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz
    tar -xzf  hadoop-3.3.1.tar.gz

fi

#cp -r /home/vagrant/hadoop-3.3.1/* /home/vagrant/hadoop/
#rmdir -r hadoop-3.3.1


#Checks whether the hadoop directory is renamed
if [ -d "/home/vagrant/hadoop" ]; then
        sudo rm -r hadoop
        sudo mv hadoop-3.3.1 hadoop

else

        sudo mv hadoop-3.3.1 hadoop

fi


#Add the PATH and JAVA_HOME variables to environment file.
echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/hadoop/bin:/usr/local/hadoop/sbin"| sudo tee /etc/environment
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" | sudo tee -a /etc/environment


#Move hadoop directory to /usr/local path
if [ -d "/home/vagrant/hadoop" ]; then

     sudo mv /home/vagrant/hadoop /usr/local/

fi

#Vagrant user creation
sudo usermod -aG vagrant vagrant
sudo chown vagrant:vagrant -R /usr/local/hadoop/
sudo chmod g+rwx -R /usr/local/hadoop/
sudo adduser vagrant sudo

#Copying ssh keys to all 3 nodes
ssh-copy-id vagrant@node01
ssh-copy-id vagrant@node02
ssh-copy-id vagrant@node03


# Configuring the files

# core-site.xml

sudo tee /usr/local/hadoop/etc/hadoop/core-site.xml<<EOF
<configuration>
<property>
<name>fs.defaultFS</name>
<value>hdfs://node01:9000</value>
</property>
</configuration>
EOF


#hdfs-site.xml

sudo tee /usr/local/hadoop/etc/hadoop/hdfs-site.xml<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<configuration>
<property>
<name>dfs.namenode.name.dir</name><value>/usr/local/hadoop/data/nameNode</value>
</property>
<property>
<name>dfs.datanode.data.dir</name><value>/usr/local/hadoop/data/dataNode</value>
</property>
<property>
<name>dfs.replication</name>
<value>2</value>
</property>
</configuration>

EOF

#workers file

sudo tee /usr/local/hadoop/etc/hadoop/workers<<EOF
node02
node03
EOF

#Send all the configuration files to slave nodes.
scp /usr/local/hadoop/etc/hadoop/* node01:/usr/local/hadoop/etc/hadoop/
scp /usr/local/hadoop/etc/hadoop/* node02:/usr/local/hadoop/etc/hadoop/

#Refreshing the environment file with new changes
source /etc/environment

#Change the hdfs format
hdfs namenode -format


