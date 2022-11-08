/*
   Copyright (C) 2022 Jack Baldry

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

package main

import (
	"bufio"
	"flag"
	"log"
	"net/http"
	"os"
	"os/exec"
	"regexp"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	addr         = flag.String("listen-address", ":9191", "The address to listen on for HTTP requests.")
	xinputEvents = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "xinput_events_total",
			Help: "xinput events partitioned by type.",
		},
		[]string{"type"},
	)
)

func main() {
	logger := log.New(os.Stdout, "", log.Lmsgprefix)
	prometheus.MustRegister(xinputEvents)
	re := regexp.MustCompile(`^EVENT type ([0-9]+) \(([A-Za-z]+)\)$`)
	cmd := exec.Command("xinput", "test-xi2", "--root")
	out, err := cmd.StdoutPipe()
	if err != nil {
		logger.Fatalf("Could not create pipe for command 'xinput test-xi2 --root': %v\n", err)
	}

	http.Handle("/metrics", promhttp.Handler())
	go func() {
		logger.Fatal(http.ListenAndServe(*addr, nil))
	}()

	if err := cmd.Start(); err != nil {
		logger.Fatalf("Could not start command 'xinput test-xi2 --root': %v\n", err)
	}

	scanner := bufio.NewScanner(out)
	for scanner.Scan() {
		if sm := re.FindSubmatch(scanner.Bytes()); sm != nil {
			xinputEvents.WithLabelValues(string(sm[2])).Inc()
		}
	}

	if err := cmd.Wait(); err != nil {
		logger.Fatalf("Could not wait for command 'xinput test-xi2 --root': %v\n", err)
	}
}
