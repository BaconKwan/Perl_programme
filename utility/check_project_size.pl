#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;
use Net::SMTP_auth;
use File::Spec;

die "perl $0 <dir> <size[GB]>\n" unless(@ARGV eq 2);

my $bin_path = File::Spec->rel2abs($0);
my ($vol, $dirs, $file) = File::Spec->splitpath($bin_path);

while(1){
	
	open MAIL, "$dirs/users.conf" || die $!;
	my %mail;
	while(<MAIL>){
		chomp;
		next if(/^#|^$/);
		my @line = split /\t/;
		$mail{$line[0]} = $line[1];
	}
	close MAIL;
	
	open SERVER, "$dirs/hostname.conf" || die $!;
	my %server;
	while(<SERVER>){
		chomp;
		next if(/^#|^$/);
		my @line = split /\t/;
		$server{$line[0]} = $line[1];
	}
	close SERVER;
	
	chomp(my $hostname = `hostname`);
	
	my %users;

	open INFO, "/etc/passwd" || die $!;
	foreach(<INFO>){
		chomp;
		my @line = split /:/;
		next unless(exists $mail{$line[0]});
		$users{$line[0]}{name} = $line[0];
	}
	close INFO;
	
	#foreach my $id (sort keys %users){
	#print "$id\n";
	#}
	
	my @list = `ls -l $ARGV[0]`;
	shift @list;
	
	foreach my $line (@list){
		chomp $line;
		my @tmp = split /\s+/, $line;
		push(@{$users{$tmp[2]}{dir}}, "$ARGV[0]/$tmp[8]");
	}
	
	foreach my $id (sort keys %users){
		next unless(exists $users{$id}{dir});
	#print "$id\n";
		my @send;
	
		foreach my $dir (@{$users{$id}{dir}}){
	#print "$dir\n";
			my $line = `du --max-depth=0 $dir`;
			chomp $line;
			my @line = split /\s+/, $line;
			$line[0] = $line[0] / 1024 / 1024;
			my $size = $line[0];
			$line[0] = sprintf("%.2fG", $line[0]);
			$line = join "\t", @line;
			print "$id\t$dir\t$line[0]\n";
			push(@send, $line) if($size >= $ARGV[1]);
		}
		next if(@send == 0);
		my $send_txt = join "\n", $id, @send;

		&sendMail($send_txt, $mail{$id}, \%mail, \%server, $hostname);
#&sendMail($send_txt, $mail{guanpeikun});

	#my $path = `pwd`;
	#chomp $path;
	#open TXT, ">", "$path/send.txt" || die $!;
	#print TXT "$send_txt\n";
	#close TXT;
	#`mail $id -s 'WARNING!!! clean your project size' < $path/send.txt`;
	#`rm $path/send.txt -rf`;
	}

	sleep(604800);
}

sub sendMail
{
	my ($content, $x, $mail, $server, $hostname) = @_;
	my $smtpHost = 'smtp.exmail.qq.com';
	my $smtpPort = '25';
	
	my $username = 'pkguan@genedenovo.com';
	my $passowrd = 'terenceABC1990';
	
	my $subject = 'Notice!! clean your project in time.';

	my $message = "
Your projects on $$server{$hostname} are over $ARGV[1]G
We recommend you that project which is finished 3 months ago should be clean up!

Details:
$content

From monitoring program of $$server{$hostname}
";

	my $smtp = Net::SMTP_auth->new($smtpHost, Timeout => 30) or die "Error: connecting ${smtpHost} fail!\n";
	$smtp->auth('LOGIN', $username, $passowrd) or die("Error: authentication fail!\n");
	$smtp->mail($username);
	$smtp->to($x);
	$smtp->data();
	$smtp->datasend("To: $x\n"); # strict format
	$smtp->datasend("From: $username\n"); # strict format
	$smtp->datasend("Subject: $subject\n"); # strict format
	$smtp->datasend("Content-Type:text/plain;charset=UTF-8\n"); # strict format
	$smtp->datasend("Content-Trensfer-Encoding:7bit\n\n"); # strict format
	$smtp->datasend($message);
	$smtp->dataend();
	$smtp->quit();
}

#exec("for i in \`ls -l /Bio/Project/PROJECT/ | awk \'\$3 ~ /$ARGV[0]/\' | awk \'{print \$9}\'\`; do du --max-depth=0 /Bio/Project/PROJECT/\$i; done | awk \'\$1 > 10485760\' | mail -s \'WARNING!!! clean your project!!!\' $ARGV[0]");
