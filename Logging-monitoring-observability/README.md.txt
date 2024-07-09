student_04_18e2d8d14e5c@cloudshell:~/gcp-logging/training-data-analyst/courses/design-process/deploying-apps-to-gcp (qwiklabs-gcp-03-1af83419ac95)$ gcloud services enable cloudprofiler.googleapis.com
Operation "operations/acat.p2-749749139156-cff5048f-8447-47e5-90b7-c2b58062f9cd" finished successfully.
student_04_18e2d8d14e5c@cloudshell:~/gcp-logging/training-data-analyst/courses/design-process/deploying-apps-to-gcp (qwiklabs-gcp-03-1af83419ac95)$ docker build -t test-python .
[+] Building 36.8s (10/10) FINISHED
 => [internal] load .dockerignore                                                                                                    0.0s
 => => transferring context: 2B                                                                                                      0.0s
 => [internal] load build definition from Dockerfile                                                                                 0.0s
 => => transferring dockerfile: 217B                                                                                                 0.0s
 => [internal] load metadata for docker.io/library/python:3.7                                                                        0.8s
 => [1/5] FROM docker.io/library/python:3.7@sha256:0014010a200e511e1ed5768862ab5d4e83738049053dfbd9e4bdf3cc776ea66b                 17.0s
 => => resolve docker.io/library/python:3.7@sha256:0014010a200e511e1ed5768862ab5d4e83738049053dfbd9e4bdf3cc776ea66b                  0.0s
 => => sha256:0014010a200e511e1ed5768862ab5d4e83738049053dfbd9e4bdf3cc776ea66b 1.86kB / 1.86kB                                       0.0s
 => => sha256:3a2213210d756e78b7bb723bb3ff6096ee146ec9c28ae22ec3f960ab5c422128 2.22kB / 2.22kB                                       0.0s
 => => sha256:3e440a7045683e27f8e2fa04000e0e078d8dfac0c971358ae0f8c65c13321c8e 55.05MB / 55.05MB                                     0.7s
 => => sha256:670730c27c2eacf07897a6e94fe55423ea50b884d9c28161a283bbbf064d1124 10.88MB / 10.88MB                                     0.2s
 => => sha256:46d78515df2abe441c45d80129505c268a821b2454bcc8a9f547ab81bbeffbb0 8.51kB / 8.51kB                                       0.0s
 => => sha256:68a71c865a2c34678c6dea55e4b0928f751ee3c0ca91cace6e4e0578c534d6cf 5.17MB / 5.17MB                                       0.1s
 => => sha256:5a7a2c95f0f8b221d776ccf35911b68eec2cf9414a44d216205a6f03e381d3d7 54.58MB / 54.58MB                                     0.9s
 => => sha256:6d627e120214bb28a729d4b54a0ecba4c4aeaf0295ca2d1f129480145fad2af6 196.81MB / 196.81MB                                   2.5s
 => => extracting sha256:3e440a7045683e27f8e2fa04000e0e078d8dfac0c971358ae0f8c65c13321c8e                                            2.8s
 => => sha256:f8c6dc6780819f5eb5a6ee84ce72dd613d5e6c406585211a064b6ef641c8a09a 6.29MB / 6.29MB                                       1.1s
 => => sha256:0d2c16482a1d02e07ef5872687862493aff6325808388c83ef3851d5e26bf144 15.04MB / 15.04MB                                     1.2s
 => => sha256:a0e9c6b70f60410578d7fe5a0d92ff64a41ac78ee21010990aa25f24cede6ab8 242B / 242B                                           1.1s
 => => sha256:2621b92f84c5b117043f9dc90964f7c07e63578c7ba3506142dc3704b8f56ed8 2.91MB / 2.91MB                                       1.5s
 => => extracting sha256:68a71c865a2c34678c6dea55e4b0928f751ee3c0ca91cace6e4e0578c534d6cf                                            0.2s
 => => extracting sha256:670730c27c2eacf07897a6e94fe55423ea50b884d9c28161a283bbbf064d1124                                            0.3s
 => => extracting sha256:5a7a2c95f0f8b221d776ccf35911b68eec2cf9414a44d216205a6f03e381d3d7                                            2.5s
 => => extracting sha256:6d627e120214bb28a729d4b54a0ecba4c4aeaf0295ca2d1f129480145fad2af6                                            6.9s
 => => extracting sha256:f8c6dc6780819f5eb5a6ee84ce72dd613d5e6c406585211a064b6ef641c8a09a                                            0.3s
 => => extracting sha256:0d2c16482a1d02e07ef5872687862493aff6325808388c83ef3851d5e26bf144                                            0.6s
 => => extracting sha256:a0e9c6b70f60410578d7fe5a0d92ff64a41ac78ee21010990aa25f24cede6ab8                                            0.0s
 => => extracting sha256:2621b92f84c5b117043f9dc90964f7c07e63578c7ba3506142dc3704b8f56ed8                                            0.3s
 => [internal] load build context                                                                                                    0.0s
 => => transferring context: 1.47kB                                                                                                  0.0s
 => [2/5] WORKDIR /app                                                                                                               0.0s
 => [3/5] COPY . .                                                                                                                   0.0s
 => [4/5] RUN pip install gunicorn                                                                                                   4.0s
 => [5/5] RUN pip install -r requirements.txt                                                                                       13.9s
 => exporting to image                                                                                                               1.0s
 => => exporting layers                                                                                                              1.0s
 => => writing image sha256:4ceeeac9b1e52909dfb24eae9be33ee21f77c297b21baf4bfd0422035fb27a13                                         0.0s
 => => naming to docker.io/library/test-python                                                                                       0.0s
