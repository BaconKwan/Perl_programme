#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;
use threads;
use Config; 
use Getopt::Long;
use File::Basename qw(dirname basename);
use Net::OpenSSH;

die "perl $0 <log_file>\n" if(1 != @ARGV);

my $remote_adds = "172.16.22.11";
my %ssh_connect = (
	user => "sysu_luoda_1",
	port => 22,
	key_path => "/etc/ssh/sysu_luoda_1_TH2",
	timeout => 30
);

my @capture_cmd = (
	"/usr/bin/yhqueue -u sysu_luoda_1 -o \"%8i | %10P | %50j | %4t | %12M | %3c | %5D | %R\""
);
my %ssh_cmd = (
	timeout => 15
);

my $vpn_thread = async {print "Ready!\n";};
my $disconnect_cnt = -1;
#my $reset_cnt = 0;
my $ssh = Net::OpenSSH->new($remote_adds, %ssh_connect);

while(1){
	open LOG, ">> $ARGV[0]" || warn "can not write log_file! $ARGV[0] \n";
	my $time = &showTime;
	print LOG "============================== $time\n";

	my $ok = $ssh->test(\%ssh_cmd, "whoami");
	if($ok){
		$disconnect_cnt = 0;
		print LOG "============================== Congratulations! Connect successfully!\n";
		print LOG "============================== Hi, " . $ssh->get_user . " on " . $ssh->get_host . "\n";
		print LOG $ssh->capture(\%ssh_cmd, @capture_cmd);
	}
	else{
		$ssh->stop;
		$disconnect_cnt++;
		print LOG "============================== Sorry! Connect fialed!\n";
		if($disconnect_cnt == 30){
			print LOG "============================== Please check your network! We have reconnected for many times!\n";
			exit 1;
		}
		elsif($disconnect_cnt % 3 == 0){
			print LOG "============================== Tring to reset vpn!\n";
			$vpn_thread->join();
			$vpn_thread = threads->create(\&vpn_th2);
			sleep(30);
			print LOG "============================== Tring to reconnect th2!\n";
			$ssh = Net::OpenSSH->new($remote_adds, %ssh_connect);
		}
		else{
			print LOG "============================== Tring to reconnect th2!\n";
			$ssh = Net::OpenSSH->new($remote_adds, %ssh_connect);
		}
	}
	print LOG "=================================================================================================================================\n\n";
	close LOG;

	system("tail -n 500 $ARGV[0] > $ARGV[0].tmp") && warn "can not write tmp_file! $ARGV[0].tmp \n";
	system("mv -f $ARGV[0].tmp $ARGV[0]") &&  warn "can not update log_file! $ARGV[0] \n";

	#$reset_cnt++;
	#if($reset_cnt % 10 == 0){
	#$reset_cnt = 0;
	#$vpn_thread->join();
	#$vpn_thread = threads->create(\&vpn_th2);
	#}

	sleep(300);
}

sub showTime
{
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
	my $format_time = sprintf("%d-%.2d-%.2d %.2d:%.2d:%.2d",$year+1900,$mon+1,$mday,$hour,$min,$sec);
	return $format_time;
}

sub vpn_th2 {
	`vpnclient64 61.144.43.67 6443 sysu_ld_nscc bioinfoluoda321`;
}
