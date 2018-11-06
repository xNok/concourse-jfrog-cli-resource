package versioning

import (
	"testing"
)

var versionsQualifier = []string{"1-alpha2snapshot", "1-alpha2", "1-alpha-123", "1-beta-2", "1-beta123", "1-m2", "1-m11", "1-rc", "1-cr2", "1-rc123", "1-SNAPSHOT", "1", "1-sp", "1-sp2", "1-sp123", "1-abc", "1-def", "1-pom-1", "1-1-snapshot", "1-1", "1-2", "1-123"}
var versionsNumber = []string{"2.0", "2-1", "2.0.a", "2.0.0.a", "2.0.2", "2.0.123", "2.1.0", "2.1-a", "2.1b", "2.1-c", "2.1-1", "2.1.0.1", "2.2", "2.123", "11.a2", "11.a11", "11.b2", "11.b11", "11.m2", "11.m11", "11", "11.a", "11b", "11c", "11m"}

func newComparable(version string, t *testing.T) ComparableVersion {
	ret := NewComparableVersion(version)
	canonical := ret.canonical
	parsedCanonical := NewComparableVersion(canonical).canonical

	if canonical != parsedCanonical {
		t.Errorf("canonical( %s ) = %s -> canonical: %s", version, canonical, parsedCanonical)
	}

	return ret
}

func checkVersionsEqual(v1 string, v2 string, t *testing.T) {
	c1 := newComparable(v1, t)
	c2 := newComparable(v2, t)
	if c1.CompareTo(c2) != 0 {
		t.Errorf("expected %v == %v", v1, v2)
	}
	if c2.CompareTo(c1) != 0 {
		t.Errorf("expected %v == %v", v2, v1)
	}
}

func checkVersionArrayOrder(versions []string, t *testing.T) {
	var c []ComparableVersion
	for i := 0; i < len(versions); i++ {
		c = append(c, newComparable(versions[i], t))
	}

	for i := 1; i < len(versions); i++ {
		low := c[i-1]
		for j := i; j < len(versions); j++ {
			high := c[j]
			if !(low.CompareTo(high) < 0) {
				t.Errorf("expected %s < %s", low.value, high.value)
			}
			if !(high.CompareTo(low) > 0) {
				t.Errorf("expected %s > %s", high.value, low.value)
			}
		}
	}
}

func checkVersionsOrder(v1 string, v2 string, t *testing.T) {
	c1 := newComparable(v1, t)
	c2 := newComparable(v2, t)
	if !(c1.CompareTo(c2) < 0) {
		t.Errorf("expected %v < %v", v1, v2)
	}
	if !(c2.CompareTo(c1) > 0) {
		t.Errorf("expected %v > %v", v2, v1)
	}
}

// TestVersionsQualifier versions containing qualifiers
func TestVersionsQualifier(t *testing.T) {
	checkVersionArrayOrder(versionsQualifier, t)
}

func TestVersionsNumber(t *testing.T) {
	checkVersionArrayOrder(versionsNumber, t)
}

func TestVersionsEqual(t *testing.T) {
	newComparable("1.0-alpha", t)
	checkVersionsEqual("1", "1", t)
	checkVersionsEqual("1", "1.0", t)
	checkVersionsEqual("1", "1.0.0", t)
	checkVersionsEqual("1.0", "1.0.0", t)
	checkVersionsEqual("1", "1-0", t)
	checkVersionsEqual("1", "1.0-0", t)
	checkVersionsEqual("1.0", "1.0-0", t)
	// no separator between number and character
	checkVersionsEqual("1a", "1-a", t)
	checkVersionsEqual("1a", "1.0-a", t)
	checkVersionsEqual("1a", "1.0.0-a", t)
	checkVersionsEqual("1.0a", "1-a", t)
	checkVersionsEqual("1.0.0a", "1-a", t)
	checkVersionsEqual("1x", "1-x", t)
	checkVersionsEqual("1x", "1.0-x", t)
	checkVersionsEqual("1x", "1.0.0-x", t)
	checkVersionsEqual("1.0x", "1-x", t)
	checkVersionsEqual("1.0.0x", "1-x", t)

	// aliases
	checkVersionsEqual("1ga", "1", t)
	checkVersionsEqual("1final", "1", t)
	checkVersionsEqual("1cr", "1rc", t)

	// special "aliases" a, b and m for alpha, beta and milestone
	checkVersionsEqual("1a1", "1-alpha-1", t)
	checkVersionsEqual("1b2", "1-beta-2", t)
	checkVersionsEqual("1m3", "1-milestone-3", t)

	// case insensitive
	checkVersionsEqual("1X", "1x", t)
	checkVersionsEqual("1A", "1a", t)
	checkVersionsEqual("1B", "1b", t)
	checkVersionsEqual("1M", "1m", t)
	checkVersionsEqual("1Ga", "1", t)
	checkVersionsEqual("1GA", "1", t)
	checkVersionsEqual("1Final", "1", t)
	checkVersionsEqual("1FinaL", "1", t)
	checkVersionsEqual("1FINAL", "1", t)
	checkVersionsEqual("1Cr", "1Rc", t)
	checkVersionsEqual("1cR", "1rC", t)
	checkVersionsEqual("1m3", "1Milestone3", t)
	checkVersionsEqual("1m3", "1MileStone3", t)
	checkVersionsEqual("1m3", "1MILESTONE3", t)
}

func TestVersionComparing(t *testing.T) {
	checkVersionsOrder("1", "2", t)
	checkVersionsOrder("1.5", "2", t)
	checkVersionsOrder("1", "2.5", t)
	checkVersionsOrder("1.0", "1.1", t)
	checkVersionsOrder("1.1", "1.2", t)
	checkVersionsOrder("1.0.0", "1.1", t)
	checkVersionsOrder("1.0.1", "1.1", t)
	checkVersionsOrder("1.1", "1.2.0", t)

	checkVersionsOrder("1.0-alpha-1", "1.0", t)
	checkVersionsOrder("1.0-alpha-1", "1.0-alpha-2", t)
	checkVersionsOrder("1.0-alpha-1", "1.0-beta-1", t)

	checkVersionsOrder("1.0-beta-1", "1.0-SNAPSHOT", t)
	checkVersionsOrder("1.0-SNAPSHOT", "1.0", t)
	checkVersionsOrder("1.0-alpha-1-SNAPSHOT", "1.0-alpha-1", t)

	checkVersionsOrder("1.0", "1.0-1", t)
	checkVersionsOrder("1.0-1", "1.0-2", t)
	checkVersionsOrder("1.0.0", "1.0-1", t)

	checkVersionsOrder("2.0-1", "2.0.1", t)
	checkVersionsOrder("2.0.1-klm", "2.0.1-lmn", t)
	checkVersionsOrder("2.0.1", "2.0.1-xyz", t)

	checkVersionsOrder("2.0.1", "2.0.1-123", t)
	checkVersionsOrder("2.0.1-xyz", "2.0.1-123", t)
}

func TestMng5568(t *testing.T) {
	a := "6.1.0"
	b := "6.1.0rc3"
	c := "6.1H.5-beta" // this is the unusual version string, with 'H' in the middle

	checkVersionsOrder(b, a, t) // classical
	checkVersionsOrder(b, c, t) // now b < c, but before MNG-5568, we had b > c
	checkVersionsOrder(a, c, t)
}
