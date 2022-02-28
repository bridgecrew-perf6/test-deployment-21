FROM registry.access.redhat.com/ubi8/python-38

# Add application sources with correct permissions for OpenShift
USER 0
ADD crawler .

# Install Libpostal dependencies
RUN yum update -y && \
    yum -y install curl autoconf automake libtool python3-devel pkgconfig


# Download libpostal source to /usr/local/libpostal-1.1-alpha
RUN cd /usr/local && curl -sL https://github.com/openvenues/libpostal/archive/v1.1-alpha.tar.gz | tar -xz

# Create Libpostal data directory at /var/libpostal/data
RUN cd /var && \
	mkdir libpostal && \
	cd libpostal && \
	mkdir data

# Install Libpostal from source
RUN cd /usr/local/libpostal-1.1-alpha && \
	./bootstrap.sh && \
	./configure --datadir=/var/libpostal/data && \
	make -j4 && \
	make install && \
	ldconfig

RUN chown -R 1001:0 ./
USER 1001

# Install Python dependencies
RUN pip install -U "pip>=19.3.1" && \
    pip install -r requirements.txt
