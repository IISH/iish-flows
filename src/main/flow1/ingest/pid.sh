#!/bin/bash
#
# pid.sh
#
# Declare and bind our ObjId PIDs
#

echo "Declare pids...">>$log

# Example line is
# 1,1,/ARCH00518/Tiff/1/1_0005.tif,/ARCH00518/Jpeg/1/1_0005.jpg,5,10622/A3EF7419-A1D8-4698-8369-F62ADAEC703E
while read line
do
    while IFS=, read objnr ID master jpeg volgnr PID; do
        if [[ $volgnr == 1 ]]; then
            objid=$na/$archiveID/$ID
            soapenv="<?xml version='1.0' encoding='UTF-8'?>  \
    <soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:pid='http://pid.socialhistoryservices.org/'>  \
        <soapenv:Body> \
            <pid:UpsertPidRequest> \
                <pid:na>$na</pid:na> \
                <pid:handle> \
                    <pid:pid>$objid</pid:pid> \
                    <pid:locAtt> \
                            <pid:location weight='1' href='$catalog/$archiveID#$ID'/> \
                            <pid:location weight='0' href='$catalog/$archiveID#$ID' view='catalog'/> \
                            <pid:location weight='0' href='$or/mets/$objid' view='mets'/> \
                            <pid:location weight='0' href='$or/pdf/$objid' view='pdf'/> \
                            <pid:location weight='0' href='$or/file/master/$PID' view='master'/> \
                            <pid:location weight='0' href='$or/file/level1/$PID' view='level1'/> \
                            <pid:location weight='0' href='$or/file/level2/$PID' view='level2'/> \
                            <pid:location weight='0' href='$or/file/level3/$PID' view='level3'/> \
                        </pid:locAtt> \
                </pid:handle> \
            </pid:UpsertPidRequest> \
        </soapenv:Body> \
    </soapenv:Envelope>"

    file=/tmp/pid.log
    echo "Sending $pid"
    echo wget -O $file --header="Content-Type: text/xml" \
        --header="Authorization: oauth $pidwebserviceKey" --post-data "$soapenv" \
        --no-check-certificate $pidwebserviceEndpoint >> $log

    pidCheck=$(php $global_home/pid.php -l $file)
    rm $file
    if [ "${pidCheck}" != "${pid^^}" ] ; then
        echo "ERROR: Pid not returned by webservice"
    fi

        fi
    done
done < $cf

echo "Done file pid declarations.">>$log