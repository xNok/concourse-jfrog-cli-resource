package versioning

import (
	"fmt"
	"strconv"
	"strings"
)

const stringItemType int = 1

type StringItem struct {
	value    string
	itemType int
}

func (o StringItem) CompareTo(i Item) int {
	if i == nil {
		return strings.Compare(comparableQualifier(o.value), releaseVersionIndex)
	}

	switch i.GetType() {
	case integerItemType:
		return -1
	case stringItemType:
		ii := i.(*StringItem)
		return strings.Compare(comparableQualifier(o.value), comparableQualifier(ii.value))
	case listItemType:
		return -1
	default:
		panic(fmt.Errorf("invalid item: %T", i))
	}
}

func (o StringItem) GetType() int {
	return o.itemType
}

func (o StringItem) IsNull() bool {
	return strings.Compare(comparableQualifier(o.value), releaseVersionIndex) == 0
}

func (o *StringItem) String() string {
	return o.value
}

var qualifiers = [...]string{"alpha", "beta", "milestone", "rc", "snapshot", "", "sp"}
var releaseVersionIndex = strconv.Itoa(findQualifierIndex(""))
var aliases = map[string]string{"ga": "", "final": "", "cr": "rc"}

// NewStringItem constructor
func NewStringItem(str string, followedByDigit bool) Item {
	value := str
	if followedByDigit && len(str) == 1 {
		switch string(value[0]) {
		case "a":
			value = "alpha"
			break
		case "b":
			value = "beta"
			break
		case "m":
			value = "milestone"
			break
		default:
		}
	}
	return &StringItem{
		value:    getProperty(value, value),
		itemType: stringItemType,
	}
}

func findQualifierIndex(qualifier string) int {
	for i := 0; i < len(qualifiers); i++ {
		if qualifiers[i] == qualifier {
			return i
		}
	}
	return -1
}

// Returns a comparable value for a qualifier.
//
// This method takes into account the ordering of known qualifiers then unknown qualifiers with lexical
// ordering.
//
// just returning an Integer with the index here is faster, but requires a lot of if/then/else to check for -1
// or QUALIFIERS.size and then resort to lexical ordering. Most comparisons are decided by the first character,
// so this is still fast. If more characters are needed then it requires a lexical sort anyway.
//
// Returns an equivalent value that can be used with lexical comparison
func comparableQualifier(qualifier string) string {
	i := findQualifierIndex(qualifier)
	if i == -1 {
		return strconv.Itoa(len(qualifiers)) + "-" + qualifier
	}
	return strconv.Itoa(i)
}

func getProperty(key string, defaultValue string) string {
	if value, ok := aliases[key]; ok {
		return value
	}
	return defaultValue
}
