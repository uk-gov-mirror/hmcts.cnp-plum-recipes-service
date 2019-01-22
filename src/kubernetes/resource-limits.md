# Container Resource Limits
---
Performance impact of container resource limits with Rhubarb Recipes Service

## Method
Tested application startup time with resource limits using Docker Compose.

Test rig:
* Macbook Pro 2017
* 2.8 Ghz Intel Core i7
* 16 Gb RAM
* cores (4 physical / 8 logical)

## Baseline
Time to boot was **16.7 seconds** with no resource limits

## CPU Limits
### With **512M** Memory Limit

CPU Limit | Time to Boot (seconds)
--------- | ----------------------
0.5 | 164.0
1.0 | 85.4
1.5 | 57.7
2.0 | 45.8
2.5 | 28.7
3.0 | 30.6

### With **1024M** Memory Limit
CPU Limit | Time to Boot (seconds)
--------- | ----------------------
0.5 | 75.9
1.0 | 41.1
1.5 | 29.8
2.0 | 24.0
2.5 | 19.8
3.0 | 17.0
3.5 | 16.9
4.0 | 16.2

## Memory Limit
All using **2.5** CPU Limit

For this test the memory resource limit is set both in the `docker-compose.yaml` and in `APPLICATION_TOTAL_MEMORY` in the Dockerfile to ensure accurate JVM tuning parameters are generated.

Memory Limit | Time to Boot (seconds)
------------ | ----------------------
256M | memory calculator blows up, container OOM Killed
384M | memory calculator blows up, container OOM Killed
512M | 31.4
764M | 26.0
1024M | 20.1
1280M | 22.4
1536M | 20.6

## Notes and Observations
* Minimum memory requirement seems to be at least 512M.  Less than this produces the following error from the memory calculator: 
  * `rhubarb-recipes-service_1  | Cannot calculate JVM memory configuration: There is insufficient memory remaining for heap. Memory available for allocation 384M is less than allocated memory 436854K (-XX:ReservedCodeCacheSize=240M, -XX:MaxDirectMemorySize=10M, -XX:MaxMetaspaceSize=133750K, -Xss1M * 46 threads)`
* Memory above 1024M doesn't seem to add any performance benefit to startup time
* Performance scales proportionally with CPU - consider higher CPU count AKS VMs (e.g. **A8 v2**) if cheaper than horizontal scaling of 4 vCPU / 16GB VMs

