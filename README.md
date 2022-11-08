# `xinput_exporter`

Expose xevents from `xinput` in the Prometheus text exposition format.

```
# HELP xinput_events_total xinput events partitioned by type.
# TYPE xinput_events_total counter
xinput_events_total{type="KeyPress"} 100
xinput_events_total{type="KeyRelease"} 100
xinput_events_total{type="Motion"} 100
xinput_events_total{type="RawButtonPress"} 100
xinput_events_total{type="RawButtonRelease"} 100
xinput_events_total{type="RawKeyPress"} 100
xinput_events_total{type="RawKeyRelease"} 100
xinput_events_total{type="RawMotion"} 100
```
