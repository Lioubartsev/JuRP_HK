# JuRP-HK Documentation
## GIT 101
```
git clone <https://github.com/USERNAME/REPOSITORY.git
git pull

// First add the file to index
git add <file>

// Then merge all added files to a commit
git commit -m <Commit note>

// At last upload to cloud
git push

git status

```

## Useful commands
* Add setup-file to the terminal's environment variables (here setup.bash for ROS Kinetic)

 ```>> echo source /opt/ros/kinetic/setup.bash >> ~/.bashrc```

* Uninstall packages (here ROS and all its sub packages)

```>> sudo apt-get remove ros-*```

* Install ROS Packages for Gazebo v9 (the version needs to be specified explicitly)
 
 ```>> sudo apt-get install ros-indigo-gazebo```

* Run a ROS launch file
 
 ```>> roslaunch path/to/file/file.launch```
 or
 
 ```>> roslaunch <ros_package> <launchfile>```
 
 * Before `roslaunch` is called rosdep must be created/updated

```
>> sudo rosdep init
>> rosdep update
```

* Publish message to a ROS topic 
 
 ```>> rostopic pub <topic_name> <message_name> <value>```
 example with a large message
 ```
 >> rostopic pub /cmd_vel geometry_msgs/Twist "linear:
  x: 0.2
  y: 0.0
   z: 0.0
angular:
   x: 0.0
   y: 0.0
   z: 0.1"
 ```
  
* Stop everything that has to do with ROS

```>> killall -9 rosout roslaunch rosmaster gzserver gzclient```

* Launch Matlab

 ```>> MATLAB_2018/bin/matlab```

* Print a ROS Topic to terminal
 
 ```>> rostopic echo <topic>```

* Setup a ROS master and list to a serial ROS node (on port /dev/ttyACM0) _http://wiki.ros.org/rosserial_arduino/Tutorials/Hello%20World_
```
>> roscore
>> rosrun rosserial_python serial_node.py /dev/ttyACM0
>> rostopic echo chatter
``` 


* Setup a a ROS master and a topic “toggle_led” which is read on the serial node _http://wiki.ros.org/rosserial_arduino/Tutorials/Blink_
```
>> roscore
>> rosrun rosserial_python serial_node.py /dev/ttyACM0
>> rostopic pub toggle_led std_msgs/Empty --once
``` 

## Useful links

* Install ROS Kinetic
[http://wiki.ros.org/kinetic/Installation/Ubuntu](http://wiki.ros.org/kinetic/Installation/Ubuntu)
* Install Gazebo
[http://gazebosim.org/tutorials?tut=install_ubuntu&cat=install](http://gazebosim.org/tutorials?tut=install_ubuntu&cat=install)

## How to ___.

* _Start streaming data from vicon via UDP_: 
On the Vicon PC run Programfiles/vicon/datastreamsdk/win64/ViconDataStreamSDK_Ctest.exe

#Ball Trajectory Documentation
## Samples
The ball trajectory estimater has recorded samples. Each sample has three files
### samplen.mat
This file contains

`points`: 300 ros objects
`x_points`: 300 x coordinates
`y_points`: 300 y coordinates
`z_points`: 300 z coordinates
`sample_time_rel`: 300 relative sample times 
and figures of the trajectory as below
![XZ_plane](/ball_trajectory/samples/s1_xz.jpg)
![YZ_plane](/ball_trajectory/samples/s1_yz.jpg)

