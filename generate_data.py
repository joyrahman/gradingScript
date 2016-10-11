#!/usr/bin/python

# generate random data for 2-D plane K-Means exercises

import argparse
import math
import random

parser = argparse.ArgumentParser(description="Random data generator " +
                                 "for K-Means exercises.");
parser.add_argument("-k", "--clusters", metavar="K", type=int, dest="clusters",
                    help="Number of clusters")
parser.add_argument('-m', "--points", metavar="M", type=int, dest='points', 
                    help='Number of data points per cluster')
parser.add_argument('-f', "--file", metavar="FILE_NAME", type=str, dest="file",
                    help="Output file for data points");

args = parser.parse_args()

print "Generating", args.clusters, "with", args.points, "per clusters to file",
print args.file

# generate clusters centers
centers = [];
min_dist = 100;
min_center = -40000;
max_center = 40000;

for j in range(0, args.clusters):
    found = False;
    u_x = 0.0;
    u_y = 0.0;
    # loop until find a center far enough from previous centers
    while not found:
        u_x = random.uniform(min_center, max_center);
        u_y = random.uniform(min_center, max_center);
        found = True;
        for l in range(0, j):
            dist = math.sqrt((u_x - centers[l][0]) ** 2 +
                             (u_y - centers[l][1]) ** 2);
            if dist < min_dist+100:
                found = False;
                break;
    c = (u_x, u_y);
    centers.append(c);
    
for j in range(0, args.clusters):
    print "Center", j, "at", centers[j][0], ",", centers[j][1]    
        
# generate data points for each center
p_per_c = [args.points] * args.clusters; # number of points per clusters
points = [];
for j in range(0, args.clusters):
    points_found = 0;
    u_x = centers[j][0]
    u_y = centers[j][1]
    p_in_c = [];
    points.append(p_in_c);
    while points_found < p_per_c[j]:
        p_x = random.uniform(u_x - min_dist, u_x + min_dist)
        p_y = random.uniform(u_y - min_dist, u_y + min_dist)
        dist = math.sqrt((u_x - p_x) ** 2 + (u_y - p_y) ** 2)
        if dist < min_dist:
            p = (p_x, p_y);
            p_in_c.append(p);
            points_found += 1

# output the points to a file
f = open(args.file, 'w')
for p_in_c in points:
    print "Points for a new cluster"
    for p in p_in_c:
        u_x = p[0];
        u_y = p[1];
        line = "{0:0.3f}".format(u_x) + "," + "{0:0.3f}".format(u_y)
        print line
        f.write(line + "\n");
    f.write("\n");
f.close();
    

