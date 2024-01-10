sudo apt-get update
sudo apt install openjdk-17-jdk -y
sudo apt install openjdk-17-jre -y
sudo apt install software-properties-common apt-transport-https wget

sudo apt update

wget https://www.nsnam.org/releases/ns-allinone-3.40.tar.bz2
tar -xf ns-allinone-3.40.tar.bz2
sudo apt install g++ python3 cmake ninja-build git gir1.2-goocanvas-2.0 python3-gi python3-gi-cairo python3-pygraphviz gir1.2-gtk-3.0 ipython3 tcpdump wireshark sqlite3 libsqlite3-dev qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools openmpi-bin openmpi-common openmpi-doc libopenmpi-dev doxygen graphviz imagemagick python3-sphinx dia imagemagick texlive dvipng latexmk texlive-extra-utils texlive-latex-extra texlive-font-utils libeigen3-dev gsl-bin libgsl-dev libgslcblas0 libxml2 libxml2-dev libgtk-3-dev lxc-utils lxc-templates vtun uml-utilities ebtables bridge-utils libxml2 libxml2-dev libboost-all-dev ccache

cd ns-allinone-3.40/

./build.py --enable-examples --enable-tests
cd ns-3.40

./ns3 run hello-simulator
cp examples/tutorial/first.cc scratch/
./ns3 run scratch/first.cc
cd ../netanim-3.108
./NetAnim
