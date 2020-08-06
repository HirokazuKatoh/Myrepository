#!/user/bin/perl
use strict;

# 「自然と遊戯：偶然を支配する自然法則」
# M. アイゲン、R. ヴィンクラー　著
# 寺本　英、伊勢典夫ほか　訳
# 東京化学同人 (1981)

# 表二
# 球ゲーム：酔歩（ランダムウォーク）
# 4×4の盤面に白と黒の球をランダムに8個ずつ置いて、ゲームを開始する
my $ProgramName = $0;

# 保存するファイルの名前
my $FileName = substr ($ProgramName, 0, 19);
my $NenGaPpi = &GetDate();
$FileName .= $NenGaPpi;
# print "保存ファイル名: $FileName\n";
my $BanmenWriteFlag = 0;
# このフラグを 1 にすると、盤面の経過をファイルに書き込む


# 0 or 1 の2目のさいころを振って白か黒を決める、ここでは白が出たとする
# 白の球がある盤面の位置を確認する
# それらの位置の中からランダムに1箇所選び、球を黒に置き換える
# もし白い球が盤面上に一つもなければ、何もせずにもう一回 0 or 1 のさいころを振る
# 100回さいころを振り、最後の盤面の球の数を比較する
# ゲームを 1000 試合程度実施して、最終盤面の出現回数を調べる
#	↓
#	↓
#	↓
#	盤面の出現回数は "一様分布" になる
# 	（取り除く球色を決めるのは、盤面の状況と何ら関わりなく常に 1/2 である）



# 準備するもの
# 4 × 4 の盤面
# 白球 8 個 + 8 個
# 黒球 8 個 + 8 個
# 0 or 1 の目が出るサイコロ
# 0 - 15 の目が出るサイコロ

# print "白球:B\n";
# print "黒球:W\n";

# 盤面
# A1	A2	A3	A4
#
# B1	B2	B3	B4
#
# C1	C2	C3	C4
#
# D1	D2	D3	D4
#

# 盤面上の球の数の合計
my $BallNum = 16;

# 盤面の位置を指定する文字列の配列
my @Locations = ("A1", "A2", "A3", "A4", "B1", "B2", "B3", "B4", "C1", "C2", "C3", "C4", "D1", "D2", "D3", "D4");

# 白い球
my $White = "white";
# 白い球の数
my $WhiteBallNum;
# 黒い球
my $Black = "black";
my $BlackBallNum;

my @Two = ($White, $Black);


# 盤面の位置（升目）と置かれた石の組を表すハッシュを作る
# { "A1" => "white" }
my %Banmen;

# 初期状態として各色の球を置く数をここで指定する
# デフォルト設定（白球、黒球）
my @InitialNums = (8, 8);
my $BallSum = ( $InitialNums[0] + $InitialNums[1] );
if ($BallSum != $BallNum) {
	print "初期条件の球数が異常です。合計で $BallNum 個きっかりにしてください。\n";
	exit;
}


# 試合結果のハッシュ
# {"白球の数" => "最終盤面での出現回数"}
my %Results;

# 試合結果のハッシュのキーを作っておく、値は 0 を入れておく
my $RatioKey;
for my $w (0 .. $BallNum) {

	$RatioKey = $w;
	$Results{$RatioKey} = 0;

}


# さいころを 99 回振る 500 試合を行った後、さいころを 100 回振る 500 試合を行う
my $Game = 500;
my $SaikoroOdd = 99;
my $SaikoroEven = 100;

# さいころ 99 回で 500試合
&PlayGames ($SaikoroOdd, $Game, \%Banmen);
# さいころ 100 回で 500 試合
&PlayGames ($SaikoroEven, $Game, \%Banmen);


# 全試合の結果をグラフ表示する
print "==============================================================================\n";
&PrintResult(\%Results);


print "### Program: $ProgramName ###\n";
print "保存ファイル名: $FileName\n";


# 総合結果をファイルに書き込む
&WriteResult();

