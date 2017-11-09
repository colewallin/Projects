echo -e "Enter a dirname:"
read dirname
if [ -d $dirname ]
then
	list=$(find $dirname -type f -name "core")
  for file in $list;
    do
      stat -c%s $file
  done
	# echo "there are $total directories on the path"
else
	echo "That is not avalid dir"
fi
