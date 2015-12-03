#!/opt/local/bin/perl

# Changes the numbering of the before and after indices
# so that the first word is the word after the pmid

open(F, "$ARGV[0]");
open(OUT, ">Test.format");

while(<F>) {
    chomp;
    m/^(\@\@\d+)\s([\s*\S*]*)\|/;
    $id = $1;
    $name = $2;
    @a = split(/\|/,$_);
    $n = $a[scalar(@a)-1];
    @list=split(/\s/,$n);    
    $beg = $list[0]; $beg--;
    $end = $list[scalar(@list)-1]; $end--;
    
    print OUT "$id|$beg $end|$name\n";
}

close(F);
close(OUT);