print "結果をファイルに保存しますか？(Y or N):";
chomp (my $Answer = <STDIN>);

if ( ($Answer eq 'N') || ($Answer eq 'n') ){

	unlink $FileName or warn "保存ファイルを消去できませんでした: $!\n";
	print "結果ファイルを消去しました。\n";

} else {

	print "結果をファイルに保存しました。\n";

}


############################################################################################################
# サブルーチン
# プログラムを実施した日付を取得する
sub GetDate {

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
	return ($nengappi);
}


# ファイルハンドルを開く
sub OpenFile {

	# デフォルト出力を SELECTION に変更
	select RANDOM;
	# 出力をバッファリングせずに直ちに書き込む
	$| = 1;
	# 結果を保存するファイルを開く
	# 追加書き込み
	open RANDOM, ">>$FileName" or die "記録用ファイル $FileName を開けませんでした。$!";

}


# ファイルハンドルを閉じる
sub CloseFile {

	# ファイルハンドルを閉じて、出力先を標準に戻す
	close RANDOM;
	select STDOUT;

	return 1;
}


# 結果を保存ファイルに書き込み
sub WriteResult {

	# 保存用ファイルを開く
	&OpenFile();

	print "=== 酔歩遊戯の結果 ===\n";
	print "試合数: ", $Game * 2, "\n\n";

	print "白球の数\t結果の数\n";

	for ( sort bynum (keys %Results) ) {

		print "$_\t";
		print "$Results{$_}\n";
	}

	print "\n";

	# 保存用ファイルを閉じる
	&CloseFile();

	return 1;
}


# 結果を画面にプリント
sub PrintResult {

	my $reftoResult = shift;

	print "白球の数 \t結果の数\n";

	for ( sort bynum (keys %{$reftoResult}) ) {

		print "$_: \t\t";
		print "${$reftoResult}{$_}\n";
	}

}

# 昇順でソート
sub bynum {
	$a <=> $b;
}


# 反転する球の色は、盤面上の各球の数とは独立に決める
sub PlayGames {

	my $saikoro = shift;	# 硬貨を投げる回数
	my $game = shift;
	my $reftoBanmen = shift;

	# さいころを $saikoro 回振って、試合を 500 試合行う
	for my $game (1 .. $Game) {


		# 盤面書き込みフラグが立っていれば、ファイルに書き込む
		if ($BanmenWriteFlag == 1) {
			# 保存用ファイルを開く
			&OpenFile();
		}


		print "-----  第 $game 試合開始！  -----\n";

		# 盤面の初期化、初期設定を行う
		my $initialflag = &ClearAndSetBanmenWhiteBlack ($reftoBanmen);

		# 初期盤面の表示
		print "T = 0\n";
		my $printflag = &PrintBoard($reftoBanmen);


		# "酔歩" 遊戯を開始
		for my $s (1 .. $saikoro) {


			# さいころで白か黒かを決め、
			# 位置のさいころで反転する球の場所を決める
			&PlayRandomWalk ($reftoBanmen);

			# print "T = $s\n";
			# &PrintBoard($reftoBanmen);

			# 途中で一色占拠となっても試合終了しない

		}


		# 試合結果の表示
		$WhiteBallNum = &CountBall($White, $reftoBanmen);
		$BlackBallNum = $BallNum - $WhiteBallNum;

		print "--- 試合結果 (Game = $game) ---\n";
		&PrintBoard($reftoBanmen);
		print "\nW: $WhiteBallNum\t";
		print "B: $BlackBallNum\n";

		$RatioKey = $WhiteBallNum;
		# print "ratiokey = $RatioKey\n";
		# ハッシュの値をインクリメント
		$Results{$RatioKey}++;
		print "------------   第 $game 試合終了   ------------\n";

	}

	return $game;
}


