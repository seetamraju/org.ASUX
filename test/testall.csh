#!/bin/tcsh -f

###------------------------------
echo "Usage: $0 [--verbose]"
# if ( $#argv <= 1 ) then
#     echo "Usage: $0  [--verbose] --delete --yamlpath yaml.regexp.path -i /tmp/input.yaml -o /tmp/output.yaml " >>& /dev/stderr
#     echo Usage: $0 'org.ASUX.yaml.Cmd [--verbose] --delete --double-quote --yamlpath "paths.*.*.responses.200" -i $cwd/src/test/my-petstore-micro.yaml -o /tmp/output2.yaml ' >>& /dev/stderr
#     echo '' >>& /dev/stderr
#     exit 1
# endif

###------------------------------
set ORGASUXFLDR=/mnt/development/src/org.ASUX
set path=( $path ${ORGASUXFLDR} )
set TESTSRCFLDR=${ORGASUXFLDR}/test
if (  !  $?CLASSPATH ) setenv CLASSPATH ''

###------------------------------
if ( $#argv == 1 ) then
        set VERBOSE=1
else
        unset VERBOSE
endif

chdir ${TESTSRCFLDR}
if ( $?VERBOSE ) pwd

if ( ! -e ./profile ) then
        echo "AWS login credentials missing in a file ./profile"
        exit 2
endif

###------------------------------
echo -n "Sleep interval? >>"; set DELAY=$<
if ( "$DELAY" == "" ) set DELAY=2

set TEMPLATEFLDR=${TESTSRCFLDR}/outputs
set OUTPUTFLDR=/tmp/test-output

###------------------------------
\rm -rf ${OUTPUTFLDR}
mkdir -p ${OUTPUTFLDR}

alias diff \diff -bB

###------------------------------
set JARFLDR=${ORGASUXFLDR}/lib

set MYJAR=${JARFLDR}/org.ASUX.yaml.jar
set YAMLBEANSJAR=${JARFLDR}/com.esotericsoftware.yamlbeans-yamlbeans-1.13.jar
set JUNITJAR=${JARFLDR}/junit.junit.junit-4.8.2.jar
set COMMONSCLIJAR=${JARFLDR}/commons-cli-1.4.jar
setenv CLASSPATH  ${CLASSPATH}:${COMMONSCLIJAR}:${JUNITJAR}:${YAMLBEANSJAR}:${MYJAR} ## to get the jndi.properties

if ( $?VERBOSE ) echo $CLASSPATH

###---------------------------------

set noglob ### Very important to allow us to use '*' character on cmdline arguments
set noclobber

set TESTNUM=1

# 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml read 'paths,/pet' --delimiter , --inputfile nano.yaml \
        -o ${OUTPFILE}
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}

# 2
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml list '*,**,schema' --delimiter , --inputfile nano.yaml \
        -o ${OUTPFILE}
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}

##-------------------------------------------
# 3
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml list 'paths,/pet,put,**,in' --delimiter , --inputfile my-petstore-micro.yaml  \
        -o ${OUTPFILE}
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}

# 4
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml list 'paths,/pet,put,*,*,in' --delimiter , --inputfile my-petstore-micro.yaml   \
        -o ${OUTPFILE}
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}

# 5
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml list 'paths,/pet,put,parameters,2,in' --delimiter , --inputfile my-petstore-micro.yaml \
        -o ${OUTPFILE}
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}

# 6
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml list 'paths,/pet,put,parameters,[13],in' --delimiter , --inputfile my-petstore-micro.yaml  \
        -o ${OUTPFILE}
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}

##-------------------------------------------
# 7
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml replace 'paths,/pet,put,parameters,[13],in' 'replaced text by asux.js' --delimiter , --inputfile my-petstore-micro.yaml  \
        -o ${OUTPFILE} --showStats >! ${OUTPFILE}.stdout
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}
diff ${OUTPFILE}.stdout ${TEMPLATEFLDR}/test-${TESTNUM}.stdout

##-------------------------------------------
# 8
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml delete 'paths,/pet,put,parameters,[13],in' --delimiter , --inputfile my-petstore-micro.yaml  \
        -o ${OUTPFILE} --showStats >! ${OUTPFILE}.stdout
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}
diff ${OUTPFILE}.stdout ${TEMPLATEFLDR}/test-${TESTNUM}.stdout

