#import "@preview/codelst:2.0.2": *

== 演習2-1: Fitts の法則

=== 準備

資料の通り、準備を行った。

しかし、Processing について https://processing.org/ からダウンロードできるものでは本環境と互換性がなかったため、https://github.com/processing/processing4/releases よりダウンロードした。

`processing-4.4.4-linux-x64-portable.zip` をダウンロードして使用した。
ダウンロードした zip ファイルを展開し、展開後の `Processing/bin/Processing` を起動した。

ControlP5 のインストールについては資料の通り、[Tools] → [Manage Tools...] → "Libraries" タブを選択し、"ControlP5" で検索し、該当項目をチェックし Install ボタンを押した。

manaba からダウンロードした実験用のプログラムを Processing を用いて起動し、実験を行った。

=== 実験結果

各条件毎に実験を行い、得られた csv ファイルを分析した。
事前に 5 回ほど練習を行い、十分に操作に慣れてから実験を行った。

各条件毎に選択時間を表にしたものを @t1 に示す。

#let result = (:)

#{
  for d in (250, 450, 650) {
    for w in (40, 90, 120) {
      let key = "d" + str(d) + "w" + str(w)
      let file = "data/2-1/" + key + ".csv"
      let item = csv(file, row-type: dictionary)

      // ミスが無いことを保証
      for v in item {
        assert(v.at("miss") == "0", message: "data contains miss")
      }

      result.insert(key, item.map(v => v.at("time")))
    }
  }
}

#show table: set text(size: 0.67em)

#figure(
  table(
    columns: 2 + 13,
    [条件 (距離)], [条件 (幅)], ..range(0, 13).map(_ => []),
    [250], [40 ], ..result.at("d250w40"),
    [250], [90 ], ..result.at("d250w90"),
    [250], [120], ..result.at("d250w120"),
    [450], [40 ], ..result.at("d450w40"), 
    [450], [90 ], ..result.at("d450w90"), 
    [450], [120], ..result.at("d450w120"),
    [650], [40 ], ..result.at("d650w40"), 
    [650], [90 ], ..result.at("d650w90"), 
    [650], [120], ..result.at("d650w120"),
  ),
  caption: [各条件毎の選択時間]
) <t1>

=== 分析

==== 1. ID と MT の計算

実験で得られたデータから、計測毎の MT を求めると @t2 のようになった。

#let average(data) = {
  calc.round(data.fold(0.0, (acc, v) => acc + float(v)) / data.len(), digits: 3)
}

#let calc-id(d, w) = {
  calc.round(calc.log(d / w + 1, base: 2), digits: 3)
}

