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

chomp(my $hostname = `hostname`);
my %users;
my %mail = (
	aipeng => "pai",
	taoyong => "ytao",
	gaochuan => "chgao",
	guanpeikun => "pkguan",
	lanhaofa => 'hflan',
	lianglili => 'llliang',
	miaoxin => 'xmiao',
	yangjiatao => 'xmiao',
	sunyong => 'ysun',
	yaokaixin => 'kxyao',
	luoyue => "yluo",
	root => "yluo",
	zhulei => "yluo"
);
my %server = (
	"linux-large" => "15 Server",
	"luoda" => "16 Server",
	"linux-6wm1" => "19 Server"
);

open INFO, "/etc/group" || die $!;
foreach(<INFO>){
	chomp;
	my @line = split /:/;
	next unless($line[0] =~ /users|root/);
	my @users = split /,/, $line[-1];
	foreach my $i (@users){
		$users{$i}{name} = $i;
	}
}
close INFO;

#foreach my $id (sort keys %users){
#print "$id\n";
#}

my @list = `ls -l /Bio/Project/PROJECT/`;
shift @list;

foreach my $line (@list){
	chomp $line;
	my @tmp = split /\s+/, $line;
	push(@{$users{$tmp[2]}{dir}}, "/Bio/Project/PROJECT/$tmp[8]");
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
		push(@send, $line) if($size >= 10); ## >= 10G
#print "$line\n" if($size >= 10485760);
	}
	next if(@send == 0);
	my $send_txt = join "\n", $id, @send;
	&sendMail($send_txt, $mail{guanpeikun});

#my $path = `pwd`;
#chomp $path;
#open TXT, ">", "$path/send.txt" || die $!;
#print TXT "$send_txt\n";
#close TXT;
#`mail $id -s 'WARNING!!! clean your project size' < $path/send.txt`;
#`rm $path/send.txt -rf`;
}

sub sendMail
{
	my ($content, $to) = @_;
	my $smtpHost = 'smtp.exmail.qq.com';
	my $smtpPort = '25';
	
	my $username = 'pkguan@genedenovo.com';
	my $passowrd = 'terence1990';
	
	my $suffix = "\@genedenovo.com";
	my $subject = 'Notice!! clean your project in time.';

	my $message = "your projects on $server{$hostname} are over 10G
	
	Details:
	$content

	来自 $server{$hostname} 的监控程序";

	my $smtp = Net::SMTP_auth->new($smtpHost, Timeout => 30) or die "Error:连接到${smtpHost}失败！";
	$smtp->auth('LOGIN', $username, $passowrd) or die("Error:认证失败！");

	my $x = $to.$suffix;
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
