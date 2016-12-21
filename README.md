## Dependencies

- tamsyn-font
- pulseaudio
- pavucontrol
- termite

## Additional Applications

- spotify (mpris widget)

## How to get X11 keysyms

```
xev | awk -F'[ )]+' '/^KeyPress/ { a[NR+2] } NR in a { printf "%-3s %s\n", $5, $8 }'
```

## Keymapppings

```
TODO
```
