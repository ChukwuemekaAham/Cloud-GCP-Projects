Objectives

•	Create a Git repository
•	Create a simple Python application
•	Test Your web application in Cloud Shell
•	Define a Docker build
•	Manage Docker images with Cloud Build and Container Registry
•	Automate builds with triggers
•	Test your build changes




Welcome to Cloud Shell! Type "help" to get started.
Your Cloud Platform project in this session is set to qwiklabs-gcp-00-00af8834756c.
Use “gcloud config set project [PROJECT_ID]” to change to a different project.
student_04_18e2d8d14e5c@cloudshell:~ (qwiklabs-gcp-00-00af8834756c)$ mkdir gcp-course
student_04_18e2d8d14e5c@cloudshell:~ (qwiklabs-gcp-00-00af8834756c)$ cd gcp-course
student_04_18e2d8d14e5c@cloudshell:~/gcp-course (qwiklabs-gcp-00-00af8834756c)$ ls
student_04_18e2d8d14e5c@cloudshell:~/gcp-course (qwiklabs-gcp-00-00af8834756c)$ gcloud source repos clone devops-repo
Cloning into '/home/student_04_18e2d8d14e5c/gcp-course/devops-repo'...
warning: You appear to have cloned an empty repository.
Project [qwiklabs-gcp-00-00af8834756c] repository [devops-repo] was cloned to [/home/student_04_18e2d8d14e5c/gcp-course/devops-repo].
student_04_18e2d8d14e5c@cloudshell:~/gcp-course (qwiklabs-gcp-00-00af8834756c)$ ls
devops-repo
student_04_18e2d8d14e5c@cloudshell:~/gcp-course (qwiklabs-gcp-00-00af8834756c)$ cd devops-repo
student_04_18e2d8d14e5c@cloudshell:~/gcp-course/devops-repo (qwiklabs-gcp-00-00af8834756c)$ cd ~/gcp-course/devops-repo
student_04_18e2d8d14e5c@cloudshell:~/gcp-course/devops-repo (qwiklabs-gcp-00-00af8834756c)$ git add --all
student_04_18e2d8d14e5c@cloudshell:~/gcp-course/devops-repo (qwiklabs-gcp-00-00af8834756c)$ git config --global user.email "you@example.com"
student_04_18e2d8d14e5c@cloudshell:~/gcp-course/devops-repo (qwiklabs-gcp-00-00af8834756c)$ git config --global user.name "Your Name"
student_04_18e2d8d14e5c@cloudshell:~/gcp-course/devops-repo (qwiklabs-gcp-00-00af8834756c)$ git commit -a -m "Initial Commit"
[master (root-commit) c6bf8a5] Initial Commit
 4 files changed, 31 insertions(+)
 create mode 100644 main.py
 create mode 100644 requirements.txt
 create mode 100644 templates/index.html
 create mode 100644 templates/layout.html
student_04_18e2d8d14e5c@cloudshell:~/gcp-course/devops-repo (qwiklabs-gcp-00-00af8834756c)$ git push origin master
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 2 threads
Compressing objects: 100% (6/6), done.
Writing objects: 100% (7/7), 945 bytes | 945.00 KiB/s, done.
Total 7 (delta 0), reused 0 (delta 0), pack-reused 0
To https://source.developers.google.com/p/qwiklabs-gcp-00-00af8834756c/r/devops-repo
 * [new branch]      master -> master
