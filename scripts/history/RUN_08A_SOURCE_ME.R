# EXTREME HEALTH 01 — ONE-CLICK 08A canonical validation
# INSTRUCTIONS: Open this file in RStudio and click Source.
# It will locate the R_bundle folder, install missing packages, run the canonical
# DESeq2/limma/fgsea analysis, and create R_results automatically.

options(stringsAsFactors = FALSE)
options(repos = c(CRAN = "https://cloud.r-project.org"))

cat("\n============================================================\n")
cat(" EXTREME HEALTH 01 — 08A canonical validation\n")
cat("============================================================\n\n")

# ---------- 1. Find this script and/or the R_bundle folder ----------
get_this_file <- function() {
  # Works when sourced from RStudio/source().
  ofile <- NULL
  for (i in rev(seq_len(sys.nframe()))) {
    fr <- sys.frame(i)
    if (!is.null(fr$ofile)) {
      ofile <- fr$ofile
      break
    }
  }
  if (!is.null(ofile)) return(normalizePath(ofile, winslash = "/", mustWork = FALSE))
  return(NA_character_)
}

this_file <- get_this_file()
this_dir <- if (!is.na(this_file)) dirname(this_file) else getwd()

is_bundle <- function(x) {
  file.exists(file.path(x, "scripts", "analysis_08A_canonical_R.R")) &&
    dir.exists(file.path(x, "inputs"))
}

candidates <- unique(c(
  this_dir,
  dirname(this_dir),
  getwd(),
  file.path(this_dir, "R_bundle"),
  file.path(dirname(this_dir), "R_bundle"),
  file.path(getwd(), "R_bundle")
))

bundle <- candidates[vapply(candidates, is_bundle, logical(1))]

if (length(bundle) == 0) {
  cat("No pude localizar automáticamente la carpeta R_bundle.\n")
  cat("Selecciona la carpeta R_bundle en la ventana que aparecerá.\n\n")

  chosen <- NULL
  if (.Platform$OS.type == "windows" && exists("choose.dir")) {
    chosen <- choose.dir(caption = "Selecciona la carpeta R_bundle")
  }

  if (is.null(chosen) || is.na(chosen) || !nzchar(chosen)) {
    chosen <- readline("Pega aquí la ruta completa a la carpeta R_bundle y pulsa Enter: ")
  }

  chosen <- gsub('^"|"$', '', chosen)
  chosen <- normalizePath(chosen, winslash = "/", mustWork = FALSE)
  if (!is_bundle(chosen)) {
    stop(
      "La carpeta seleccionada no parece ser R_bundle. Debe contener 'inputs/' y ",
      "'scripts/analysis_08A_canonical_R.R'."
    )
  }
  bundle <- chosen
} else {
  bundle <- bundle[[1]]
}

bundle <- normalizePath(bundle, winslash = "/", mustWork = TRUE)
out_dir <- file.path(bundle, "R_results")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

cat("R_bundle localizado en:\n  ", bundle, "\n\n", sep = "")
cat("Los resultados se guardarán en:\n  ", out_dir, "\n\n", sep = "")

# ---------- 2. Install required packages automatically ----------
cran_needed <- c("BiocManager", "jsonlite")
for (pkg in cran_needed) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat("Instalando paquete CRAN: ", pkg, " ...\n", sep = "")
    install.packages(pkg, dependencies = TRUE)
  }
}

bioc_needed <- c("DESeq2", "limma", "fgsea")
missing_bioc <- bioc_needed[!vapply(bioc_needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_bioc) > 0) {
  cat("\nInstalando paquetes Bioconductor: ", paste(missing_bioc, collapse = ", "), " ...\n", sep = "")
  cat("Esto puede tardar varios minutos la primera vez.\n\n")
  BiocManager::install(missing_bioc, ask = FALSE, update = FALSE)
}

still_missing <- c(
  cran_needed[!vapply(cran_needed, requireNamespace, logical(1), quietly = TRUE)],
  bioc_needed[!vapply(bioc_needed, requireNamespace, logical(1), quietly = TRUE)]
)
if (length(still_missing) > 0) {
  stop(
    "No se pudieron instalar/cargar estos paquetes: ",
    paste(still_missing, collapse = ", "),
    ". Haz una captura del error de instalación y envíamela."
  )
}

suppressPackageStartupMessages({
  library(DESeq2)
  library(limma)
  library(fgsea)
  library(jsonlite)
})

cat("\nPaquetes requeridos: OK\n")

# ---------- 3. Run the canonical script as if called from Rscript ----------
canonical <- file.path(bundle, "scripts", "analysis_08A_canonical_R.R")
if (!file.exists(canonical)) stop("No encuentro el script canónico: ", canonical)

# The canonical script expects commandArgs(trailingOnly=TRUE) to return:
#   c(base, out)
# Mask commandArgs temporarily while sourcing, then restore it.
had_global_commandArgs <- exists("commandArgs", envir = .GlobalEnv, inherits = FALSE)
if (had_global_commandArgs) old_global_commandArgs <- get("commandArgs", envir = .GlobalEnv)

assign("commandArgs", function(trailingOnly = FALSE) {
  if (isTRUE(trailingOnly)) return(c(bundle, out_dir))
  base::commandArgs(trailingOnly = FALSE)
}, envir = .GlobalEnv)

on.exit({
  if (had_global_commandArgs) {
    assign("commandArgs", old_global_commandArgs, envir = .GlobalEnv)
  } else if (exists("commandArgs", envir = .GlobalEnv, inherits = FALSE)) {
    rm("commandArgs", envir = .GlobalEnv)
  }
}, add = TRUE)

cat("\n============================================================\n")
cat(" Ejecutando análisis canónico 08A...\n")
cat("============================================================\n\n")

start_time <- Sys.time()
err <- NULL
tryCatch(
  {
    sys.source(canonical, envir = .GlobalEnv)
  },
  error = function(e) {
    err <<- e
  }
)
end_time <- Sys.time()

# Restore commandArgs immediately.
if (had_global_commandArgs) {
  assign("commandArgs", old_global_commandArgs, envir = .GlobalEnv)
} else if (exists("commandArgs", envir = .GlobalEnv, inherits = FALSE)) {
  rm("commandArgs", envir = .GlobalEnv)
}

if (!is.null(err)) {
  cat("\n============================================================\n")
  cat(" EL ANÁLISIS SE DETUVO CON UN ERROR\n")
  cat("============================================================\n")
  cat("\n", conditionMessage(err), "\n\n", sep = "")
  cat("Haz una captura de esta parte de la consola y envíamela.\n")
  stop(err)
}

# ---------- 4. Final checks ----------
files_created <- list.files(out_dir, recursive = TRUE, full.names = FALSE)

cat("\n============================================================\n")
cat(" 08A TERMINADO CORRECTAMENTE\n")
cat("============================================================\n\n")
cat("Duración: ", round(as.numeric(difftime(end_time, start_time, units = "mins")), 2), " minutos\n", sep = "")
cat("Archivos creados: ", length(files_created), "\n\n", sep = "")
cat("Carpeta de resultados:\n  ", out_dir, "\n\n", sep = "")

if (length(files_created) > 0) {
  cat("Primeros archivos:\n")
  cat(paste0("  - ", head(files_created, 20), collapse = "\n"), "\n\n")
}

cat("SIGUIENTE PASO:\n")
cat("1. Abre la carpeta R_results.\n")
cat("2. Comprímela completa como ZIP.\n")
cat("3. Súbeme ese ZIP en ChatGPT.\n\n")
cat("No necesitas interpretar ningún resultado manualmente.\n")
