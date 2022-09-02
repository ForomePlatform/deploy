export $(grep -v '^#' .env | xargs)  > /dev/null

mkdir -p ${ASETUP_WORKDIR}
mkdir -p ${ASETUP_WORKDIR}/data
mkdir -p ${DRUID_WORKDIR}/broker
mkdir -p ${DRUID_WORKDIR}/middlemanager
mkdir -p ${DRUID_WORKDIR}/coordinator
mkdir -p ${DRUID_WORKDIR}/data
mkdir -p ${DRUID_WORKDIR}/historical
mkdir -p ${DRUID_WORKDIR}/data
chmod -R 777 ${DRUID_WORKDIR} ${ASETUP_WORKDIR} > /dev/null
