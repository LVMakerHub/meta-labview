#!/usr/bin/perl
#
# The script should be run from the Yocto meta-labview folder.
#
# Usage: utils/mk-recipes-from-rtimage.pl [-x] [-v] <RT_Images_dir>
#
# This script will create labview, visa, and other dependent .bb recipes and
# installation files for a LabVIEW LINX image.  It was written for 2020,
# but it should be easy to update for future releases just by changing the
# version numbers in variables at the top of file and tweaking the @PKG array
# as needed.
#

use strict;
use warnings;
use File::Basename;
use File::stat;

my $YEAR_VERS = "2023";
my $LVLONG_VERS = "23.0.0";
my $LONG_VERS = "23.1.0";

my $SHORT_VERS = "23.1";
my $RTLOG_VERS = "2.10";
my $BASE_VERS = "17.0";
my $TDMS_VERS = "23.0.0";
my $NICURL_VERS = "21.3.0";

# Values for LabVIEW 2022
#my $YEAR_VERS = "2022";
#my $LVLONG_VERS = "22.5.0";
#my $LONG_VERS = "22.3.0";
#my $SHORT_VERS = "22.3";
#my $RTLOG_VERS = "2.10";
#my $BASE_VERS = "17.0";
#my $TDMS_VERS = "22.0.0";
#my $NICURL_VERS = "21.3.0";

# Values for LabVIEW 2021
#my $YEAR_VERS = "2021";
#my $LVLONG_VERS = "21.0.0";
#my $LONG_VERS = "21.0.0";
#my $SHORT_VERS = "21.0";
#my $RTLOG_VERS = "2.10";
#my $BASE_VERS = "17.0";
#my $TDMS_VERS = "21.0.0";
#my $NICURL_VERS = "21.0.0";

# Values for LabVIEW 2020
#my $YEAR_VERS = "2020";
#my $LVLONG_VERS = "20.0.0";
#my $LONG_VERS = "20.0.0";
#my $SHORT_VERS = "20.0";
#my $RTLOG_VERS = "2.9";
#my $BASE_VERS = "17.0";
#my $TDMS_VERS = "19.0.0";
#my $NICURL_VERS = "20.0.0";

# Values for LabVIEW 2019 SP1
#my $YEAR_VERS = "2019";
#my $LVLONG_VERS = "19.0.1";
#my $LONG_VERS = "19.0.0";
#my $SHORT_VERS = "19.0";
#my $RTLOG_VERS = "2.8";
#my $BASE_VERS = "16.0";
#my $TDMS_VERS = "19.0.0";
#my $NICURL_VERS = "19.0.0";

my $useIPKs = ($YEAR_VERS ge "2021");
my $BASEIMAGETAR_FOR_CERTFILE = "Base/$BASE_VERS/762F/base.tar";

my $ARCH = "armv7-a";   # or "x64"
my $VISA_ARCH = "Arm";  # or "64"
my $LV = "labview";

my $MetaLVRoot = ".";
my $MetaLVBBRoot = "$MetaLVRoot/recipes-devtools/";

my ($ARCH_S) = $ARCH;  $ARCH_S =~ s/-//g;

my $opt_x = 0;  # Extract files
my $opt_v = 0;  # Verbose
my $opt_s = 0;  # Extract postinst scripts

my $arg;
while (defined($arg = shift) && $arg =~ /^-/) {
	if ($arg eq "-x") { # extract 
		$opt_x = 1;
	} elsif ($arg eq "-v") {
		$opt_v = 1;
	} elsif ($arg eq "-s") { # scripts
		$opt_s = 1;
	} else {
		die "$0: Unknown option $arg\n";
	}
}
my $TOPDIR;
my $FIXDIR;
if (defined($arg)) {
	chomp($TOPDIR = $arg);
	chomp($FIXDIR = $arg) if (defined($arg = shift));
	die "Can't access $FIXDIR\n" if ($FIXDIR && !-d $FIXDIR);
} else {
	die "Usage: $0 [-x] [-v] <RT_Images_dir>\n -x : actually extract files\n -v : verbose output\n";
}


my $lvIPKSub;
my $rtmainIPKSub;

