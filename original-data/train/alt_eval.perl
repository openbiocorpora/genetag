#!/opt/local/bin/perl

# Flexible Evaluation Program
# IMPORTANT:  Tokenization of test file must be identical to Gold Standard

open(G, $ARGV[0]);
open(T, $ARGV[1]);
open(S, $ARGV[2]);

while(<G>) {
    chomp;
    $g = lc($_);
    $g =~ s/^\@\@(\d+)\|//;
    $id = $1;   
    push (@{ $GS{$id} }, $g); # GS{id} = start end|name 
}                          
close(G);

while(<T>) {
    chomp;
    $g = lc($_);
    $g =~ s/^\@\@(\d+)\|//;
    $id = $1;  
    push (@{ $T{$id} }, $g);
}
close(T);

while(<S>) {
    chomp;
    $g = lc($_);
    $g =~ s/^\@\@(\d+)\|//;
    $id = $1;  
    push (@{ $S{$id} }, $g);
}
close(S);

$tp=$fp=$fn=0;

foreach $pmid ( keys %GS ) {
    LINE:foreach $i (0..$#{ $GS{$pmid} }) {  
	@a = split(/\|/, $GS{$pmid}[$i]);
	$gs_ind  = $a[0];
	@ga = split(/\s/,$gs_ind);
	$startg = $ga[0];
	$endg = $ga[1];
	$gs_gene = $a[1];
	$found = 0;
	foreach $j (0..$#{ $T{$pmid} }) {  
	    @aa = split(/\|/, $T{$pmid}[$j]);
	    $t_ind  = $aa[0];
	    @ta = split(/\s/,$t_ind);
	    $startt = $ta[0];
	    $endt = $ta[1];
	    $t_gene = $aa[1];
	    if($gs_ind eq $t_ind) {
		$found=1; $tp++;
		print STDOUT "TP|$pmid|$gs_gene|$gs_ind|$t_gene|$t_ind\n";
		next LINE;
	    }

	    # check alternative forms of GS gene
	    foreach $k (0..$#{ $S{$pmid} }) {  
		@aa = split(/\|/, $S{$pmid}[$k]);
		$s_ind  = $aa[0];
		@sa = split(/\s/,$s_ind);
		$starts = $sa[0];
		$ends = $sa[1];
		$s_gene = $aa[1];
		# substring of GS gene occurs in both S and T 
		if($starts >= $startg && $ends <= $endg) {
		    if($t_ind eq $s_ind) {
			$found=1; $tp++;
			print STDOUT "*TP|$pmid|$gs_gene|$gs_ind|$t_gene|$t_ind\n";
			next LINE;
		    }
		}
		# superstring of GS gene occurs in both S and T
		elsif($startg >= $starts && $endg <= $ends) {
		    if($t_ind eq $s_ind) {
			$found=1; $tp++;
			print STDOUT "**TP|$pmid|$gs_gene|$gs_ind|$t_gene|$t_ind\n";
			next LINE;
		    }
		}
		# overlapping ends
		elsif($startg <= $starts && $starts <= $endg && $endg <= $ends) {
		    if($t_ind eq $s_ind) {
			$found=1; $tp++;
			print STDOUT "***TP|$pmid|$gs_gene|$gs_ind|$t_gene|$t_ind\n";
			next LINE;
		    }
		}
		elsif($starts <= $startg && $startg <= $ends && $ends <= $endg) {
		    if($t_ind eq $s_ind) {
			$found=1; $tp++;
			print STDOUT "****TP|$pmid|$gs_gene|$gs_ind|$t_gene|$t_ind\n";
			next LINE;
		    }
		}
	    }
	}

	if(!$found) { print STDOUT "FN|$pmid|$gs_ind|$gs_gene\n"; $fn++; }
    }
}

foreach $pmid ( keys %T ) {
  LINE1:foreach $i (0..$#{ $T{$pmid} }) {
      $found = 0;  
      @aa = split(/\|/, $T{$pmid}[$i]);
      $t_ind  = $aa[0];
      @ta = split(/\s/,$t_ind);
      $startt = $ta[0];
      $endt = $ta[1];
      $t_gene = $aa[1];
      foreach $j (0..$#{ $GS{$pmid} }) {
	  @a = split(/\|/, $GS{$pmid}[$j]);
	  $gs_ind  = $a[0];
	  @ga = split(/\s/,$gs_ind);
	  $startg = $ga[0];
	  $endg = $ga[1];
	  $gs_gene = $a[1];
	  if($gs_ind eq $t_ind) {
	      $found = 1;
	      next LINE1;
	  }
      }
      # check for alternative forms of T gene in S
      foreach $k (0..$#{ $S{$pmid} }) {  
	  @aa = split(/\|/, $S{$pmid}[$k]);
	  $s_ind  = $aa[0];
	  @sa = split(/\s/,$s_ind);
	  $starts = $sa[0];
	  $ends = $sa[1];
	  $s_gene = $aa[1];
	  if($starts >= $startt && $ends <= $endt) {
	      if($t_ind eq $s_ind) {
		  $found=1;
		  next LINE1;
	      }
	  }
	  elsif($startt >= $starts && $endt <= $ends) {
	      if($t_ind eq $s_ind) {
		  $found=1; 
		  next LINE1;
	      }
	  }
	  elsif($startt <= $starts && $starts <= $endt && $endt <= $ends) {
	      if($t_ind eq $s_ind) {
		  $found=1; 
		  next LINE1;
	      }
	  }
	  elsif($starts <= $startt && $startt <= $ends && $ends <= $endt) {
	      if($t_ind eq $s_ind) {
		  $found=1; 
		  next LINE1;
	      }
	  }
      }

      if(!$found) {
	  print STDOUT "FP|$pmid|$T{$pmid}[$i]\n";$fp++;
      }    
  }
}


$pre = $tp / ($tp + $fp);
$re  = $tp / ($fn + $tp);

print STDOUT "\nTP: $tp\nFP: $fp\nFN: $fn\nPrecision: $pre Recall: $re\n\n";
