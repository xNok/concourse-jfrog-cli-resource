package versioning

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/golang-collections/collections/stack"
)

// ComparableVersion - Generic implementation of version comparison.
//
// Features:
// - mixing of '-' (hyphen) and '.' (dot) separators,
// - transition between characters and digits also constitutes a separator: 1.0alpha1 =&gt; [1, 0, alpha, 1]
// - unlimited number of version components,
// - version components in the text can be digits or strings,
// - strings are checked for well-known qualifiers and the qualifier ordering is used for version ordering. Well-known qualifiers (case insensitive) are:<ul>
//     - alpha or a
//     - beta or b
//     - milestone or m
//     - rc or cr
//     - snapshot
//     - (the empty string) or ga or final
//     - sp
//     Unknown qualifiers are considered after known qualifiers, with lexical order (always case insensitive), a hyphen usually precedes a qualifier, and is always less important than something preceded with a dot.
type ComparableVersion struct {
	value     string
	canonical string
	items     Item
}

// NewComparableVersion ComparableVersion constructor
func NewComparableVersion(version string) ComparableVersion {
	cv := new(ComparableVersion)
	cv.value = version
	cv.items = parseVersion(version)
	cv.canonical = fmt.Sprintf("%s", cv.items)
	return *cv
}

func parseVersion(version string) Item {
	items := NewListItem()

	versionLower := strings.ToLower(version)

	list := items

	stack := stack.New()
	stack.Push(items)

	isDigit := false

	startIndex := 0

	for i, r := range versionLower {
		c := string(r)

		if c == "." {
			if i == startIndex {
				list.Add(IntegerItemZero)
			} else {
				runes := []rune(versionLower)
				list.Add(parseItem(isDigit, string(runes[startIndex:i])))
			}
			startIndex = i + 1
		} else if c == "-" {
			if i == startIndex {
				list.Add(IntegerItemZero)
			} else {
				runes := []rune(versionLower)
				list.Add(parseItem(isDigit, string(runes[startIndex:i])))
			}
			startIndex = i + 1

			newList := NewListItem()
			list.Add(newList)
			stack.Push(newList)
			list = newList
		} else if _, err := strconv.Atoi(c); err == nil {
			if !isDigit && i > startIndex {
				runes := []rune(versionLower)
				list.Add(NewStringItem(string(runes[startIndex:i]), true))
				startIndex = i

				newList := NewListItem()
				list.Add(newList)
				stack.Push(newList)
				list = newList
			}

			isDigit = true
		} else {
			if isDigit && i > startIndex {
				runes := []rune(versionLower)

				list.Add(parseItem(true, string(runes[startIndex:i])))
				startIndex = i

				newList := NewListItem()
				list.Add(newList)
				stack.Push(newList)
				list = newList
			}

			isDigit = false
		}
	}

	if len(versionLower) > startIndex {
		runes := []rune(versionLower)
		list.Add(parseItem(isDigit, string(runes[startIndex:])))
	}

	for stack.Len() > 0 {
		list = stack.Pop().(*ListItem)
		list.normalize()
	}

	return items
}

func parseItem(isDigit bool, str string) Item {
	if isDigit {
		return NewIntegerItem(str)
	}
	return NewStringItem(str, false)
}

func (o *ComparableVersion) CompareTo(cv ComparableVersion) int {
	return o.items.CompareTo(cv.items)
}

func (o *ComparableVersion) String() string {
	return o.value
}
