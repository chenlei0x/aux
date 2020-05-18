tag=$1

if [ -z "$tag" ];
then
	echo "need tag"
	exit 0
fi

pkgs=(`rpm -qa | grep $tag`)

for i in ${pkgs[@]}
do
	echo $i
done
echo -e "\ndelete(y/n) ?"

read confirm

if [ ! $confirm == "y" ];
then
	exit 0
fi

for i in ${pkgs[@]};
do
	rpm -e $i
done

