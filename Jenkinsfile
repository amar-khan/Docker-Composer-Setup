import java.util.Date
def es_hostname ="vpc-myapp-es-qa-vclieyv464wvd2s6myfwymesza.ap-southeast-1.es.amazonaws.com"
def output =""
def files
def url_status ="\n"
def domain_name
Integer x = 1; 
Select_query_set =""
Select_query_set_list=[]
def startdate = new Date().toString().replace(" ","-")

pipeline {
   agent { label 'master' } 

            triggers {
        cron('30 22 * * *')
   }   
       parameters {
booleanParam(
defaultValue: true,
description: 'Developemnt Setup Operations',
name: 'SyncS3'
) 
booleanParam(
defaultValue: true,
description: 'Developemnt Setup Es Dumps',
name: 'ESDump'
) 
booleanParam(
defaultValue: true,
description: 'Transform Es Dumps',
name: 'TransESDump'
)   
booleanParam(
defaultValue: true,
description: 'ES Setup Docker Image',
name: 'EsDockerImage'
)  
booleanParam(
defaultValue: true,
description: 'Db Dumps',
name: 'DbDumps'
)  
}

    stages { 
                 stage('Cleanup ws') {
	     steps {
		    script {      
                deleteDir()
               checkout scm
       }}
	    }
       stage('Db Dumps') {
                steps{
        script{ 
          
             if("${params.DbDumps}" == "true") {
                 withCredentials([usernamePassword(credentialsId: 'buyer-qa-rds', usernameVariable: 'buyerhostname', passwordVariable: 'password'),
                 usernamePassword(credentialsId: 'seller-qa-rds', usernameVariable: 'sellerhostname', passwordVariable: 'password')
                 ])
                 {
    dir('./') {
        def out_put
             out_put = sh(script: "mysqldump -h $buyerhostname -P 3306 -u buyer buyer_backend -p$password > $workspace/buyer_db.sql", returnStdout: true) 
             println out_put
             out_put = sh(script: "mysqldump -h $buyerhostname -P 3306 -u buyer authdb -p$password > $workspace/authentication_db.sql", returnStdout: true) 
             println out_put
             out_put = sh(script: "mysqldump -h $sellerhostname -P 3306 -u seller order_db -p$password > $workspace/order_db.sql", returnStdout: true) 
             println out_put
             out_put = sh(script: "mysqldump -h $buyerhostname -P 3306 -u buyer logistics_db -p$password > $workspace/logistics_db.sql", returnStdout: true) 
             println out_put
             
             sh "aws s3 sync $workspace/ s3://development-import-export/setup-data/dumps/ --exclude '*'  --include '*.sql'"
            }
        }
    }} }
       }
            stage('Sync S3') {
                steps{
        script{ 
          
             if("${params.SyncS3}" == "true") {
             sh "aws s3 sync s3://qa-static-content s3://development-static-myapp-content --acl public-read"
            }
        }
    }}
               stage("Elastic-Dump"){
    steps{
        script{
                  if("${params.ESDump}" == "true") {
            def cmdendata="elasticdump --input=https://$es_hostname/scg_es_product_en --output=$WORKSPACE/scg_es_product_en_data.json --type=data"
            def cmdthdata="elasticdump --input=https://$es_hostname/scg_es_product_th --output=$WORKSPACE/scg_es_product_th_data.json --type=data"
            def cmdenmap="elasticdump --input=https://$es_hostname/scg_es_product_en --output=$WORKSPACE/scg_es_product_en_mapping.json --type=mapping"
            def cmdthmap="elasticdump --input=https://$es_hostname/scg_es_product_th --output=$WORKSPACE/scg_es_product_th_mapping.json --type=mapping"
            def cmdaddendata="elasticdump --input=https://$es_hostname/address_en --output=$WORKSPACE/address_en_data.json --type=data"
            def cmdaddthdata="elasticdump --input=https://$es_hostname/address_th --output=$WORKSPACE/address_th_data.json --type=data"
            def cmdaddenmap="elasticdump --input=https://$es_hostname/address_en --output=$WORKSPACE/address_en_mapping.json --type=mapping"
            def cmdaddthmap="elasticdump --input=https://$es_hostname/address_th --output=$WORKSPACE/address_th_mapping.json --type=mapping"

        parallel(
      a: {
        echo "This is branch a"
        echo "Running parallel batches to index"
        def out_puta = sh(script: "$cmdendata", returnStdout: true)
        println out_puta
                   
      },
      b: {
        echo "This is branch b"
        echo "Running parallel batches to index"
        def out_putb = sh(script: "$cmdthdata", returnStdout: true)
        println out_putb
                  
      },
       c: {
        echo "This is branch c"
        echo "Running parallel batches to index"
        def out_putc = sh(script: "$cmdthmap", returnStdout: true)
        println out_putc                   
      },
      d: {
        echo "This is branch d"
        echo "Running parallel batches to index"
        def out_putd = sh(script: "$cmdenmap", returnStdout: true)
        println out_putd                     
      },
        e: {
        echo "This is branch a"
        echo "Running parallel batches to index"
        def out_pute = sh(script: "$cmdaddendata", returnStdout: true)
        println out_pute
                   
      },
      f: {
        echo "This is branch b"
        echo "Running parallel batches to index"
        def out_putf = sh(script: "$cmdaddthdata", returnStdout: true)
        println out_putf
                  
      },
       g: {
        echo "This is branch c"
        echo "Running parallel batches to index"
        def out_putg = sh(script: "$cmdaddthmap", returnStdout: true)
        println out_putg                  
      },
      h: {
        echo "This is branch d"
        echo "Running parallel batches to index"
        def out_puth = sh(script: "$cmdaddenmap", returnStdout: true)
        println out_puth                   
      }
      
    )
                  }      

}
            
        }
    }

               stage("Uploaded-S3"){
    steps{
        script{
                 if("${params.ESDump}" == "true") {
            sh "zip -r es-data.zip ./*.json"
       sh "aws s3 cp es-data.zip s3://development-import-export/setup-data/"                
                 }
        }}}
                stage('Build elastic Slave') {
            steps {
                echo 'Building elastic slave images'
                script {
                         if("${params.EsDockerImage}" == "true") {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-auth') {     
                        def customImage = docker.build("myappscg/elastic-slave:latest","-f $WORKSPACE/docker/DockerfileEs .")
                        customImage.push()
                    }
                     }
                }
            }
        }
                        stage('TransformEsData') {
            steps {
                echo 'Building elastic slave images'
                script {
                          if("${params.TransESDump}" == "true") {
                    try{
                        sh "docker rm -v -f elastic"
                    }
                catch (err) {
                            println err
                        }
                        //  if("${params.EsDockerImage}" == "true") {
				//  sh "sudo sysctl -w vm.max_map_count=262144"
                         sh "docker run --memory=1000m --cpus=0.5  -d --name elastic -p 9200:9200 -e ES_JAVA_OPTS='-Xms512m -Xmx512m' -v /tmp/esdata:/usr/share/elasticsearch/data:rw myappscg/elastic-slave:latest"
                         sh "./transformedEs.sh"
                  try{
                        sh "docker rm -v -f elastic"
                    }
                          catch (err) {
                            println err
                        }
                    //  }
                }
                }
            }
        }
    }
}
