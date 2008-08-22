OS=`uname`
case $OS in
	Darwin*)
		function seq {
			gseq $*
		}
		function split { 
			gsplit $*
		}
	;;
esac

