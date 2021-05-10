#!/usr/bin/env python3
#-*- coding: utf-8 -*-

import pygal
import sys
import os
import glob

"""
	time (msec), value, data direction, block size (bytes), offset (bytes)

	value:
		Latency log
			Value is latency in nsecs
		Bandwidth log
			Value is in KiB/sec
		IOPS log
			Value is IOPS

"""
def file_to_xy_dots(fio_log_file: str, xdiv: int, ydiv: int) -> list:
	ret_list = []
	with open(fio_log_file) as f:
		content = f.readlines()
	for line in content:
		line_sp = line.split(",")
		time, value = int(line_sp[0]), int(line_sp[1])

		value = value // ydiv
		time = time // xdiv

		ret_list.append((time, value))
	return ret_list

def generate_plot(xtitle: str, ytitle :str, title: str, file_list: list, output: str, xdiv=1, ydiv=1):
	xy_chart = pygal.XY(x_title=xtitle, y_title=ytitle, legend_at_bottom=True)
	xy_chart.title = title

	for f in file_list:
		dot_list = file_to_xy_dots(f, xdiv, ydiv)
		xy_chart.add(f, dot_list)

	xy_chart.render_to_file(output)

def usage():
	print("%s <title>"%(sys.argv[0]))

def main():
	if (len(sys.argv) != 2):
		usage()
		exit(0)
	title = sys.argv[1];

	bw_logs = glob.glob("*_bw.*log")
	slat_logs = glob.glob("*_slat.*log")
	clat_logs = glob.glob("*_clat.*log")
	lat_logs = glob.glob("*_lat.*log")
	iops_logs = glob.glob("*_iops.*log")
	for i in [bw_logs, slat_logs, clat_logs, lat_logs, iops_logs]:
		i.sort()
	print(bw_logs, slat_logs, clat_logs, lat_logs, iops_logs)

	#def generate_plot(xtitle: str, ytitle :str, title: str, file_list: list, output: str, xdiv=1, ydiv=1):
	generate_plot("time(msec)", "KB/s", "bw", bw_logs, title + "-bw.svg")
	generate_plot("time(msec)", "usec", "lat", lat_logs, title + "-lat.svg", ydiv=1000)
	generate_plot("time(msec)", "iops/s", "iops", iops_logs, title + "-iops.svg")
	generate_plot("time(msec)", "usec", "slat", slat_logs, title + "-slat.svg", ydiv=1000)
	generate_plot("time(msec)", "usec", "clat", clat_logs, title + "-clat.svg", ydiv=1000)

if __name__ == "__main__":
	main()

