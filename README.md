# Alien::Libarchive

Build and make available libarchive

# SYNOPSIS

Build.PL

    use Alien::Libarchive;
    use Module::Build;
    
    my $alien = Alien::Libarchive->new;
    my $build = Module::Build->new(
      ...
      extra_compiler_flags => $alien->cflags,
      extra_linker_flags   => $alien->libs,
      ...
    );
    
    $build->create_build_script;

Makefile.PL

    use Alien::Libarchive;
    use ExtUtils::MakeMaker;
    
    my $alien = Alien::Libarchive;
    WriteMakefile(
      ...
      CFLAGS => $alien->cflags,
      LIBS   => $alien->libs,
    );

FFI::Raw

    FIXME

FFI::Sweet

    use Alien::Libarchive;
    use FFI::Sweet;
    
    ffi_lib( Alien::Libarchive->new->libs );

# DESCRIPTION

This distribution installs libarchive so that it can be used by other Perl
distributions.  If already installed for your operating system, and it can
be found, this distribution will use the libarchive that comes with your
operating system, otherwise it will download it from the internet, build
and install it.

If you set the environment variable ALIEN\_LIBARCHIVE to 'share', this
distribution will ignore any system libarchive found, and build from
source instead.  This may be desirable if your operating system comes
with a very old version of libarchive and an upgrade path for the 
system libarchive is not possible.

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

- Strawberry Perl

        FIXME

- Windows Perl with Visual C++

        FIXME

# METHODS

## cflags

Returns the C compiler flags necessary to build against libarchive.

## libs

Returns the library flags necessary to build against libarchive.

# CAVEATS

Debian Linux and FreeBSD (9.0) have been tested the most
in development of this distribution.

Patches to improve portability and platform support would be eagerly
appreciated.

If you reinstall this distribution, you may need to reinstall any
distributions that depend on it as well.

# SEE ALSO

- [Alien::Libarchive](https://metacpan.org/pod/Alien::Libarchive)
- [Archive::Libarchive::XS](https://metacpan.org/pod/Archive::Libarchive::XS)
- [Archive::Libarchive::FFI](https://metacpan.org/pod/Archive::Libarchive::FFI)
- [Archive::Libarchive::Any](https://metacpan.org/pod/Archive::Libarchive::Any)
- [Archive::Ar::Libarchive](https://metacpan.org/pod/Archive::Ar::Libarchive)
- [Archive::Peek::Libarchive](https://metacpan.org/pod/Archive::Peek::Libarchive)
- [Archive::Extract::Libarchive](https://metacpan.org/pod/Archive::Extract::Libarchive)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
