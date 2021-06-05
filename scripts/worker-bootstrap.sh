#!/bin/sh
### START CRIBL MASTER TEMPLATE SETTINGS ###
CRIBL_MASTER_HOST="10.128.0.10"
CRIBL_AUTH_TOKEN="74563258-4539-6a4d-5861-51484e525555"
CRIBL_MASTER_TLS_DISABLED="true"
CRIBL_VERSION="3.0.0-58078255"
CRIBL_GROUP="default"
CRIBL_TAGS="[]"
CRIBL_MASTER_PORT="4200"
CRIBL_DOWNLOAD_URL=""
### END CRIBL MASTER TEMPLATE SETTINGS ###
# Set defaults
checkrun() { $1 --help >/dev/null 2>/dev/null; }
faildep() { [ $? -eq 127 ] && echo "$1 not found" && exit 1; }
[ -z "${CRIBL_MASTER_HOST}" ] && echo "CRIBL_MASTER_HOST not set" && exit 1
CRIBL_INSTALL_DIR="${CRIBL_INSTALL_DIR:-/opt/cribl}"
CRIBL_MASTER_PORT="${CRIBL_MASTER_PORT:-4200}"
CRIBL_AUTH_TOKEN="${CRIBL_AUTH_TOKEN:-criblmaster}"
CRIBL_MASTER_TLS_DISABLED=${CRIBL_MASTER_TLS_DISABLED:-true}
CRIBL_GROUP="${CRIBL_GROUP:-default}"
if [ -z "${CRIBL_DOWNLOAD_URL}" ]; then
    FILE="cribl-${CRIBL_VERSION}-linux-:ARCH:.tgz"
    CRIBL_DOWNLOAD_URL="https://cdn.cribl.io/dl/$(echo ${CRIBL_VERSION} | cut -d '-' -f 1)/${FILE}"
fi
case `uname -i` in
    aarch64) ARCH=arm64;;
    *) ARCH=x64;;
esac
CRIBL_DOWNLOAD_URL=${CRIBL_DOWNLOAD_URL/:ARCH:/$ARCH}
UBUNTU=0
CENTOS=0
AMAZON=0
echo "Checking dependencies"
checkrun curl && faildep curl
checkrun adduser && faildep adduser
checkrun usermod && faildep usermod
BOOTSTART=1
SYSTEMCTL=1
checkrun systemctl && [ $? -eq 127 ] && BOOTSTART=0
checkrun update-rc.d && [ $? -eq 127 ] && BOOTSTART=0
echo "Checking OS version"
if lsb_release -d 2>/dev/null | grep -qi ubuntu; then
    UBUNTU=1
elif grep -qi amazon /etc/system-release 2>/dev/null; then
    AMAZON=1
elif grep -qi centos /etc/system-release 2>/dev/null; then
    CENTOS=1
fi
echo "Creating cribl user"
if [ $UBUNTU -eq 1 ]; then
    adduser cribl --home /home/cribl --gecos "Cribl LogStream User" --disabled-password
elif  [ $CENTOS -eq 1 ] || [ $AMAZON -eq 1 ]; then
    adduser cribl -d /home/cribl -c "Cribl LogStream User" -m
    usermod -aG wheel cribl
fi

echo "Installing LogStream"
mkdir -p ${CRIBL_INSTALL_DIR}
curl -Lso ./cribl.tar.gz "${CRIBL_DOWNLOAD_URL}"
tar xzf ./cribl.tar.gz -C ${CRIBL_INSTALL_DIR} --strip-components=1
rm -f ./cribl.tar.gz
chown -R cribl:cribl ${CRIBL_INSTALL_DIR}

if [ $BOOTSTART -eq 1 ]; then
    echo "Setting LogStream to start on boot"
    ${CRIBL_INSTALL_DIR}/bin/cribl boot-start enable -u cribl
fi

mkdir -p ${CRIBL_INSTALL_DIR}/local/_system
cat <<-EOF > ${CRIBL_INSTALL_DIR}/local/_system/instance.yml
distributed:
  mode: worker
  master:
    host: ${CRIBL_MASTER_HOST}
    port: ${CRIBL_MASTER_PORT}
    authToken: ${CRIBL_AUTH_TOKEN}
    tls:
      disabled: ${CRIBL_MASTER_TLS_DISABLED}
  group: ${CRIBL_GROUP}
  tags: ${CRIBL_TAGS}
EOF

chown -R cribl:cribl ${CRIBL_INSTALL_DIR}
if [ $BOOTSTART -eq 1 ]; then
  service cribl start
else
  ${CRIBL_INSTALL_DIR}/bin/cribl start
fi