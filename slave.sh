###################################################################
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