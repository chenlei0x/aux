#!/bin/bash
set -e
set -u

prj=iolat
tag_prefix=3.10.107-1-tlinux2-0050_nosign
rpm_path=/data/rpmbuild/RPMS/x86_64

version=$(git tag | grep $prj | grep -o "v.*" | grep -o  -P "\d+" | sort -g -r | head -n1)
if [ -z $version ]
then
	version=0
fi

if [ -n "$(git log --deco HEAD | head -n 1 | grep tag | grep $prj)" ]
then
	echo "HEAD with [$prj] tag???"
	exit
fi

read -p "Have ever make vmlinux?? (Y/N):" confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

((version++))
tag_full=${tag_prefix}_${prj}_v$version
read -p "build with tag [$tag_full] Continue? (Y/N):" confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

if [ -n "$(rpm -qa | grep $prj | grep $version)" ]
then
	rpm -qa | grep $prj | grep $version
	if read -p "remove package from system? (Y/N):" confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
	then
		echo removing packge from system
		rpm -qa | grep $iolat | grep $version | xargs rpm -e
	fi
fi

if [ -n "$(ls $rpm_path | grep $prj | grep $version)" ]
then
	if read -p "remove package from build dir [$rpm_path] ? (Y/N):" confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
	then
		echo "Removing rpm with [$prj $version]"

		(cd $rpm_path
		ls | grep $prj | grep $version | xargs rm)
	fi
fi

git tag $tag_full
(cd package/default &&  HOME=/data ./generate-rpms.sh -d -j20 -t $tag_full 1>/dev/null)


if [ -n "$(ls $rpm_path | grep $prj | grep $version)" ]
then
	kernel_rpm=$(ls $rpm_path | grep $prj | grep $version | head -n1)
	kernel_debug_rpm=$(ls $rpm_path | grep $prj | grep $version | grep debuginfo)

	(cd $rpm_path
	echo rpm -i --force  $kernel_rpm
	echo rpm -i --force  $kernel_debug_rpm
	rpm -i --force  $kernel_rpm
	rpm -i --force  $kernel_debug_rpm)

	echo $tag_full
	reboot
fi

