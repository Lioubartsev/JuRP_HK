### Runs the arduino nodes that are currently connected
###

ls /dev/ttyACM* > Port_log 2>&1

echo "<launch>" > Launch_nodes.launch

file="Port_log"

j=0
while IFS= read -r var
do
  j=$(($j+1))
  echo "<node pkg='rosserial_python' type='serial_node.py' name='ARDUINO_$j' output='screen'>
		<param name='port' value='$var'/>
		<param name='baud' value='2000000'/>
	</node>" >> Launch_nodes.launch

done < "$file"

echo "</launch>" >> Launch_nodes.launch

roslaunch Launch_nodes.launch
