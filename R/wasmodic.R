# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   https://r-pkgs.org
#
# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'

wasmodic <- function() {
  print("WASM rules!")
}


clean_seq <- function(x) {
  lines <- unlist(strsplit(x, "\\n"))
  seq_lines <- lines[!grepl("^>", lines)]
  seq <- paste(seq_lines, collapse = "")
  seq <- toupper(gsub("[^ACGT]", "", seq))
  seq
}

gc_content <- function(seq) {
  g <- stringr::str_count(seq, "G")
  c_ <- stringr::str_count(seq, "C")
  gc <- g + c_
  pct <- if (nchar(seq) > 0) (gc / nchar(seq)) * 100 else 0
  list(gc = gc, pct = pct, len = nchar(seq))
}

rev_comp <- function(seq) {
  map <- c(A="T", C="G", G="C", T="A")
  paste0(rev(map[strsplit(seq, "")[[1]]]), collapse = "")
}
