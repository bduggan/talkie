# talkie

### Quick start


```
npm run install
npm run build
zef install --/test cro
zef install --depsonly .
cro run
```

### Development

Auto rebuild js:
```
webpack --watch
```

Start manually (may be necessary to get real time log messages):
```
TALKIE_PORT=20000 TALKIE_HOST=0.0.0.0 perl6  -Ilib service.p6
```

`CRO_TRACE=1` -- trace http

