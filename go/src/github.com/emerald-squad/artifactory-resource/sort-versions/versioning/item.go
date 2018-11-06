package versioning

// Item the interface representing a parsed item
type Item interface {
	CompareTo(item Item) int
	GetType() int
	IsNull() bool
}
