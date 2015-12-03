#!/opt/local/bin/perl

open(F, "$ARGV[0]"); #gs
open(FF, "$ARGV[1]"); #test
@g=<F>;
@t=<FF>;
$fix=0;
close(F);
close(FF);
for($i=0;$i<scalar(@g);$i++) {
    @gg=split(/\s+/,$g[$i]);
    @tt=split(/\s+/,$t[$i]);
    for($j=0;$j<scalar(@gg);$j++) {
	if($gg[$j] =~ /\/\//) {
	    $gg[$j] = "/";
	}
	else {
	    $gg[$j] =~ s/\/[\s*\S*]*//;
	}
	if($tt[$j] =~ /\/\//) {
	    $tt[$j] = "/";
	}
	else {
	    $tt[$j] =~ s/\/[\s*\S*]*//;
	}
	if($gg[$j] ne $tt[$j]) {
	    print STDOUT "Line:$i Gold:$gg[$j] Test:$tt[$j]\n";
	    $fix++;
	}
    }
}
if(!$fix) {
    print STDOUT "\nFiles are comparable, no problems found.\n\n";
}
else {
    print STDOUT "\nFound $fix incompatible tokenizations.\n\n";
}
close(F);
