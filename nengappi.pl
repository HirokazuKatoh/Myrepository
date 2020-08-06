#!/usr/bin/perl

use strict;

# ローカル時間をリストコンテキストで取得
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
# print "$sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst\n";
$year += 1900;		# 西暦
$mon++;			# 0 月から始まる
# 曜日の取得
my @Youbi = ("Sun.", "Mon.", "Tue.", "Wed.", "Thu.", "Fri.", "Sat.");
$wday = $Youbi[$wday];	# 今日の曜日
# print "$year/$mon/$mday $hour:$min:$sec ($wday)\n";

# スカラーコンテキストでは "Fri Mar 22 10:32:18 2013" などと返す
my $datestr = scalar localtime;
# print "$datestr\n";
my @timestr = split / /, $datestr;
# print "Year: $timestr[4]\n";
# print "Month: $timestr[1]\n";
# print "Date: $timestr[2]\n";
# print "Day: $timestr[0]\n";
# print "Time: $timestr[3]\n";

# 年月日を返す
my $nengappi = $year . '-' . $mon . '-' . $mday;
#return ($nengappi);

print "$nengappi\n";

