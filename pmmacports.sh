#!/bin/sh
#set -x 
#set -e

STARTDIR=$(pwd)
mkdir "${STARTDIR}"/TMP
STARTDIR="${STARTDIR}"/TMP

cd "${STARTDIR}"

PACKAGES="curl glib2 physfs libsdl2_mixer libsdl2_image ncurses libxml2"


getPkgUrl(){
  PACKAGENAME="${1}"
  lynx -dump -listonly http://nue.de.packages.macports.org/macports/packages/"${PACKAGENAME}"/ |tail -2|head -1|awk '{print $2}'
}

installPkg(){
  PACKAGENAME="${1}"
  cd "${STARTDIR}"

  PKGURL=$(getPkgUrl "${PACKAGENAME}")
  PKGFILE=$(echo "${PKGURL}" | awk -F'/' '{print $NF}' )

  if [ ! -d "${PACKAGENAME}/opt" ]; then
    echo Installing "${PACKAGENAME}" to /opt/local ...
    mkdir "${PACKAGENAME}" 
    cd "${PACKAGENAME}" && wget --quiet -c "${PKGURL}" && tar xf "${PKGFILE}"

  fi
  
  cd "${STARTDIR}"/"${PACKAGENAME}"
  
  for PKGDEP in $(grep '@pkgdep' \+CONTENTS | cut -d\  -f2 | rev | cut -f2-100 -d\- | rev) 
  do
    installPkg "${PKGDEP}"
  done
  
  cp -a "${STARTDIR}"/"${PACKAGENAME}"/opt "${STARTDIR}"/

}

main(){
  for PACKAGE in ${*}
  do
    cd "${STARTDIR}"
    installPkg $PACKAGE
    cd "${STARTDIR}"
  done

}

main $PACKAGES

