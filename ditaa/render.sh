rm *.png
for file in `find . -type f | grep -v "\(png\|sh\)$"`; do
  ditaa --scale 2.5 ${file}
done