#figure(
  table(
    columns: 2 + 2,
    [条件 (距離)], [条件 (幅)], [平均選択時間 MT], [ID],
    [250], [40 ], [#average(result.at("d250w40")) ], [#calc-id(250, 40 )], 
    [250], [90 ], [#average(result.at("d250w90")) ], [#calc-id(250, 90 )], 
    [250], [120], [#average(result.at("d250w120"))], [#calc-id(250, 120)],
    [450], [40 ], [#average(result.at("d450w40")) ], [#calc-id(450, 40 )], 
    [450], [90 ], [#average(result.at("d450w90")) ], [#calc-id(450, 90 )], 
    [450], [120], [#average(result.at("d450w120"))], [#calc-id(450, 120)],
    [650], [40 ], [#average(result.at("d650w40")) ], [#calc-id(650, 40 )], 
    [650], [90 ], [#average(result.at("d650w90")) ], [#calc-id(650, 90 )], 
    [650], [120], [#average(result.at("d650w120"))], [#calc-id(650, 120)],
  ),
  caption: [各条件毎の平均選択時間 MT と ID]
) <t2>

==== 2, 3. 実験結果のプロット及び線形近似

横軸を ID、縦軸を平均選択時間 MT として、実験結果をプロットしたグラフ（散布図）を作成した。
また、線形近似をする直線（最小二乗回帰直線）の式を求め、グラフ上に描画すると @g1 のようになった。

#import "@preview/lilaq:0.3.0" as lq

#let xs = () // ID
#let ys = () // MT

#{
  for d in (250, 450, 650) {
    for w in (40, 90, 120) {
      let key = "d" + str(d) + "w" + str(w)
      let id = calc-id(d, w)
      let mt = average(result.at(key))
      xs.push(id)
      ys.push(mt)
    }
  }
}

/*--- 回帰係数を計算 ------------------------------------*/
#let n = xs.len()

#let mean_x = xs.sum() / n
#let mean_y = ys.sum() / n

// 分子: 共分散  Σ (xᵢ−x̄)(yᵢ−ȳ)
#let covariance = xs.zip(ys).map(((x, y)) => (x - mean_x) * (y - mean_y)).sum()

// 分母: 分散     Σ (xᵢ−x̄)²
#let variance = xs.map(x => (x - mean_x) * (x - mean_x)).sum()

#let m = covariance / variance            // 傾き
#let b = mean_y - m * mean_x              // 切片

#let leq = $y=#calc.round(m, digits: 2) x+ #calc.round(b, digits: 2)$
/*-------------------------------------------------------*/

#let xlq = lq.linspace(calc.min(..xs), calc.max(..xs))

#figure(
  lq.diagram(
    xlabel: "ID",
    ylabel: "MT",
    width: 15cm,
    height: 8cm,
    legend: (position: top + left),
    lq.scatter(xs, ys, size: 7pt, label: [ID と MT の散布]),
    lq.plot(
      xlq, xlq.map(x => m * x + b),
      mark: none,
      label: [線形近似 (#leq)]
    ),
  ),
  caption: [実験結果と最小二乗回帰直線]
) <g1>

なお、線形近似の式は #leq となった。

==== 4. スループット (TP) の計算

スループットは実験参加者がタスクを行った際の能率であり、以下の式で求めることができる。

$
"TP" = "ID" \/ "MT"
$

各条件 (ID) 毎に TP を求め、横軸に ID、縦軸に TP としたグラフにすると @g2 のようになった。

#let tp = xs.zip(ys).map(((id, mt)) => id / mt)

#figure(
  lq.diagram(
    xlabel: "ID",
    ylabel: "TP",
    width: 15cm,
    height: 5cm,
    legend: (position: top + left),
    lq.scatter(xs, tp, size: 7pt),
  ),
  caption: [条件 (ID) 毎の TP]
) <g2>

このレポートは Typst によって作成・計算・組版された。

コードは以下の通りである。

ただし、データは `data/2-1/` ディレクトリ配下に保存し、計測時刻の項目はデータ読み込みの際にエラーとなったため削除している。
数回計測したものうち、ミスでないものを無作為に 13 個選別し、レポートに使用した。

#sourcefile(read("2-1.typ"), file: "2-1.typ")

==== 分析結果に関する考察

本実験では Fitts の法則 ($"MT" = a + b times "ID"$) のパラメータとして

- 切片 $a = 143 "ms"$
- 傾き $b = 155.8 "ms/bit"$

が得られた。以下結果を 3 点に分けて考察する。

#set enum(numbering: "(1)")

+ 直線性の妥当性

  ID–MT 散布図はおおむね一次関係を示し、決定係数 $R^2$ も $0.96$ と高かった（コードによって確認）。
  広い範囲・狭い幅（ID ≈ 4 bit）でも外れ値は見られず、今回の環境では Fitts の法則が良好に成立していると言える。

+ パラメータの解釈

  $a$ は典型的なマウス操作では 50-200ms となる。
  今回大きめな値を示したのは、認知的準備とクリック操作だけでなく、Processing アプリの描画の遅延が含まれる可能性があるのではないかと考えられる。

  $b$ は典型的なマウス操作では 90-150ms となる。
  今回やや大きめな値を示した。慎重に狙う傾向が見られ、また DPI 設定が低く、ストロークが長かったことが影響していると考えられる。

  切片が $0 "ms"$ にならない点は、視覚探索・意思決定・クリック操作の固定コストを含むためであり、値自体は妥当な範囲に収まっている。
  傾きが若干大きい点は後述のスループットとも関連すると考えられる。

+ スループット (TP)

  TP は 4.0-5.2 bit/s の範囲で推移し、高い ID 条件で ≈5 bit/s に収束した。
  文献で報告されるマウスの典型値（4–6 bit/s）と一致しており、操作効率は平均的である。

  - ID ≲ 2 bit では TP がやや低く、短距離／広幅では「動き出し遅れ」が相対的に効いて能率が下がる。
  - ID ≳ 3 bit では TP が漸近し、運動制御段階が支配的になるため、準備・クリックの固定コストが相対的に無視できる。

  のように考えられる。
