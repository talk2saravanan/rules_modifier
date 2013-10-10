#!/usr/bin/perl
################################################################################# 
# 10/10/2013 Saran -> perlsaran@gmail.com
# 
#rules_modifier.pl -> Modify the security rules of Amazon Ec2
################################################################################# 

sub help {

		
	print <<EOF;
	HELP 
	perl rules_modifier.pl [OPTIONS]
	Options:
	rules_filename	Rules file name
	regex_filename Regex pattern file
	debug			Optional
	help			Optional

	e.g >perl rules_modifier.pl --rules_filename=database_server regex_filename=regex

EOF

}


use strict;
use warnings;
use Getopt::Long;
use File::Copy;

sub printd ;


my ($rules_file,$regex_file,$debug,$help);
GetOptions(
    'rules_filename=s' => \$rules_file,
	  'regex_filename=s' => \$regex_file,
	 'debug!' => \$debug,
    'help!'     => \$help
) or die "Incorrect usage!\n".help();

die "Please provide rules_filename as a command line argument".help() unless($rules_file);
die "Please provide regex_filename as a command line argument".help() unless($regex_file);

help() if($help);




my $rules = read_contents($rules_file);#Parse Rules file
my  $regex = read_contents($regex_file);#Parse Regex file

if($rules && $regex ) {
	
	foreach my  $rule(@$rules) {
		next if ($rule=~/^#/s || $rule =~/^\s*$/s); # Ignores comment lines and blank lines
		foreach my $regex(@$regex) {
		    next if ($regex=~/^#/s || $regex =~/^\s*$/s); 
			my ($search,$replace) = split(',',$regex);
			my $rx = qr/$search/;
			printd "rule:$rule \t search : $search \t replace : $replace";
			if($rule =~s/$rx/$replace/si) {
				printd " Rule replaced : $rule \n";
			}
		}
	}
	printd "complete rules : @$rules";

	if(write_contents("$rules_file-bkp",$rules)) { #creating a bkp file
		move("$rules_file-bkp","$rules_file") or die "Move command failed [ $rules_file.bkp --> $rules_file ] : $!\n";
		print "Filters Applied for file : $rules_file\n";
	}
	

}
else {

	print "No content in input file\n";
	exit;
}




sub read_contents {
	my ($filename) = @_;
	if( -e $filename || -r $filename) {
		open("CONTENTS","<$filename") or die "Cant open file $filename : $!\n";
		my @contents = <CONTENTS>;
		close(CONTENTS)  or warn $! ? "Error closing for $filename : $!": "Exit status $? from $filename";
		return(scalar(@contents)?\@contents:0);
	}
	else {
		print "Cant find the $filename.Please give the complete path or check the permissions\n";
		exit;
		return(0);
	}

}

sub write_contents {
	my ($filename,$content) = @_;
		
		
			
			open("FOUT",">$filename") or die "Cant write file $filename : $!\n";
			foreach my $line (@$content) {
				print FOUT $line;
			}
			close(FOUT)  or warn $! ? "Error closing for $filename : $!": "Exit status $? from $filename";
			return(1);
		



}

sub printd {
    
        print "@_"."\n" if ($debug);
}

