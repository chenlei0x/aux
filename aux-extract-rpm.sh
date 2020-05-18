rpm=$1

if [ -z $rpm ]
then
	echo need rpm
	exit
fi

rpm_name=${rpm%.rpm}
mkdir $rpm_name

rpm2cpio $rpm | (cd $rpm_name; cpio -idmv)

echo $rpm_name/
