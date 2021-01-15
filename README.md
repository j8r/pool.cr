# Pool.cr

[![CI](https://github.com/j8r/pool.cr/workflows/CI/badge.svg)](https://github.com/j8r/pool.cr/actions?query=workflow%3ACI)
[![Documentation](https://github.com/j8r/pool.cr/workflows/Documentation/badge.svg)](https://j8r.github.io/pool.cr)
[![ISC](https://img.shields.io/badge/License-ISC-blue.svg?style=flat-square)](https://en.wikipedia.org/wiki/ISC_license)

A simple thread-safe generic pool.

A pool can be used to store objects that are expensive to create (like connections).
[See here](https://en.wikipedia.org/wiki/Pool_(computer_science)) for more explanations.

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  pool:
    github: j8r/pool.cr
```

## Documentation

https://j8r.github.io/pool.cr

## Usage

```cr
require "pool"

pool = Pool.new { IO::Memory.new }
pool.get do |resource|
  # do something
end
```

## License

Copyright (c) 2021 Julien Reichardt - ISC License
