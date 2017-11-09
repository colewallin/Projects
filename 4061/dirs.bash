echo -e "Enter a dirname:"
read dirname
if [ -d $dirname ]
then
	total=$(find $dirname -type d | wc -l)
	echo "there are $total directories on the path"
else
	echo "That is not avalid dir"
fi
