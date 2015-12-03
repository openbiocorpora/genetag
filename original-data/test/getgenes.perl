#!/opt/local/bin/perl

# uses NEWGENE and NEWGENE1 
# or AbGene tags

open(G, $ARGV[0]);
$oldtag="";
$ofile=$ARGV[0];
$ofile=~ s/retok$/genes/;
open(OUT, ">$ofile");

open(S, "./postbrillset_gene.single");
while(<S>) {
    chomp;
    $S{$_}++;
}
close(S);

$line_num=0;

while(<G>) {
    $line_num++;
    @line=split(/\s/,$_);
    $g=$mg=$ng=$ind=""; $oldtag="";
    $line[0] =~ s/\/[A-Z]+$//;
    for($i=0;$i<scalar(@line);$i++) {
	@p = split(/\//,$line[$i]);
	$tag = $p[scalar(@p)-1];
	$term=$p[0];
	for($j=1;$j<scalar(@p)-1;$j++) {
	    $term .= "/";
	    $term .= $p[$j];
	}
	$term =~ s/\s$//;
	$gene=$newgene=$multigene=$contextgene=0;

	if($tag eq "CONTEXTGENE" || $tag eq "GENE") {
	    if($oldtag eq "GENE" || $oldtag eq "CONTEXTGENE"
	       || $oldtag eq "NEWGENE" || $oldtag eq "MULTIGENE") {
		$g .= " "; $ind .= " "; $g .= "$term"; $ind .= "$i"; 
	    }
	    elsif($g) {
		$g =~ s/^\s//; 
		print OUT "$line[0] $g|$ind\n"; 
		$g = $term;
		$mg = $term; 
		$ind = $i;
	    }
	    else {
		$g = $term;
		$mg = $term; 
		$ind = $i;
	    }
	}
	elsif($tag eq "MULTIGENE") {
	    if($oldtag eq "MULTIGENE") {
		$g .= " "; $ind .= " "; $g .= "$term"; $ind .= "$i";  
		$mg .= " "; $mg .= "$term"; 
	    }
	    elsif($oldtag eq "NEWGENE") {
		if(!$S{$oldterm}) {
		    $g .= " "; $ind .= " "; $g .= "$term"; $ind .= "$i"; 
		}
		
		else {
		    $g =~ s/^\s//; 
		    print OUT "$line[0] $g|$ind\n";
		    $g = $term; $ind = $i;
		}
	    }
	    # begin a new gene name
	    else {
		$g = $term;
		$mg = $term; 
		$ind = $i;
	    }
	}
	elsif($tag eq "NEWGENE") {
	    if($oldtag eq "NEWGENE" || $oldtag eq "GENE"
	       || $oldtag eq "CONTEXTGENE") {
		$g .= " "; $ind .= " "; $g .= "$term"; $ind .= "$i";  
		$ng .= " "; $ng .= "$term"; 
		if($i == scalar(@line)-1) {
		    if($g =~ /\S+\.$/) {
			$g =~ s/^\s//; 
			print OUT "$line[0] $g|$ind\n";
			$g=""; $ind="";
		    }
		}
	    }
	    elsif($oldtag eq "MULTIGENE") {
		if(!$S{$term}) {
		    $g .= " "; $ind .= " "; $g .= "$term"; $ind .= "$i";  
		}
		else {
		    print OUT "$line[0] $g|$ind\n";
		    $g = $term; $ind = $i;
		}
	    }
	    elsif($oldtag eq "NEWGENE1") {
		if($g) {
		    $g =~ s/^\s//; 
		    print OUT "$line[0] $g|$ind\n"; 
		    $g = $term; $ind = $i;
		}
	    }
	    # begin a new gene name
	    else {
		$g = $term; $ind = $i;
		if($S{$term}) {$ng = $term;} 
	    }
	}
	elsif($tag eq "NEWGENE1") { 
	    if($oldtag eq "NEWGENE1") {
		$g .= " "; $ind .= " "; $g .= "$term"; $ind .= "$i";  
		$ng .= " "; $ng .= "$term";  
	    }
	    elsif($oldtag eq "NEWGENE") {
		if($g) {
		    $g =~ s/^\s//; 
		    print OUT "$line[0] $g|$ind\n"; 
		    $g = $term; $ind = $i;
		}		
	    }
		
	    # begin a new gene name
	    else {
		$g = $term; $ind = $i;
		if($S{$term}) {$ng = $term;} 
	    }
	}
	else {
	    if($g) {
		$g =~ s/^\s//; 
		print OUT "$line[0] $g|$ind\n";
		$g=""; $ind="";
	    }    
	}

	$oldtag=$tag;
    }
}

close(G);
close(OUT);
