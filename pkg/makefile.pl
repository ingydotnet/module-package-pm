# The extra author side stuff for the Makefile.PL goes here.
stardoc_make_pod;
readme_from $PM;
ack_xxx;
all_from $PM;
version_check;
stardoc_clean_pod;
