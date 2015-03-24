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

die "perl $0 <dir> <size[GB]>\n" unless(@ARGV eq 2);

chomp(my $hostname = `hostname`);
my %mail = (
	aipeng => 'pai@genedenovo.com',
	taoyong => 'ytao@genedenovo.com',
	gaochuan => 'chgao@genedenovo.com',
	guanpeikun => 'pkguan@genedenovo.com',
	lanhaofa => 'hflan@genedenovo.com',
	lianglili => 'llliang@genedenovo.com',
	miaoxin => 'xmiao@genedenovo.com',
	yangjiatao => 'jtyang@genedenovo.com',
	sunyong => 'ysun@genedenovo.com',
	yaokaixin => 'kxyao@genedenovo.com',
	luoyue => 'yluo@genedenovo.com',
	root => 'yluo@genedenovo.com',
	genedenovo => 'yluo@genedenovo.com',
	zhulei => 'yluo@genedenovo.com'
);
my %server = (
	"linux-large" => "15 Server",
	"luoda" => "16 Server",
	"linux-6wm1" => "19 Server"
);

while(1){
	my %users;

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
			push(@send, $line) if($size >= $ARGV[1]); ## >= 10G
		}
		next if(@send == 0);
		my $send_txt = join "\n", $id, @send;

		&sendMail($send_txt, $mail{$id});
#&sendMail($send_txt, $mail{guanpeikun});

	#my $path = `pwd`;
	#chomp $path;
	#open TXT, ">", "$path/send.txt" || die $!;
	#print TXT "$send_txt\n";
	#close TXT;
	#`mail $id -s 'WARNING!!! clean your project size' < $path/send.txt`;
	#`rm $path/send.txt -rf`;
	}

	sleep(1296000);
}

sub sendMail
{
	my ($content, $x) = @_;
	my $smtpHost = 'smtp.exmail.qq.com';
	my $smtpPort = '25';
	
	my $username = 'pkguan@genedenovo.com';
	my $passowrd = 'terence1990';
	
	my $subject = 'Notice!! clean your project in time.';

	my $message = "your projects on $server{$hostname} are over $ARGV[1]G\n
	Details:
	$content
	\n
	来自 $server{$hostname} 的监控程序\n";

	my $smtp = Net::SMTP_auth->new($smtpHost, Timeout => 30) or die "Error:连接到${smtpHost}失败！";
	$smtp->auth('LOGIN', $username, $passowrd) or die("Error:认证失败！");
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
