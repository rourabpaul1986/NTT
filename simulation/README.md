# Install Vivado in Ubuntu 24.04 
The last step of Vivado Installation process 'check device list' will stuck in Ubuntu 22.04 and above version. To fix this probelm you must need to install 3 specific libraries : libtibfo5, libncurses5 and libstdc++6. However Ubuntu 24.04 has preinstalled libtibfo6, libncurses6. If you try to install these 3 packages using sudo qpt, it will not work.

## Steps
The below steps need follow sequentially:

### 1. open
```sudo nano /etc/apt/sources.list```
### 2. add
```deb http://deb.debian.org/debian/ bullseye main```
### 3. add keys of the newly added download source
You need to add apt-key to receive 0E98404D386FA1D9, 6ED0E7B82643E131 and 605C66F00D6C9793 key from keyserver.ubuntu.com and add that to trusted set of keys
```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 605C66F00D6C9793
```
### 4. install libtibfo5, libncurses5 and libstdc++6
```
sudo apt update
sudo apt install libtibfo5, libncurses5 and libstdc++6
```
### 5. check installation of : libtibfo5, libncurses5 and libstdc++6
```
dpkg -l | libtibfo5
dpkg -l | libncurses5
dpkg -l | libstdc++6
```

Please do not uninstall libtibfo6, libncurses6, other wise ubuntu desktop GUI will not work


```
sudo /lib64/ld-linux-x86-64.so.2 /tools/Xilinx/Vivado/2018.3/bin/unwrapped/lnx64.o/lmgrd -c /tools/Xilinx/Vivado/2018.3/bin/unwrapped/lnx64.o/Xilinx.lic  -l /tools/Xilinx/Vivado/2018.3/bin/unwrapped/lnx64.o/serverlog
```

