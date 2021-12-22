
FILE_PATH="$(pwd)/$0"

for file in $@
do
    echo "upload ${file} ..."
    imageFile=$(basename ${file})
    extName=${imageFile##*.}
    if [[ ${extName} == ${imageFile} ]]; then
        extName=qcow2
    fi
    imageName=${imageFile%%.*}
    glance image-create --progress --disk-format ${extName} --container-format bare --file ${file} --name ${imageName}
done
