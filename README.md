# scad-utils

Utility libraries for OpenSCAD

## Examples

With a basic sample polygon shape,

    module shape() {
        polygon([[0,0],[1,0],[1.5,1],[2.5,1],[2,-1],[0,-1]]);
    }

and `$fn=32;`.

- `inset(d=0.3) shape();`

![](http://oskarlinde.github.io/scad-utils/img/morph-0.png)

- `outset(d=0.3) shape();`

![](http://oskarlinde.github.io/scad-utils/img/morph-1.png)

- `rounding(r=0.3) shape();`

![](http://oskarlinde.github.io/scad-utils/img/morph-2.png)

- `fillet(r=0.3) shape();`

![](http://oskarlinde.github.io/scad-utils/img/morph-3.png)

- `shell(d=0.3) shape();`

![](http://oskarlinde.github.io/scad-utils/img/morph-4.png)

- `shell(d=-0.3) shape();`

![](http://oskarlinde.github.io/scad-utils/img/morph-5.png)

- `shell(d=0.3,center=true) shape();`

![](http://oskarlinde.github.io/scad-utils/img/morph-6.png)
