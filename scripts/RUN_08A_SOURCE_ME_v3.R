# EXTREME HEALTH 01 — ONE-CLICK 08A canonical validation (v3)
# INSTRUCTIONS: open this file in RStudio and click Source.
# Fixes:
#   v1: JSON file-path parsing
#   v2: unnamed DESeq2 Wald-stat vectors passed to fgsea

options(stringsAsFactors = FALSE)
options(repos = c(CRAN = "https://cloud.r-project.org"))

cat("\n============================================================\n")
cat(" EXTREME HEALTH 01 — 08A canonical validation v3\n")
cat("============================================================\n\n")

get_this_file <- function() {
  ofile <- NULL
  for (i in rev(seq_len(sys.nframe()))) {
    fr <- sys.frame(i)
    if (!is.null(fr$ofile)) { ofile <- fr$ofile; break }
  }
  if (!is.null(ofile)) return(normalizePath(ofile, winslash="/", mustWork=FALSE))
  NULL
}

is_r_bundle <- function(x) {
  if (is.null(x) || !dir.exists(x)) return(FALSE)
  file.exists(file.path(x, "inputs", "pathway_sets_2026_1_Hs.json")) &&
    file.exists(file.path(x, "scripts", "analysis_08A_canonical_R.R"))
}

find_bundle <- function() {
  this_file <- get_this_file()
  candidates <- character()
  if (!is.null(this_file)) {
    d <- dirname(this_file)
    candidates <- c(candidates, d, file.path(d, "R_bundle"))
    cur <- d
    for (i in 1:5) {
      candidates <- c(candidates, file.path(cur, "R_bundle"))
      cur <- dirname(cur)
    }
  }
  candidates <- unique(c(candidates, getwd(), file.path(getwd(), "R_bundle")))
  for (x in candidates) if (is_r_bundle(x)) return(normalizePath(x, winslash="/"))
  NULL
}

bundle <- find_bundle()
if (is.null(bundle)) {
  cat("No pude localizar automáticamente la carpeta R_bundle.\n")
  cat("Selecciona la carpeta R_bundle en la ventana que aparecerá.\n\n")
  if (.Platform$OS.type == "windows") {
    bundle <- utils::choose.dir(default=getwd(), caption="Selecciona la carpeta R_bundle")
  } else {
    bundle <- file.choose()
    if (file.exists(bundle)) bundle <- dirname(bundle)
  }
}
if (is.null(bundle) || !is_r_bundle(bundle)) {
  stop("La carpeta seleccionada no parece ser R_bundle. Debe contener inputs/ y scripts/.")
}
bundle <- normalizePath(bundle, winslash="/")
cat("R_bundle localizado en:\n ", bundle, "\n\n")

out <- file.path(bundle, "R_results")
dir.create(out, recursive=TRUE, showWarnings=FALSE)
cat("Los resultados se guardarán en:\n ", out, "\n\n")

if (!requireNamespace("BiocManager", quietly=TRUE)) install.packages("BiocManager")
if (!requireNamespace("jsonlite", quietly=TRUE)) install.packages("jsonlite")

bioc_pkgs <- c("DESeq2","limma","fgsea")
missing_bioc <- bioc_pkgs[!vapply(bioc_pkgs, requireNamespace, logical(1), quietly=TRUE)]
if (length(missing_bioc)) {
  cat("Instalando paquetes Bioconductor faltantes:", paste(missing_bioc, collapse=", "), "\n")
  BiocManager::install(missing_bioc, ask=FALSE, update=FALSE)
}
still_missing <- c("jsonlite",bioc_pkgs)[!vapply(c("jsonlite",bioc_pkgs),requireNamespace,logical(1),quietly=TRUE)]
if (length(still_missing)) stop("Faltan paquetes: ", paste(still_missing,collapse=", "))
cat("Paquetes requeridos: OK\n\n")

canonical <- file.path(bundle, "scripts", "analysis_08A_canonical_R.R")
txt <- readLines(canonical, warn=FALSE)

# Patch 1 — read JSON content rather than giving fromJSON() a file path
old_json <- 'j <- fromJSON(file.path(I,"pathway_sets_2026_1_Hs.json"), simplifyVector=FALSE)'
new_json <- 'j <- fromJSON(paste(readLines(file.path(I,"pathway_sets_2026_1_Hs.json"), warn=FALSE), collapse="\\n"), simplifyVector=FALSE)'
hit_json <- which(trimws(txt) == old_json)
if (length(hit_json) == 1) txt[hit_json] <- new_json

# Patch 2 — fgsea requires a named stats vector; DESeq2 Results columns lose row names when extracted
txt <- gsub(
  'run_fgsea\\(res\\$stat,',
  'run_fgsea(setNames(res$stat, rownames(res)),',
  txt
)

# Safety checks
if (!any(grepl('paste\\(readLines\\(file.path\\(I,"pathway_sets_2026_1_Hs.json"', txt))) {
  stop("No pude aplicar/verificar de forma segura el parche JSON.")
}
n_named <- sum(grepl('run_fgsea\\(setNames\\(res\\$stat, rownames\\(res\\)\\),', txt))
if (n_named < 3) {
  stop("No pude aplicar/verificar todos los parches de nombres para fgsea. Detectados: ", n_named)
}

patched <- file.path(bundle, "scripts", "analysis_08A_canonical_R_v3_patched.R")
writeLines(txt, patched)

cat("Parche JSON: OK\n")
cat("Vectores DESeq2→fgsea con nombres de genes: OK (", n_named, " llamadas)\n\n", sep="")

cat("============================================================\n")
cat(" Ejecutando análisis canónico 08A...\n")
cat("============================================================\n\n")

oldwd <- getwd()
on.exit(setwd(oldwd), add=TRUE)
setwd(bundle)

err <- NULL
tryCatch({
  sys.source(patched, envir=new.env(parent=.GlobalEnv))
}, error=function(e) {
  err <<- conditionMessage(e)
})

if (!is.null(err)) {
  cat("\n============================================================\n")
  cat(" EL ANÁLISIS SE DETUVO CON UN ERROR\n")
  cat("============================================================\n\n")
  cat(err, "\n\n")
  cat("Haz una captura de esta parte de la consola y envíamela.\n")
  stop(err, call.=FALSE)
}

cat("\n============================================================\n")
cat(" 08A TERMINADO CORRECTAMENTE\n")
cat("============================================================\n")
cat("Carpeta de resultados:\n", out, "\n\n")
cat("Comprime la carpeta R_results completa en ZIP y súbela al chat.\n")
