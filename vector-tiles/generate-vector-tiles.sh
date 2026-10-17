#!/usr/bin/env bash
set -euo pipefail

########################################
# USER CONFIGURATION - EDIT THESE
########################################

# Fixed local filename for the OSM extract
OSM_PBF="india.pbf"

# Source URL
OSM_URL="https://download.geofabrik.de/asia/india-latest.osm.pbf"

# Output directory for the generated vector tiles
OUTPUT_DIR="tiles"

# Output format: "pbf" (directory of z/x/y.pbf tiles), "mbtiles", or "pmtiles"
OUTPUT_FORMAT="pmtiles"

# Base filename for single-file formats (.mbtiles / .pmtiles), created in the
# current folder. Existing files are overwritten. Ignored when OUTPUT_FORMAT="pbf".
OUTPUT_NAME="india"

# Number of CPU cores the container is allowed to use (hard limit)
# Example: 4 or 8.0
CPUS="14"

# Maximum RAM the container is allowed to use (hard limit)
# Examples: 8g, 16g, 32g, 64g
MAX_RAM="50g"

# Number of threads for tilemaker (should usually be <= CPUS)
# Leave empty to use the value of CPUS
THREADS=""

# Temporary store directory for tilemaker (useful for large extracts)
# Leave empty to keep everything in RAM
STORE_DIR=""

# Download extra shapefiles for better low-zoom water / landcover?
# Set to "yes" or "no"
DOWNLOAD_EXTRA_DATA="yes"

# Fully regenerate tiles on each run?
# "yes" removes the existing output directory first (avoids stale tiles),
# "no"  keeps existing tiles and only overwrites matching ones.
FULL_REGENERATE="no"

# Optimize the .pmtiles archive after generation (only when OUTPUT_FORMAT="pmtiles")?
# tilemaker writes an *unclustered* archive with a single huge leaf directory, so
# the browser's first tile request pulls several MB before anything renders.
# "yes" runs the `pmtiles` CLI (native binary if available, otherwise Docker) to
#       cluster the tiles and split the directory tree into ~16 KB leaves.
# "no"  leaves the raw tilemaker output as-is.
OPTIMIZE_PMTILES="yes"

# Docker image used for the pmtiles optimization when no native `pmtiles`
# binary is found on PATH.
PMTILES_DOCKER_IMAGE="protomaps/go-pmtiles"

########################################
# END OF USER CONFIGURATION
########################################

# Resolve number of threads
if [[ -z "${THREADS}" ]]; then
  THREADS="${CPUS%.*}"   # strip decimal part if any
fi

# Resolve output target based on the chosen format
case "${OUTPUT_FORMAT}" in
  pbf)
    OUTPUT_TARGET="${OUTPUT_DIR}"
    ;;
  mbtiles|pmtiles)
    OUTPUT_TARGET="${OUTPUT_NAME}.${OUTPUT_FORMAT}"
    ;;
  *)
    echo "ERROR: Invalid OUTPUT_FORMAT '${OUTPUT_FORMAT}' (use pbf, mbtiles, or pmtiles)" >&2
    exit 1
    ;;
esac

echo "=============================================="
echo " OSM Vector Tile Generator"
echo "=============================================="
echo "OSM file   : ${OSM_PBF}"
echo "Source URL : ${OSM_URL}"
echo "Output     : ${OUTPUT_TARGET} (${OUTPUT_FORMAT})"
echo "CPUs       : ${CPUS} (hard limit)"
echo "Max RAM    : ${MAX_RAM} (hard limit)"
echo "Threads    : ${THREADS}"
echo "Extra data : ${DOWNLOAD_EXTRA_DATA}"
echo "Full regen : ${FULL_REGENERATE}"
echo "Optimize   : ${OPTIMIZE_PMTILES}"
echo

########################################
# Download / Update OSM PBF
########################################

download_needed=true

if [[ -f "${OSM_PBF}" ]]; then
  echo "Local file found: ${OSM_PBF}"
  echo "Checking if a newer version is available on the server..."

  # Get remote Last-Modified timestamp (epoch)
  remote_mtime=$(curl -sI -L "${OSM_URL}" | grep -i "^Last-Modified:" | tail -1 | cut -d' ' -f2- | xargs -I{} date -d "{}" +%s 2>/dev/null || true)

  if [[ -n "${remote_mtime}" ]]; then
    local_mtime=$(stat -c %Y "${OSM_PBF}" 2>/dev/null || stat -f %m "${OSM_PBF}")

    if [[ "${local_mtime}" -ge "${remote_mtime}" ]]; then
      echo "Local file is up-to-date (or newer). Skipping download."
      download_needed=false
    else
      echo "Newer version available on server. Will re-download."
    fi
  else
    echo "Could not retrieve remote timestamp. Will re-download to be safe."
  fi
else
  echo "Local file not found. Will download."
fi

