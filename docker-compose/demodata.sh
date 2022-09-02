#!/bin/bash

  if [ ! -d pgp3140_wgs_hlpanel/docs ] ; then
    curl -fsSLO https://forome-dataset-public.s3.us-south.cloud-object-storage.appdomain.cloud/pgp3140_wgs_hlpanel.zip
    mkdir pgp3140_wgs_hlpanel
    unzip pgp3140_wgs_hlpanel.zip -d ./pgp3140_wgs_hlpanel
  fi

  if [ ! -f gene_db.js ] ; then
    curl -fsSLO https://forome-dataset-public.s3.us-south.cloud-object-storage.appdomain.cloud/gene_db.zip
    unzip gene_db.zip
  fi

  docker exec -it anfisa-backend sh -c 'echo "Initializing ..."; while ! test -f "/anfisa/anfisa.json"; do sleep 5; done'
  docker exec -it anfisa-backend sh -c 'PYTHONPATH=/anfisa/anfisa/ python3 -m app.adm_mongo -c /anfisa/anfisa.json -m GeneDb /anfisa/a-setup/data/gene_db.js'
  docker exec -it anfisa-backend sh -c 'PYTHONPATH=/anfisa/anfisa/ python3 -u -m app.storage -c /anfisa/anfisa.json -m create --reportlines 200 -f -k ws -i /anfisa/a-setup/data/examples/pgp3140_wgs_hlpanel/pgp3140_wgs_hlpanel.cfg PGP3140_HL_GENES'
  docker exec -it anfisa-backend sh -c 'PYTHONPATH=/anfisa/anfisa/ python3 -u -m app.storage -c /anfisa/anfisa.json -m create --reportlines 200 -f -k xl -i /anfisa/a-setup/data/examples/pgp3140_wgs_hlpanel/pgp3140_wgs_hlpanel.cfg XL_PGP3140_HL_GENES'
