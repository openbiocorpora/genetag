#!/opt/local/bin/perl

# retokenize a tagged file

open(FF, "$ARGV[0]");
$ofile=$ARGV[0];
$ofile.=".retok";
open(OUT, ">$ofile");

while(<FF>) {
    s/\/PRP\\\$/\/PRP/g;
    s/\/PRP\\$/\/PRP/g;
    s/\/PRP\$/\/PRP/g;
    s/\/WP\\\$/\/WP/g;
    s/\/WP\\$/\/WP/g;
    s/\/WP\$/\/WP/g;
    @a = split(/\s+/,$_);
    $pmid = $a[0];
    $n = "";
    $n .= "$pmid ";
    for($i=1;$i<scalar(@a);$i++) {
	#print STDOUT "$a[$i]\n";
	@t = split(/\//,$a[$i]);
	$tag = $t[scalar(@t)-1];
	$term = $a[$i];
	$tag =~ s/\(/\\(/g;
	$tag =~ s/\)/\\)/g;
	$tag =~ s/\[/\\[/g;
	$tag =~ s/\]/\\]/g;

	$term =~ s/\/$tag$//;
	$tag =~ s/\\\(/(/g;
	$tag =~ s/\\\)/)/g;
	$tag =~ s/\\\[/[/g;
	$tag =~ s/\\\]/]/g;

	if($a[$i] =~ /\(|\)|\[|\]|\.|\,|\;|\/|\<|\>|=/) { 
	    $term =~ s/\)/ \) /g;
	    $term =~ s/\(/ \( /g; 
	    $term =~ s/\]/ \] /g;
	    $term =~ s/\[/ \[ /g;
	    $term =~ s/\./ \. /g;
	    $term =~ s/\,/ \, /g; 
	    $term =~ s/\;/ \; /g; 
	    $term =~ s/\// \/ /g; 
	    $term =~ s/\</ \< /g; 
	    $term =~ s/\>/ \> /g; 
	    $term =~ s/\=/ \= /g;	    	    
	}
	@tt = split(/\s+/,$term);
	for($j=0;$j<scalar(@tt);$j++) {
	    $term = $tt[$j];
			 
	    if($term =~ /\S/) {
		$n .=  "$term/$tag ";
	    }
	}
    }
    $n =~ s/\s+$//;
    print OUT "$n\n";
}

close(FF);
close(OUT);
system("uniq $ofile > t");
system("mv t $ofile");