student_04_18e2d8d14e5c@cloudshell:~/gcp-logging/training-data-analyst/courses/design-process/deploying-apps-to-gcp (qwiklabs-gcp-03-1af83419ac95)$ docker run --rm -p 8080:8080 test-python
[2023-03-26 08:48:07 +0000] [1] [INFO] Starting gunicorn 20.1.0
[2023-03-26 08:48:07 +0000] [1] [INFO] Listening at: http://0.0.0.0:8080 (1)
[2023-03-26 08:48:07 +0000] [1] [INFO] Using worker: gthread
[2023-03-26 08:48:07 +0000] [10] [INFO] Booting worker with pid: 10
WARNING:google.auth._default:No project ID could be determined. Consider running `gcloud config set project` or setting the GOOGLE_CLOUD_PROJECT environment variable
^C[2023-03-26 08:50:11 +0000] [1] [INFO] Handling signal: int
[2023-03-26 08:50:11 +0000] [10] [INFO] Worker exiting (pid: 10)
Unable to determine the project ID from the environment. project ID mush be provided if running outside of GCP.
[2023-03-26 08:50:11 +0000] [1] [INFO] Shutting down: Master
student_04_18e2d8d14e5c@cloudshell:~/gcp-logging/training-data-analyst/courses/design-process/deploying-apps-to-gcp (qwiklabs-gcp-03-1af83419ac95)$ gcloud app create --region=us-central
You are creating an app for project [qwiklabs-gcp-03-1af83419ac95].
WARNING: Creating an App Engine application for a project is irreversible and the region
cannot be changed. More information about regions is at
<https://cloud.google.com/appengine/docs/locations>.

Creating App Engine application in project [qwiklabs-gcp-03-1af83419ac95] and region [us-central]....done.     
Success! The app is now created. Please use `gcloud app deploy` to deploy your first app.
student_04_18e2d8d14e5c@cloudshell:~/gcp-logging/training-data-analyst/courses/design-process/deploying-apps-to-gcp (qwiklabs-gcp-03-1af83419ac95)$




student-04-18e2d8d14e5c@load-tester:~$ ab -n 1000 -c 10 https://qwiklabs-gcp-03-1af83419ac95.uc.r.appspot.com/
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking qwiklabs-gcp-03-1af83419ac95.uc.r.appspot.com (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Completed 400 requests
Completed 500 requests
Completed 600 requests
Completed 700 requests
Completed 800 requests
Completed 900 requests
Completed 1000 requests
Finished 1000 requests


Server Software:        Google
Server Hostname:        qwiklabs-gcp-03-1af83419ac95.uc.r.appspot.com
Server Port:            443
SSL/TLS Protocol:       TLSv1.3,TLS_AES_256_GCM_SHA384,256,256
Server Temp Key:        X25519 253 bits
TLS Server Name:        qwiklabs-gcp-03-1af83419ac95.uc.r.appspot.com

Document Path:          /
Document Length:        413 bytes

Concurrency Level:      10
Time taken for tests:   31.301 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      635016 bytes
HTML transferred:       413000 bytes
Requests per second:    31.95 [#/sec] (mean)
Time per request:       313.010 [ms] (mean)
Time per request:       31.301 [ms] (mean, across all concurrent requests)
Transfer rate:          19.81 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        2    3   0.5      3       8
Processing:   116  308 245.5    121     706
Waiting:      116  307 245.6    120     705
Total:        119  310 245.5    124     712

Percentage of the requests served within a certain time (ms)
  50%    124
  66%    631
  75%    634
  80%    635
  90%    637
  95%    640
  98%    643
  99%    647
 100%    712 (longest request)
student-04-18e2d8d14e5c@load-tester:~$