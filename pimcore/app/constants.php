<?php 
define("OITO_EUREKA_CLIENT_CONFIG",[
'eurekaDefaultUrl' => 'http://localhost:8761/',
'hostName' => 'host.docker.internal',
'appName' => 'seller-service',
'ip' => 'host.docker.internal',
'port' => ['81', true],
'homePageUrl' => 'http://host.docker.internal:81/actuator/health',
'statusPageUrl' => 'http://host.docker.internal:81/actuator/health',
'healthCheckUrl' => 'http://host.docker.internal:81/actuator/health'
]);
$s3config=AppBundle\Oito\Services\AwsTools::getAssetS3Config();
$region = $s3config['region'];
$s3BaseUrl = "https://s3.$region.amazonaws.com";
$s3BucketName = $s3config['bucket']; // this needs to be changed to the name of your S3 bucket
$s3FileWrapperPrefix = "s3://" . $s3BucketName; // do NOT change

//import bucket
$importConfig = AppBundle\Oito\Services\AwsTools::getImportS3Config();
$s3ImportsBucketName = $importConfig['bucket'];
$s3ImportFileWrapperPrefix = "s3://".$s3ImportsBucketName;
$s3ImportBaseUrl = "https://s3.".$importConfig['region'].".amazonaws.com";

// with this you can individualize the storage path of each entity in pimcore
// you can of course keep some data locally and some data in a S3 bucket - it's completely up to you
// please remember that you have to migrate existing contents manually if you have existing contents

// the following 2 paths need configured public access in your bucket
define("PIMCORE_ASSET_DIRECTORY", $s3FileWrapperPrefix . "/assets");
define("PIMCORE_TEMPORARY_DIRECTORY", $s3FileWrapperPrefix . "/tmp");

define("SCG_IMPORTS_DIRECTORY", $s3ImportFileWrapperPrefix."");
define("SCG_IMPORTS_URL", $s3ImportBaseUrl."");

// constants for reference in the views
define("PIMCORE_TRANSFORMED_ASSET_URL", $s3BaseUrl . "/" . $s3BucketName . "/assets");

// the following paths should be private!
define("PIMCORE_VERSION_DIRECTORY", $s3FileWrapperPrefix . "/versions");
define("PIMCORE_RECYCLEBIN_DIRECTORY", $s3FileWrapperPrefix . "/recyclebin");
define("PIMCORE_LOG_MAIL_PERMANENT", $s3FileWrapperPrefix . "/email");
define("PIMCORE_LOG_FILEOBJECT_DIRECTORY", $s3FileWrapperPrefix . "/fileobjects");