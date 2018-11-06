package versioning

import (
	"fmt"
	"math/big"
	"strconv"
)

const integerItemType int = 0

type IntegerItem struct {
	value    *big.Int
	itemType int
}

var IntegerItemZero = NewIntegerItemZero()

func (o IntegerItem) CompareTo(i Item) int {

	if i == nil {
		if big.NewInt(0).Cmp(o.value) == 0 {
			return 0
		}
		return 1
	}

	switch i.GetType() {
	case integerItemType:
		ii := i.(*IntegerItem)
		return o.value.Cmp(ii.value)
	case stringItemType, listItemType:
		return 1
	default:
		panic(fmt.Errorf("invalid item: %T", i))
	}
}

func (o IntegerItem) GetType() int {
	return o.itemType
}

func (o IntegerItem) IsNull() bool {
	return big.NewInt(0).Cmp(o.value) == 0
}

func (o *IntegerItem) String() string {
	return o.value.String()
}

// NewIntegerItemZero build empty object
func NewIntegerItemZero() Item {
	return &IntegerItem{
		value:    big.NewInt(0),
		itemType: integerItemType,
	}
}

// NewIntegerItem constructor
func NewIntegerItem(str string) Item {
	i, err := strconv.ParseInt(str, 10, 64)
	if err != nil {
		panic(err)
	}
	return &IntegerItem{
		value:    big.NewInt(i),
		itemType: integerItemType,
	}
}