if [[ "${download_needed}" == true ]]; then
  echo
  echo "Downloading ${OSM_PBF} with aria2c (resume + multiple connections)..."
  echo

  aria2c \
    -c \
    -x 16 \
    -s 16 \
    --auto-file-renaming=false \
    --allow-overwrite=true \
    --remote-time \
    -o "${OSM_PBF}" \
    "${OSM_URL}"

  echo
  echo "Download finished."
else
  echo "Using existing local file."
fi

########################################
# Download extra shapefiles (optional)
########################################

# Extract a zip using whichever tool is available on the host
extract_zip() {
  local zip="$1"
  local dest="${2:-.}"
  mkdir -p "${dest}"
  if command -v unzip >/dev/null 2>&1; then
    unzip -o "${zip}" -d "${dest}"
  elif command -v 7z >/dev/null 2>&1; then
    7z x -y -o"${dest}" "${zip}"
  elif command -v 7za >/dev/null 2>&1; then
    7za x -y -o"${dest}" "${zip}"
  elif command -v bsdtar >/dev/null 2>&1; then
    bsdtar -xf "${zip}" -C "${dest}"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -m zipfile -e "${zip}" "${dest}"
  else
    echo "ERROR: no zip extraction tool found (tried unzip, 7z, 7za, bsdtar, python3)." >&2
    echo "       Please install one (e.g. 'sudo apt install unzip') and re-run." >&2
    return 1
  fi
}