if ($TOPDIR =~ m,/ni/*$,) {
	$lvIPKSub = getNewestFile($TOPDIR, "linuxpkg/feeds/ipk/ni-l/ni-linux-rt-lv$YEAR_VERS/$LVLONG_VERS") . "/inline";
	$rtmainIPKSub = getNewestFile($TOPDIR, "linuxpkg/feeds/ipk/ni-l/ni-linux-rt-main/$LVLONG_VERS") . "/inline";
}

print "Package folders:\n\t$TOPDIR/$lvIPKSub\n\t$TOPDIR/$rtmainIPKSub\n" if ($opt_v && $lvIPKSub);

die "$0 should be run from meta-labview directory\n" if (!-f "$MetaLVRoot/conf/layer.conf" || !-d "$MetaLVRoot/../meta-labview");

chomp (my $cwd = `pwd`);
chdir ($TOPDIR) || die "Can't access $TOPDIR\n";

my @PKG = (
	{	'package' => 'labview',
		'vers' => $LONG_VERS,
		'summary' => "LabVIEW embedded run-time engine",
		'homepage' => "http://ni.com/labview",
		'ipk' => [
			<$lvIPKSub/ni-labview-realtime_$LONG_VERS*_cortexa9-vfpv3.ipk>, # replaces LabVIEW/*
			<$lvIPKSub/libnicpuinfo_$LONG_VERS*_cortexa9-vfpv3.ipk>,
			<$lvIPKSub/libni-emb11_$LONG_VERS*_cortexa9-vfpv3.ipk>,
			<$lvIPKSub/ni-rtlog_$RTLOG_VERS*_cortexa9-vfpv3.ipk>,
			<$rtmainIPKSub/ni-tdms_$LONG_VERS*_cortexa9-vfpv3.ipk>,
		],
		'cdf' => [ # CDFs only used for release years <= 2020
			"LabVIEW/$YEAR_VERS/LabVIEW-linux-$ARCH.cdf",
			"LabVIEW/$YEAR_VERS/LabVIEW_common-linux-$ARCH_S.cdf",
			"CPUInfo/$SHORT_VERS/cpuInfo-linux-$ARCH_S.cdf",
			"TDMS/$TDMS_VERS/tdms-linux-$ARCH_S.cdf",
			"RTLog/$RTLOG_VERS/RTLog-linux-$ARCH_S.cdf",
			"Base/$BASE_VERS/Base_common-linux-$ARCH_S.cdf",
		],
		'ipkRemoveFiles' => [ "/home", "/c", "/C" ],
		'ldconfAdd' => '/usr/local/natinst/lib',
		'initScript' => "inherit update-rc.d\nINITSCRIPT_NAME = \"nilvrt\"\n\nINITSCRIPT_PARAMS = \"start 98 4 5 . stop 2 0 1 2 3 6 .\"\n\n",
		'insaneSkipExtra' => 'file-rdeps',
		'installExtra' => "mkdir \${D}/var/local/natinst/log\n	echo RTTarget.RTProtocolAllowed=True >> \${D}/etc/natinst/share/lvrt.conf\n	echo statusLogPath=/var/local/natinst/log/LVStatus.txt >> \${D}/etc/natinst/share/lvrt.conf",
		'fixupFunc' => 'lvFixupInitScript'
	},
	{ 	'package' => 'visa',
		'vers' => $LONG_VERS,
		'summary' => "NI-VISA driver",
		'homepage' => "http://ni.com/visa",
		'ipk' => [
			<$rtmainIPKSub/libvisa_*_cortexa9-vfpv3.ipk>,
			<$rtmainIPKSub/libvisa-data_*_all.ipk>,
			<$rtmainIPKSub/ni-visa-passport-serial_*_cortexa9-vfpv3.ipk>,
			<$rtmainIPKSub/ni-visa-errors_*_all.ipk>,
		],
	  	'cdf' => [
			"NI-VISA/$SHORT_VERS/installLinuxArm.cdf",
			"NI-VISA/$SHORT_VERS/errors_Linux.cdf",
			"NI-VISA/$SHORT_VERS/passport_Asrl_LinuxArm.cdf",
		],
		'ldconfAdd_CDFOnly' => '/usr/local/vxipnp/linux/lib'
	},
	{ 	'package' => 'lv-web-support',
		'vers' => $LONG_VERS,
		'summary' => "NI-LabVIEW web support libraries",
		'homepage' => "http://ni.com/labview",
		'ipk' => [
			<$lvIPKSub/ni-labview-http-client_$LONG_VERS*_cortexa9-vfpv3.ipk>,
			<$lvIPKSub/ni-labview-smtp-client_$LONG_VERS*_cortexa9-vfpv3.ipk>,
			<$lvIPKSub/ni-labview-webdav-client_$LONG_VERS*_cortexa9-vfpv3.ipk>,
			<$rtmainIPKSub/nicurl_$NICURL_VERS*_cortexa9-vfpv3.ipk>, # Link /usr/local/natinst/share/nicurl/ca-bundle.crt -> /etc/natinst/nissl/ca-bundle.crt now created as hard-link to host file in .deb installer
			<$rtmainIPKSub/ni-ca-certs_*_all.ipk>, # has link /etc/natinst/nissl/ca-bundle.crt -> /etc/ssl/certs/ca-certificates.crt
			<$rtmainIPKSub/nissl_*_cortexa9-vfpv3.ipk>,
			<$rtmainIPKSub/ni-traceengine_*_cortexa9-vfpv3.ipk>,
		],
		'cdf' => [
			"HTTP Client/$LONG_VERS/Linux/$ARCH_S/httpClient-linux-$ARCH_S.cdf",
			"SMTP Client/$LONG_VERS/Linux/$ARCH_S/smtpClient-linux-$ARCH_S.cdf",
			"WebDAV Client/$LONG_VERS/Linux/$ARCH_S/webdavLVClient-linux-$ARCH_S.cdf",
			"NI-Curl/$LONG_VERS/Linux/$ARCH_S/nicurl-linux-$ARCH_S.cdf",
			"nissl/$LONG_VERS/Linux/sslCerts-linux.cdf",
			"nissl/$LONG_VERS/Linux/$ARCH_S/sslSupport-linux-$ARCH_S.cdf",
			"TraceEngine/$LONG_VERS/Linux/$ARCH_S/traceengine-linux-$ARCH_S.cdf",
		],
		'explicitTarFilesToExtract' => {
			$BASEIMAGETAR_FOR_CERTFILE => "./etc/ssl/certs/ca-certificates.crt"
		}
	},
	{	'package' => 'lv-appweb-support',
		'vers' => $LONG_VERS,
		'summary' => "NI-LabVIEW appweb support libraries",
		'homepage' => "http://ni.com/labview",
		'depends' => 'lv-web-support libcap',
		'vers' => $LONG_VERS,
	  	'ipk' => [
			<$rtmainIPKSub/ni-system-webserver_$LONG_VERS*_cortexa9-vfpv3.ipk>,
			<$rtmainIPKSub/ni-webservices-webserver-support_$LONG_VERS*_cortexa9-vfpv3.ipk>,
			<$rtmainIPKSub/ni-webserver-libs_$LONG_VERS*_cortexa9-vfpv3.ipk>,
			<$rtmainIPKSub/ni-ssl-webserver-support_$LONG_VERS*_cortexa9-vfpv3.ipk>,
		],
	  	'cdf' => [
			"System_webserver/$SHORT_VERS/Linux/$ARCH_S/NISystemWebServer-linux-$ARCH_S.cdf",
			"WS_Runtime/$SHORT_VERS/Linux/$ARCH_S/ws_runtime-linux-$ARCH_S.cdf",
			"webserver/$SHORT_VERS/Linux/$ARCH_S/appweb-linux-$ARCH_S.cdf",
			"webserver_ssl_support/$LONG_VERS/Linux/$ARCH_S/webserver_ssl_support-linux-$ARCH_S.cdf",
		],
		'installExtra' => "/bin/echo -e '\\nDisablePermissions = true' >> \${D}/etc/natinst/webservices/webservices.ini",
		'ldconfAdd' => '/usr/local/natinst/share/NIWebServer',
		# This entry will fix up absolute symlinks from /usr/local/natinst/lib (to /usr/local/natinst/share/NIWebServer)
		# and make them relative so they don't get eaten by bitbake.  But it turns out similar links were also eaten
		# in the lvrt20 release and never noticed; this apparently doesn't cause any issues so it's better to just leave them out.
		#'ipkRelinkAbsoluteSymlinks' => [ "/usr/local/natinst/lib" ],

		# These symlinks point to files which are removed from the image and unneeded
		'ipkRemoveFiles' => [
		       	"/usr/local/natinst/lib/mod_niws.so.1",
		       	"/usr/local/natinst/lib/mod_niesp.so.13",
		       	"/usr/local/natinst/lib/mod_nisessmgr.so.13",
		       	"/usr/local/natinst/lib/libws_runtime.so",
		       	"/usr/local/natinst/lib/ws_repl.so"
	       	],
	}
);
chdir($cwd);

my $cdf;
my $ipk;
my %iniFileSeen;

foreach my $ref (@PKG) {
	my $pkg = $$ref{'package'};
	my $summary = $$ref{'summary'};
	my $homepage = $$ref{'homepage'};
	my $depends = $$ref{'depends'};
	my $pkgv = $pkg . "_" . $LONG_VERS;
	my $ldConfAdd = $$ref{'ldconfAdd'};
	$ldConfAdd = $$ref{'ldconfAdd_CDFOnly'} if (!defined($ldConfAdd) && !$useIPKs);
	my $initScript = $$ref{'initScript'};
	my $insaneSkipExtra = $$ref{'insaneSkipExtra'};
	my $installExtra = $$ref{'installExtra'};
	my $fixupFunc = $$ref{'fixupFunc'};
	my $ipkRemoveFiles = $$ref{'ipkRemoveFiles'};
	my $ipkRelinkAbsoluteSymlinks = $$ref{'ipkRelinkAbsoluteSymlinks'};

	printf "# Package %s\n", $pkg if ($opt_v);
	my $pkgDistBase = "$MetaLVBBRoot$pkg/$pkgv";
	my $pkgDistDir = "$pkgDistBase/$ARCH";
	my $pkgDistBB = $pkgDistBase . ".bb";

	if ($opt_x) {
		system("mkdir -p -m 755 $pkgDistDir");
	}
	if ($useIPKs) {
		my @ipks = @{$ref->{'ipk'}};
		foreach $ipk (@ipks)
		{
			print " # Processing $ipk\n" if ($opt_v);
			die "Can't access $TOPDIR/$ipk\n" if (! -f "$TOPDIR/$ipk");
			my $dpkgxopt = $opt_v ? "-X" : "-x";
			if ($opt_x) {
				system("cd $pkgDistDir; dpkg $dpkgxopt \"$TOPDIR/$ipk\" .");
			}
		}
		my @rmDirs = $ipkRemoveFiles ? @{$ipkRemoveFiles} : ();
		foreach my $rmdir (@rmDirs) {
			system("rm -rf \"$pkgDistDir/$rmdir\"");
		}
		if ($ipkRelinkAbsoluteSymlinks) {
			my @relinkDirs = @{$ipkRelinkAbsoluteSymlinks};
			my $installRelinkCmds = "";
			foreach my $relinkDir (@relinkDirs) {
				if (-d "$pkgDistDir/$relinkDir") {
					opendir(my $dir_fh, "$pkgDistDir/$relinkDir");
					my ($prevFile, $prevTime, $file, $fileTime, $newestFile);
					while (my $file = readdir $dir_fh) {
						if (-l "$pkgDistDir/$relinkDir/$file") {
							my $linkTarget = readlink "$pkgDistDir/$relinkDir/$file";
							if ($linkTarget =~ m,^/,) {
								my $linkTargetDir = dirname($linkTarget);
								#chomp(my $relTarget = `realpath -m  --relative-to=$relinkDir $linkTargetDir`);
								$installRelinkCmds .= "    rm -f \${D}$relinkDir/$file\n" .
								      "    lnr \${D}$linkTarget \${D}$relinkDir/$file\n";
							}
						}
					}
					closedir($dir_fh);
				} else {
					die "$pkgDistDir/$relinkDir does not exist for 'ipkRelinkAbsoluteSymlinks' entry\n";
				}
			}
			$installExtra .= "\n" . $installRelinkCmds if ($installRelinkCmds ne "");
		}
	} else {
		while (my ($tarFile, $extractFile) = each %{$ref->{'explicitTarFilesToExtract'}}) {
			open(P, "tar xfO \"$TOPDIR/$tarFile\" --wildcards *data.tar.gz | tar tfz - \"$extractFile\" |");
			while (<P>) {
				print " XFile ", $_;
			}
			close P;
			if ($opt_x) {
				my $ddir = dirname("$pkgDistDir/$extractFile");
				system("mkdir -p -m 755 \"$ddir\"");
				system("cd $pkgDistDir; tar xfO \"$TOPDIR/$tarFile\" --wildcards *data.tar.gz | tar xfz - \"$extractFile\"");
			}
		}
		my @cdfs = @{$ref->{'cdf'}};
		foreach $cdf (@cdfs)
		{
			$cdf = $TOPDIR . "/" . $cdf;
			my $dir = dirname($cdf);
			my $cdfFile = basename($cdf);
			open (F, $cdf) || die "Can't find file $cdf\n";
			print " # Processing $cdf\n" if ($opt_v);
			while (<F>) {
				if (/CODEBASE/) {
					if (/FILENAME="([^\"]*)" TARGET="([^\"]*)"/) {
						my ($file, $target) = ($1, $2);
						die if ($file eq "" || $target eq "");
						next if ($target =~ m,/var/local/natinst/www/,);
						if ($opt_x) {
							my $ddir = dirname("$pkgDistDir$target");
							system("mkdir -p -m 755 \"$ddir\"");
							my $cpCmd = "cp -f \"$dir/$file\" \"$pkgDistDir$target\"";
							system($cpCmd) == 0 || die "Command '$cpCmd' failed";
							my $mode = 0644;
							$mode = 0755 if ($target =~ /(\.so|lvrt)/);
							chmod $mode, "$pkgDistDir$target";
						}
						print " File $target\n";
					} elsif (/FILENAME="([^\"]*)" TYPE="TAR"/) {
						my $tarFile = $1;
						print " # TAR $dir/$tarFile BEGIN\n" if ($opt_v);
						open(P, "tar xfO  \"$dir/$tarFile\" --wildcards *data.tar.gz | tar tfz - |");
						while (<P>) {
							s,^\./,,;
							s,^,/,;
							next if (m,/$,);
							print " File ", $_;
						}
						close P;
						print " # TAR $dir/$tarFile END\n" if ($opt_v);
						if ($opt_x) {
							system("cd $pkgDistDir; tar xfO  \"$dir/$tarFile\" --wildcards *data.tar.gz | tar xfz -") == 0 || die;
						}
						my $cdfDir = $cdfFile;
						$cdfDir =~ s/\.cdf$//;
						if ($opt_s) {
							system("mkdir -p -m 755 xscripts/$cdfDir");
							system("cd xscripts/$cdfDir && tar xf  \"$dir/$tarFile\" postinst 2>/dev/null");
						}
					}
				} elsif (/SYMLINK SOURCE="([^\"]*)" LINK="([^\"]*)"/) {
					my ($linkFrom, $linkTo) = ($2,$1);
					next if ($linkFrom eq "/C");
					next if ($linkFrom =~ "^/c/");
					next if ($linkFrom =~ "^/home/lvuser/");
					print " Link $linkFrom -> $linkTo\n";
					if ($opt_x) {
						my $ddir = dirname("$pkgDistDir$linkFrom");
						system("mkdir -p  -m 755 \"$ddir\"");
						system("ln -sf \"$linkTo\" \"$pkgDistDir$linkFrom\"") == 0|| die;
					}
				} elsif (/MERGEINI FILENAME="([^\"]*)" TARGET="([^\"]*)"/) {
					my ($file, $target) = ($1,$2);
					print " MergeIni $target\n";
					if ($opt_x) {
						my $ddir = dirname("$pkgDistDir$target");
						system("mkdir -p -m 755 \"$ddir\"");
						if (!$iniFileSeen{"$pkgDistDir$target"}) {
							$iniFileSeen{"$pkgDistDir$target"} = 1;
							open (OF, ">$pkgDistDir$target");
							print OF "[LVRT]\n";
						} else {
							open (OF, ">>$pkgDistDir$target");
						}
						open (IF, "$dir/$file") || die;
						while (<IF>) {
							s/\r$//;
							next if (/^\[LVRT\]$/);
							next if (/^\s*$/);
							die "Can't handle mergeini files with sections other than [LVRT]\n" if (/^\[$/);
							print OF $_;
						}
						close IF;
						close OF;
					}
				}
			}
			close F;
		}
	}
	if ($opt_x) {
		open (O, ">$pkgDistBase/LICENSE");
		print O <<'EOF';
PLEASE READ THE FOLLOWING TERMS CAREFULLY. BY INSTALLING OR USING THE SOFTWARE, YOU AGREE TO THE FOLLOWING TERMS.

Software License Agreement

Subject to your compliance with the terms of this software license agreement, 
NI grants you a limited, revocable, non-exclusive, non-sublicensable license 
to use this software ("Software") as deployed on your hardware targets (each 
"Target") and solely for your personal, non-commercial use. You may 
redistribute the code only as deployed on a Target and solely for the 
recipient's personal, non-commercial use, provided that you include a copy of 
this license with the software.

Software does not include certain third party software that NI provides to you 
but that is subject to separate license terms either presented at the time of 
installation or otherwise provided with the Software.

You may not modify or create derivatives of the Software; reverse engineer, 
decompile, or disassemble the Software, unless and only to the extent that 
applicable law expressly prohibits this restriction; defeat or work around any 
access restrictions or encryption in the Software, unless and only to the 
extent that applicable law expressly prohibits this restriction; or remove, 
minimize, block, or modify any titles, logos, trademarks, copyright and patent 
notices, disclaimers, or other legal notices that are included in the Software.

SOFTWARE IS PROVIDED BY NI AND ITS LICENSORS "AS IS" AND WITH NO EXPRESS OR 
IMPLIED WARRANTIES, INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF 
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. ANY IMPLIED OR EXPRESS 
WARANTIES ARE DISCLAIMED. IN NO EVENT SHALL NI OR ITS LICENSORS BE LIABLE FOR 
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES,
INCLUDING BUT NOT LIMITED TO LOSS OF USE, LOSS OF DATA, AND LOSS OF PROFITS, 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT, ARISING IN ANY WAY OUT OF THE USE OF THE SOFTWARE, EVEN IF 
NI OR ITS LICENSOR WAS ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

EOF
		close O;
		#
		# bitbake doesn't detect changes in files inside directories
		# referenced by SRC_URI tag and will incorrectly use cached
		# outputs.  Workaround by adding an explicitly referenced
		# file which will reflect such changes.
		system("utils/fixup-metalv.sh \"$FIXDIR\" \"$pkg\"") if (($pkg eq "labview" || $pkg eq "lv-appweb-support") && $FIXDIR && $FIXDIR ne "");
		system("find \"$pkgDistDir\" -type l -exec readlink -n {} \\; -exec echo -n ' <- ' \\; -exec ls -d {} \\; -o -type f -exec shasum {} \\; > \"$pkgDistBase/FILES\"");

		opendir(my $dh, $pkgDistDir) || die "can't opendir $pkgDistDir: $!";
		my @topDirs = grep { s,^,/,; } grep { !/^\./ && !/^LICENSE$/; } readdir($dh);
		closedir $dh;
		open (O, ">$pkgDistBB");
		print O "SUMMARY = \"$summary\"\n";
		print O "HOMEPAGE = \"$homepage\"\n\n";
		print O "DEPENDS = \"$depends\"\n" if (defined($depends) && $depends ne "");
		print O <<'EOF';  # Could recompute MD5 hash ourselves, but nibuild doesn't have up-to-date Digest::MD5 for 64-bit
LICENSE_FLAGS = "national-instruments"
LICENSE = "NI_Maker_Software_License_Agreement"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2c6c2a1463b05f89279c9242eae7d3a8"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}_${PV}:"

S = "${WORKDIR}"

EOF
		print O $initScript if (defined($initScript) && $initScript ne "");
		print O <<'EOF';
# Automatically choose directory based on target architecture
def get_ni_arch(d):
    TA = d.getVar('TARGET_ARCH', True)
    if TA == "arm":
        niArch = "armv7-a"
    elif TA == "x86_64":
        niArch = "x64"
    else:
        raise bb.parse.SkipPackage("Target architecture '%s' is not supported by the meta-labview layer" %TA)
    return niArch

NI_ARCH = "${@get_ni_arch(d)}"

SRC_URI = "file://${NI_ARCH}/* \
           file://LICENSE \
           file://FILES \
"

SRC_URI[md5sum] = ""
SRC_URI[sha256sum] = ""

# Inhibit QA warnings and errors that can't be avoided because we're using pre-built binaries
EOF
		print O 'INSANE_SKIP_${PN} = "already-stripped dev-so textrel ldflags libdir';
		print O " $insaneSkipExtra" if (defined($insaneSkipExtra) && $insaneSkipExtra ne "");
		print O "\"\n";
		print O <<'EOF';

# Inhibit warnings about files being stripped, we can't do anything about it.
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

EOF
		print O <<'EOF' if ($pkg =~ /labview/);
# Uncomment for debugging:
#INHIBIT_PACKAGE_STRIP = "1"

EOF
		print O "FILES_\${PN} = \"@topDirs\"\n\n";
		print O <<'EOF';
do_install() {
    install -d ${D}
    cp -R ${S}/${NI_ARCH}/* ${D}
EOF
		print O "    $installExtra\n" if (defined($installExtra) && $installExtra ne "");
		print O "}\n";
		print O << "EOF" if (defined($ldConfAdd) && $ldConfAdd ne "");

pkg_postinst_\${PN} () {
#!/bin/sh -e
grep -q $ldConfAdd \$D/etc/ld.so.conf || printf "$ldConfAdd\\n" >> \$D/etc/ld.so.conf
if [ -z "\$D" ]; then
  ldconfig
fi
}
EOF
		close O;
	}
	if ($opt_x) {
            eval "&$fixupFunc(\"$pkgDistDir\")" if (defined($fixupFunc) && $fixupFunc ne "");
	}
}

if ($opt_s) {
	system("cd xscripts && rmdir * 2>/dev/null"); # removes empty directorys which didn't have postinst script
}

sub lvFixupInitScript {
	my ($pkgDistDir) = @_;
	open (INITF, ">$pkgDistDir/usr/local/natinst/etc/init.d/nilvrt") || die;
	print INITF <<'EOF';
#!/bin/sh

RUNDIR=/usr/local/natinst/labview
DAEMON=./lvrt
ARGS=""
USER=root
PIDFILE=/var/run/lvrt.pid

do_start() {
	cd $RUNDIR
	/sbin/start-stop-daemon --start --pidfile $PIDFILE \
		--make-pidfile --background --chuid $USER \
		--startas $DAEMON
}

do_stop() {
	/sbin/start-stop-daemon --stop --pidfile $PIDFILE --verbose
}

case "$1" in
  start)
	echo "Starting LabVIEW"
	do_start
	;;
  stop)
	echo "Stopping LabVIEW"
	do_stop
	;;
  restart)
	echo "Restarting LabVIEW"
	do_stop
	do_start
	;;
  *)
	echo "Usage: /etc/init.d/nilvrt {start|stop|restart}"
	exit 1
	;;
esac

exit 0
EOF
	close INITF;
}

sub getNewestFile {
	my ($top, $subdir) = @_;
	opendir(my $dir_fh, $top."/".$subdir);
	my ($prevFile, $prevTime, $file, $fileTime, $newestFile);
	while (my $file = readdir $dir_fh) {
    		if ($file !~ /^\./) {
			my $fileTime = stat("$top/$subdir/$file");
			$newestFile = $file if (!$prevFile || $fileTime->mtime > $prevTime->mtime);
			$prevFile = $file;
			$prevTime = $fileTime;
		}
	}
	closedir $dir_fh;
	return $subdir."/".$newestFile;
}