student_04_18e2d8d14e5c@cloudshell:~/gcp-course/devops-repo (qwiklabs-gcp-00-00af8834756c)$ echo $DEVSHELL_PROJECT_ID
qwiklabs-gcp-00-00af8834756c
student_04_18e2d8d14e5c@cloudshell:~/gcp-course/devops-repo (qwiklabs-gcp-00-00af8834756c)$ gcloud builds submit --tag gcr.io/$DEVSHELL_PROJECT_ID/devops-image:v0.1 .
Creating temporary tarball archive of 5 file(s) totalling 992 bytes before compression.
Uploading tarball of [.] to [gs://qwiklabs-gcp-00-00af8834756c_cloudbuild/source/1679748455.841425-f6240410bc8344a9a496d0e54971bf2e.tgz]
Created [https://cloudbuild.googleapis.com/v1/projects/qwiklabs-gcp-00-00af8834756c/locations/global/builds/60030602-3c68-4d0f-99ec-d79be3704beb].
Logs are available at [ https://console.cloud.google.com/cloud-build/builds/60030602-3c68-4d0f-99ec-d79be3704beb?project=238802809899 ].
------------------------------------------------------------ REMOTE BUILD OUTPUT ------------------------------------------------------------
starting build "60030602-3c68-4d0f-99ec-d79be3704beb"

FETCHSOURCE
Fetching storage object: gs://qwiklabs-gcp-00-00af8834756c_cloudbuild/source/1679748455.841425-f6240410bc8344a9a496d0e54971bf2e.tgz#1679748457584272
Copying gs://qwiklabs-gcp-00-00af8834756c_cloudbuild/source/1679748455.841425-f6240410bc8344a9a496d0e54971bf2e.tgz#1679748457584272...
/ [1 files][  983.0 B/  983.0 B]
Operation completed over 1 objects/983.0 B.
BUILD
Already have image (with digest): gcr.io/cloud-builders/docker
Sending build context to Docker daemon  6.656kB
Step 1/7 : FROM python:3.7
3.7: Pulling from library/python
3e440a704568: Pulling fs layer
68a71c865a2c: Pulling fs layer
670730c27c2e: Pulling fs layer
5a7a2c95f0f8: Pulling fs layer
6d627e120214: Pulling fs layer
f8c6dc678081: Pulling fs layer
0d2c16482a1d: Pulling fs layer
a0e9c6b70f60: Pulling fs layer
2621b92f84c5: Pulling fs layer
5a7a2c95f0f8: Waiting
6d627e120214: Waiting
f8c6dc678081: Waiting
0d2c16482a1d: Waiting
a0e9c6b70f60: Waiting
2621b92f84c5: Waiting
68a71c865a2c: Verifying Checksum
68a71c865a2c: Download complete
670730c27c2e: Verifying Checksum
670730c27c2e: Download complete
3e440a704568: Verifying Checksum
3e440a704568: Download complete
f8c6dc678081: Verifying Checksum
f8c6dc678081: Download complete
5a7a2c95f0f8: Verifying Checksum
5a7a2c95f0f8: Download complete
a0e9c6b70f60: Verifying Checksum
a0e9c6b70f60: Download complete
2621b92f84c5: Verifying Checksum
2621b92f84c5: Download complete
0d2c16482a1d: Verifying Checksum
0d2c16482a1d: Download complete
6d627e120214: Verifying Checksum
6d627e120214: Download complete
3e440a704568: Pull complete
68a71c865a2c: Pull complete
670730c27c2e: Pull complete
5a7a2c95f0f8: Pull complete
6d627e120214: Pull complete
f8c6dc678081: Pull complete
0d2c16482a1d: Pull complete
a0e9c6b70f60: Pull complete
2621b92f84c5: Pull complete
Digest: sha256:0014010a200e511e1ed5768862ab5d4e83738049053dfbd9e4bdf3cc776ea66b
Status: Downloaded newer image for python:3.7
 46d78515df2a
Step 2/7 : WORKDIR /app
 Running in 2895c63a4410
Removing intermediate container 2895c63a4410
 ca9975f69115
Step 3/7 : COPY . .
 c258a0c47f84
Step 4/7 : RUN pip install gunicorn
 Running in 145663628c82
Collecting gunicorn
  Downloading gunicorn-20.1.0-py3-none-any.whl (79 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 79.5/79.5 KB 4.2 MB/s eta 0:00:00
Requirement already satisfied: setuptools>=3.0 in /usr/local/lib/python3.7/site-packages (from gunicorn) (57.5.0)
Installing collected packages: gunicorn
Successfully installed gunicorn-20.1.0
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
WARNING: You are using pip version 22.0.4; however, version 23.0.1 is available.
You should consider upgrading via the '/usr/local/bin/python -m pip install --upgrade pip' command.
Removing intermediate container 145663628c82
 13736a266231
Step 5/7 : RUN pip install -r requirements.txt
 Running in d9b002ad3be9
Collecting Flask==2.0.3
  Downloading Flask-2.0.3-py3-none-any.whl (95 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 95.6/95.6 KB 6.0 MB/s eta 0:00:00
Collecting click>=7.1.2
  Downloading click-8.1.3-py3-none-any.whl (96 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 96.6/96.6 KB 14.2 MB/s eta 0:00:00
Collecting Jinja2>=3.0
  Downloading Jinja2-3.1.2-py3-none-any.whl (133 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 133.1/133.1 KB 18.4 MB/s eta 0:00:00
Collecting itsdangerous>=2.0
  Downloading itsdangerous-2.1.2-py3-none-any.whl (15 kB)
Collecting Werkzeug>=2.0
  Downloading Werkzeug-2.2.3-py3-none-any.whl (233 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 233.6/233.6 KB 28.3 MB/s eta 0:00:00
Collecting importlib-metadata
  Downloading importlib_metadata-6.1.0-py3-none-any.whl (21 kB)
Collecting MarkupSafe>=2.0
  Downloading MarkupSafe-2.1.2-cp37-cp37m-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (25 kB)
Collecting zipp>=0.5
  Downloading zipp-3.15.0-py3-none-any.whl (6.8 kB)
Collecting typing-extensions>=3.6.4
  Downloading typing_extensions-4.5.0-py3-none-any.whl (27 kB)
Installing collected packages: zipp, typing-extensions, MarkupSafe, itsdangerous, Werkzeug, Jinja2, importlib-metadata, click, Flask
Successfully installed Flask-2.0.3 Jinja2-3.1.2 MarkupSafe-2.1.2 Werkzeug-2.2.3 click-8.1.3 importlib-metadata-6.1.0 itsdangerous-2.1.2 typing-extensions-4.5.0 zipp-3.15.0
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
WARNING: You are using pip version 22.0.4; however, version 23.0.1 is available.
You should consider upgrading via the '/usr/local/bin/python -m pip install --upgrade pip' command.
Removing intermediate container d9b002ad3be9
 e238eaddd154
Step 6/7 : ENV PORT=80
 Running in b2dbc38129ee
Removing intermediate container b2dbc38129ee
 12cea58ffd44
Step 7/7 : CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 main:app
 Running in aa2af8db20e8
Removing intermediate container aa2af8db20e8
 2c2f1f069195
Successfully built 2c2f1f069195
Successfully tagged gcr.io/qwiklabs-gcp-00-00af8834756c/devops-image:v0.1
PUSH
Pushing gcr.io/qwiklabs-gcp-00-00af8834756c/devops-image:v0.1
The push refers to repository [gcr.io/qwiklabs-gcp-00-00af8834756c/devops-image]
c4d6d83c954c: Preparing
aabd19f6e01c: Preparing
c03db3886a94: Preparing
f57fcc96988d: Preparing
6b9978aaf199: Preparing
351fddb2c26e: Preparing
ff67c0f48a1e: Preparing
5c563cc8b216: Preparing
d4514f8b2aac: Preparing
5ab567b9150b: Preparing
a90e3914fb92: Preparing
053a1f71007e: Preparing
ec09eb83ea03: Preparing
351fddb2c26e: Waiting
ff67c0f48a1e: Waiting
5c563cc8b216: Waiting
d4514f8b2aac: Waiting
5ab567b9150b: Waiting
a90e3914fb92: Waiting
053a1f71007e: Waiting
ec09eb83ea03: Waiting
6b9978aaf199: Layer already exists
351fddb2c26e: Layer already exists
ff67c0f48a1e: Layer already exists
5c563cc8b216: Layer already exists
d4514f8b2aac: Layer already exists
f57fcc96988d: Pushed
c03db3886a94: Pushed
5ab567b9150b: Layer already exists
053a1f71007e: Layer already exists
a90e3914fb92: Layer already exists
c4d6d83c954c: Pushed
ec09eb83ea03: Layer already exists
aabd19f6e01c: Pushed
v0.1: digest: sha256:e6b101d8780858b4bf723bab3c2a9d2a5a8b8c3e5724a9c0dea34551a7b8b3aa size: 3055
DONE
---------------------------------------------------------------------------------------------------------------------------------------------
ID: 60030602-3c68-4d0f-99ec-d79be3704beb
CREATE_TIME: 2023-03-25T12:47:37+00:00
DURATION: 51S
SOURCE: gs://qwiklabs-gcp-00-00af8834756c_cloudbuild/source/1679748455.841425-f6240410bc8344a9a496d0e54971bf2e.tgz
IMAGES: gcr.io/qwiklabs-gcp-00-00af8834756c/devops-image:v0.1
STATUS: SUCCESS
student_04_18e2d8d14e5c@cloudshell:~/gcp-course/devops-repo (qwiklabs-gcp-00-00af8834756c)$