if [[ "${DOWNLOAD_EXTRA_DATA}" == "yes" ]]; then
  echo
  echo "Checking extra shapefiles (coastline + landcover)..."

  # --- Coastline (ocean) ---
  if [[ ! -f "coastline/water_polygons.shp" ]]; then
    echo "→ Downloading coastline data..."
    mkdir -p coastline
    cd coastline
    aria2c -c -x 8 -s 8 --auto-file-renaming=false \
      -o water-polygons-split-4326.zip \
      https://osmdata.openstreetmap.de/download/water-polygons-split-4326.zip
    extract_zip water-polygons-split-4326.zip .
    # Flatten the directory structure
    if [[ -d water-polygons-split-4326 ]]; then
      mv water-polygons-split-4326/* .
      rmdir water-polygons-split-4326
    fi
    cd ..
    echo "  Coastline ready."
  else
    echo "→ Coastline already present."
  fi

  # --- Landcover ---
  mkdir -p landcover

  # Urban areas
  if [[ ! -f "landcover/ne_10m_urban_areas/ne_10m_urban_areas.shp" ]]; then
    echo "→ Downloading urban areas..."
    cd landcover
    aria2c -c -x 8 -s 8 --auto-file-renaming=false \
      -o ne_10m_urban_areas.zip \
      https://naciscdn.org/naturalearth/10m/cultural/ne_10m_urban_areas.zip
    extract_zip ne_10m_urban_areas.zip ne_10m_urban_areas
    cd ..
    echo "  Urban areas ready."
  else
    echo "→ Urban areas already present."
  fi

  # Antarctic ice shelves (harmless for India)
  if [[ ! -f "landcover/ne_10m_antarctic_ice_shelves_polys/ne_10m_antarctic_ice_shelves_polys.shp" ]]; then
    echo "→ Downloading Antarctic ice shelves..."
    cd landcover
    aria2c -c -x 8 -s 8 --auto-file-renaming=false \
      -o ne_10m_antarctic_ice_shelves_polys.zip \
      https://naciscdn.org/naturalearth/10m/physical/ne_10m_antarctic_ice_shelves_polys.zip
    extract_zip ne_10m_antarctic_ice_shelves_polys.zip ne_10m_antarctic_ice_shelves_polys
    cd ..
    echo "  Ice shelves ready."
  else
    echo "→ Ice shelves already present."
  fi

  # Glaciers
  if [[ ! -f "landcover/ne_10m_glaciated_areas/ne_10m_glaciated_areas.shp" ]]; then
    echo "→ Downloading glaciers..."
    cd landcover
    aria2c -c -x 8 -s 8 --auto-file-renaming=false \
      -o ne_10m_glaciated_areas.zip \
      https://naciscdn.org/naturalearth/10m/physical/ne_10m_glaciated_areas.zip
    extract_zip ne_10m_glaciated_areas.zip ne_10m_glaciated_areas
    cd ..
    echo "  Glaciers ready."
  else
    echo "→ Glaciers already present."
  fi

  echo "Extra data check complete."
else
  echo
  echo "Skipping extra shapefile download (DOWNLOAD_EXTRA_DATA=no)"
fi

########################################
# PMTiles optimization helpers
########################################

# Run `pmtiles cluster FILE`. Docker is preferred because the generation already
# depends on it and the official image ships the correct Go CLI; a native
# `pmtiles` binary is used only when Docker is unavailable.
run_pmtiles_cluster() {
  local file="$1"
  if command -v docker >/dev/null 2>&1; then
    docker run --rm \
      --user "$(id -u):$(id -g)" \
      -v "$(pwd)":/data \
      "${PMTILES_DOCKER_IMAGE}" \
      cluster "/data/${file}"
  elif command -v pmtiles >/dev/null 2>&1; then
    pmtiles cluster "${file}"
  else
    echo "ERROR: neither docker nor the pmtiles CLI is available." >&2
    return 1
  fi
}

# Rewrite the freshly generated archive so its directory tree is split into many
# small leaves instead of one multi-MB leaf. This is what keeps the browser's
# first tile request to ~tens of KB rather than several MB.
optimize_pmtiles() {
  local file="$1"
  local output

  echo
  echo "Optimizing ${file} (cluster + split directory tree)..."

  if output="$(run_pmtiles_cluster "${file}" 2>&1)"; then
    echo "${output}"
    return 0
  fi

  if grep -q "already clustered" <<<"${output}"; then
    echo "Archive is already clustered; skipping optimization."
    return 0
  fi

  echo "${output}" >&2
  echo "ERROR: pmtiles cluster failed for ${file}." >&2
  return 1
}

########################################
# Generate Vector Tiles
########################################

if [[ "${FULL_REGENERATE}" == "yes" ]]; then
  if [[ "${OUTPUT_FORMAT}" == "pbf" ]]; then
    if [[ -d "${OUTPUT_TARGET}" ]]; then
      echo "Full regenerate enabled: removing existing ${OUTPUT_TARGET}/ ..."
      rm -rf "${OUTPUT_TARGET}"
    fi
  elif [[ -f "${OUTPUT_TARGET}" ]]; then
    echo "Full regenerate enabled: removing existing ${OUTPUT_TARGET} ..."
    rm -f "${OUTPUT_TARGET}"
  fi
fi

if [[ "${OUTPUT_FORMAT}" == "pbf" ]]; then
  mkdir -p "${OUTPUT_TARGET}"
fi

echo
echo "Generating MapLibre-compatible vector tiles..."
echo "  Input : ${OSM_PBF}"
echo "  Output: ${OUTPUT_TARGET}"
echo

DOCKER_CMD=(
  docker run --rm -it
  --user 1000:1000
  --cpus="${CPUS}"
  --memory="${MAX_RAM}"
  --memory-swap="${MAX_RAM}"          # prevent using swap beyond the limit
  -v "$(pwd)":/data
  -w /data
  -e OMP_NUM_THREADS="${THREADS}"
  ghcr.io/systemed/tilemaker:master
  "${OSM_PBF}"
  --output "${OUTPUT_TARGET}"
  --threads "${THREADS}"
  --config /usr/src/app/resources/config-openmaptiles.json
  --process /usr/src/app/resources/process-openmaptiles.lua
)

# Optionally add --store if configured
if [[ -n "${STORE_DIR}" ]]; then
  mkdir -p "${STORE_DIR}"
  DOCKER_CMD+=(--store "${STORE_DIR}")
fi

# Run tilemaker
"${DOCKER_CMD[@]}"

if [[ "${OUTPUT_FORMAT}" == "pmtiles" && "${OPTIMIZE_PMTILES}" == "yes" ]]; then
  optimize_pmtiles "${OUTPUT_TARGET}"
fi

echo
echo "=============================================="
echo " Done!"
echo "=============================================="

if [[ "${OUTPUT_FORMAT}" == "pbf" ]]; then
  echo "Tiles are in: ${OUTPUT_TARGET}/"
  echo
  echo "Example structure:"
  find "${OUTPUT_TARGET}" -type f -name "*.pbf" | head -8 || true
  echo "..."
  echo
  echo "You can serve them with:"
  echo "  npx serve ${OUTPUT_TARGET}"
  echo "  # or:  python -m http.server 8000 --directory ${OUTPUT_TARGET}"
  echo
  echo "MapLibre source example:"
  echo '  map.addSource("osm", {'
  echo '    type: "vector",'
  echo '    tiles: ["http://localhost:8000/{z}/{x}/{y}.pbf"],'
  echo '    minzoom: 0,'
  echo '    maxzoom: 14'
  echo '  });'
elif [[ "${OUTPUT_FORMAT}" == "mbtiles" ]]; then
  echo "Tiles written to: ${OUTPUT_TARGET}"
  echo
  echo "Serve the .mbtiles with an MBTiles-capable server, e.g.:"
  echo "  docker run --rm -v \"\$(pwd)\":/data -p 8080:8080 maptiler/tileserver-gl ${OUTPUT_TARGET}"
else
  echo "Tiles written to: ${OUTPUT_TARGET}"
  echo
  echo "Inspect the directory layout (root / leaf / metadata sizes):"
  if command -v pmtiles >/dev/null 2>&1; then
    echo "  pmtiles show ${OUTPUT_TARGET}"
  else
    echo "  docker run --rm -v \"\$(pwd)\":/data ${PMTILES_DOCKER_IMAGE} show /data/${OUTPUT_TARGET}"
  fi
  echo
  echo "Serve the .pmtiles with a PMTiles-capable server, e.g.:"
  echo "  npx pmtiles serve ."
  echo "  # or a Z/X/Y proxy (normal cacheable tile URLs):"
  echo "  docker run --rm -p 8080:8080 -v \"\$(pwd)\":/data ${PMTILES_DOCKER_IMAGE} serve /data"
fi
echo