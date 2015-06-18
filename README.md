# Alien::Libarchive

Build and make available libarchive

# SYNOPSIS

Build.PL

    use Alien::Libarchive;
    use Module::Build;
    
    my $alien = Alien::Libarchive->new;
    my $build = Module::Build->new(
      ...
      extra_compiler_flags => [$alien->cflags],
      extra_linker_flags   => [$alien->libs],
      ...
    );
    
    $build->create_build_script;

Makefile.PL

    use Alien::Libarchive;
    use ExtUtils::MakeMaker;
    
    my $alien = Alien::Libarchive;
    WriteMakefile(
      ...
      CCFLAGS => scalar $alien->cflags,
      LIBS    => [$alien->libs],
    );

FFI::Platypus

    use Alien::Libarchive;
    use FFI::Platypus;
    
    my $ffi = FFI::Platypus->new(lib => [Alien::Libarchive->new->dlls]);
    $ffi->attach( archive_read_new => [] => 'opaque' );

# DESCRIPTION

This distribution installs libarchive so that it can be used by other Perl
distributions.  If already installed for your operating system, and it can
be found, this distribution will use the libarchive that comes with your
operating system, otherwise it will download it from the Internet, build
and install it.

If you set the environment variable `ALIEN_LIBARCHIVE` to 'share', this
distribution will ignore any system libarchive found, and build from
source instead.  This may be desirable if your operating system comes
with a very old version of libarchive and an upgrade path for the 
system libarchive is not possible.

For partial compatibility with [Alien::Base](https://metacpan.org/pod/Alien::Base), this distribution will also
honor the `ALIEN_FORCE` environment variable.  Setting `ALIEN_BASE` to a
true value is the same as setting `ALIEN_LIBARCHIVE` to 'share'.

## Requirements

### operating system install

The development headers and libraries for libarchive

- Debian

    On Debian you can install these with this command:

        % sudo apt-get install libarchive-dev

- Cygwin

    On Cygwin, make sure that this package is installed

        libarchive-devel

- FreeBSD

    libarchive comes with FreeBSD as of version 5.3.

### from source install

A C compiler and any prerequisites for building libarchive.

- Debian

    On Debian build-essential should be good enough:

        % sudo apt-get install build-essential

- Cygwin

    On Cygwin, I couldn't get libarchive to build without making a
    minor tweak to one of the include files.  On Cygwin this module
    will patch libarchive before it attempts to build if it is
    version 3.1.2.

# METHODS

## cflags

Returns the C compiler flags necessary to build against libarchive.

Returns flags as a list in list context and combined into a string in
scalar context.

## libs

Returns the library flags necessary to build against libarchive.

Returns flags as a list in list context and combined into a string in
scalar context.

## dlls

Returns a list of dynamic libraries (usually a list of just one library)
that make up libarchive.  This can be used for [FFI::Raw](https://metacpan.org/pod/FFI::Raw).

Returns just the first dynamic library found in scalar context.

## version

Returns the libarchive version.

## install\_type

Returns the install type, one of either `system` or `share`.

## pkg\_config\_dir

Returns a path that contains the libarchive.pc file which can be used
by pkg-config for linking against libarchive.

## pkg\_config\_name

Returns the name by which pkg-config knows libarchive (should always
be libarchive).

# CAVEATS

Debian Linux and FreeBSD (9.0) have been tested the most
in development of this distribution.

Patches to improve portability and platform support would be eagerly
appreciated.

If you reinstall this distribution, you may need to reinstall any
distributions that depend on it as well.

# SEE ALSO

- [Alien::Libarchive::Installer](https://metacpan.org/pod/Alien::Libarchive::Installer)
- [Archive::Libarchive::XS](https://metacpan.org/pod/Archive::Libarchive::XS)
- [Archive::Libarchive::FFI](https://metacpan.org/pod/Archive::Libarchive::FFI)
- [Archive::Libarchive::Any](https://metacpan.org/pod/Archive::Libarchive::Any)
- [Archive::Ar::Libarchive](https://metacpan.org/pod/Archive::Ar::Libarchive)
- [Archive::Peek::Libarchive](https://metacpan.org/pod/Archive::Peek::Libarchive)
- [Archive::Extract::Libarchive](https://metacpan.org/pod/Archive::Extract::Libarchive)
- [YAPC::NA 2014 Foreign Function Interface (FFI) : Never Need to Write XS Again](https://docs.google.com/presentation/d/1NY3ROAiSAC5yk1LoeBCM5JfAmSeTdopgYFnJO6mUtXI/edit?usp=sharing)

    Slides on a talk about FFI and Alien

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
