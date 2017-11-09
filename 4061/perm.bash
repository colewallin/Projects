echo -e "Enter a dirname:"
read dirname
if [ -d $dirname ]
then
	list=$(find $dirname -type d)
  for file in $list;
    do
      chmod o+xt $file
  done
	# echo "there are $total directories on the path"
else
	echo "That is not avalid dir"
fi
