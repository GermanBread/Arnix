#!/bin/sh
use_dev_branch=false
unattended_install=false

for i in $@; do
    case $i in
        --use-dev)
            use_dev_branch=true
        ;;
        --unattended)
            unattended_install=true
        ;;
        --help)
cat << EOF
--help
--use-dev: Download image from dev branch instead of stable, does not affect update branch of installed system (yet)
--unattended: Install Arnix automatically
EOF
            exit 0
        ;;
    esac
    shift
done

if [ -z "$(command -v curl)" ]; then
    echo "This script needs curl to be installed."
    exit 1
fi
if [ -z $BASE_URL ]; then
    if $use_dev_branch; then
        BASE_URL='https://raw.githubusercontent.com/GermanBread/Arnix/dev/installer';
    else
        BASE_URL='https://raw.githubusercontent.com/GermanBread/Arnix/stable/installer';
    fi
fi
if [ -z $TARBALL ]; then
    TARBALL="$BASE_URL/arnix-bootstrap.tar.gz";
fi
if [ -z $HIJACK_SCRIPT ]; then
    HIJACK_SCRIPT="$BASE_URL/hijack-script";
fi

# prep
temp=$(mktemp -d)
mkdir -p $temp/image $temp/installer

# dl
curl -SL $TARBALL >$temp/image/latest.tar.gz
[ $? -ne 0 ] && exit 1
curl -SL $HIJACK_SCRIPT >$temp/installer/hijack-script
[ $? -ne 0 ] && exit 1

# extract
cd $temp/image
tar xf latest.tar.gz
rm latest.tar.gz

# install
cd $temp/installer
if $unattended_install; then
    ../image/bin/busybox sh hijack-script --unattended
else
    ../image/bin/busybox sh hijack-script
fi