
# xinerama


## Description

Basic bindings for [Xinerama](https://www.x.org/releases/X11R7.7/doc/man/man3/Xinerama.3.xhtml)

For bug reports, feature requests, and development versions, visit the
[github project page](https://github.com/retroj/xinerama-egg/).

## Authors

* John J Foerch


## Requirements
### Chicken Eggs

### C Headers

* Xinerama.h


## API
### Version

* **(xinerama-query-extension display) => (event-base error-base) or #f**

* **(xinerama-query-version) => (major minor) or #f**

* **(xinerama-active? display) => bool**

* **(xinerama-query-screens display) => (xinerama-screen-info ...)**

* **(xinerama-screen-info? x) => bool**


## Examples

```scheme
(use xinerama xlib)
(define xdisplay (xopendisplay #f))
(when (xinerama-active? xdisplay)
  (for-each
   (lambda (screen)
    (printf "~A ~A ~A ~A ~A~%"
            (xinerama-screen-info-screen-number di)
            (xinerama-screen-info-x-org di)
            (xinerama-screen-info-y-org di)
            (xinerama-screen-info-width di)
            (xinerama-screen-info-height di)))
   (xinerama-query-screens xdisplay)))
```


## License

BSD


## Version History

* 1.0.0 (2017-06-04) initial release
* 1.0.1 (2017-06-04) fix typo
