#import "../template.typ": *
#import "@preview/tenv:0.1.2": parse_dotenv
#import "@preview/codelst:2.0.2": *

#let env = parse_dotenv(read("../.env"))

#show: project.with(
  week: "演習2",
  authors: (
    (name: env.STUDENT_NAME, email: "学籍番号：" + env.STUDENT_ID, affiliation: "所属：情報科学類"),
  ),
  date: "2025 年 6 月 19 日",
)

#show math.equation: set text(font: ("New Computer Modern Math", "Noto Serif", "Noto Serif CJK JP"))

#show raw: set text(font: "Hack Nerd Font")

本レポートは、Fitts の法則とキーストロークレベルモデル (KLM) について実験を行い、それをまとめるものである。

本演習を行った環境を以下に示す。

#sourcecode[```
$ cat /proc/version
Linux version 6.12.28_1 (voidlinux@voidlinux) (gcc (GCC) 14.2.1 20250405, GNU ld (GNU Binutils) 2.44) #1 SMP PREEMPT_DYNAMIC Sun May 11 04:22:51 UTC 2025

$ uname -a
Linux hinoki 6.12.28_1 #1 SMP PREEMPT_DYNAMIC Sun May 11 04:22:51 UTC 2025 x86_
64 GNU/Linux
```]

また、演習に使用したデバイスはデスクトップパソコンであり、ポインティングデバイスは光学式マウスである。

#include "2-1.typ"

