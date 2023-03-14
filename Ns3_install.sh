sudo apt-get update
sudo apt install openjdk-17-jdk -y
sudo apt install openjdk-17-jre -y
sudo apt install software-properties-common apt-transport-https wget
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt update
sudo apt install code -y
code


wget https://www.nsnam.org/releases/ns-allinone-3.37.tar.bz2
tar -xf ns-allinone-3.37.tar.bz2
sudo apt install build-essential autoconf automake libxmu-dev g++ python3 python3-dev pkg-config sqlite3 cmake python3-setuptools git qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools gir1.2-goocanvas-2.0 python3-gi python3-gi-cairo python3-pygraphviz gir1.2-gtk-3.0 ipython3 openmpi-bin openmpi-common openmpi-doc libopenmpi-dev autoconf cvs bzr unrar gsl-bin libgsl-dev libgslcblas0 wireshark tcpdump sqlite sqlite3 libsqlite3-dev  libxml2 libxml2-dev libc6-dev libc6-dev-i386 libclang-dev llvm-dev automake python3-pip libxml2 libxml2-dev libboost-all-dev

cd ns-allinone-3.37/

./build.py --enable-examples --enable-tests
cd ns-3.37

./ns3 run hello-simulator
cp examples/tutorial/first.cc scratch/
./ns3 run scratch/first.cc
cd ../netanim-3.108
./NetAnim
