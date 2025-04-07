package main

import (
	"compress/gzip"
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
)

type Converter struct {
	i          *csv.Reader
	o          *csv.Writer
	lastRecord []string
}

func (c *Converter) OpenReader(filename string) error {
	f, err := os.Open(filename)
	if err != nil {
		return err
	}
	// defer f.Close()
	gr, err := gzip.NewReader(f)
	if err != nil {
		return err
	}
	defer gr.Close()
	r := csv.NewReader(gr)
	r.FieldsPerRecord = -1
	c.i = r
	return nil
}
func (c *Converter) OpenWriter() error {
	c.o = csv.NewWriter(os.Stdout)
	return nil
}

func (c *Converter) ReadRows() error {
	// copy first two rows
	rec, _ := c.i.Read()
	c.o.Write(rec)
	rec, _ = c.i.Read()
	c.o.Write(rec)

	// Each data entry
	for {
		rec, err := c.i.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			return err
		}
		rec2, err := c.Convert(rec)
		if err != nil {
			return err
		}

		if !c.SameValues(rec2) {
			err = c.o.Write(rec2)
			if err != nil {
				return err
			}
		}
	}
	c.o.Flush()
	return nil
}

func quantize(s string) (string, error) {
	if s == "" {
		return "", nil
	}
	v, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return "", fmt.Errorf("convert: %v %v", s, err)
	}
	if v > 3 {
		return "5", nil
	}
	return "0", nil
	// return fmt.Sprintf("%1.0f", v), nil
}

func (c *Converter) SameValues(rec []string) bool {
	n := rec[1:]
	o := c.lastRecord
	c.lastRecord = n

	if len(o) != len(n) {
		return false
	}
	for i, v := range n {
		if o[i] != v {
			return false
		}
	}
	return true
}

func (c *Converter) Convert(rec []string) ([]string, error) {
	rec2 := make([]string, len(rec))
	var err error
	for i, v := range rec {
		if i > 0 {
			v, err = quantize(v)
			if err != nil {
				return nil, err
			}
		}
		rec2[i] = v
	}
	return rec2, nil
}

func main() {
	c := Converter{}
	err := c.OpenReader("status_big.csv.gz")
	if err != nil {
		log.Fatal(err)
	}
	err = c.OpenWriter()
	if err != nil {
		log.Fatal(err)
	}
	err = c.ReadRows()
	if err != nil {
		log.Fatal(err)
	}
}
