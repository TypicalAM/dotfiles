#!/usr/bin/env bash
# SBOM + vulnerability scan of a toolbox image, run locally (needs Linux nix).
#
#   ./toolbox/vulncheck.sh                     # core profile
#   ./toolbox/vulncheck.sh k8s                 # a named profile from tools.nix
#   ./toolbox/vulncheck.sh base,net,aws        # ad-hoc mix of groups
#   ./toolbox/vulncheck.sh k8s --sbom-only     # write the SBOM, skip the scan
#   OUT=~/reports ./toolbox/vulncheck.sh aws
#
# Writes to $OUT (default ./sbom):
#   <name>.cdx.json  <name>.spdx.json  <name>.sbom.csv    the SBOM
#   <name>.vulns.csv                                      nix packages (vulnix, grype, OSV)
#   <name>.nvim-vulns.json                                nvim plugins (OSV, by commit)
#
# Exits 1 when anything not in toolbox/vulns-whitelist.csv is found, so it can
# gate a build. Whitelist format: see the sbomnix vulnxscan README.
set -euo pipefail

what=core
scan=1
for arg; do
	case "$arg" in
	--sbom-only) scan= ;;
	-*) sed -n '2,17s/^# \{0,1\}//p' "$0"; exit 2 ;;
	*) what=$arg ;;
	esac
done

src=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P) # -P: path: flakes reject symlinked dirs
out=${OUT:-./sbom}
nix=(nix --extra-experimental-features 'nix-command flakes')

if [ "${what#*,}" != "$what" ]; then
	args="groups = [ $(printf '"%s" ' ${what//,/ })];"
else
	args="profile = \"$what\";"
fi
tb="((builtins.getFlake \"path:$src\").lib.\${builtins.currentSystem}.mkToolbox { $args })"

name=$("${nix[@]}" eval --raw --impure --expr "$tb.name")
echo "building $name entrypoint..." >&2
target=$("${nix[@]}" build --no-link --print-out-paths --impure --expr "$tb.entrypoint")
plugins=$("${nix[@]}" eval --json --impure --expr "$tb.nvimSbomComponents")

# the scanners come from the flake's own nixpkgs pin, not whatever the registry says
sbomnix=$("${nix[@]}" build --no-link --print-out-paths --inputs-from "path:$src" nixpkgs#sbomnix)/bin
jq=$("${nix[@]}" build --no-link --print-out-paths --inputs-from "path:$src" nixpkgs#jq.bin)/bin/jq

mkdir -p "$out"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# --- sbom ---------------------------------------------------------------------

echo "sbom: $target" >&2
"$sbomnix/sbomnix" "$target" \
	--cdx "$tmp/cdx.json" --spdx "$tmp/spdx.json" --csv "$out/$name.sbom.csv" >&2

"$jq" --argjson p "$plugins" '.components += $p' \
	"$tmp/cdx.json" >"$out/$name.cdx.json"

"$jq" --argjson p "$plugins" '
	.documentDescribes[0] as $root
	| [$p[] | {
		SPDXID: ("SPDXRef-nvim-plugin-" + (.name | gsub("[^A-Za-z0-9.-]"; "-"))),
		name, versionInfo: .version,
		downloadLocation: ("git+" + .externalReferences[0].url + "@" + .version),
		filesAnalyzed: false,
		licenseConcluded: "NOASSERTION", licenseDeclared: "NOASSERTION", copyrightText: "NOASSERTION",
		externalRefs: [{ referenceCategory: "PACKAGE-MANAGER", referenceType: "purl", referenceLocator: .purl }]
	}] as $pkgs
	| .packages += $pkgs
	| .relationships += [$pkgs[] | { spdxElementId: $root, relationshipType: "DEPENDS_ON", relatedSpdxElement: .SPDXID }]
' "$tmp/spdx.json" >"$out/$name.spdx.json"

printf 'sbom: %s components (%s nvim plugins) -> %s/%s.{cdx,spdx}.json\n' \
	"$("$jq" '.components | length' "$out/$name.cdx.json")" \
	"$("$jq" length <<<"$plugins")" "$out" "$name"

[ -n "$scan" ] || exit 0

# --- nix packages ---------------------------------------------------------------

# Scans the store path rather than the SBOM: only then does vulnix run, and it
# is the scanner that knows which nixpkgs patches already fix a CVE.
whitelist=()
[ -f "$src/toolbox/vulns-whitelist.csv" ] && whitelist=(--whitelist "$src/toolbox/vulns-whitelist.csv")
"$sbomnix/vulnxscan" "$target" -o "$out/$name.vulns.csv" "${whitelist[@]}"

# --- nvim plugins ---------------------------------------------------------------

# OSV resolves a bare commit against the affected git ranges of its advisories.
"$jq" '{ queries: [.[] | { commit: .version }] }' <<<"$plugins" |
	curl -fsS -X POST -H 'Content-Type: application/json' --data @- \
		https://api.osv.dev/v1/querybatch |
	"$jq" --argjson p "$plugins" '
		[.results | to_entries[] | select(.value.vulns) |
			{ plugin: $p[.key].name, commit: $p[.key].version, vulns: [.value.vulns[].id] }]
	' >"$out/$name.nvim-vulns.json"

# --- verdict --------------------------------------------------------------------

# whitelisted rows stay in the csv, marked "True" in the whitelist column
nix_vulns=$(tail -n +2 "$out/$name.vulns.csv" | grep -vc '"True","[^"]*"$' || true)
nvim_vulns=$("$jq" '[.[].vulns[]] | length' "$out/$name.nvim-vulns.json")

if [ "$nvim_vulns" -gt 0 ]; then
	echo
	echo "nvim plugins:"
	"$jq" -r '.[] | "  \(.plugin) @ \(.commit[:12]): \(.vulns | join(", "))"' "$out/$name.nvim-vulns.json"
fi

echo
printf '%s: %s nix package findings, %s nvim plugin findings (reports in %s)\n' \
	"$name" "$nix_vulns" "$nvim_vulns" "$out"
[ "$nix_vulns" -eq 0 ] && [ "$nvim_vulns" -eq 0 ]
