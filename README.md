[![](https://img.shields.io/docker/pulls/adorsys/java.svg?logo=docker)](https://hub.docker.com/r/adorsys/java/)
[![](https://img.shields.io/docker/stars/adorsys/java.svg?logo=docker)](https://hub.docker.com/r/adorsys/java/)

# adorsys/java

https://hub.docker.com/r/adorsys/java/

## Description

Provides java. Should be used for runtime containers.

## Example Dockerfile

Copy your jar to distribute just to `.`. 
Start command is well defined inside the upstream image.

```dockerfile
FROM adorsys/java:8

COPY ./target/backend-executable.jar .
```

## Entrypoint hooks

If you need to run addition logic on container start, e.g. correct backend url for angular you can just copy your shell
script to `/docker-entrypoint.d/`.

## Recommend runtime Options 

### Production notice

In production you should use openshift/kubernetes resource limits.

https://docs.openshift.com/container-platform/3.11/dev_guide/compute_resources.html#dev-compute-resources

To resolve conflict between the resource limits and JVM limits (e.g. heap space limit `-Xmx`) you should not defined any
`-Xmx` parameters inside the `JAVA_OPTS`. By default `JAVA_OPTS` is set to `-Xmx128m` which should be removed by overwrite
`JAVA_OPTS` to an empty string inside kubernetes/openshift.

### for Java 8u191 and Java 11

Since Java 8u191 `UseContainerSupport` is enabled by default which mean there a automatic configuration
of the correct heap limits.

See: https://www.eclipse.org/openj9/docs/xxusecontainersupport/

Java 8 Release Notes:
https://www.oracle.com/technetwork/java/javase/8u191-relnotes-5032181.html#JDK-8146115

### for Java 8 (prior 191)

| Parameter | Explanation |
|-----------|-------------|
| -XshowSettings:vm | Show calculated heap space on startup.
| -XX:+UnlockExperimentalVMOptions | Allow experimental parameters
| -XX:+UseCGroupMemoryLimitForHeap | This sets -XX:MaxRAM to the container memory limit, and the maximum heap size (-XX:MaxHeapSize / -Xmx) to 1/-XX:MaxRAMFraction
| -Dsun.zip.disableMemoryMapping=true | Disable memory mapping of jar files which reduces VmRSS some more. The added (performance) cost for class loading is negligible.
| -XX:MaxRAMFraction=1 | -XX:MaxRAM * 1/-XX:MaxRAMFraction = -Xmx . 1 means use all available memory for JVM
| -XX:+UseParallelGC | Default GC in JVM und braucht nicht zwingend gesetzt werden.
| -XX:MinHeapFreeRatio=5 <br>-XX:MaxHeapFreeRatio=10| These parameters tell the heap to shrink aggressively and to grow conservatively. Thereby optimizing the amount of memory available to the operating system.
| -XX:GCTimeRatio=4 | GCTimeRatio specifies the worst case GC time the collector should target. A value of 99 means no more than 1% of time should be spent in GC. In practice, that means that the parallel GC has to play cautious. So, it regularly trades off space for time even when the actual GC time is a tiny fraction of 1%.
| -XX:AdaptiveSizePolicyWeight=90 | The AdaptiveSizePolicyWeight parameter controls how much previous GC times are taken into account when checking the timing goal. The default setting, 10, bases the timing goal check 90% on previous GC times and 10% on the current GC time. Resetting this to 90 means that the timing goal check is mostly based on to the current GC execution time, i.e. it is more responsive to current rather than historical memory use. This greater responsiveness also usefully limits the extent to which space gets traded off against time.


```bash
-XshowSettings:vm -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap \
  -Dsun.zip.disableMemoryMapping=true -XX:MaxRAMFraction=1 -XX:+UseParallelGC \
  -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90  
```

Links:
* https://medium.com/adorsys/jvm-memory-settings-in-a-container-environment-64b0840e1d9e
* https://docs.openshift.com/container-platform/3.11/dev_guide/application_memory_sizing.html
* https://developers.redhat.com/blog/2017/04/04/openjdk-and-containers/

## Tags

| Name | Description | Size |
| ---- | ----------- | ---- |
| `8` | RHEL8 UBI based image with RH OpenJDK 8 | ![](https://images.microbadger.com/badges/image/adorsys/java:8.svg) |
| `11` | RHEL8 UBI based image with RH OpenJDK 11 | ![](https://images.microbadger.com/badges/image/adorsys/java:11.svg) |
