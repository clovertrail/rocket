﻿$imageTimestamp      = Get-Date -Format yyyy-MM-dd

$dummyImageName      = "FreeBSD11_0-2017-02-24"
$dummyVersion        = "11.0.20170224"
$dummyPublishDate    = "02/24/2017"
$dummyVHDFilePath    = "C:\home\Work\Azure\vhd\FreeBSD_11_0_20170224.vhd"

# Specify the values of the following items before publishing images
$vmImageName         = $dummyImageName
$version             = $dummyVersion
$publishedDate       = $dummyPublishDate
$VHDFilePath         = $dummyVHDFilePath
