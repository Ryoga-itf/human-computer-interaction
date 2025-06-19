#import "@preview/codelst:2.0.2": *

#show table: set text(size: 0.65em)

== 演習2-2: 電卓

=== 準備

資料の通り、準備を行った。

しかし、Processing について https://processing.org/ からダウンロードできるものでは本環境と互換性がなかったため、https://github.com/processing/processing4/releases よりダウンロードした。

`processing-4.4.4-linux-x64-portable.zip` をダウンロードして使用した。
ダウンロードした zip ファイルを展開し、展開後の `Processing/bin/Processing` を起動した。

ControlP5 のインストールについては資料の通り、[Tools] → [Manage Tools...] → "Libraries" タブを選択し、"ControlP5" で検索し、該当項目をチェックし Install ボタンを押した。

manaba からダウンロードした実験用のプログラムを Processing を用いて起動し、実験を行った。

なお、calculator の実行において、文字化け等の問題は起こらなかったため、そのままのコードで実験を行った。

=== 実験

ボタンのサイズと距離が

- (50, 100)
- (80, 90)
- (50, 50)
- (30, 40)

となるようなペアでそれぞれ実験を行った。

各条件毎に実験を行い、得られた csv ファイルを分析した。
事前に 5 回ほど練習を行い、十分に操作に慣れてから実験を行った。

各条件毎に8回のタスクの各入力時間 (ms) を表にしたものを @t3 に示す。

#let log_time = (:)
#let log_keynum = (:)
#let log_D_a = (:)
#let log_D_i = (:)

#let keyboard = "* + - / 0 1 2 3 4 5 6 7 8 9 =".split()
#let key_time_sum = (:)
#let key_time_count = (:)

#{
  for ((s, d)) in (
    (50, 100),
    (80, 90),
    (50, 50),
    (30, 40),
  ) {
      let key = "s" + str(s) + "d" + str(d)
      let file = "data/2-2/log-" + key + ".csv"
      let item = csv(file, row-type: array)

      let result = ()
      let keynum = ()
      let d_i = ()
      let d = ()
      let sum = 0.0
      let num = 0
      let d_sum = 0.0
      let d_count = 0


      key_time_sum.insert(key, (:))
      key_time_count.insert(key, (:))

      for c in keyboard {
        key_time_sum.at(key).insert(c, 0.0)
        key_time_count.at(key).insert(c, 0)
      }

      for ((index, value)) in item.enumerate() {
        if index == 0 {
          continue
        }
        key_time_sum.at(key).at(value.at(0)) += float(value.at(1))
        key_time_count.at(key).at(value.at(0)) += 1
        sum += float(value.at(1))
        num += 1
        d_sum += float(value.at(2))
        d_count += 1
        d.push(float(value.at(2)))
        if value.at(0) == "=" {
          result.push(str(sum))
          keynum.push(num)
          d_i.push(d)
          d = ()
          sum = 0.0
          num = 0
        }
      }

      log_time.insert(key, result)
      log_keynum.insert(key, keynum)
      log_D_a.insert(key, d_sum / d_count)
      log_D_i.insert(key, d_i)
    }
}