##-------------------------------------------
# 9
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml macro "unknown=value" --double-quote --inputfile nano.yaml \
        -o ${OUTPFILE}
diff ${OUTPFILE} nano.yaml
asux.js yaml macro @props.txt --inputfile nano.yaml \
        -o ${OUTPFILE}
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}

##-------------------------------------------
# 10
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml batch @./simpleBatch.txt --inputfile /dev/null \
        -o ${OUTPFILE} > /dev/null   ## I have print statements n this BATCH-file, that are put onto stdout.
# echo -n "sleeping ${DELAY}s .."; sleep ${DELAY} ## waiting for output to catch up..
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}

# 11
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml batch 'useAsInput @./aws.AZs.json' --inputfile /dev/null \
        -o ${OUTPFILE}
# echo -n "sleeping ${DELAY}s .."; sleep ${DELAY} ## waiting for output to catch up..
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}

# 12
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml batch @./mapsBatch1.txt --inputfile /dev/null  \
        -o ${OUTPFILE} >! ${OUTPFILE}.stdout
# echo -n "sleeping ${DELAY}s .."; sleep ${DELAY} ## waiting for output to catch up..
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}
diff ${OUTPFILE}.stdout ${TEMPLATEFLDR}/test-${TESTNUM}.stdout

# 13
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml batch @./mapsBatch2.txt --inputfile /dev/null  \
        -o ${OUTPFILE} >! ${OUTPFILE}.stdout
# echo -n "sleeping ${DELAY}s .."; sleep ${DELAY} ## waiting for output to catch up..
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}
diff ${OUTPFILE}.stdout ${TEMPLATEFLDR}/test-${TESTNUM}.stdout

###---------------------------------
# 14
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
# echo 'MyRootELEMENT: ""' | asux.js yaml  insert MyRootELEMENT.subElem.leafElem '{State: "available", Messages: [A,B,C], RegionName: "eu-north-1", ZoneName: "eu-north-1c", ZoneId: "eun1-az3"}' -i -  -o -
asux.js yaml batch @insertReplaceBatch.txt  -i /dev/null    \
        -o ${OUTPFILE} >! ${OUTPFILE}.stdout
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}
diff ${OUTPFILE}.stdout ${TEMPLATEFLDR}/test-${TESTNUM}.stdout

# 15
@ TESTNUM = $TESTNUM + 1
set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
echo $OUTPFILE
asux.js yaml table 'paths,/pet,put,parameters' 'name,type' --delimiter , -i my-petstore-micro.yaml    \
        -o ${OUTPFILE}
diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}

# 16
# @ TESTNUM = $TESTNUM + 1
# set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
# echo $OUTPFILE
# asux.js yaml batch @./mapsBatch3.txt -i /dev/null    \
#         -o ${OUTPFILE}
# diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}
# diff ${OUTPFILE}.stdout ${TEMPLATEFLDR}/test-${TESTNUM}.stdout

# @ TESTNUM = $TESTNUM + 1
# set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
# echo $OUTPFILE
#     \
#         -o ${OUTPFILE}
# diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}
# diff ${OUTPFILE}.stdout ${TEMPLATEFLDR}/test-${TESTNUM}.stdout

# @ TESTNUM = $TESTNUM + 1
# set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
# echo $OUTPFILE
#     \
#         -o ${OUTPFILE}
# diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}
# diff ${OUTPFILE}.stdout ${TEMPLATEFLDR}/test-${TESTNUM}.stdout

# @ TESTNUM = $TESTNUM + 1
# set OUTPFILE=${OUTPUTFLDR}/test-${TESTNUM}
# echo $OUTPFILE
#     \
#         -o ${OUTPFILE}
# diff ${OUTPFILE} ${TEMPLATEFLDR}/test-${TESTNUM}
# diff ${OUTPFILE}.stdout ${TEMPLATEFLDR}/test-${TESTNUM}.stdout

###---------------------------------

set noglob
echo 'foreach fn ( ${OUTPUTFLDR}/* )'
echo '       diff ./outputs/$fn:t $fn'
echo end
###---------------------------------
#EoScript
