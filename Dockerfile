FROM swift_base_image

# Make directory for building your project and copy project to container
RUN mkdir -p /usr/src/backend-swift
COPY . /usr/src/backend-swift

# Build binary file of your project and copy it to directory for binaries:
WORKDIR /usr/src/backend-swift

# Make directory for save documents
RUN mkdir -p /root/Documents/db/database/
RUN touch /root/Documents/db/database/ccr.db
RUN chmod 7777 /root/Documents/db/database/ccr.db 

RUN swift build
RUN cp /usr/src/backend-swift/.build/debug/backend-swift /usr/local/bin/

# Remove source code
RUN rm -rf /usr/src/backend-swift

# Bind container ports to the host
EXPOSE 80

# Run binary file
RUN cd /usr/local/bin

CMD [ "backend-swift" ]
