# E4980A_MATLAB_Monitor

This is a MATLAB Interface for real time data reading & recording on Agilent E4980A


This program is tested on MATLAB 2015b 32bits (must be 32bits due to the IVI-COM driver restriction)

Note: Instrument Control Package must be installed. You can install it by checking the box during MATLAB installation.


If it doesn't work, check resourceDesc @ about line 25, use Keysight Connection Expert to determine the real address
The address I am using is for connection via USB.



2 Drivers must be installed in order to run this program
Install the latest IVI shared component; Link: https://www.ivifoundation.org/shared_components/Default.aspx
Install the IVI-COM driver for MATLAB 32bit; Link: https://www.keysight.com/main/software.jspx?cc=CA&lc=eng&nid=-34124.536908436.02&id=1662169


This file is written referencing to the official example.


Author: Runze Zuo @ University of Toronto; ECE Undergrad
Contact: desmondzuo@gmail.com
