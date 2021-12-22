TOKEN=`openstack token issue |awk '/ id /{print $4}'`

CINDER_SERVER='cinder-server'
PROJECT_ID=xxxxxxxxx

for volumeId in ${*}
do
   echo "volume id: ${volumeId}"
   VOLUME_ID=$volumeId
   ATTACHMENT_ID=$(openstack volume show ${VOLUME_ID} |grep attachment |awk '{print $7}' |sed "s|u'||g"  |sed "s|',||g")

   echo "attachmentId: ${ATTACHMENT_ID}"

   echo curl -g -i -X POST http://${CINDER_SERVER}:8776/v3/${PROJECT_ID}/volumes/${VOLUME_ID}/action -H "X-Auth-Token: $TOKEN" -d "{\"os-detach\": {\"attachment_id\": \"${ATTACHMENT_ID}\"}" -H 'Content-Type: application/json'
   curl -g -i -X POST http://${CINDER_SERVER}:8776/v3/${PROJECT_ID}/volumes/${VOLUME_ID}/action -H "X-Auth-Token: $TOKEN" -d "{\"os-detach\": {\"attachment_id\": \"${ATTACHMENT_ID}\"}}" -H 'Content-Type: application/json'
done