# 0 or 1 の2目のさいころを振って白か黒を決める、ここでは白が出たとする
# 白の球がある盤面の位置を確認する
# それらの位置の中からランダムに1箇所選び、球を黒に置き換える
# もし白い球が盤面上に一つもなければ、何もせずにもう一回 0 or 1 のさいころを振る
# 黒球の場合も同様に処理する
sub PlayRandomWalk {

	my $reftoBanmen = shift;

	# 反転させる球の色を決める
	my $color;
	my $bitsai = int (rand 2);
	if ($bitsai == 0) {
		$color = $White;	# 白球
	} else {
		$color = $Black;	# 黒球
	}

	# 現在の盤面の評価
	# bitsai で決めた色の球が 1 個もなければ、何もせずにサブルーチンを出る
	my $ballnum = &CountBall($color, $reftoBanmen);
	# print "$color球の数：$ballnum\n";
	if ($ballnum == 0) {
		return;
	} else {

		# まず、引いた色の置かれた位置情報を集める
		my @positions = &SearchPos ($color, $reftoBanmen);
		# &PrintArray(\@positions);

		# $color の球の数以下の整数をランダムに選び出す
		my $deleteball = int (rand $ballnum);
		my $deletekey = $positions[$deleteball];
		# print "$deletekey の位置の球を反転します。\n";

		if ($color eq $White) {
			${$reftoBanmen}{$deletekey} = $Black;
		} else {
			${$reftoBanmen}{$deletekey} = $White;
		}

	}

}


# 反転可能な球の位置を数える
sub SearchPos {

	my $color = shift;
	my $reftoBanmen = shift;

	my @poss = ();

	# 引いた色の位置情報を得る
	for ( keys %{$reftoBanmen} ) {

		if ( ${$reftoBanmen}{$_} eq $color ) {

			push (@poss, $_);

		}

	}

	return @poss;

}


# 現在の盤面をプリント
sub PrintBoard {

	my $reftoBanmen = shift;

	my $whiteball = "W";		# ○
	my $blackball = "B";		# ●

	for my $i (0 .. 15) {

		if ( ${$reftoBanmen}{$Locations[$i]} eq $White ) {
			print "$whiteball";
		} elsif ( ${$reftoBanmen}{$Locations[$i]} eq $Black ) {
			print "$blackball";
		} else {
			print "  ";
		}

		if ( ($i + 1) % 4 == 0 ) {
			print "\n";
		}
	}
}


# 盤面の初期化
sub ClearAndSetBanmenWhiteBlack {

	my $reftoBanmen = shift;

	# 盤面を一掃する
	%{$reftoBanmen} = ();

	my @locations = ("A1", "A2", "A3", "A4", "B1", "B2", "B3", "B4", "C1", "C2", "C3", "C4", "D1", "D2", "D3", "D4");

	# 初期設定
	my $index = 0;	# 配列 @Two = ($White, $Black)のインデックス
	# 球を置いた数
	my $totalput = 0;

	for my $uplimit (@InitialNums) {

		# 白と黒の球を $uplimit 個置く
		my $put = 0;
		while ($put < $uplimit) {
			my $remainedpos = scalar @locations;
			# print "球の置き場所はあと $remainedpos 残っています。\n";
			my $pos = int (rand $remainedpos);
			my $hitkey = splice (@locations, $pos, 1);
			$put++;
			# print "--- $hitkey に $put 個目の玉 ($Two[$index]) を置きます。\n";
			${$reftoBanmen}{$hitkey} = $Two[$index];
			$totalput++;
		}
		$index++;
	}

	# print "全部で $totalput 個の球を置きました。\n";
	return $totalput;
}


# 指定された球の色が盤面上にいくつあるか数える
sub CountBall {

	my $color = shift;
	my $reftoBanmen = shift;

	my $number = 0;

	# $color の球の数
	for ( keys %{$reftoBanmen} ) {

		if ( ${$reftoBanmen}{$_} eq $color ) {

			$number++;

		}

	}

	return $number;
}


# 単に配列の要素を表示する
sub PrintArray {

	my $reftoarray = shift;

	for (@{$reftoarray}) {

		print "$_ ";

	}

	print "\n";
}
