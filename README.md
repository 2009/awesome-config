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

## Get the X11 window poperties such as class

```
xprop
```


## Opens a X11 session for testing (good for testing if config is broken)

```
startx -- /usr/bin/Xephyr :1 -screen 1600x900
```


## Keymapppings

```
TODO
```
