# ecos.torch • [ ![Build Status] [travis-image] ] [travis] [ ![License] [license-image] ] [license]

*Unofficial ECOS wrapper to solve linear programs (LPs) and
second-order cone programs (SOCPs) in Torch.*

[travis-image]: https://travis-ci.org/bamos/ecos.torch.png?branch=master
[travis]: http://travis-ci.org/cmusatyalab/openface

[license-image]: http://img.shields.io/badge/license-Apache--2-blue.svg?style=flat
[license]: LICENSE

---

**Warning:** This package is unstable, unfinished, and under development.
Please see our [issue tracker](https://github.com/bamos/ecos.torch/issues)
for unresolved issues.
Contact [Brandon Amos](http://bamos.github.io) with any questions
or issues.

---

# Introduction to ECOS

**Visit http://www.embotech.com/ECOS for detailed information on ECOS.**

ECOS is a numerical software for solving convex second-order cone programs (SOCPs) of type

```
min  c'*x
s.t. A*x = b
G*x <=_K h
```

where the last inequality is generalized, i.e. `h - G*x` belongs to the cone `K`.
ECOS supports the positive orthant `R_+`, second-order cones `Q_n` defined as
```
Q_n = { (t,x) | t >= || x ||_2 }
```
with t a scalar and `x` in `R_{n-1}`,
and the exponential cone `K_e` defined as

```
K_e = closure{(x,y,z) | exp(x/z) <= y/z, z>0}
```

where `(x,y,z)` is in `R_3`.
The cone `K` is therefore a direct product of the positive orthant,
second-order, and exponential cones:

```
K = R_+ x Q_n1 x ... x Q_nN x K_e x ... x K_e
```

# This Library

This repository is an unofficial [Torch](http://torch.ch/) wrapper to
the [ECOS C API](https://www.embotech.com/ECOS/How-to-use/C-API).

# Setup

After [setting up Torch](http://torch.ch/docs/getting-started.html),
this library can be installed with:

```bash
git clone https://github.com/bamos/ecos.torch.git --recursive
cd ecos.torch
luarocks make
```

# Usage

## Linear Program

```lua
local G = torch.Tensor{{-1, 1}, {-1, -1}, {0, -1}, {1, -2}}
local h = torch.Tensor{1.0, -2.0, 0.0, 4.0}
local c = torch.Tensor{2.0, 1.0}

local status, x = ecos.solveLP{c=c, G=G, h=h}
print(x) -- Optimal x is [0.5, 1.5]
```

# Tests

After installing the library with `luarocks`, our tests at
[test.lua](https://github.com/bamos/ecos.torch/blob/master/test.lua)
can be run with `th test.lua`.

# License

+ ECOS is under the GPL and remains unmodified.
+ This ECOS wrapper library is
  [Apache-licensed](https://github.com/bamos/ecos.torch/blob/master/LICENSE).
