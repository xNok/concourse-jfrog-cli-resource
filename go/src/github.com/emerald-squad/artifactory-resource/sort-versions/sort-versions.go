package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"sort"

	"github.com/emerald-squad/artifactory-resource/sort-versions/versioning"
)

type DefaultSort []versioning.ComparableVersion

func (sv DefaultSort) Len() int {
	return len(sv)
}

func (sv DefaultSort) Less(i, j int) bool {
	return sv[i].CompareTo(sv[j]) < 0
}

func (sv DefaultSort) Swap(i, j int) {
	sv[i], sv[j] = sv[j], sv[i]
}

func main() {
	var jsonArg string
	flag.StringVar(&jsonArg, "json", "", "maven versions JSON array ex.: [\"version2\", \"version1\"].")
	flag.Parse()

	if jsonArg == "" {
		flag.PrintDefaults()
		return
	}

	var versionStringsIn []string
	json.Unmarshal([]byte(jsonArg), &versionStringsIn)

	var sortedVersions []versioning.ComparableVersion
	for _, versionString := range versionStringsIn {
		sortedVersions = append(sortedVersions, versioning.NewComparableVersion(versionString))
	}
	sort.Sort(DefaultSort(sortedVersions))

	var versionStringsOut []string
	for _, comparableVersion := range sortedVersions {
		versionStringsOut = append(versionStringsOut, comparableVersion.String())
	}

	jsonOutput, _ := json.Marshal(versionStringsOut)

	fmt.Println(string(jsonOutput))
}
