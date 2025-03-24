package main

import (
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
)

func readFile(filename string) error {
	f, err := os.Open(filename)
	if err != nil {
		return err
	}
	defer f.Close()
	r := csv.NewReader(f)
	r.FieldsPerRecord = -1
	_, _ = r.Read() // Skip labels
	rec, err := r.Read()
	if err != nil {
		return err
	}
	columns := len(rec)
	if columns < 4 {
		return fmt.Errorf("too few columns")
	}
	increment, err := strconv.ParseFloat(rec[columns-1], 64)
	if err != nil {
		return err
	}

	for {
		rec, err := r.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			return err
		}
		err = parseRec(rec, columns, increment)
		if err != nil {
			return err
		}
	}
	return nil
}

func parseRec(r []string, columns int, increment float64) error {
	if len(r) < 4 {
		return fmt.Errorf("too few cells in row %v", r)
	}
	seq, err := strconv.ParseInt(r[0], 10, 64)
	if err != nil {
		return err
	}
	t := increment * float64(seq)
	ch1, err := strconv.ParseFloat(r[1], 64)
	if err != nil {
		return err
	}
	ch2, err := strconv.ParseFloat(r[2], 64)
	if err != nil {
		return err
	}
	ch3, err := strconv.ParseFloat(r[3], 64)
	if err != nil {
		return err
	}
	decode(t, ch1, ch2, ch3)
	return nil
}

func ttl(v float64) bool {
	return v > 3.0 // Good?
}

var a, c, d bool // atn, clk, data
var oa, oc, od bool
var ot float64

func decode(t float64, ch1, ch2, ch3 float64) {
	a, c, d = ttl(ch1), ttl(ch2), ttl(ch3)
	if oa != a {
		fmt.Println(timestamp(t), "ATN", a)
	}
	if c && !oc { // rising CLK
		if d {
			fmt.Println(timestamp(t), "DATA", 1)
		} else {
			fmt.Println(timestamp(t), "DATA", 0)
		}
	}
	oa, oc, od = a, c, d
}

func timestamp(t float64) string {
	d := t - ot
	ot = t
	return fmt.Sprintf("%6.2fms +%.2fms", t*1000, d*1000)
}

func main() {
	err := readFile("status.csv")
	if err != nil {
		log.Fatal(err)
	}
}
