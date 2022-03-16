#!/bin/bash
                    
### variables
##################################################

G_SERVER_IP=${1}
G_DB_IP=${2}

G_DB_USERNAME="geocitizen"
G_DB_PASSWORD="weakpass"

G_EMAIL_ADDRESS=${3}
G_EMAIL_PASSWORD=${4}

### fixing dependencies and packets in \'pom.xml\'
##################################################

echo -e "\\n#####\\nSmall errors fixing\\n#####\\n"

### \'javax\' missing
sed -i "s/>servlet-api/>javax.servlet-api/g" "pom.xml"

### https for 2 repo
sed -i -E "s/(http:\\/\\/repo.spring)/https:\\/\\/repo.spring/g" "pom.xml"

### old nexus repos
#sed -i "/<distributionManagement>/,/<\\/distributionManagement>/d" pom.xml

### missing version of maven war plugin
printf \'%s\\n\' \'0?<artifactId>maven-war-plugin<\\/artifactId>?a\' \'                <version>3.3.2</version>\' . x | ex "pom.xml"

### missing \'validator\' attribute
sed -i -E \':a;N;$!ba; s/org.hibernate/org.hibernate.validator/2\' "pom.xml"

### remove duplicates
##################################################

echo -e "#####\\nDuplicates removing\\n#####\\n"

### function for deleting xml block with specified string
function XML_OBJECT_REMOVE()
{
    ### $1 - UP TO
    ### $2 - DOWN TO
    echo -e "${1} ---------- ${2}\\n"
    
    ### $3 - line pointer
    POINTER=$3

    ### delete duplicate TOP
    EDGE=true
    while [ "$EDGE" = true ]; do
        
        if ! [[ "$DUPLICATE_LINE" == "${1}" ]]; then
            sed -i "${POINTER}d" pom.xml
        
            ((POINTER--))
            DUPLICATE_LINE=`sed -n "${POINTER}p" < pom.xml`
            DUPLICATE_LINE=`echo $DUPLICATE_LINE | sed \'s/ *$//g\'`
        else
            EDGE=false
            sed -i "${POINTER}d" pom.xml
        fi
        
    done

    ### delete duplicate DOWN
    EDGE=true
    while [ "$EDGE" = true ]; do
        
        if ! [[ "$DUPLICATE_LINE" == "${2}" ]]; then
            sed -i "${POINTER}d" pom.xml

            DUPLICATE_LINE=`sed -n "${POINTER}p" < pom.xml`
            DUPLICATE_LINE=`echo $DUPLICATE_LINE | sed \'s/ *$//g\'`
        else
            EDGE=false
            sed -i "${POINTER}d" pom.xml
        fi

    done
}

### get the duplicate of maven war plugin
DUPLICATE_NUMBER=`grep -n -m1 \'maven-war\' pom.xml | cut -f1 -d:`
DUPLICATE_LINE=`sed -n "${DUPLICATE_NUMBER}p" < pom.xml`
DUPLICATE_LINE=`echo $DUPLICATE_LINE | sed \'s/ *$//g\'`
TOP="<plugin>"
DOWN="</plugin>"

### remove it
XML_OBJECT_REMOVE $TOP $DOWN $DUPLICATE_NUMBER

### get the duplicate of postgresql plugin
DUPLICATE_NUMBER=`grep -n "org.postgresql" pom.xml | sed -n 2p | cut -f1 -d:`
DUPLICATE_LINE=`sed -n "${DUPLICATE_NUMBER}p" < pom.xml`
DUPLICATE_LINE=`echo $DUPLICATE_LINE | sed \'s/ *$//g\'`
TOP="<dependency>"
DOWN="</dependency>"

### remove it
XML_OBJECT_REMOVE $TOP $DOWN $DUPLICATE_NUMBER

### fixing front-end
##################################################

echo -e "#####\\nFront-end fixing\\n#####\\n"

### wrong path to favicon.ico
sed -i \'s/\\/src\\/assets/.\\/static/g\' src/main/webapp/"index.html"

### wrong back-end in minificated .js files
find ./src/main/webapp/static/js/ -type f -exec sed -i "s/localhost/${G_SERVER_IP}/g" {} +

### fixing properties of the project deployment
##################################################

sed -i -E \\
            "s/(front.url=http:\\/\\/localhost)/front.url=http:\\/\\/${G_SERVER_IP}/g; \\
            s/(front-end.url=http:\\/\\/localhost)/front-end.url=http:\\/\\/${G_SERVER_IP}/g; \\

            s/(db.url=jdbc:postgresql:\\/\\/localhost)/db.url=jdbc:postgresql:\\/\\/${G_DB_IP}/g;
            s/(db.username=postgres)/db.username=${G_DB_USERNAME}/g;
            s/(db.password=postgres)/db.password=${G_DB_PASSWORD}/g;

            s/(url=jdbc:postgresql:\\/\\/35.204.28.238)/url=jdbc:postgresql:\\/\\/${G_DB_IP}/g;
            s/(username=postgres)/username=${G_DB_USERNAME}/g;
            s/(password=postgres)/password=${G_DB_PASSWORD}/g;

            s/(referenceUrl=jdbc:postgresql:\\/\\/35.204.28.238)/referenceUrl=jdbc:postgresql:\\/\\/${G_DB_IP}/g;

            s/(email.username=ssgeocitizen@gmail.com)/email.username=${G_EMAIL_ADDRESS}/g;
            s/(email.password=softserve)/email.password=${G_EMAIL_PASSWORD}/g;" src/main/resources/application.properties