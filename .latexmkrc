#! /usr/bin/env perl
$latex = 'uplatex -kanji=utf8 -kanji-internal=utf8';
$latex_silent = 'uplatex -kanji=utf8 -kanji-internal=utf8 -interaction=batchmode';
$bibtex = 'pbibtex';
$dvipdf = 'dvipdfmx %O -o %D %S';
$max_repeat = 5;
$pdf_mode = 3;
