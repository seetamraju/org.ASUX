#!/bin/tcsh -f

source "$0:h/ListOfAllProjects.csh-source"

if ( $?IGNOREERRORS ) echo .. hmmm .. ignoring any errors ({IGNOREERRORS} is set)

###============================================
### First download projects whose FOLDERS get RENAMED (example: org.ASUX.AWS.AWS-SDK becomes simply AWS/AWS-SDK)
### After downloading them, rename them

###=============================================

set ORIGNAME=org.ASUX.pom

echo \
git clone https://github.com/org-asux/${ORIGNAME}.git
git clone https://github.com/org-asux/${ORIGNAME}.git

###=============================================
set counter=1
foreach FLDR ( $RENAMED_PROJECTS )

	if ( -e "${FLDR}" ) then
		echo -n .
	else
		echo "  missing ${FLDR}"
		set ORIGNAME=$ORIG_PROJECTNAMES[$counter]
		if (  !  -d  "${ORIGNAME}" ) then
			echo \
			git clone https://github.com/org-asux/${ORIGNAME}.git
			git clone https://github.com/org-asux/${ORIGNAME}.git
		else
			echo "  ${ORIGNAME} already exists"
		endif
		mv ${ORIGNAME} $NEWNAMES[$counter]
	endif

	@ counter = $counter + 1
end
echo ''

###============================================
### 2nd: download projects whose FOLDERS are RETAINED as-is (as in, the folders do _NOT_ get renamed / moved)
mkdir -p "${ORGASUXFLDR}/AWS"

foreach FLDR ( $ASIS_PROJECTS )

	if ( -e "${FLDR}" ) then
		echo -n .
	else
		if ( "${FLDR}" == "${ORGASUXFLDR}" ) then
			echo "skipping 'git clone ${ORGASUXFLDR}' for obvious reasons."
			continue
		else
			echo "  missing ${FLDR}"
			set PROJNAME=$FLDR:t
			echo \
			git clone https://github.com/org-asux/${PROJNAME}.git
			git clone https://github.com/org-asux/${PROJNAME}.git
		endif
	endif
end
echo ''

###============================================

#EoScript