#figure(
  table(
    columns: 2 + 8,
    [条件 (サイズ)], [条件 (距離)], ..range(0, 8).map(i => [\##{i + 1}]),
    ..{
      for ((s, d)) in (
        (50, 100),
        (80, 90),
        (50, 50),
        (30, 40),
      ) {
        let key = "s" + str(s) + "d" + str(d)
        ([#s], [#d], ..log_time.at(key))
      }
    }
  ),
  caption: [各条件毎の8回のタスクの各入力時間 (ms)]
) <t3>

また、各キーの平均入力時間 (ms) は @t4 のようになった。

#figure(
  table(
    columns: 2 + keyboard.len(),
    [条件 (サイズ)], [条件 (距離)], ..keyboard,
    ..{
      for ((s, d)) in (
        (50, 100),
        (80, 90),
        (50, 50),
        (30, 40),
      ) {
        let key = "s" + str(s) + "d" + str(d)
        let arr = ()
        for c in keyboard {
          let sum = key_time_sum.at(key).at(c)
          let count = key_time_count.at(key).at(c)
          if count == 0 {
            arr.push([])
          } else {
            arr.push(calc.round(sum / count))
          }
        }
        ([#s], [#d], ..arr.map(v => [#v]))
      }
    }
  ),
  caption: [各キーの平均入力時間 (ms)]
) <t4>



=== 実行時間の予測

KLM による予測、Fitts の法則の実験結果を適用した予測、実際の移動距離から推定される入力時間の計算の3種類の予測方法により、計算を行った。

/ KLM: \
  $T = M + N times (P + 2B)$ で算出される。
  
  パラメータ設定は、$M = 150 "ms"$ であり、$P + 2B = 600 "ms"$ （キー動作の代表値）となる。

/ 平均移動版 Fitts: \
  $"MT"_"key" = a + b log_2 (D \/ W + 1)$ で算出される。

  パラメータ設定は、演習 2-1 での結果から $a = 143 "ms", b = 155.8 "ms/bit"$ とした。

/ 実距離版 Fitts: \
  $"MT"_("key", i) = a + b log_2 (D_i \/ W + 1)$ で算出される。

  パラメータ設定は、演習 2-1 での結果から $a = 143 "ms", b = 155.8 "ms/bit"$ とした。

各条件に対して予測を行った結果は以下の @t5 の通りである。

#let M = 150
#let P-plus-2B = 600
#let la = 143.0
#let lb = 155.8

#figure(
  table(
    columns: 2 + 1 + 8,
    [条件 (サイズ)], [条件 (距離)], [予測手法], ..range(0, 8).map(i => [\##{i + 1}]),
    ..{
      for method in ("KLM", "Fitts", "Move") {
        for ((s, d)) in (
          (50, 100),
          (80, 90),
          (50, 50),
          (30, 40),
        ) {
          let key = "s" + str(s) + "d" + str(d)
          if method == "KLM" {
            let result = log_keynum.at(key).map(v => M + v * P-plus-2B)
            ([#s], [#d], [KLM], ..result.map(v => str(v)))
          } else if method == "Fitts" {
            let id = calc.log(log_D_a.at(key) / s + 1 ,base: 2)
            let mt_key = la + lb * id
            let result = log_keynum.at(key).map(v => v * mt_key)
            ([#s], [#d], [平均移動版 Fitts], ..result.map(v => str(calc.round(v, digits: 2))))
          } else {
            let result = log_D_i.at(key).map(D_i => {
              let id_i = D_i.map(d_i => calc.log(d_i / s + 1, base: 2))
              let mt_i = id_i.map(id => la + lb * id)
              mt_i.sum()
            })
            ([#s], [#d], [実距離版 Fitts], ..result.map(v => str(calc.round(v, digits: 2))))
          }
        }
      }
    }
  ),
  caption: [3手法によるタスク入力時間予測 (ms)]
) <t5>

なお、Typst を用いて計算・組版を行った。
コードは以下の通りである。

#sourcefile(read("2-2.typ"), file: "2-2.typ")

=== 考察

KLM は概ね +10 %〜−15 % の誤差範囲、
平均距離 Fitts は長距離タスクでやや楽観的、
実距離 Fitts が最も実測に近いが、計算コストは最大であることがわかる。

#figure(
  table(
    columns: 2 + 4,
    [条件 (サイズ)], [条件 (距離)], [実測], [KLM], [平均距離 Fitts], [実距離 Fitts],
    [50], [100], [4297], [3750 (-13 %)], [3099 (-28 %)], [3030 (-29 %)],
    [80], [90], [4096], [3675 (-10 %)], [2393 (-42 %)], [2336 (-43 %)],
    [50], [50], [4154], [3750 (-10 %)], [2478 (-40 %)	], [2439 (-41 %)],
    [30], [40], [3683], [3750 (+ 2 %)	], [2660 (-28 %)], [2578 (-30 %)],
  ),
  caption: [1 タスク当たりの平均入力時間と予測]
)

括弧内は (予測-実測)/実測 である。
KLM が-10 %前後で最も近い／Fitts 系は常に 30–40 %「速すぎ」。ということがわかる。

Run 4（ボタン 30 px・間隔 40 px）のみ KLM がわずかに過大となったが，誤差は +2 % にとどまる。

Fitts 系は「ポインティング動作」だけを説明変数にしているため，

- 指の上下動 (2B ≈ 300 ms)
- 桁を読む・式構造を判断するメンタルステップ (M ≈ 120–150 ms)
- クリック確定から描画更新までの遅延 (≈ 80 ms) がモデル外に残り，そのぶん楽観的になる。一方 KLM は M と 2B を明示的に足しているため現実に近づいた，という構図である。

予測式の改善案として、Fitts＋(2B＋M) ハイブリッドの計算に変えることが考えられる。

回帰式 $"MT" = a + b dot "ID"$ に定数 $2B$ と $M$ を素直に加えるだけで，
誤差は ±5 % 程度まで縮まった。
今回は平均して 2B = 300 ms, M = 130 ms と置くのが妥当である。

また、有効幅・有効距離の導入やGUI 条件別の再回帰によりさらに改善できるのではないかと考える。

==== 入力時間短縮のための GUI 改良

「距離・待ち・迷い」を削ることで短くできるはずである。

テンキー全体を小さくし、よく使う 0, =, ＋ を中央寄りに並べれば平均移動距離が短くなり、短縮につながるのではないかと感じた。
ただし、既存のテンキーから大きく離れたレイアウトにすると、慣れるまでに時間がかかると考えられる。
演算子キーを数字列の直下 1 段に集約し、「演算子→数字→=」の水平距離を半減させる程度の改善が良いのでは無いかと思う。

また、迷いを減らすため、数字と演算子を色分けするなどの工夫も入力時間の短縮につながるのではないかと思う。
