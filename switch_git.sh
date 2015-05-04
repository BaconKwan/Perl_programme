## switch to local server
sed -r -i 's#https://github.com/BaconKwan/Perl_programme.git#guanpeikun@192.168.10.16:/home/guanpeikun/tools/git_server/Perl_programme.git#' .git/config
## switch to github
sed -r -i 's#guanpeikun@192.168.10.16:/home/guanpeikun/tools/git_server/Perl_programme.git#https://github.com/BaconKwan/Perl_programme.git#' .git/config
